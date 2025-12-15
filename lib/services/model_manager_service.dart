import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  List<Model3DConfig> _customModels = [];
  String? _selectedModelId;
  bool _isInitialized = false;

  /// 内置模型列表
  static final List<Model3DConfig> builtInModels = [
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

    _isInitialized = true;
    notifyListeners();
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
