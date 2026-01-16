import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:primordial_spirit/models/fortune_models.dart';
import 'package:primordial_spirit/services/fortune_api_service.dart';

enum DisplayMode { mode3D, mode2D, live2D }

/// 3D 模型配置
class Model3DConfig {
  final String id;
  final String name;
  final String path;
  final String? defaultAnimation;
  final bool isAsset; // true = 内置资源, false = 外部文件

  Model3DConfig({
    required this.id,
    required this.name,
    required this.path,
    this.defaultAnimation,
    this.isAsset = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'path': path,
        'defaultAnimation': defaultAnimation,
        'isAsset': isAsset,
      };

  factory Model3DConfig.fromJson(Map<String, dynamic> json) => Model3DConfig(
        id: json['id'] as String,
        name: json['name'] as String,
        path: json['path'] as String,
        defaultAnimation: json['defaultAnimation'] as String?,
        isAsset: json['isAsset'] as bool? ?? false,
      );
}

/// 模型管理服务
class ModelManagerService extends ChangeNotifier {
  static const String _storageKey = 'custom_3d_models';
  static const String _selectedModelKey = 'selected_model_id';
  static const String _displayModeKey = 'display_mode';
  static const String _userBaziKey = 'user_bazi_data';
  static const String _fortuneDataKey = 'fortune_data';
  static const String _visitorIdKey = 'visitor_id';
  static const String _image2dCacheKey = 'image_2d_cache';

  List<Model3DConfig> _customModels = [];
  String? _selectedModelId;
  DisplayMode _displayMode = DisplayMode.mode2D; // 默认使用2D模式
  bool _isInitialized = false;
  Map<String, dynamic>? _userBaziData;
  FortuneData? _fortuneData;
  String? _visitorId;
  String? _image2dUrl;
  String? _image2dTaskId;
  int? _image2dPromptHash;
  bool _isGenerating2dImage = false;
  String? _image2dError;

  /// 2D 形象对应的轻动作视频缓存（key=imageUrl, value=videoUrl）
  final Map<String, String> _motionVideoCache = {};

  /// 内置模型列表
  static final List<Model3DConfig> builtInModels = [
    Model3DConfig(
      id: 'builtin_texture',
      name: '多纹理角色',
      path: 'assets/3d_models/Meshy_AI_Ethereal_Enchantment_1216033315_texture.glb',
      isAsset: true,
    ),
    Model3DConfig(
      id: 'builtin_1',
      name: '动画角色 1',
      path: 'assets/3d_models/Meshy_AI_biped/Meshy_AI_Meshy_Merged_Animations.glb',
      defaultAnimation: 'Walking',
      isAsset: true,
    ),
    Model3DConfig(
      id: 'builtin_2',
      name: '动画角色 2',
      path: 'assets/3d_models/Meshy_AI_biped/Meshy_AI_Meshy_Merged_Animations1.glb',
      defaultAnimation: 'Walking',
      isAsset: true,
    ),
    Model3DConfig(
      id: 'builtin_3',
      name: '静态角色 1',
      path: 'assets/3d_models/Meshy_AI_biped/Meshy_AI_Character_output.glb',
      isAsset: true,
    ),
    Model3DConfig(
      id: 'builtin_4',
      name: '静态角色 2',
      path: 'assets/3d_models/Meshy_AI_biped/Meshy_AI_Character_output1.glb',
      isAsset: true,
    ),
  ];

  /// 获取所有模型（内置 + 自定义）
  List<Model3DConfig> get allModels => [...builtInModels, ..._customModels];

  /// 获取自定义模型
  List<Model3DConfig> get customModels => _customModels;

  /// 获取当前显示模式
  DisplayMode get displayMode => _displayMode;

  /// 获取当前选中的模型
  Model3DConfig? get selectedModel {
    if (_selectedModelId == null) {
      return builtInModels.first;
    }
    return allModels.firstWhere(
      (m) => m.id == _selectedModelId,
      orElse: () => builtInModels.first,
    );
  }

  /// 获取当前选中的模型 ID
  String? get selectedModelId => _selectedModelId;

  /// 获取用户八字数据
  Map<String, dynamic>? get userBaziData => _userBaziData;

  /// 获取完整命盘数据
  FortuneData? get fortuneData => _fortuneData;

  /// 访问者ID（用于后端生图接口追踪）
  String? get visitorId => _visitorId;

  /// 2D 生图结果（URL）
  /// 优先使用 fortuneData.avatar3dInfo 中的 URL，其次使用缓存
  String? get image2dUrl {
    // 如果 fortuneData 中有有效的 2D 图片 URL，优先使用
    if (_fortuneData?.avatar3dInfo?.thumbnailUrl != null &&
        _fortuneData!.avatar3dInfo!.thumbnailUrl!.isNotEmpty) {
      return _fortuneData!.avatar3dInfo!.thumbnailUrl;
    }
    if (_fortuneData?.avatar3dInfo?.glbUrl != null &&
        _fortuneData!.avatar3dInfo!.glbUrl!.isNotEmpty &&
        (_fortuneData!.avatar3dInfo!.glbUrl!.startsWith('http://') ||
         _fortuneData!.avatar3dInfo!.glbUrl!.startsWith('https://'))) {
      return _fortuneData!.avatar3dInfo!.glbUrl;
    }
    // 否则使用缓存
    return _image2dUrl;
  }

  /// 2D 生图任务ID
  String? get image2dTaskId => _image2dTaskId;

  /// 2D 生图中
  bool get isGenerating2dImage => _isGenerating2dImage;

  /// 2D 生图错误信息（如有）
  String? get image2dError => _image2dError;

  /// 获取轻动作视频 URL（如已缓存）
  String? getMotionVideoUrl(String imageUrl) => _motionVideoCache[imageUrl];

  /// 写入轻动作视频 URL 缓存
  void setMotionVideoUrl(String imageUrl, String videoUrl) {
    if (imageUrl.isEmpty || videoUrl.isEmpty) return;
    _motionVideoCache[imageUrl] = videoUrl;
    notifyListeners();
  }

  /// 是否已完成首次设置（已填写生辰信息）
  bool get hasCompletedSetup => _fortuneData != null || _userBaziData != null;

  /// 初始化
  Future<void> init() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();

    // 加载自定义模型
    final modelsJson = prefs.getString(_storageKey);
    if (modelsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(modelsJson);
        _customModels = decoded
            .map((e) => Model3DConfig.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('加载自定义模型失败: $e');
      }
    }

    // 加载选中的模型
    _selectedModelId = prefs.getString(_selectedModelKey);
    
    // 加载显示模式
    final modeIndex = prefs.getInt(_displayModeKey);
    if (modeIndex != null && modeIndex >= 0 && modeIndex < DisplayMode.values.length) {
      _displayMode = DisplayMode.values[modeIndex];
    }

    // 加载用户八字数据
    final baziJson = prefs.getString(_userBaziKey);
    if (baziJson != null) {
      try {
        _userBaziData = jsonDecode(baziJson) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('加载用户八字数据失败: $e');
      }
    }

    // 加载完整命盘数据
    final fortuneJson = prefs.getString(_fortuneDataKey);
    if (fortuneJson != null) {
      try {
        _fortuneData = FortuneData.fromJsonString(fortuneJson);
      } catch (e) {
        debugPrint('加载命盘数据失败: $e');
      }
    }

    // visitor_id
    _visitorId = prefs.getString(_visitorIdKey);
    if (_visitorId == null || _visitorId!.isEmpty) {
      _visitorId = _generateVisitorId();
      await prefs.setString(_visitorIdKey, _visitorId!);
    }

    // 2D 生图缓存
    final image2dJson = prefs.getString(_image2dCacheKey);
    if (image2dJson != null) {
      try {
        final cached = jsonDecode(image2dJson) as Map<String, dynamic>;
        _image2dUrl = cached['url'] as String?;
        _image2dTaskId = cached['task_id'] as String?;
        _image2dPromptHash = cached['prompt_hash'] as int?;
      } catch (e) {
        debugPrint('加载2D生图缓存失败: $e');
      }
    }

    _isInitialized = true;
    notifyListeners();

    // ⚠️ 禁止自动触发生图接口
    // 生图接口只能在提交个人信息时触发（avatar_generation_screen.dart）
    // if (_displayMode == DisplayMode.mode2D) {
    //   ensure2DImageGenerated();
    // }
  }

  /// 保存自定义模型到本地
  Future<void> _saveCustomModels() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_customModels.map((m) => m.toJson()).toList());
    await prefs.setString(_storageKey, json);
  }

  /// 添加自定义模型
  Future<Model3DConfig?> addCustomModel({
    required String name,
    required String sourcePath,
    String? defaultAnimation,
  }) async {
    try {
      // 获取应用文档目录
      final appDir = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${appDir.path}/3d_models');

      // 创建目录
      if (!await modelsDir.exists()) {
        await modelsDir.create(recursive: true);
      }

      // 复制文件到应用目录
      final sourceFile = File(sourcePath);
      final fileName = sourcePath.split('/').last.split('\\').last;
      final targetPath = '${modelsDir.path}/$fileName';
      await sourceFile.copy(targetPath);

      // 创建模型配置
      final model = Model3DConfig(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        path: targetPath,
        defaultAnimation: defaultAnimation,
        isAsset: false,
      );

      _customModels.add(model);
      await _saveCustomModels();
      notifyListeners();

      return model;
    } catch (e) {
      debugPrint('添加自定义模型失败: $e');
      return null;
    }
  }

  /// 删除自定义模型
  Future<bool> deleteCustomModel(String modelId) async {
    try {
      final model = _customModels.firstWhere(
        (m) => m.id == modelId,
        orElse: () => throw Exception('模型不存在'),
      );

      // 删除文件
      final file = File(model.path);
      if (await file.exists()) {
        await file.delete();
      }

      // 从列表中移除
      _customModels.removeWhere((m) => m.id == modelId);

      // 如果删除的是当前选中的模型，重置选择
      if (_selectedModelId == modelId) {
        _selectedModelId = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_selectedModelKey);
      }

      await _saveCustomModels();
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('删除自定义模型失败: $e');
      return false;
    }
  }

  /// 更新模型名称
  Future<bool> updateModelName(String modelId, String newName) async {
    try {
      final index = _customModels.indexWhere((m) => m.id == modelId);
      if (index == -1) return false;

      final oldModel = _customModels[index];
      _customModels[index] = Model3DConfig(
        id: oldModel.id,
        name: newName,
        path: oldModel.path,
        defaultAnimation: oldModel.defaultAnimation,
        isAsset: oldModel.isAsset,
      );

      await _saveCustomModels();
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('更新模型名称失败: $e');
      return false;
    }
  }

  /// 设置选中的模型
  Future<void> setSelectedModel(String modelId) async {
    _selectedModelId = modelId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedModelKey, modelId);
    notifyListeners();
  }

  /// 设置显示模式
  Future<void> setDisplayMode(DisplayMode mode) async {
    _displayMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_displayModeKey, mode.index);
    notifyListeners();

    // ⚠️ 禁止自动触发生图接口
    // 生图接口只能在提交个人信息时触发（avatar_generation_screen.dart）
    // if (mode == DisplayMode.mode2D) {
    //   ensure2DImageGenerated();
    // }
  }

  int _stableHash(String input) {
    // FNV-1a 32-bit
    const int fnvPrime = 16777619;
    int hash = 2166136261;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * fnvPrime) & 0xFFFFFFFF;
    }
    return hash;
  }

  String _generateVisitorId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  String _build2DImagePrompt() {
    final basePrompt = _fortuneData?.avatar3dInfo?.prompt;
    final gender = _fortuneData?.birthInfo.gender ?? (_userBaziData?['gender'] as String?) ?? '男';
    final dayMaster = _fortuneData?.baziInfo.dayMaster ?? _fortuneData?.baziInfo.dayGan;

    final promptParts = <String>[];
    if (basePrompt != null && basePrompt.trim().isNotEmpty) {
      promptParts.add(basePrompt.trim());
    } else {
      promptParts.add('Full body shot, frontal view, ethereal Xianxia immortal spirit companion, Chinese fantasy style');
      if (dayMaster != null && dayMaster.isNotEmpty) {
        promptParts.add('day master: $dayMaster');
      }
      promptParts.add('gender: $gender');
    }

    // 强制2D风格（用于“2D平面”模式）
    promptParts.addAll([
      '2D illustration',
      'high quality',
      'clean background',
      'soft lighting',
    ]);

    return promptParts.join(', ');
  }

  Future<void> ensure2DImageGenerated() async {
    if (_isGenerating2dImage) return;

    // 优先检查 fortuneData 中是否已有有效的 2D 图片 URL
    if (_fortuneData?.avatar3dInfo?.thumbnailUrl != null &&
        _fortuneData!.avatar3dInfo!.thumbnailUrl!.isNotEmpty) {
      debugPrint('[ModelManager] fortuneData 中已有 2D 图片，跳过生成');
      return;
    }
    if (_fortuneData?.avatar3dInfo?.glbUrl != null &&
        _fortuneData!.avatar3dInfo!.glbUrl!.isNotEmpty &&
        (_fortuneData!.avatar3dInfo!.glbUrl!.startsWith('http://') ||
         _fortuneData!.avatar3dInfo!.glbUrl!.startsWith('https://'))) {
      debugPrint('[ModelManager] fortuneData.glbUrl 中已有 2D 图片 URL，跳过生成');
      return;
    }

    final visitorId = _visitorId;
    if (visitorId == null || visitorId.isEmpty) {
      // 理论上 init 已生成，这里兜底一次
      final prefs = await SharedPreferences.getInstance();
      _visitorId = prefs.getString(_visitorIdKey);
      if (_visitorId == null || _visitorId!.isEmpty) {
        _visitorId = _generateVisitorId();
        await prefs.setString(_visitorIdKey, _visitorId!);
      }
    }

    final prompt = _build2DImagePrompt();
    final promptHash = _stableHash(prompt);

    // 命中缓存（同prompt）则不重复调用
    if (_image2dUrl != null && _image2dUrl!.isNotEmpty && _image2dPromptHash == promptHash) {
      debugPrint('[ModelManager] 命中缓存，跳过生成');
      return;
    }

    debugPrint('[ModelManager] 开始生成 2D 图片');
    debugPrint('[ModelManager] 提示词: $prompt');
    
    _isGenerating2dImage = true;
    _image2dError = null;
    notifyListeners();

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final api = FortuneApiService();
      final resp = await api.generateImageSync(
        prompt: prompt,
        visitorId: _visitorId!,
        timestamp: now,
      );

      if (resp.success == true && resp.resultUrl != null && resp.resultUrl!.isNotEmpty) {
        _image2dUrl = resp.resultUrl;
        _image2dTaskId = resp.taskId;
        _image2dPromptHash = promptHash;
        
        debugPrint('[ModelManager] 2D 图片生成成功: $_image2dUrl');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _image2dCacheKey,
          jsonEncode({
            'url': _image2dUrl,
            'task_id': _image2dTaskId,
            'prompt_hash': _image2dPromptHash,
            'updated_at': now,
          }),
        );
      } else {
        _image2dError = resp.error ?? '生图失败（未返回结果URL）';
        debugPrint('[ModelManager] 2D 图片生成失败: $_image2dError');
      }
    } catch (e) {
      _image2dError = '生图异常: $e';
      debugPrint('[ModelManager] 2D 图片生成异常: $e');
    } finally {
      _isGenerating2dImage = false;
      notifyListeners();
    }
  }

  /// 保存用户八字数据
  Future<void> saveUserBaziData(Map<String, dynamic> baziData) async {
    // 转换 DateTime 和 TimeOfDay 为可序列化格式
    final serializableData = <String, dynamic>{
      'gender': baziData['gender'],
      'date': (baziData['date'] as DateTime).toIso8601String(),
      'hour': (baziData['time'] as dynamic).hour,
      'minute': (baziData['time'] as dynamic).minute,
    };

    _userBaziData = serializableData;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userBaziKey, jsonEncode(serializableData));
    notifyListeners();
  }

  /// 保存完整命盘数据（包含八字和紫薇计算结果）
  Future<void> saveFortuneData(FortuneData data) async {
    _fortuneData = data;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fortuneDataKey, data.toJsonString());
    notifyListeners();

    // ⚠️ 禁止自动触发生图接口
    // 生图接口只能在提交个人信息时触发（avatar_generation_screen.dart）
    // 命盘更新后，若当前处于2D模式，则自动刷新一次2D形象
    // if (_displayMode == DisplayMode.mode2D) {
    //   ensure2DImageGenerated();
    // }
  }

  /// 清除用户数据（用于重置）
  Future<void> clearUserData() async {
    _userBaziData = null;
    _fortuneData = null;
    _image2dUrl = null;
    _image2dTaskId = null;
    _image2dPromptHash = null;
    _image2dError = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userBaziKey);
    await prefs.remove(_fortuneDataKey);
    await prefs.remove(_image2dCacheKey);
    notifyListeners();
  }

  /// 下载远程 3D 模型到本地（解决 CORS 问题）
  /// 返回本地文件路径，如果下载失败返回 null
  Future<String?> downloadRemoteModel(
    String remoteUrl, {
    String? taskId,
    Function(double progress)? onProgress,
  }) async {
    try {
      debugPrint('[ModelManager] 开始下载模型: $remoteUrl');

      // 获取应用文档目录
      final appDir = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${appDir.path}/3d_models/downloaded');

      // 创建目录
      if (!await modelsDir.exists()) {
        await modelsDir.create(recursive: true);
      }

      // 生成文件名（使用 taskId 或 URL hash）
      final fileName = taskId != null
          ? '${taskId}_model.glb'
          : '${remoteUrl.hashCode.abs()}_model.glb';
      final localPath = '${modelsDir.path}/$fileName';
      final localFile = File(localPath);

      // 如果文件已存在且大小合理，直接返回
      if (await localFile.exists()) {
        final fileSize = await localFile.length();
        if (fileSize > 1024) {
          // 大于 1KB 认为是有效文件
          debugPrint('[ModelManager] 使用缓存文件: $localPath (${fileSize} bytes)');
          return localPath;
        }
      }

      // 下载文件
      final request = http.Request('GET', Uri.parse(remoteUrl));
      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        debugPrint('[ModelManager] 下载失败: ${response.statusCode}');
        return null;
      }

      // 获取文件总大小
      final contentLength = response.contentLength ?? 0;
      var downloadedBytes = 0;

      // 创建文件并写入
      final sink = localFile.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        downloadedBytes += chunk.length;

        // 报告进度
        if (contentLength > 0 && onProgress != null) {
          onProgress(downloadedBytes / contentLength);
        }
      }

      await sink.close();

      final finalSize = await localFile.length();
      debugPrint('[ModelManager] 下载完成: $localPath (${finalSize} bytes)');

      return localPath;
    } catch (e) {
      debugPrint('[ModelManager] 下载模型失败: $e');
      return null;
    }
  }

  /// 获取本地缓存的模型路径（如果存在）
  Future<String?> getCachedModelPath(String taskId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final localPath = '${appDir.path}/3d_models/downloaded/${taskId}_model.glb';
      final localFile = File(localPath);

      if (await localFile.exists()) {
        final fileSize = await localFile.length();
        if (fileSize > 1024) {
          return localPath;
        }
      }
    } catch (e) {
      debugPrint('[ModelManager] 检查缓存失败: $e');
    }
    return null;
  }

  /// 清除下载的模型缓存
  Future<void> clearDownloadedModels() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${appDir.path}/3d_models/downloaded');

      if (await modelsDir.exists()) {
        await modelsDir.delete(recursive: true);
        debugPrint('[ModelManager] 已清除下载的模型缓存');
      }
    } catch (e) {
      debugPrint('[ModelManager] 清除缓存失败: $e');
    }
  }

  /// 获取模型文件大小
  Future<String> getModelFileSize(Model3DConfig model) async {
    if (model.isAsset) {
      return '内置资源';
    }

    try {
      final file = File(model.path);
      if (await file.exists()) {
        final bytes = await file.length();
        if (bytes < 1024) {
          return '$bytes B';
        } else if (bytes < 1024 * 1024) {
          return '${(bytes / 1024).toStringAsFixed(1)} KB';
        } else {
          return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        }
      }
    } catch (e) {
      debugPrint('获取文件大小失败: $e');
    }
    return '未知';
  }
}
