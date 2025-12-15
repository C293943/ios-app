import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';

/// 设置页面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ModelManagerService>(
        builder: (context, modelManager, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 3D 模型设置
              _buildSectionTitle('3D 模型管理'),
              const SizedBox(height: 12),

              // 添加模型按钮
              _buildAddModelButton(modelManager),
              const SizedBox(height: 16),

              // 内置模型
              _buildSubSectionTitle('内置模型'),
              const SizedBox(height: 8),
              ...ModelManagerService.builtInModels.map(
                (model) => _buildModelCard(model, modelManager, isBuiltIn: true),
              ),

              // 自定义模型
              if (modelManager.customModels.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSubSectionTitle('自定义模型'),
                const SizedBox(height: 8),
                ...modelManager.customModels.map(
                  (model) => _buildModelCard(model, modelManager, isBuiltIn: false),
                ),
              ],

              const SizedBox(height: 24),

              // 关于
              _buildSectionTitle('关于'),
              const SizedBox(height: 12),
              _buildSettingTile(
                icon: Icons.info_outline,
                title: '版本',
                subtitle: '1.0.0',
                onTap: null,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.purple.shade700,
      ),
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildAddModelButton(ModelManagerService modelManager) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _isLoading ? null : () => _pickAndAddModel(modelManager),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.purple.shade400,
                        ),
                      )
                    : Icon(
                        Icons.add,
                        color: Colors.purple.shade400,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '添加 3D 模型',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '支持 .glb, .gltf, .obj 格式',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.file_upload_outlined,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelCard(
    Model3DConfig model,
    ModelManagerService modelManager, {
    required bool isBuiltIn,
  }) {
    final isSelected = modelManager.selectedModelId == model.id ||
        (modelManager.selectedModelId == null && model.id == 'builtin_1');

    return Card(
      elevation: isSelected ? 3 : 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.purple.shade400 : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => modelManager.setSelectedModel(model.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 选中指示器
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.purple.shade100
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.view_in_ar,
                  color: isSelected
                      ? Colors.purple.shade400
                      : Colors.grey.shade400,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // 模型信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildTag(
                          model.defaultAnimation != null ? '带动画' : '静态',
                          model.defaultAnimation != null
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        _buildTag(
                          isBuiltIn ? '内置' : '自定义',
                          isBuiltIn ? Colors.blue : Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 操作按钮
              if (!isBuiltIn)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
                  onSelected: (value) {
                    if (value == 'rename') {
                      _showRenameDialog(model, modelManager);
                    } else if (value == 'delete') {
                      _showDeleteConfirmDialog(model, modelManager);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('重命名'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('删除', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.purple.shade400),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }

  Future<void> _pickAndAddModel(ModelManagerService modelManager) async {
    setState(() => _isLoading = true);

    try {
      // 使用 FileType.any 因为 Android 不支持 .glb/.gltf/.obj 的 MIME 类型
      // 然后在代码中手动验证文件扩展名
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;

        // 手动检查文件扩展名
        final extension = fileName.split('.').last.toLowerCase();
        final supportedExtensions = ['glb', 'gltf', 'obj'];

        if (!supportedExtensions.contains(extension)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('不支持的文件格式，请选择 .glb, .gltf 或 .obj 文件'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        // 显示命名对话框
        if (mounted) {
          final name = await _showNameInputDialog(fileName);
          if (name != null && name.isNotEmpty) {
            final model = await modelManager.addCustomModel(
              name: name,
              sourcePath: filePath,
            );

            if (model != null && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('模型 "$name" 添加成功'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('添加模型失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> _showNameInputDialog(String defaultName) async {
    final controller = TextEditingController(
      text: defaultName.replaceAll(RegExp(r'\.(glb|gltf|obj)$'), ''),
    );

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('模型名称'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '请输入模型名称',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameDialog(
    Model3DConfig model,
    ModelManagerService modelManager,
  ) async {
    final controller = TextEditingController(text: model.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名模型'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '请输入新名称',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != model.name) {
      final success = await modelManager.updateModelName(model.id, newName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '重命名成功' : '重命名失败'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmDialog(
    Model3DConfig model,
    ModelManagerService modelManager,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除模型'),
        content: Text('确定要删除模型 "${model.name}" 吗？\n此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await modelManager.deleteCustomModel(model.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '删除成功' : '删除失败'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
