import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';
import 'package:primordial_spirit/widgets/common/mystic_background.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '设置',
          style: GoogleFonts.notoSerifSc(
            color: AppTheme.deepVoidBlue,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.deepVoidBlue),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: MysticBackground(
        child: Consumer<ModelManagerService>(
          builder: (context, modelManager, child) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
              children: [
                // 显示模式设置
                _buildSectionTitle('显示模式'),
                const SizedBox(height: 12),
                GlassContainer(
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      _buildModeOption(modelManager, DisplayMode.mode3D, '3D 元灵', Icons.view_in_ar),
                      _buildModeOption(modelManager, DisplayMode.mode2D, '2D 平面', Icons.image),
                      _buildModeOption(modelManager, DisplayMode.live2D, 'Live2D', Icons.face),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

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

                // 生辰设置
                _buildSectionTitle('生辰信息'),
                const SizedBox(height: 12),
                _buildSettingTile(
                  icon: Icons.calendar_month,
                  title: '重新设置生辰',
                  subtitle: '修改出生日期、时辰和地点',
                  onTap: () => _navigateToBaziInput(),
                ),
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.notoSerifSc(
        fontSize: 18,
        fontWeight: FontWeight.bold, // Bolder
        color: AppTheme.deepVoidBlue, 
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.notoSerifSc(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.deepVoidBlue.withOpacity(0.8), // Darker
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildModeOption(
    ModelManagerService modelManager,
    DisplayMode mode,
    String label,
    IconData icon,
  ) {
    final isSelected = modelManager.displayMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () async => modelManager.setDisplayMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.jadeGreen.withOpacity(0.95) : Colors.transparent, // More solid
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
               color: isSelected ? AppTheme.jadeGreen : AppTheme.deepVoidBlue.withOpacity(0.1), // Solid border when selected
               width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.deepVoidBlue, // Full opacity unselected
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.notoSerifSc(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600, // Bolder
                  color: isSelected ? Colors.white : AppTheme.deepVoidBlue.withOpacity(0.9), // Darker unselected
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddModelButton(ModelManagerService modelManager) {
    return GlassContainer(
      width: double.infinity,
      borderRadius: BorderRadius.circular(20),
      onTap: _isLoading ? null : () => _pickAndAddModel(modelManager),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.jadeGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.jadeGreen,
                    ),
                  )
                : Icon(
                    Icons.add,
                    color: AppTheme.jadeGreen,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '添加 3D 模型',
                  style: GoogleFonts.notoSerifSc(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.deepVoidBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '支持 .glb, .gltf, .obj 格式',
                  style: GoogleFonts.notoSerifSc(
                    fontSize: 12,
                    color: AppTheme.deepVoidBlue.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.file_upload_outlined,
            color: AppTheme.deepVoidBlue.withOpacity(0.5),
          ),
        ],
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        onTap: () => modelManager.setSelectedModel(model.id),
        child: Row(
          children: [
            // 选中指示器
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.jadeGreen.withOpacity(0.25)
                    : AppTheme.deepVoidBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppTheme.jadeGreen : Colors.transparent,
                  width: isSelected ? 2.5 : 0, // Solid thick border
                ),
              ),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.view_in_ar,
                color: isSelected
                    ? AppTheme.jadeGreen
                    : AppTheme.deepVoidBlue.withOpacity(0.5),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),

            // 模型信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.name,
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: AppTheme.deepVoidBlue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildTag(
                        model.defaultAnimation != null ? '带动画' : '静态',
                        model.defaultAnimation != null
                            ? AppTheme.jadeGreen
                            : AppTheme.fluidGold,
                      ),
                      const SizedBox(width: 6),
                      _buildTag(
                        isBuiltIn ? '内置' : '自定义',
                        isBuiltIn ? AppTheme.celestialCyan : AppTheme.lotusPink,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 操作按钮
            if (!isBuiltIn)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: AppTheme.deepVoidBlue.withOpacity(0.5)),
                color: Colors.white.withOpacity(0.9),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (value) {
                  if (value == 'rename') {
                    _showRenameDialog(model, modelManager);
                  } else if (value == 'delete') {
                    _showDeleteConfirmDialog(model, modelManager);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 18),
                        const SizedBox(width: 8),
                        Text('重命名', style: GoogleFonts.notoSerifSc()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, size: 18, color: Colors.red),
                        const SizedBox(width: 8),
                        Text('删除', style: GoogleFonts.notoSerifSc(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.notoSerifSc(
          fontSize: 10,
          color: color, 
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  } 

// ... inside _buildSettingTile ...

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.deepVoidBlue.withOpacity(0.1), // Darker bg
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.deepVoidBlue, size: 24), // Full opacity
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSerifSc(
                    fontSize: 15, 
                    fontWeight: FontWeight.bold, // Bolder
                    color: AppTheme.deepVoidBlue,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSerifSc(
                    fontSize: 12,
                    color: AppTheme.deepVoidBlue.withOpacity(0.7), // Darker
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null) Icon(Icons.chevron_right, color: AppTheme.deepVoidBlue.withOpacity(0.5)),
        ],
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
                  backgroundColor: AppTheme.jadeGreen,
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
        backgroundColor: Colors.white,
        title: Text('模型名称', style: GoogleFonts.notoSerifSc(color: AppTheme.deepVoidBlue)),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.jadeGreen),
            child: const Text('确定', style: TextStyle(color: Colors.white)),
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
        backgroundColor: Colors.white,
        title: Text('重命名模型', style: GoogleFonts.notoSerifSc(color: AppTheme.deepVoidBlue)),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.jadeGreen),
            child: const Text('确定', style: TextStyle(color: Colors.white)),
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
            backgroundColor: success ? AppTheme.jadeGreen : Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToBaziInput() {
    // 跳转到生辰输入页，并清除之前的路由栈
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.baziInput,
      (route) => false,
    );
  }

  Future<void> _showDeleteConfirmDialog(
    Model3DConfig model,
    ModelManagerService modelManager,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('删除模型', style: GoogleFonts.notoSerifSc(color: AppTheme.deepVoidBlue)),
        content: Text('确定要删除模型 "${model.name}" 吗？\n此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除', style: TextStyle(color: Colors.white)),
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
            backgroundColor: success ? AppTheme.jadeGreen : Colors.red,
          ),
        );
      }
    }
  }
}
