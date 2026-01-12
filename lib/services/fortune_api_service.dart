import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:primordial_spirit/config/app_config.dart';
import 'package:primordial_spirit/models/fortune_models.dart';

/// SSE 连接状态
enum SSEConnectionState {
  connecting,
  connected,
  disconnected,
  error,
}

/// SSE 连接管理器 - 处理单个 SSE 连接的生命周期
class SSEConnection {
  final String id;
  final http.Client _client;
  StreamSubscription<List<int>>? _subscription;
  final StreamController<String> _controller = StreamController<String>.broadcast();
  final StringBuffer _buffer = StringBuffer();
  Timer? _timeoutTimer;
  bool _isClosed = false;
  SSEConnectionState _state = SSEConnectionState.disconnected;

  SSEConnection(this.id) : _client = http.Client();

  Stream<String> get stream => _controller.stream;
  SSEConnectionState get state => _state;
  bool get isClosed => _isClosed;

  /// 连接到 SSE 端点
  Future<void> connect(
    http.Request request, {
    Duration timeout = const Duration(minutes: 10),
    Duration connectionTimeout = const Duration(seconds: 30),
  }) async {
    if (_isClosed) return;

    _state = SSEConnectionState.connecting;

    try {
      // 设置连接超时
      final streamedResponse = await _client.send(request).timeout(connectionTimeout);

      if (_isClosed) {
        streamedResponse.stream.drain();
        return;
      }

      if (streamedResponse.statusCode == 200) {
        _state = SSEConnectionState.connected;

        // 设置整体超时
        _timeoutTimer = Timer(timeout, () {
          debugPrint('[SSE $id] 连接超时');
          _controller.addError(TimeoutException('SSE 连接超时', timeout));
          close();
        });

        // 监听数据流
        _subscription = streamedResponse.stream.listen(
          (bytes) {
            if (_isClosed) return;
            _resetTimeout(timeout);
            _processChunk(utf8.decode(bytes));
          },
          onDone: () {
            if (!_isClosed) {
              _controller.close();
              _state = SSEConnectionState.disconnected;
            }
          },
          onError: (error) {
            if (!_isClosed) {
              _controller.addError(error);
              _state = SSEConnectionState.error;
            }
          },
          cancelOnError: false,
        );
      } else {
        _state = SSEConnectionState.error;
        _controller.addError(
          Exception('SSE 连接失败: ${streamedResponse.statusCode}'),
        );
        _controller.close();
      }
    } on TimeoutException {
      _state = SSEConnectionState.error;
      _controller.addError(TimeoutException('SSE 连接超时', connectionTimeout));
      _controller.close();
    } catch (e) {
      _state = SSEConnectionState.error;
      _controller.addError(e);
      _controller.close();
    }
  }

  /// 重置超时计时器
  void _resetTimeout(Duration timeout) {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(timeout, () {
      debugPrint('[SSE $id] 数据接收超时');
      _controller.addError(TimeoutException('SSE 数据接收超时', timeout));
      close();
    });
  }

  /// 处理接收到的数据块 - 支持跨 chunk 的数据
  void _processChunk(String chunk) {
    _buffer.write(chunk);
    final content = _buffer.toString();
    final lines = content.split('\n');

    // 保留最后一个可能不完整的行
    _buffer.clear();
    if (!content.endsWith('\n') && lines.isNotEmpty) {
      _buffer.write(lines.removeLast());
    }

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      if (trimmedLine.startsWith('data: ')) {
        final data = trimmedLine.substring(6).trim();
        if (data.isNotEmpty) {
          _controller.add(data);
        }
      }
      // 忽略其他 SSE 字段（event:, id:, retry:）
    }
  }

  /// 关闭连接
  void close() {
    if (_isClosed) return;
    _isClosed = true;
    _state = SSEConnectionState.disconnected;
    _timeoutTimer?.cancel();
    _subscription?.cancel();
    _client.close();
    if (!_controller.isClosed) {
      _controller.close();
    }
    debugPrint('[SSE $id] 连接已关闭');
  }
}

/// 算命API服务
class FortuneApiService {
  static final FortuneApiService _instance = FortuneApiService._internal();
  factory FortuneApiService() => _instance;
  FortuneApiService._internal();

  final http.Client _client = http.Client();

  /// 活跃的 SSE 连接
  final Map<String, SSEConnection> _activeConnections = {};

  /// 请求状态回调
  Function(String status)? onStatusChanged;

  /// 取消指定类型的 SSE 连接
  void cancelSSEConnection(String connectionId) {
    final connection = _activeConnections.remove(connectionId);
    connection?.close();
    debugPrint('[API] 取消 SSE 连接: $connectionId');
  }

  /// 取消所有 SSE 连接
  void cancelAllSSEConnections() {
    for (final connection in _activeConnections.values) {
      connection.close();
    }
    _activeConnections.clear();
    debugPrint('[API] 取消所有 SSE 连接');
  }

  /// 创建并管理 SSE 连接
  SSEConnection _createSSEConnection(String id) {
    // 如果已存在同 ID 的连接，先关闭
    cancelSSEConnection(id);

    final connection = SSEConnection(id);
    _activeConnections[id] = connection;
    return connection;
  }

  /// 步骤1：计算八字和紫薇
  /// POST /api/v1/calculate
  Future<CalculateResponse> calculate(BirthInfo birthInfo) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/v1/calculate');
    debugPrint('[API] 请求URL: $url');
    debugPrint('[API] 请求数据: ${jsonEncode({'birth_info': birthInfo.toJson()})}');
    onStatusChanged?.call('正在连接服务器...');

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'birth_info': birthInfo.toJson()}),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('[API] 响应状态码: ${response.statusCode}');
      debugPrint('[API] 响应内容: ${response.body}');

      if (response.statusCode == 200) {
        onStatusChanged?.call('计算成功，正在解析...');
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return CalculateResponse.fromJson(json);
      } else {
        onStatusChanged?.call('服务器错误: ${response.statusCode}');
        debugPrint('[API] Calculate API error: ${response.statusCode} - ${response.body}');
        return CalculateResponse(
          success: false,
          message: '计算失败: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      onStatusChanged?.call('请求超时，请检查网络');
      debugPrint('[API] Calculate API timeout');
      return CalculateResponse(
        success: false,
        message: '请求超时，请检查网络连接',
      );
    } catch (e) {
      onStatusChanged?.call('网络错误: $e');
      debugPrint('[API] Calculate API exception: $e');
      return CalculateResponse(
        success: false,
        message: '网络错误: $e',
      );
    }
  }

  /// 步骤2：算命（流式）
  /// POST /api/v1/fortune/stream
  /// 返回一个Stream，逐字返回AI回复
  ///
  /// [connectionId] 可选的连接ID，用于取消请求。默认为 'fortune_chat'
  Stream<String> fortuneStream(
    FortuneRequest request, {
    String connectionId = 'fortune_chat',
    Duration timeout = const Duration(minutes: 5),
  }) async* {
    final url = Uri.parse('${AppConfig.baseUrl}/api/v1/fortune/stream');
    final httpRequest = http.Request('POST', url);
    httpRequest.headers['Content-Type'] = 'application/json';
    httpRequest.body = jsonEncode(request.toJson());

    final connection = _createSSEConnection(connectionId);

    try {
      // 启动连接（不等待完成）
      connection.connect(
        httpRequest,
        timeout: timeout,
        connectionTimeout: const Duration(seconds: 30),
      );

      // 监听数据流
      await for (final jsonStr in connection.stream) {
        try {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          if (json.containsKey('chunk')) {
            yield json['chunk'] as String;
          } else if (json['done'] == true) {
            // 流结束
            return;
          } else if (json.containsKey('error')) {
            // 后端返回错误
            debugPrint('Fortune stream API error from server: ${json['error']}');
            yield '\n[服务器错误] ${json['error']}';
            return;
          }
        } catch (e) {
          debugPrint('Parse SSE chunk error: $e, data: $jsonStr');
        }
      }
    } on TimeoutException catch (e) {
      debugPrint('Fortune stream timeout: $e');
      yield '[错误] 请求超时，请稍后重试';
    } catch (e) {
      debugPrint('Fortune stream API exception: $e');
      yield '[错误] 网络错误: $e';
    } finally {
      _activeConnections.remove(connectionId);
    }
  }

  /// 取消聊天流式请求
  void cancelFortuneStream({String connectionId = 'fortune_chat'}) {
    cancelSSEConnection(connectionId);
  }

  /// 创建 3D 元神形象生成任务
  /// POST /api/v1/avatar3d/create
  /// 后端会自动执行两阶段流程：预览 -> 精细化
  Future<Avatar3dCreateResponse> createAvatar3dTask({
    required String dayMaster,
    required String gender,
    Map<String, int>? fiveElements,
    Map<String, double>? fiveElementsStrength,
    bool autoRefine = true,
    bool enablePbr = true,
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/v1/avatar3d/create');

    // 构建请求体（所有参数都放在 body 中）
    final requestBody = {
      'day_master': dayMaster,
      'gender': gender,
      'auto_refine': autoRefine,
      'enable_pbr': enablePbr,
      if (fiveElements != null) 'five_elements': fiveElements,
      if (fiveElementsStrength != null)
        'five_elements_strength': fiveElementsStrength,
    };

    debugPrint('[API] 创建3D任务 URL: $url');
    debugPrint('[API] 请求体: ${jsonEncode(requestBody)}');

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('[API] 3D任务响应: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          final data = json['data'] as Map<String, dynamic>;
          return Avatar3dCreateResponse(
            success: true,
            taskId: data['task_id'] as String?,
            previewTaskId: data['preview_task_id'] as String?,
            prompt: data['prompt'] as String?,
            status: data['status'] as String?,
            stage: data['stage'] as String?,
            autoRefine: data['auto_refine'] as bool? ?? true,
          );
        }
      }

      return Avatar3dCreateResponse(
        success: false,
        error: '创建3D任务失败: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('[API] 创建3D任务异常: $e');
      return Avatar3dCreateResponse(
        success: false,
        error: '网络错误: $e',
      );
    }
  }

  /// 查询 3D 任务状态
  /// GET /api/v1/avatar3d/status/{task_id}
  /// 后端会自动处理两阶段流程，预览完成后自动创建精细化任务
  Future<Avatar3dStatusResponse> getAvatar3dStatus(String taskId) async {
    final url =
        Uri.parse('${AppConfig.baseUrl}/api/v1/avatar3d/status/$taskId');

    try {
      final response = await _client
          .get(url)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          return Avatar3dStatusResponse.fromJson(
              json['data'] as Map<String, dynamic>);
        }
      }

      return Avatar3dStatusResponse(
        taskId: taskId,
        status: 'FAILED',
        progress: 0,
        error: '查询失败: ${response.statusCode}',
      );
    } catch (e) {
      return Avatar3dStatusResponse(
        taskId: taskId,
        status: 'FAILED',
        progress: 0,
        error: '网络错误: $e',
      );
    }
  }

  /// SSE 流式获取 3D 任务进度（推荐）
  /// GET /api/v1/avatar3d/stream/{task_id}
  /// 后端会自动处理两阶段流程
  Stream<Avatar3dStreamEvent> streamAvatar3dProgress(
    String taskId, {
    String? connectionId,
    Duration timeout = const Duration(minutes: 15),
  }) async* {
    final url = Uri.parse('${AppConfig.baseUrl}/api/v1/avatar3d/stream/$taskId');
    final connId = connectionId ?? 'avatar3d_$taskId';

    debugPrint('[API] SSE 连接: $url');

    final request = http.Request('GET', url);
    final connection = _createSSEConnection(connId);

    try {
      connection.connect(
        request,
        timeout: timeout,
        connectionTimeout: const Duration(seconds: 30),
      );

      await for (final jsonStr in connection.stream) {
        try {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          yield Avatar3dStreamEvent.fromJson(json);
        } catch (e) {
          debugPrint('[API] SSE 解析错误: $e');
        }
      }
    } on TimeoutException {
      yield Avatar3dStreamEvent(
        taskId: taskId,
        stage: 'error',
        status: 'FAILED',
        progress: 0,
        totalProgress: 0,
        error: 'SSE 连接超时',
        done: true,
      );
    } catch (e) {
      debugPrint('[API] SSE 异常: $e');
      yield Avatar3dStreamEvent(
        taskId: taskId,
        stage: 'error',
        status: 'FAILED',
        progress: 0,
        totalProgress: 0,
        error: '网络错误: $e',
        done: true,
      );
    } finally {
      _activeConnections.remove(connId);
    }
  }

  /// 取消 3D 任务进度流
  void cancelAvatar3dStream(String taskId) {
    cancelSSEConnection('avatar3d_$taskId');
  }

  /// 通过 SSE 等待 3D 任务完成（推荐）
  /// 支持分阶段展示：预览完成后先回调预览结果，再继续精细化
  Future<Avatar3dStatusResponse> waitForAvatar3dCompletionSSE(
    String taskId, {
    Function(String status, int totalProgress, String stage)? onProgress,
    Function(String stage)? onStageChanged,
    Function(Avatar3dStreamEvent previewResult)? onPreviewComplete,  // 预览完成回调
  }) async {
    String? lastStage;
    Avatar3dStreamEvent? lastPreviewResult;

    await for (final event in streamAvatar3dProgress(taskId)) {
      // 通知阶段变化
      if (event.stage != lastStage) {
        lastStage = event.stage;
        onStageChanged?.call(event.stage);
      }

      // 通知进度
      onProgress?.call(event.status, event.totalProgress, event.stage);

      debugPrint('[API SSE] 状态: ${event.status}, 进度: ${event.totalProgress}%, 阶段: ${event.stage}');

      // 预览完成，回调预览结果（让前端可以先展示）
      if (event.isPreviewSucceeded && event.modelUrls != null) {
        lastPreviewResult = event;
        onPreviewComplete?.call(event);
        debugPrint('[API SSE] 预览完成，可以先展示预览模型');
      }

      // 任务完成
      if (event.done) {
        return Avatar3dStatusResponse(
          taskId: taskId,
          previewTaskId: taskId,
          refineTaskId: event.refineTaskId,
          status: event.status,
          progress: event.progress,
          stage: event.stage,
          type: event.type,
          modelUrls: event.modelUrls,
          thumbnailUrl: event.thumbnailUrl,
          videoUrl: event.videoUrl,
          textureUrls: event.textureUrls,
          error: event.error,
        );
      }
    }

    // 流结束但没有 done 标记
    // 如果有预览结果，返回预览结果
    if (lastPreviewResult != null) {
      debugPrint('[API SSE] 流结束，返回预览结果');
      return Avatar3dStatusResponse(
        taskId: taskId,
        previewTaskId: taskId,
        status: 'SUCCEEDED',
        progress: 100,
        stage: 'preview',
        modelUrls: lastPreviewResult.modelUrls,
        thumbnailUrl: lastPreviewResult.thumbnailUrl,
        videoUrl: lastPreviewResult.videoUrl,
      );
    }

    return Avatar3dStatusResponse(
      taskId: taskId,
      status: 'FAILED',
      progress: 0,
      error: 'SSE 流意外结束',
    );
  }

  /// 轮询等待 3D 任务完成（备用方案）
  /// 后端会自动在预览完成后创建精细化任务
  Future<Avatar3dStatusResponse> waitForAvatar3dCompletion(
    String taskId, {
    Duration pollInterval = const Duration(seconds: 3),
    Duration timeout = const Duration(minutes: 10), // 增加超时时间以支持两阶段
    Function(String status, int progress)? onProgress,
    Function(String stage)? onStageChanged,
  }) async {
    final startTime = DateTime.now();
    String? lastStage;

    while (true) {
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed > timeout) {
        return Avatar3dStatusResponse(
          taskId: taskId,
          status: 'FAILED',
          progress: 0,
          error: '任务超时',
        );
      }

      final status = await getAvatar3dStatus(taskId);

      // 通知阶段变化
      if (status.stage != null && status.stage != lastStage) {
        lastStage = status.stage;
        onStageChanged?.call(status.stage!);
      }

      // 计算总进度（预览占50%，精细化占50%）
      int totalProgress = status.progress;
      if (status.stage == 'preview') {
        totalProgress = (status.progress * 0.5).round();
      } else if (status.stage == 'refine') {
        totalProgress = 50 + (status.progress * 0.5).round();
      }

      onProgress?.call(status.status, totalProgress);

      // 只有精细化阶段完成才算真正完成
      if (status.stage == 'refine' && status.isCompleted) {
        return status;
      }

      // 如果预览阶段失败，也返回
      if (status.stage == 'preview' && status.status == 'FAILED') {
        return status;
      }

      await Future.delayed(pollInterval);
    }
  }

  // ============================================================
  // Retexture API（换皮肤/换材质）
  // ============================================================

  /// 创建换皮肤任务
  /// POST /api/v1/avatar3d/retexture
  ///
  /// [inputTaskId] - 精细化任务ID（与 modelUrl 二选一）
  /// [modelUrl] - 模型URL（与 inputTaskId 二选一）
  /// [textStylePrompt] - 文字描述风格（与 imageStyleUrl 二选一）
  /// [imageStyleUrl] - 参考图片URL（与 textStylePrompt 二选一）
  /// [enablePbr] - 是否生成PBR贴图
  /// [enableOriginalUv] - 是否保留原始UV
  Future<RetextureCreateResponse> createRetextureTask({
    String? inputTaskId,
    String? modelUrl,
    String? textStylePrompt,
    String? imageStyleUrl,
    bool enablePbr = true,
    bool enableOriginalUv = true,
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.avatar3dRetextureEndpoint}');

    final requestBody = <String, dynamic>{
      'enable_pbr': enablePbr,
      'enable_original_uv': enableOriginalUv,
    };

    if (inputTaskId != null) {
      requestBody['input_task_id'] = inputTaskId;
    } else if (modelUrl != null) {
      requestBody['model_url'] = modelUrl;
    }

    if (textStylePrompt != null) {
      requestBody['text_style_prompt'] = textStylePrompt;
    } else if (imageStyleUrl != null) {
      requestBody['image_style_url'] = imageStyleUrl;
    }

    debugPrint('[API] 创建换皮肤任务 URL: $url');
    debugPrint('[API] 请求体: ${jsonEncode(requestBody)}');

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('[API] 换皮肤任务响应: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          final data = json['data'] as Map<String, dynamic>;
          return RetextureCreateResponse(
            success: true,
            taskId: data['task_id'] as String?,
            status: data['status'] as String?,
          );
        }
      }

      return RetextureCreateResponse(
        success: false,
        error: '创建换皮肤任务失败: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('[API] 创建换皮肤任务异常: $e');
      return RetextureCreateResponse(
        success: false,
        error: '网络错误: $e',
      );
    }
  }

  /// 查询换皮肤任务状态
  /// GET /api/v1/avatar3d/retexture/{task_id}
  Future<RetextureStatusResponse> getRetextureStatus(String taskId) async {
    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.avatar3dRetextureEndpoint}/$taskId');

    try {
      final response = await _client
          .get(url)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          return RetextureStatusResponse.fromJson(json['data'] as Map<String, dynamic>);
        }
      }

      return RetextureStatusResponse(
        taskId: taskId,
        status: 'FAILED',
        progress: 0,
        error: '查询失败: ${response.statusCode}',
      );
    } catch (e) {
      return RetextureStatusResponse(
        taskId: taskId,
        status: 'FAILED',
        progress: 0,
        error: '网络错误: $e',
      );
    }
  }

  /// SSE 流式获取换皮肤任务进度
  Stream<RetextureStreamEvent> streamRetextureProgress(
    String taskId, {
    String? connectionId,
    Duration timeout = const Duration(minutes: 10),
  }) async* {
    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.avatar3dRetextureEndpoint}/$taskId/stream');
    final connId = connectionId ?? 'retexture_$taskId';

    debugPrint('[API] 换皮肤 SSE 连接: $url');

    final request = http.Request('GET', url);
    final connection = _createSSEConnection(connId);

    try {
      connection.connect(
        request,
        timeout: timeout,
        connectionTimeout: const Duration(seconds: 30),
      );

      await for (final jsonStr in connection.stream) {
        try {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          yield RetextureStreamEvent.fromJson(json);
        } catch (e) {
          debugPrint('[API] 换皮肤 SSE 解析错误: $e');
        }
      }
    } on TimeoutException {
      yield RetextureStreamEvent(
        taskId: taskId,
        status: 'FAILED',
        progress: 0,
        error: 'SSE 连接超时',
        done: true,
      );
    } catch (e) {
      debugPrint('[API] 换皮肤 SSE 异常: $e');
      yield RetextureStreamEvent(
        taskId: taskId,
        status: 'FAILED',
        progress: 0,
        error: '网络错误: $e',
        done: true,
      );
    } finally {
      _activeConnections.remove(connId);
    }
  }

  /// 取消换皮肤任务进度流
  void cancelRetextureStream(String taskId) {
    cancelSSEConnection('retexture_$taskId');
  }

  // ============================================================
  // Rigging API（骨骼绑定）
  // ============================================================

  /// 创建骨骼绑定任务
  /// POST /api/v1/avatar3d/rig
  ///
  /// [inputTaskId] - 精细化或换皮肤后的任务ID（与 modelUrl 二选一）
  /// [modelUrl] - 模型URL（与 inputTaskId 二选一）
  /// [heightMeters] - 角色身高（米），默认1.7
  Future<RiggingCreateResponse> createRiggingTask({
    String? inputTaskId,
    String? modelUrl,
    double heightMeters = 1.7,
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.avatar3dRigEndpoint}');

    final requestBody = <String, dynamic>{
      'height_meters': heightMeters,
    };

    if (inputTaskId != null) {
      requestBody['input_task_id'] = inputTaskId;
    } else if (modelUrl != null) {
      requestBody['model_url'] = modelUrl;
    }

    debugPrint('[API] 创建骨骼绑定任务 URL: $url');
    debugPrint('[API] 请求体: ${jsonEncode(requestBody)}');

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('[API] 骨骼绑定任务响应: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          final data = json['data'] as Map<String, dynamic>;
          return RiggingCreateResponse(
            success: true,
            taskId: data['task_id'] as String?,
            status: data['status'] as String?,
          );
        }
      }

      return RiggingCreateResponse(
        success: false,
        error: '创建骨骼绑定任务失败: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('[API] 创建骨骼绑定任务异常: $e');
      return RiggingCreateResponse(
        success: false,
        error: '网络错误: $e',
      );
    }
  }

  /// 查询骨骼绑定任务状态
  /// GET /api/v1/avatar3d/rig/{task_id}
  Future<RiggingStatusResponse> getRiggingStatus(String taskId) async {
    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.avatar3dRigEndpoint}/$taskId');

    try {
      final response = await _client
          .get(url)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          return RiggingStatusResponse.fromJson(json['data'] as Map<String, dynamic>);
        }
      }

      return RiggingStatusResponse(
        taskId: taskId,
        status: 'FAILED',
        progress: 0,
        error: '查询失败: ${response.statusCode}',
      );
    } catch (e) {
      return RiggingStatusResponse(
        taskId: taskId,
        status: 'FAILED',
        progress: 0,
        error: '网络错误: $e',
      );
    }
  }

  /// SSE 流式获取骨骼绑定任务进度
  Stream<RiggingStreamEvent> streamRiggingProgress(
    String taskId, {
    String? connectionId,
    Duration timeout = const Duration(minutes: 10),
  }) async* {
    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.avatar3dRigEndpoint}/$taskId/stream');
    final connId = connectionId ?? 'rigging_$taskId';

    debugPrint('[API] 骨骼绑定 SSE 连接: $url');

    final request = http.Request('GET', url);
    final connection = _createSSEConnection(connId);

    try {
      connection.connect(
        request,
        timeout: timeout,
        connectionTimeout: const Duration(seconds: 30),
      );

      await for (final jsonStr in connection.stream) {
        try {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          yield RiggingStreamEvent.fromJson(json);
        } catch (e) {
          debugPrint('[API] 骨骼绑定 SSE 解析错误: $e');
        }
      }
    } on TimeoutException {
      yield RiggingStreamEvent(
        taskId: taskId,
        status: 'FAILED',
        progress: 0,
        error: 'SSE 连接超时',
        done: true,
      );
    } catch (e) {
      debugPrint('[API] 骨骼绑定 SSE 异常: $e');
      yield RiggingStreamEvent(
        taskId: taskId,
        status: 'FAILED',
        progress: 0,
        error: '网络错误: $e',
        done: true,
      );
    } finally {
      _activeConnections.remove(connId);
    }
  }

  /// 取消骨骼绑定任务进度流
  void cancelRiggingStream(String taskId) {
    cancelSSEConnection('rigging_$taskId');
  }

  // ============================================================
  // Animation API（动画绑定）
  // ============================================================

  /// 创建动画任务
  /// POST /api/v1/avatar3d/animate
  ///
  /// [rigTaskId] - 骨骼绑定任务ID
  /// [actionId] - 动画动作ID（参考动画库）
  /// [postProcess] - 后处理选项
  Future<AnimationCreateResponse> createAnimationTask({
    required String rigTaskId,
    required int actionId,
    AnimationPostProcess? postProcess,
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.avatar3dAnimateEndpoint}');

    final requestBody = <String, dynamic>{
      'rig_task_id': rigTaskId,
      'action_id': actionId,
    };

    if (postProcess != null) {
      requestBody['post_process'] = postProcess.toJson();
    }

    debugPrint('[API] 创建动画任务 URL: $url');
    debugPrint('[API] 请求体: ${jsonEncode(requestBody)}');

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('[API] 动画任务响应: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          final data = json['data'] as Map<String, dynamic>;
          return AnimationCreateResponse(
            success: true,
            taskId: data['task_id'] as String?,
            status: data['status'] as String?,
          );
        }
      }

      return AnimationCreateResponse(
        success: false,
        error: '创建动画任务失败: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('[API] 创建动画任务异常: $e');
      return AnimationCreateResponse(
        success: false,
        error: '网络错误: $e',
      );
    }
  }

  /// 查询动画任务状态
  /// GET /api/v1/avatar3d/animate/{task_id}
  Future<AnimationStatusResponse> getAnimationStatus(String taskId) async {
    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.avatar3dAnimateEndpoint}/$taskId');

    try {
      final response = await _client
          .get(url)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          return AnimationStatusResponse.fromJson(json['data'] as Map<String, dynamic>);
        }
      }

      return AnimationStatusResponse(
        taskId: taskId,
        status: 'FAILED',
        progress: 0,
        error: '查询失败: ${response.statusCode}',
      );
    } catch (e) {
      return AnimationStatusResponse(
        taskId: taskId,
        status: 'FAILED',
        progress: 0,
        error: '网络错误: $e',
      );
    }
  }

  /// SSE 流式获取动画任务进度
  Stream<AnimationStreamEvent> streamAnimationProgress(
    String taskId, {
    String? connectionId,
    Duration timeout = const Duration(minutes: 10),
  }) async* {
    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.avatar3dAnimateEndpoint}/$taskId/stream');
    final connId = connectionId ?? 'animation_$taskId';

    debugPrint('[API] 动画 SSE 连接: $url');

    final request = http.Request('GET', url);
    final connection = _createSSEConnection(connId);

    try {
      connection.connect(
        request,
        timeout: timeout,
        connectionTimeout: const Duration(seconds: 30),
      );

      await for (final jsonStr in connection.stream) {
        try {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          yield AnimationStreamEvent.fromJson(json);
        } catch (e) {
          debugPrint('[API] 动画 SSE 解析错误: $e');
        }
      }
    } on TimeoutException {
      yield AnimationStreamEvent(
        taskId: taskId,
        status: 'FAILED',
        progress: 0,
        error: 'SSE 连接超时',
        done: true,
      );
    } catch (e) {
      debugPrint('[API] 动画 SSE 异常: $e');
      yield AnimationStreamEvent(
        taskId: taskId,
        status: 'FAILED',
        progress: 0,
        error: '网络错误: $e',
        done: true,
      );
    } finally {
      _activeConnections.remove(connId);
    }
  }

  /// 取消动画任务进度流
  void cancelAnimationStream(String taskId) {
    cancelSSEConnection('animation_$taskId');
  }

  /// 获取动画库列表
  /// GET /api/v1/avatar3d/animations
  Future<List<AnimationLibraryItem>> getAnimationLibrary({
    String? category,
  }) async {
    var url = Uri.parse('${AppConfig.baseUrl}${AppConfig.avatar3dAnimationLibraryEndpoint}');
    if (category != null) {
      url = url.replace(queryParameters: {'category': category});
    }

    try {
      final response = await _client
          .get(url)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          final list = json['data'] as List;
          return list
              .map((item) => AnimationLibraryItem.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('[API] 获取动画库异常: $e');
      return [];
    }
  }

  // ============================================================
  // 完整流程（一键生成）
  // ============================================================

  /// 创建完整流程任务（预览→精细化→绑定→动画）
  /// POST /api/v1/avatar3d/create-full
  Future<FullPipelineCreateResponse> createFullPipelineTask({
    required String dayMaster,
    required String gender,
    Map<String, int>? fiveElements,
    Map<String, double>? fiveElementsStrength,
    bool enablePbr = true,
    double heightMeters = 1.7,
    List<int>? animationIds,  // 要生成的动画ID列表
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.avatar3dCreateFullEndpoint}');

    final requestBody = <String, dynamic>{
      'day_master': dayMaster,
      'gender': gender,
      'enable_pbr': enablePbr,
      'height_meters': heightMeters,
      'pose_mode': 'a-pose',  // 人形角色建议用 A-Pose
      if (fiveElements != null) 'five_elements': fiveElements,
      if (fiveElementsStrength != null) 'five_elements_strength': fiveElementsStrength,
      if (animationIds != null && animationIds.isNotEmpty) 'animation_ids': animationIds,
    };

    debugPrint('[API] 创建完整流程任务 URL: $url');
    debugPrint('[API] 请求体: ${jsonEncode(requestBody)}');

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('[API] 完整流程任务响应: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          final data = json['data'] as Map<String, dynamic>;
          return FullPipelineCreateResponse(
            success: true,
            pipelineId: data['pipeline_id'] as String?,
            previewTaskId: data['preview_task_id'] as String?,
            prompt: data['prompt'] as String?,
            status: data['status'] as String?,
          );
        }
      }

      return FullPipelineCreateResponse(
        success: false,
        error: '创建完整流程任务失败: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('[API] 创建完整流程任务异常: $e');
      return FullPipelineCreateResponse(
        success: false,
        error: '网络错误: $e',
      );
    }
  }

  /// SSE 流式获取完整流程进度
  /// 返回各阶段的进度更新
  Stream<FullPipelineStreamEvent> streamFullPipelineProgress(
    String pipelineId, {
    String? connectionId,
    Duration timeout = const Duration(minutes: 30),
  }) async* {
    final url = Uri.parse('${AppConfig.baseUrl}/api/v1/avatar3d/full/$pipelineId/stream');
    final connId = connectionId ?? 'pipeline_$pipelineId';

    debugPrint('[API] 完整流程 SSE 连接: $url');

    final request = http.Request('GET', url);
    final connection = _createSSEConnection(connId);

    try {
      connection.connect(
        request,
        timeout: timeout,
        connectionTimeout: const Duration(seconds: 30),
      );

      await for (final jsonStr in connection.stream) {
        try {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          yield FullPipelineStreamEvent.fromJson(json);
        } catch (e) {
          debugPrint('[API] 完整流程 SSE 解析错误: $e');
        }
      }
    } on TimeoutException {
      yield FullPipelineStreamEvent(
        pipelineId: pipelineId,
        currentStage: 'error',
        status: 'FAILED',
        totalProgress: 0,
        error: 'SSE 连接超时',
        done: true,
      );
    } catch (e) {
      debugPrint('[API] 完整流程 SSE 异常: $e');
      yield FullPipelineStreamEvent(
        pipelineId: pipelineId,
        currentStage: 'error',
        status: 'FAILED',
        totalProgress: 0,
        error: '网络错误: $e',
        done: true,
      );
    } finally {
      _activeConnections.remove(connId);
    }
  }

  /// 取消完整流程进度流
  void cancelFullPipelineStream(String pipelineId) {
    cancelSSEConnection('pipeline_$pipelineId');
  }

  /// 等待完整流程完成
  Future<FullPipelineResult> waitForFullPipelineCompletion(
    String pipelineId, {
    Function(String stage, int progress, String status)? onProgress,
    Function(String stage)? onStageChanged,
    Function(FullPipelineStreamEvent)? onPreviewComplete,
    Function(FullPipelineStreamEvent)? onRefineComplete,
    Function(FullPipelineStreamEvent)? onRiggingComplete,
  }) async {
    String? lastStage;

    await for (final event in streamFullPipelineProgress(pipelineId)) {
      // 通知阶段变化
      if (event.currentStage != lastStage) {
        lastStage = event.currentStage;
        onStageChanged?.call(event.currentStage);
      }

      // 通知进度
      onProgress?.call(event.currentStage, event.totalProgress, event.status);

      debugPrint('[API SSE] 完整流程 - 阶段: ${event.currentStage}, 状态: ${event.status}, 进度: ${event.totalProgress}%');

      // 各阶段完成回调
      if (event.currentStage == 'preview' && event.status == 'STAGE_COMPLETE') {
        onPreviewComplete?.call(event);
      } else if (event.currentStage == 'refine' && event.status == 'STAGE_COMPLETE') {
        onRefineComplete?.call(event);
      } else if (event.currentStage == 'rigging' && event.status == 'STAGE_COMPLETE') {
        onRiggingComplete?.call(event);
      }

      // 任务完成
      if (event.done) {
        return FullPipelineResult(
          success: event.status == 'SUCCEEDED',
          pipelineId: pipelineId,
          previewTaskId: event.previewTaskId,
          refineTaskId: event.refineTaskId,
          rigTaskId: event.rigTaskId,
          animationTaskIds: event.animationTaskIds,
          modelUrls: event.modelUrls,
          riggedModelUrls: event.riggedModelUrls,
          basicAnimations: event.basicAnimations,
          error: event.error,
        );
      }
    }

    return FullPipelineResult(
      success: false,
      pipelineId: pipelineId,
      error: 'SSE 流意外结束',
    );
  }

  // ============================================================
  // Image Generate API（图片生成）
  // ============================================================

  /// 异步生成图片
  /// POST /api/v1/generate
  Future<ImageGenerateResponse> generateImage({
    required String prompt,
    List<String> inputImages = const [],
    String aspectRatio = 'portrait',
    required String visitorId,
    required int timestamp,
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.imageGenerateEndpoint}');

    final requestBody = {
      'prompt': prompt,
      'input_images': inputImages,
      'aspect_ratio': aspectRatio,
      'visitor_id': visitorId,
      'timestamp': timestamp,
    };

    debugPrint('[API] 生成图片 URL: $url');
    debugPrint('[API] 请求体: ${jsonEncode(requestBody)}');

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('[API] 生成图片响应: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          final data = json['data'] as Map<String, dynamic>;
          return ImageGenerateResponse(
            success: true,
            taskId: data['task_id'] as String?,
            status: data['status'] as String?,
            createdAt: data['created_at'] as double?,
          );
        }
      }

      return ImageGenerateResponse(
        success: false,
        error: '生成图片失败: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('[API] 生成图片异常: $e');
      return ImageGenerateResponse(
        success: false,
        error: '网络错误: $e',
      );
    }
  }

  /// 查询图片生成状态
  /// GET /api/v1/status/{task_id}
  Future<ImageGenerateStatusResponse> getImageGenerateStatus(String taskId) async {
    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.imageStatusEndpoint}/$taskId');

    try {
      final response = await _client
          .get(url)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          return ImageGenerateStatusResponse.fromJson(json['data'] as Map<String, dynamic>);
        }
      }

      return ImageGenerateStatusResponse(
        taskId: taskId,
        status: 'FAILED',
        error: '查询失败: ${response.statusCode}',
      );
    } catch (e) {
      return ImageGenerateStatusResponse(
        taskId: taskId,
        status: 'FAILED',
        error: '网络错误: $e',
      );
    }
  }

  /// SSE 流式获取图片生成进度
  Stream<ImageGenerateStreamEvent> streamImageGenerateProgress(
    String taskId, {
    String? connectionId,
    Duration timeout = const Duration(minutes: 10),
  }) async* {
    final url = Uri.parse('${AppConfig.baseUrl}/api/v1/stream/$taskId');
    final connId = connectionId ?? 'image_generate_$taskId';

    debugPrint('[API] 图片生成 SSE 连接: $url');

    final request = http.Request('GET', url);
    final connection = _createSSEConnection(connId);

    try {
      connection.connect(
        request,
        timeout: timeout,
        connectionTimeout: const Duration(seconds: 30),
      );

      await for (final jsonStr in connection.stream) {
        try {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          yield ImageGenerateStreamEvent.fromJson(json);
        } catch (e) {
          debugPrint('[API] 图片生成 SSE 解析错误: $e');
        }
      }
    } on TimeoutException {
      yield ImageGenerateStreamEvent(
        taskId: taskId,
        status: 'FAILED',
        progress: 0,
        message: 'SSE 连接超时',
        error: 'SSE 连接超时',
        done: true,
      );
    } catch (e) {
      debugPrint('[API] 图片生成 SSE 异常: $e');
      yield ImageGenerateStreamEvent(
        taskId: taskId,
        status: 'FAILED',
        progress: 0,
        message: '网络错误: $e',
        error: '网络错误: $e',
        done: true,
      );
    } finally {
      _activeConnections.remove(connId);
    }
  }

  /// 取消图片生成进度流
  void cancelImageGenerateStream(String taskId) {
    cancelSSEConnection('image_generate_$taskId');
  }

  /// 同步生成图片（立即返回结果）
  /// POST /api/v1/generate/sync
  Future<ImageGenerateSyncResponse> generateImageSync({
    required String prompt,
    List<String> inputImages = const [],
    String aspectRatio = 'portrait',
    required String visitorId,
    required int timestamp,
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/v1/generate/sync');

    final requestBody = {
      'prompt': prompt,
      'input_images': inputImages,
      'aspect_ratio': aspectRatio,
      'visitor_id': visitorId,
      'timestamp': timestamp,
    };

    debugPrint('[API] 同步生成图片 URL: $url');
    debugPrint('[API] 请求体: ${jsonEncode(requestBody)}');

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 60)); // 同步生成可能需要更长时间

      debugPrint('[API] 同步生成图片响应: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          final data = json['data'] as Map<String, dynamic>;
          return ImageGenerateSyncResponse(
            success: true,
            taskId: data['task_id'] as String?,
            resultUrl: data['result_url'] as String?,
            status: data['status'] as String?,
            prompt: data['prompt'] as String?,
            aspectRatio: data['aspect_ratio'] as String?,
          );
        }
      }

      return ImageGenerateSyncResponse(
        success: false,
        error: '同步生成图片失败: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('[API] 同步生成图片异常: $e');
      return ImageGenerateSyncResponse(
        success: false,
        error: '网络错误: $e',
      );
    }
  }

  /// 关闭客户端
  void dispose() {
    _client.close();
  }
}

/// 3D 任务创建响应
class Avatar3dCreateResponse {
  final bool success;
  final String? taskId;
  final String? previewTaskId;
  final String? prompt;
  final String? status;
  final String? stage;
  final bool autoRefine;
  final String? error;

  Avatar3dCreateResponse({
    required this.success,
    this.taskId,
    this.previewTaskId,
    this.prompt,
    this.status,
    this.stage,
    this.autoRefine = true,
    this.error,
  });
}

/// 3D 任务状态响应
class Avatar3dStatusResponse {
  final String taskId;
  final String? previewTaskId;
  final String? refineTaskId;
  final String status;
  final int progress;
  final String? stage;
  final String? type;
  final Map<String, String>? modelUrls;
  final String? thumbnailUrl;
  final String? videoUrl;
  final List<Map<String, String>>? textureUrls;
  final String? error;
  final String? message;

  Avatar3dStatusResponse({
    required this.taskId,
    this.previewTaskId,
    this.refineTaskId,
    required this.status,
    required this.progress,
    this.stage,
    this.type,
    this.modelUrls,
    this.thumbnailUrl,
    this.videoUrl,
    this.textureUrls,
    this.error,
    this.message,
  });

  bool get isCompleted =>
      status == 'SUCCEEDED' || status == 'FAILED' || status == 'CANCELED';
  bool get isSucceeded => status == 'SUCCEEDED';

  /// 是否是精细化后的完整模型（带贴图）
  bool get isRefinedModel => type == 'text-to-3d-refine' || stage == 'refine';

  factory Avatar3dStatusResponse.fromJson(Map<String, dynamic> json) {
    Map<String, String>? modelUrls;
    if (json['model_urls'] != null && json['model_urls'] is Map) {
      modelUrls = (json['model_urls'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v?.toString() ?? ''));
    }

    List<Map<String, String>>? textureUrls;
    if (json['texture_urls'] != null && json['texture_urls'] is List) {
      textureUrls = (json['texture_urls'] as List)
          .map((e) => (e as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v?.toString() ?? '')))
          .toList();
    }

    return Avatar3dStatusResponse(
      taskId: json['task_id'] as String? ?? '',
      previewTaskId: json['preview_task_id'] as String?,
      refineTaskId: json['refine_task_id'] as String?,
      status: json['status'] as String? ?? 'UNKNOWN',
      progress: json['progress'] as int? ?? 0,
      stage: json['stage'] as String?,
      type: json['type'] as String?,
      modelUrls: modelUrls,
      thumbnailUrl: json['thumbnail_url'] as String?,
      videoUrl: json['video_url'] as String?,
      textureUrls: textureUrls,
      error: json['error'] as String?,
      message: json['message'] as String?,
    );
  }
}

/// SSE 流事件
class Avatar3dStreamEvent {
  final String taskId;
  final String? refineTaskId;
  final String stage;
  final String status;
  final int progress;
  final int totalProgress;
  final Map<String, String>? modelUrls;
  final String? thumbnailUrl;
  final String? videoUrl;
  final List<Map<String, String>>? textureUrls;
  final String? type;
  final String? error;
  final String? refineError;
  final bool done;
  final bool isPreview;  // 是否是预览结果

  Avatar3dStreamEvent({
    required this.taskId,
    this.refineTaskId,
    required this.stage,
    required this.status,
    required this.progress,
    required this.totalProgress,
    this.modelUrls,
    this.thumbnailUrl,
    this.videoUrl,
    this.textureUrls,
    this.type,
    this.error,
    this.refineError,
    this.done = false,
    this.isPreview = false,
  });

  bool get isSucceeded => status == 'SUCCEEDED' && done;
  bool get isFailed => (status == 'FAILED' || status == 'CANCELED') && done;
  bool get isStageChange => status == 'STAGE_CHANGE';
  bool get isPreviewSucceeded => status == 'PREVIEW_SUCCEEDED';

  factory Avatar3dStreamEvent.fromJson(Map<String, dynamic> json) {
    Map<String, String>? modelUrls;
    if (json['model_urls'] != null && json['model_urls'] is Map) {
      modelUrls = (json['model_urls'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v?.toString() ?? ''));
    }

    List<Map<String, String>>? textureUrls;
    if (json['texture_urls'] != null && json['texture_urls'] is List) {
      textureUrls = (json['texture_urls'] as List)
          .map((e) => (e as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v?.toString() ?? '')))
          .toList();
    }

    return Avatar3dStreamEvent(
      taskId: json['task_id'] as String? ?? '',
      refineTaskId: json['refine_task_id'] as String?,
      stage: json['stage'] as String? ?? 'preview',
      status: json['status'] as String? ?? 'UNKNOWN',
      progress: json['progress'] as int? ?? 0,
      totalProgress: json['total_progress'] as int? ?? 0,
      modelUrls: modelUrls,
      thumbnailUrl: json['thumbnail_url'] as String?,
      videoUrl: json['video_url'] as String?,
      textureUrls: textureUrls,
      type: json['type'] as String?,
      error: json['error'] as String?,
      refineError: json['refine_error'] as String?,
      done: json['done'] as bool? ?? false,
      isPreview: json['is_preview'] as bool? ?? false,
    );
  }
}

// ============================================================
// Retexture（换皮肤）相关响应类
// ============================================================

/// 换皮肤任务创建响应
class RetextureCreateResponse {
  final bool success;
  final String? taskId;
  final String? status;
  final String? error;

  RetextureCreateResponse({
    required this.success,
    this.taskId,
    this.status,
    this.error,
  });
}

/// 换皮肤任务状态响应
class RetextureStatusResponse {
  final String taskId;
  final String status;
  final int progress;
  final Map<String, String>? modelUrls;
  final String? thumbnailUrl;
  final List<Map<String, String>>? textureUrls;
  final String? error;

  RetextureStatusResponse({
    required this.taskId,
    required this.status,
    required this.progress,
    this.modelUrls,
    this.thumbnailUrl,
    this.textureUrls,
    this.error,
  });

  bool get isCompleted =>
      status == 'SUCCEEDED' || status == 'FAILED' || status == 'CANCELED';
  bool get isSucceeded => status == 'SUCCEEDED';

  factory RetextureStatusResponse.fromJson(Map<String, dynamic> json) {
    Map<String, String>? modelUrls;
    if (json['model_urls'] != null && json['model_urls'] is Map) {
      modelUrls = (json['model_urls'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v?.toString() ?? ''));
    }

    List<Map<String, String>>? textureUrls;
    if (json['texture_urls'] != null && json['texture_urls'] is List) {
      textureUrls = (json['texture_urls'] as List)
          .map((e) => (e as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v?.toString() ?? '')))
          .toList();
    }

    return RetextureStatusResponse(
      taskId: json['task_id'] as String? ?? '',
      status: json['status'] as String? ?? 'UNKNOWN',
      progress: json['progress'] as int? ?? 0,
      modelUrls: modelUrls,
      thumbnailUrl: json['thumbnail_url'] as String?,
      textureUrls: textureUrls,
      error: json['error'] as String?,
    );
  }
}

/// 换皮肤 SSE 流事件
class RetextureStreamEvent {
  final String taskId;
  final String status;
  final int progress;
  final Map<String, String>? modelUrls;
  final String? thumbnailUrl;
  final List<Map<String, String>>? textureUrls;
  final String? error;
  final bool done;

  RetextureStreamEvent({
    required this.taskId,
    required this.status,
    required this.progress,
    this.modelUrls,
    this.thumbnailUrl,
    this.textureUrls,
    this.error,
    this.done = false,
  });

  factory RetextureStreamEvent.fromJson(Map<String, dynamic> json) {
    Map<String, String>? modelUrls;
    if (json['model_urls'] != null && json['model_urls'] is Map) {
      modelUrls = (json['model_urls'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v?.toString() ?? ''));
    }

    List<Map<String, String>>? textureUrls;
    if (json['texture_urls'] != null && json['texture_urls'] is List) {
      textureUrls = (json['texture_urls'] as List)
          .map((e) => (e as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v?.toString() ?? '')))
          .toList();
    }

    return RetextureStreamEvent(
      taskId: json['task_id'] as String? ?? '',
      status: json['status'] as String? ?? 'UNKNOWN',
      progress: json['progress'] as int? ?? 0,
      modelUrls: modelUrls,
      thumbnailUrl: json['thumbnail_url'] as String?,
      textureUrls: textureUrls,
      error: json['error'] as String?,
      done: json['done'] as bool? ?? false,
    );
  }
}

// ============================================================
// Rigging（骨骼绑定）相关响应类
// ============================================================

/// 骨骼绑定任务创建响应
class RiggingCreateResponse {
  final bool success;
  final String? taskId;
  final String? status;
  final String? error;

  RiggingCreateResponse({
    required this.success,
    this.taskId,
    this.status,
    this.error,
  });
}

/// 骨骼绑定任务状态响应
class RiggingStatusResponse {
  final String taskId;
  final String status;
  final int progress;
  final String? riggedGlbUrl;
  final String? riggedFbxUrl;
  final Map<String, String>? basicAnimations;
  final String? error;

  RiggingStatusResponse({
    required this.taskId,
    required this.status,
    required this.progress,
    this.riggedGlbUrl,
    this.riggedFbxUrl,
    this.basicAnimations,
    this.error,
  });

  bool get isCompleted =>
      status == 'SUCCEEDED' || status == 'FAILED' || status == 'CANCELED';
  bool get isSucceeded => status == 'SUCCEEDED';

  factory RiggingStatusResponse.fromJson(Map<String, dynamic> json) {
    Map<String, String>? basicAnimations;
    final result = json['result'] as Map<String, dynamic>?;
    if (result != null && result['basic_animations'] != null) {
      basicAnimations = (result['basic_animations'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v?.toString() ?? ''));
    }

    return RiggingStatusResponse(
      taskId: json['task_id'] as String? ?? json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'UNKNOWN',
      progress: json['progress'] as int? ?? 0,
      riggedGlbUrl: result?['rigged_character_glb_url'] as String?,
      riggedFbxUrl: result?['rigged_character_fbx_url'] as String?,
      basicAnimations: basicAnimations,
      error: json['task_error']?['message'] as String? ?? json['error'] as String?,
    );
  }
}

/// 骨骼绑定 SSE 流事件
class RiggingStreamEvent {
  final String taskId;
  final String status;
  final int progress;
  final String? riggedGlbUrl;
  final String? riggedFbxUrl;
  final Map<String, String>? basicAnimations;
  final String? error;
  final bool done;

  RiggingStreamEvent({
    required this.taskId,
    required this.status,
    required this.progress,
    this.riggedGlbUrl,
    this.riggedFbxUrl,
    this.basicAnimations,
    this.error,
    this.done = false,
  });

  factory RiggingStreamEvent.fromJson(Map<String, dynamic> json) {
    Map<String, String>? basicAnimations;
    final result = json['result'] as Map<String, dynamic>?;
    if (result != null && result['basic_animations'] != null) {
      basicAnimations = (result['basic_animations'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v?.toString() ?? ''));
    }

    return RiggingStreamEvent(
      taskId: json['task_id'] as String? ?? json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'UNKNOWN',
      progress: json['progress'] as int? ?? 0,
      riggedGlbUrl: result?['rigged_character_glb_url'] as String?,
      riggedFbxUrl: result?['rigged_character_fbx_url'] as String?,
      basicAnimations: basicAnimations,
      error: json['task_error']?['message'] as String? ?? json['error'] as String?,
      done: json['done'] as bool? ?? (json['status'] == 'SUCCEEDED' || json['status'] == 'FAILED'),
    );
  }
}

// ============================================================
// Animation（动画绑定）相关响应类
// ============================================================

/// 动画后处理选项
class AnimationPostProcess {
  final String operationType;  // change_fps, fbx2usdz, extract_armature
  final int? fps;  // 仅 change_fps 时使用，可选值：24, 25, 30, 60

  AnimationPostProcess({
    required this.operationType,
    this.fps,
  });

  Map<String, dynamic> toJson() => {
        'operation_type': operationType,
        if (fps != null) 'fps': fps,
      };
}

/// 动画任务创建响应
class AnimationCreateResponse {
  final bool success;
  final String? taskId;
  final String? status;
  final String? error;

  AnimationCreateResponse({
    required this.success,
    this.taskId,
    this.status,
    this.error,
  });
}

/// 动画任务状态响应
class AnimationStatusResponse {
  final String taskId;
  final String status;
  final int progress;
  final String? animationGlbUrl;
  final String? animationFbxUrl;
  final String? processedUsdzUrl;
  final String? error;

  AnimationStatusResponse({
    required this.taskId,
    required this.status,
    required this.progress,
    this.animationGlbUrl,
    this.animationFbxUrl,
    this.processedUsdzUrl,
    this.error,
  });

  bool get isCompleted =>
      status == 'SUCCEEDED' || status == 'FAILED' || status == 'CANCELED';
  bool get isSucceeded => status == 'SUCCEEDED';

  factory AnimationStatusResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>?;

    return AnimationStatusResponse(
      taskId: json['task_id'] as String? ?? json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'UNKNOWN',
      progress: json['progress'] as int? ?? 0,
      animationGlbUrl: result?['animation_glb_url'] as String?,
      animationFbxUrl: result?['animation_fbx_url'] as String?,
      processedUsdzUrl: result?['processed_usdz_url'] as String?,
      error: json['task_error']?['message'] as String? ?? json['error'] as String?,
    );
  }
}

/// 动画 SSE 流事件
class AnimationStreamEvent {
  final String taskId;
  final String status;
  final int progress;
  final String? animationGlbUrl;
  final String? animationFbxUrl;
  final String? processedUsdzUrl;
  final String? error;
  final bool done;

  AnimationStreamEvent({
    required this.taskId,
    required this.status,
    required this.progress,
    this.animationGlbUrl,
    this.animationFbxUrl,
    this.processedUsdzUrl,
    this.error,
    this.done = false,
  });

  factory AnimationStreamEvent.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>?;

    return AnimationStreamEvent(
      taskId: json['task_id'] as String? ?? json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'UNKNOWN',
      progress: json['progress'] as int? ?? 0,
      animationGlbUrl: result?['animation_glb_url'] as String?,
      animationFbxUrl: result?['animation_fbx_url'] as String?,
      processedUsdzUrl: result?['processed_usdz_url'] as String?,
      error: json['task_error']?['message'] as String? ?? json['error'] as String?,
      done: json['done'] as bool? ?? (json['status'] == 'SUCCEEDED' || json['status'] == 'FAILED'),
    );
  }
}

// ============================================================
// 完整流程相关响应类
// ============================================================

/// 完整流程任务创建响应
class FullPipelineCreateResponse {
  final bool success;
  final String? pipelineId;
  final String? previewTaskId;
  final String? prompt;
  final String? status;
  final String? error;

  FullPipelineCreateResponse({
    required this.success,
    this.pipelineId,
    this.previewTaskId,
    this.prompt,
    this.status,
    this.error,
  });
}

/// 完整流程 SSE 流事件
class FullPipelineStreamEvent {
  final String pipelineId;
  final String currentStage;  // preview, refine, rigging, animation
  final String status;
  final int stageProgress;
  final int totalProgress;
  final String? previewTaskId;
  final String? refineTaskId;
  final String? rigTaskId;
  final List<String>? animationTaskIds;
  final Map<String, String>? modelUrls;
  final Map<String, String>? riggedModelUrls;
  final Map<String, String>? basicAnimations;
  final String? error;
  final bool done;

  FullPipelineStreamEvent({
    required this.pipelineId,
    required this.currentStage,
    required this.status,
    this.stageProgress = 0,
    required this.totalProgress,
    this.previewTaskId,
    this.refineTaskId,
    this.rigTaskId,
    this.animationTaskIds,
    this.modelUrls,
    this.riggedModelUrls,
    this.basicAnimations,
    this.error,
    this.done = false,
  });

  factory FullPipelineStreamEvent.fromJson(Map<String, dynamic> json) {
    Map<String, String>? modelUrls;
    if (json['model_urls'] != null && json['model_urls'] is Map) {
      modelUrls = (json['model_urls'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v?.toString() ?? ''));
    }

    Map<String, String>? riggedModelUrls;
    if (json['rigged_model_urls'] != null && json['rigged_model_urls'] is Map) {
      riggedModelUrls = (json['rigged_model_urls'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v?.toString() ?? ''));
    }

    Map<String, String>? basicAnimations;
    if (json['basic_animations'] != null && json['basic_animations'] is Map) {
      basicAnimations = (json['basic_animations'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v?.toString() ?? ''));
    }

    List<String>? animationTaskIds;
    if (json['animation_task_ids'] != null && json['animation_task_ids'] is List) {
      animationTaskIds = (json['animation_task_ids'] as List)
          .map((e) => e.toString())
          .toList();
    }

    return FullPipelineStreamEvent(
      pipelineId: json['pipeline_id'] as String? ?? '',
      currentStage: json['current_stage'] as String? ?? 'preview',
      status: json['status'] as String? ?? 'UNKNOWN',
      stageProgress: json['stage_progress'] as int? ?? 0,
      totalProgress: json['total_progress'] as int? ?? 0,
      previewTaskId: json['preview_task_id'] as String?,
      refineTaskId: json['refine_task_id'] as String?,
      rigTaskId: json['rig_task_id'] as String?,
      animationTaskIds: animationTaskIds,
      modelUrls: modelUrls,
      riggedModelUrls: riggedModelUrls,
      basicAnimations: basicAnimations,
      error: json['error'] as String?,
      done: json['done'] as bool? ?? false,
    );
  }
}

/// 完整流程结果
class FullPipelineResult {
  final bool success;
  final String pipelineId;
  final String? previewTaskId;
  final String? refineTaskId;
  final String? rigTaskId;
  final List<String>? animationTaskIds;
  final Map<String, String>? modelUrls;
  final Map<String, String>? riggedModelUrls;
  final Map<String, String>? basicAnimations;
  final String? error;

  FullPipelineResult({
    required this.success,
    required this.pipelineId,
    this.previewTaskId,
    this.refineTaskId,
    this.rigTaskId,
    this.animationTaskIds,
    this.modelUrls,
    this.riggedModelUrls,
    this.basicAnimations,
    this.error,
  });
}
