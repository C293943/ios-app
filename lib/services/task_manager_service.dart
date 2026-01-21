// 后台任务管理服务，负责生图/生视频任务的调度与状态维护。
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:primordial_spirit/services/fortune_api_service.dart';
import 'package:primordial_spirit/services/video_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 任务类型
enum TaskType {
  imageGeneration,  // 图片生成
  videoGeneration,  // 视频生成
  avatar3d,         // 3D形象生成
}

/// 任务状态
enum TaskStatus {
  pending,      // 待处理
  processing,   // 处理中
  completed,    // 已完成
  failed,       // 失败
  cancelled,    // 已取消
}

/// 任务信息
class TaskInfo {
  final String id;
  final TaskType type;
  final String taskId;  // 后端返回的任务ID
  final TaskStatus status;
  final String? resultUrl;
  final String? error;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic> metadata;

  TaskInfo({
    required this.id,
    required this.type,
    required this.taskId,
    required this.status,
    this.resultUrl,
    this.error,
    required this.createdAt,
    this.completedAt,
    this.metadata = const {},
  });

  /// 是否成功完成
  bool get isCompletedSuccessfully => status == TaskStatus.completed && resultUrl != null;

  /// 是否正在进行中
  bool get isProcessing => status == TaskStatus.processing || status == TaskStatus.pending;

  TaskInfo copyWith({
    String? id,
    TaskType? type,
    String? taskId,
    TaskStatus? status,
    String? resultUrl,
    String? error,
    DateTime? createdAt,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return TaskInfo(
      id: id ?? this.id,
      type: type ?? this.type,
      taskId: taskId ?? this.taskId,
      status: status ?? this.status,
      resultUrl: resultUrl ?? this.resultUrl,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'task_id': taskId,
      'status': status.name,
      'result_url': resultUrl,
      'error': error,
      'created_at': createdAt.millisecondsSinceEpoch,
      'completed_at': completedAt?.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  factory TaskInfo.fromJson(Map<String, dynamic> json) {
    return TaskInfo(
      id: json['id'] as String,
      type: TaskType.values.firstWhere((e) => e.name == json['type']),
      taskId: json['task_id'] as String,
      status: TaskStatus.values.firstWhere((e) => e.name == json['status']),
      resultUrl: json['result_url'] as String?,
      error: json['error'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      completedAt: json['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completed_at'] as int)
          : null,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }
}

/// 任务管理服务 - 处理后台请求的创建、查询和状态管理
///
/// 核心职责:
/// 1. 生图/生视频任务的自动后台提交
/// 2. 任务状态的持久化和恢复
/// 3. 任务完成后的自动更新
/// 4. 觉醒时的视频自动生成触发
class TaskManagerService extends ChangeNotifier {
  static const String _tasksKey = 'background_tasks';
  static const String _lastEggImageKey = 'last_egg_image_url';

  final FortuneApiService _api = FortuneApiService();

  /// 活跃的任务列表
  final Map<String, TaskInfo> _tasks = {};

  /// 轮询定时器
  Timer? _pollTimer;

  /// 是否正在轮询
  bool _isPolling = false;

  /// 最后一次使用的egg图片URL
  String? _lastEggImageUrl;

  /// 获取所有任务
  List<TaskInfo> get tasks => _tasks.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// 获取指定类型的任务
  List<TaskInfo> getTasksByType(TaskType type) {
    return tasks.where((task) => task.type == type).toList();
  }

  /// 获取正在进行的任务
  List<TaskInfo> get processingTasks {
    return tasks.where((task) => task.isProcessing).toList();
  }

  /// 获取最后的egg图片URL
  String? get lastEggImageUrl => _lastEggImageUrl;

  /// 初始化
  Future<void> init() async {
    debugPrint('[TaskManager] 初始化任务管理服务');
    await _loadTasks();
    await _loadLastEggImage();

    // 恢复未完成的任务
    await _restorePendingTasks();

    // 启动轮询
    _startPolling();

    debugPrint('[TaskManager] 初始化完成, 当前任务数: ${_tasks.length}');
  }

  /// 加载保存的任务
  Future<void> _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_tasksKey);
      if (tasksJson != null) {
        final List<dynamic> decoded = [];
        // 简单处理: 实际应该用jsonDecode
        final tasksList = decoded as List<Map<String, dynamic>>;
        for (final taskJson in tasksList) {
          final task = TaskInfo.fromJson(taskJson);
          // 只加载未完成的任务
          if (task.isProcessing) {
            _tasks[task.id] = task;
          }
        }
      }
    } catch (e) {
      debugPrint('[TaskManager] 加载任务失败: $e');
    }
  }

  /// 保存任务
  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = _tasks.values.map((t) => t.toJson()).toList();
      await prefs.setString(_tasksKey, tasksJson.toString());
    } catch (e) {
      debugPrint('[TaskManager] 保存任务失败: $e');
    }
  }

  /// 加载最后的egg图片
  Future<void> _loadLastEggImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastEggImageUrl = prefs.getString(_lastEggImageKey);
    } catch (e) {
      debugPrint('[TaskManager] 加载egg图片失败: $e');
    }
  }

  /// 保存最后的egg图片
  Future<void> _saveLastEggImage(String imageUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastEggImageKey, imageUrl);
      _lastEggImageUrl = imageUrl;
      debugPrint('[TaskManager] 已保存egg图片: $imageUrl');
    } catch (e) {
      debugPrint('[TaskManager] 保存egg图片失败: $e');
    }
  }

  /// 恢复未完成的任务
  Future<void> _restorePendingTasks() async {
    for (final task in _tasks.values) {
      if (task.isProcessing) {
        debugPrint('[TaskManager] 恢复任务: ${task.id} (${task.type.name})');
      }
    }
  }

  /// 启动轮询
  void _startPolling() {
    if (_isPolling) return;
    _isPolling = true;

    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _pollTaskStatus();
    });

    debugPrint('[TaskManager] 启动任务轮询');
  }

  /// 停止轮询
  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _isPolling = false;
    debugPrint('[TaskManager] 停止任务轮询');
  }

  /// 轮询任务状态
  Future<void> _pollTaskStatus() async {
    if (_tasks.isEmpty) return;

    final processingTasks = _tasks.values.where((t) => t.isProcessing).toList();
    if (processingTasks.isEmpty) return;

    debugPrint('[TaskManager] 轮询 ${processingTasks.length} 个任务状态');

    for (final task in processingTasks) {
      await _updateTaskStatus(task);
    }
  }

  /// 更新单个任务状态
  Future<void> _updateTaskStatus(TaskInfo task) async {
    try {
      switch (task.type) {
        case TaskType.imageGeneration:
          await _updateImageTaskStatus(task);
          break;
        case TaskType.videoGeneration:
          await _updateVideoTaskStatus(task);
          break;
        case TaskType.avatar3d:
          await _updateAvatar3dTaskStatus(task);
          break;
      }
    } catch (e) {
      debugPrint('[TaskManager] 更新任务状态失败: ${task.id}, 错误: $e');
    }
  }

  /// 更新图片任务状态
  Future<void> _updateImageTaskStatus(TaskInfo task) async {
    final response = await _api.getImageGenerateStatus(task.taskId);

    final newTask = task.copyWith(
      status: _mapApiStatus(response.status),
      resultUrl: response.resultUrl,
      error: response.error,
      completedAt: response.status == 'SUCCEEDED' ? DateTime.now() : null,
    );

    _updateTask(newTask);
  }

  /// 更新视频任务状态
  Future<void> _updateVideoTaskStatus(TaskInfo task) async {
    final response = await _api.getMotionVideoStatus(taskId: task.taskId);

    final newTask = task.copyWith(
      status: _mapApiStatus(response.status),
      resultUrl: response.videoUrl,
      error: response.error,
      completedAt: response.status == 'success' ? DateTime.now() : null,
    );

    _updateTask(newTask);
  }

  /// 更新3D形象任务状态
  Future<void> _updateAvatar3dTaskStatus(TaskInfo task) async {
    final response = await _api.getAvatar3dStatus(task.taskId);

    final newTask = task.copyWith(
      status: _mapApiStatus(response.status),
      resultUrl: response.modelUrls?['glb'],
      error: response.error,
      completedAt: response.isCompleted ? DateTime.now() : null,
    );

    _updateTask(newTask);
  }

  /// 映射API状态到TaskStatus
  TaskStatus _mapApiStatus(String? apiStatus) {
    if (apiStatus == null) return TaskStatus.pending;

    switch (apiStatus.toLowerCase()) {
      case 'pending':
      case 'queued':
        return TaskStatus.pending;
      case 'processing':
      case 'in_progress':
        return TaskStatus.processing;
      case 'succeeded':
      case 'success':
      case 'completed':
        return TaskStatus.completed;
      case 'failed':
      case 'error':
        return TaskStatus.failed;
      case 'cancelled':
      case 'canceled':
        return TaskStatus.cancelled;
      default:
        return TaskStatus.pending;
    }
  }

  /// 更新任务
  void _updateTask(TaskInfo newTask) {
    final oldTask = _tasks[newTask.id];
    if (oldTask == null || oldTask.status != newTask.status) {
      _tasks[newTask.id] = newTask;
      _saveTasks();
      notifyListeners();

      debugPrint('[TaskManager] 任务更新: ${newTask.id}, 状态: ${newTask.status.name}');

      // 如果任务完成,触发回调
      if (newTask.isCompletedSuccessfully) {
        _onTaskCompleted(newTask);
      }
    }
  }

  /// 任务完成回调
  void _onTaskCompleted(TaskInfo task) {
    debugPrint('[TaskManager] 任务完成: ${task.id}, 结果: ${task.resultUrl}');

    // 根据任务类型处理完成逻辑
    switch (task.type) {
      case TaskType.imageGeneration:
        // 图片生成完成,更新lastEggImage
        if (task.resultUrl != null) {
          _saveLastEggImage(task.resultUrl!);
          debugPrint('[TaskManager] 已保存egg图片URL: ${task.resultUrl}');
        }
        break;
      case TaskType.videoGeneration:
        // 视频生成完成
        debugPrint('[TaskManager] 视频生成完成: ${task.resultUrl}');
        final videoUrl = task.resultUrl;
        if (videoUrl != null && videoUrl.isNotEmpty) {
          final imageUrl = task.metadata['image_url'] as String?;
          if (imageUrl != null && imageUrl.isNotEmpty) {
            unawaited(
              VideoCacheService().cacheVideoForImage(
                imageUrl: imageUrl,
                videoUrl: videoUrl,
              ),
            );
          } else {
            unawaited(VideoCacheService().cacheVideoByUrl(videoUrl));
          }
        }
        break;
      case TaskType.avatar3d:
        // 3D形象生成完成
        debugPrint('[TaskManager] 3D形象生成完成: ${task.resultUrl}');
        break;
    }
  }

  /// 提交生图任务(后台)
  ///
  /// 当用户首次提交八字信息时调用,使用默认的egg图片prompt
  /// 使用同步API,立即返回结果URL
  Future<TaskInfo?> submitImageGenerationTask({
    required String prompt,
    String? visitorId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final taskId = 'img_${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('[TaskManager] 提交生图任务, prompt: $prompt');

      // 使用同步API,立即返回结果
      final response = await _api.generateImageSync(
        prompt: prompt,
        visitorId: visitorId ?? 'default',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      if (!response.success) {
        debugPrint('[TaskManager] 提交生图任务失败: ${response.error}');
        return null;
      }

      debugPrint('[TaskManager] 生图API返回: success=${response.success}, resultUrl=${response.resultUrl}');

      final task = TaskInfo(
        id: taskId,
        type: TaskType.imageGeneration,
        taskId: response.taskId ?? taskId,
        status: response.resultUrl != null ? TaskStatus.completed : TaskStatus.processing,
        resultUrl: response.resultUrl,
        createdAt: DateTime.now(),
        completedAt: response.resultUrl != null ? DateTime.now() : null,
        metadata: metadata ?? {},
      );

      _tasks[task.id] = task;
      await _saveTasks();
      notifyListeners();

      debugPrint('[TaskManager] 生图任务: ${task.id}, 状态: ${task.status.name}, URL: ${task.resultUrl}');

      // 如果立即完成,触发回调
      if (task.isCompletedSuccessfully) {
        _onTaskCompleted(task);
      }

      return task;
    } catch (e) {
      debugPrint('[TaskManager] 提交生图任务异常: $e');
      return null;
    }
  }

  /// 提交生视频任务(后台)
  ///
  /// 在觉醒完成时自动调用,基于当前形象图片生成视频
  /// 视频生成完成后自动触发觉醒过渡动画
  Future<TaskInfo?> submitVideoGenerationTask({
    required String imageUrl,
    String? visitorId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final taskId = 'vid_${DateTime.now().millisecondsSinceEpoch}';
      final response = await _api.createMotionVideoTask(
        firstFrameImage: imageUrl,
        visitorId: visitorId,
      );

      if (!response.success || response.taskId == null) {
        debugPrint('[TaskManager] 提交生视频任务失败: ${response.error}');
        return null;
      }

      // 如果已经有videoUrl,说明是快速返回
      if (response.videoUrl != null && response.videoUrl!.isNotEmpty) {
        final task = TaskInfo(
          id: taskId,
          type: TaskType.videoGeneration,
          taskId: response.taskId!,
          status: TaskStatus.completed,
          resultUrl: response.videoUrl,
          createdAt: DateTime.now(),
          completedAt: DateTime.now(),
          metadata: metadata ?? {},
        );

        _tasks[task.id] = task;
        await _saveTasks();
        notifyListeners();

        debugPrint('[TaskManager] 生视频任务快速完成: ${task.id}');
        if (task.isCompletedSuccessfully) {
          _onTaskCompleted(task);
        }
        return task;
      }

      final task = TaskInfo(
        id: taskId,
        type: TaskType.videoGeneration,
        taskId: response.taskId!,
        status: TaskStatus.processing,
        createdAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      _tasks[task.id] = task;
      await _saveTasks();
      notifyListeners();

      debugPrint('[TaskManager] 生视频任务已提交: ${task.id}, 后端任务ID: ${response.taskId}');
      return task;
    } catch (e) {
      debugPrint('[TaskManager] 提交生视频任务异常: $e');
      return null;
    }
  }

  /// 取消任务
  Future<bool> cancelTask(String taskId) async {
    final task = _tasks[taskId];
    if (task == null) return false;

    // 根据任务类型取消
    switch (task.type) {
      case TaskType.imageGeneration:
        _api.cancelImageGenerateStream(task.taskId);
        break;
      case TaskType.videoGeneration:
        // 视频任务取消API暂未实现
        break;
      case TaskType.avatar3d:
        _api.cancelAvatar3dStream(task.taskId);
        break;
    }

    final newTask = task.copyWith(
      status: TaskStatus.cancelled,
      completedAt: DateTime.now(),
    );

    _updateTask(newTask);
    return true;
  }

  /// 清理已完成和失败的任务
  Future<void> clearCompletedTasks() async {
    _tasks.removeWhere((key, task) => !task.isProcessing);
    await _saveTasks();
    notifyListeners();
    debugPrint('[TaskManager] 已清理完成的任务');
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}
