import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';
import 'package:primordial_spirit/services/theme_service.dart';
import 'package:primordial_spirit/widgets/common/themed_background.dart';
import 'package:primordial_spirit/widgets/common/liquid_card.dart';
import 'package:primordial_spirit/widgets/common/mystic_button.dart';
import 'package:primordial_spirit/widgets/common/toast_overlay.dart';
import 'package:primordial_spirit/models/avatar_theme_config.dart';
import 'package:primordial_spirit/l10n/l10n.dart';

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
          context.l10n.settingsTitle,
          style: GoogleFonts.notoSerifSc(
            color: AppTheme.warmYellow,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.warmYellow),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ThemedBackground(
        child: Consumer2<ModelManagerService, ThemeService>(
          builder: (context, modelManager, themeService, child) {
            return ListView(
              padding: EdgeInsets.fromLTRB(AppTheme.spacingLg, 100, AppTheme.spacingLg, AppTheme.spacingLg),
              children: [
                // 显示模式设置
                _buildSectionTitle(context.l10n.displayModeSection),
                SizedBox(height: AppTheme.spacingMd),
                LiquidCard(
                  margin: EdgeInsets.zero,
                  compact: true,
                  child: Row(
                    children: [
                      _buildModeOption(
                        modelManager,
                        DisplayMode.mode3D,
                        context.l10n.displayMode3d,
                        Icons.view_in_ar,
                      ),
                      _buildModeOption(
                        modelManager,
                        DisplayMode.mode2D,
                        context.l10n.displayMode2d,
                        Icons.image,
                      ),
                      _buildModeOption(
                        modelManager,
                        DisplayMode.live2D,
                        context.l10n.displayModeLive2d,
                        Icons.face,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppTheme.spacingLg),

                // 主题设置
                _buildSectionTitle(context.l10n.themeSection),
                SizedBox(height: AppTheme.spacingMd),
                LiquidCard(
                  margin: EdgeInsets.zero,
                  compact: true,
                  child: Row(
                    children: [
                      _buildThemeOption(
                        themeService,
                        AvatarThemeMode.light,
                        context.l10n.themeLight,
                        Icons.light_mode,
                      ),
                      _buildThemeOption(
                        themeService,
                        AvatarThemeMode.dark,
                        context.l10n.themeDark,
                        Icons.dark_mode,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppTheme.spacingLg),

                // 3D 模型设置
                _buildSectionTitle(context.l10n.modelManagementSection),
                SizedBox(height: AppTheme.spacingMd),

                // 添加模型按钮
                _buildAddModelButton(modelManager),
                SizedBox(height: AppTheme.spacingMd),

                // 内置模型
                _buildSubSectionTitle(context.l10n.builtInModels),
                SizedBox(height: AppTheme.spacingSm),
                ...ModelManagerService.builtInModels.map(
                  (model) => _buildModelCard(model, modelManager, isBuiltIn: true),
                ),

                // 自定义模型
                if (modelManager.customModels.isNotEmpty) ...[
                  SizedBox(height: AppTheme.spacingMd),
                  _buildSubSectionTitle(context.l10n.customModels),
                  SizedBox(height: AppTheme.spacingSm),
                  ...modelManager.customModels.map(
                    (model) => _buildModelCard(model, modelManager, isBuiltIn: false),
                  ),
                ],

                SizedBox(height: AppTheme.spacingLg),


                // 生辰设置
                _buildSectionTitle(context.l10n.birthInfoSection),
                SizedBox(height: AppTheme.spacingMd),
                _buildSettingTile(
                  icon: Icons.calendar_month,
                  title: context.l10n.resetBirthInfo,
                  subtitle: context.l10n.resetBirthInfoSubtitle,
                  onTap: () => _navigateToBaziInput(),
                ),
                SizedBox(height: AppTheme.spacingLg),

                // 关于
                _buildSectionTitle(context.l10n.aboutSection),
                SizedBox(height: AppTheme.spacingMd),
                _buildSettingTile(
                  icon: Icons.info_outline,
                  title: context.l10n.versionLabel,
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
        color: AppTheme.warmYellow,
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
        color: AppTheme.warmYellow.withOpacity(0.85),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: AnimatedContainer(
              duration: Duration(milliseconds: AppTheme.animNormal),
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
              margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingXs),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.jadeGreen.withOpacity(0.9)
                    : AppTheme.liquidGlassLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.jadeGreen
                      : AppTheme.liquidGlassBorderSoft,
                  width: isSelected ? AppTheme.borderMedium : AppTheme.borderThin,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.jadeGreen.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Colors.white : AppTheme.inkText.withOpacity(0.9),
                    size: 24,
                  ),
                  SizedBox(height: AppTheme.spacingXs),
                  Text(
                    label,
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.inkText.withOpacity(0.92),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    ThemeService themeService,
    AvatarThemeMode mode,
    String label,
    IconData icon,
  ) {
    final isSelected = themeService.themeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () async => themeService.setThemeMode(mode),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: AnimatedContainer(
              duration: Duration(milliseconds: AppTheme.animNormal),
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
              margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingXs),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.jadeGreen.withOpacity(0.9)
                    : AppTheme.liquidGlassLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.jadeGreen
                      : AppTheme.liquidGlassBorderSoft,
                  width: isSelected ? AppTheme.borderMedium : AppTheme.borderThin,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.jadeGreen.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Colors.white : AppTheme.inkText.withOpacity(0.9),
                    size: 24,
                  ),
                  SizedBox(height: AppTheme.spacingXs),
                  Text(
                    label,
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.inkText.withOpacity(0.92),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddModelButton(ModelManagerService modelManager) {
    return GestureDetector(
      onTap: _isLoading ? null : () => _pickAndAddModel(modelManager),
      child: LiquidCard(
        margin: EdgeInsets.zero,
        accentColor: AppTheme.jadeGreen,
        compact: true,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.jadeGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: AppTheme.jadeGreen.withOpacity(0.3),
                  width: AppTheme.borderThin,
                ),
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
            SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.addModelTitle,
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.inkText,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingXs),
                  Text(
                    context.l10n.addModelFormatsHint,
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 12,
                      color: AppTheme.inkText.withOpacity(0.72),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.file_upload_outlined,
              color: AppTheme.amberGold.withOpacity(0.75),
            ),
          ],
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

    return GestureDetector(
      onTap: () => modelManager.setSelectedModel(model.id),
      child: Container(
        margin: EdgeInsets.only(bottom: AppTheme.spacingMd),
        child: LiquidMiniCard(
          accentColor: isSelected ? AppTheme.jadeGreen : null,
          child: Row(
            children: [
              // 选中指示器
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.jadeGreen.withOpacity(0.2)
                      : AppTheme.liquidGlassLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.jadeGreen
                        : AppTheme.liquidGlassBorderSoft,
                    width: isSelected ? AppTheme.borderMedium : AppTheme.borderThin,
                  ),
                ),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.view_in_ar,
                  color: isSelected
                      ? AppTheme.jadeGreen
                      : AppTheme.inkText.withOpacity(0.65),
                  size: 22,
                ),
              ),
              SizedBox(width: AppTheme.spacingMd),

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
                        color: isSelected ? AppTheme.warmYellow : AppTheme.inkText,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingSm),
                    Row(
                      children: [
                        LiquidInfoTag(
                          text: model.defaultAnimation != null
                              ? context.l10n.modelTagAnimated
                              : context.l10n.modelTagStatic,
                          color: model.defaultAnimation != null
                              ? AppTheme.jadeGreen
                              : AppTheme.fluidGold,
                        ),
                        SizedBox(width: AppTheme.spacingSm),
                        LiquidInfoTag(
                          text: isBuiltIn
                              ? context.l10n.modelTagBuiltIn
                              : context.l10n.modelTagCustom,
                          color: isBuiltIn ? AppTheme.fluorescentCyan : AppTheme.lotusPink,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 操作按钮
              if (!isBuiltIn)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppTheme.inkText.withOpacity(0.75)),
                  color: AppTheme.liquidGlassBase,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    side: BorderSide(
                      color: AppTheme.liquidGlassBorder,
                      width: AppTheme.borderThin,
                    ),
                  ),
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
                          SizedBox(width: AppTheme.spacingSm),
                          Text(
                            context.l10n.rename,
                            style: GoogleFonts.notoSerifSc(),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: AppTheme.spacingSm),
                          Text(
                            context.l10n.delete,
                            style: GoogleFonts.notoSerifSc(color: Colors.red),
                          ),
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

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidCard(
        margin: EdgeInsets.zero,
        compact: true,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: AppTheme.amberGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: AppTheme.amberGold.withOpacity(0.3),
                  width: AppTheme.borderThin,
                ),
              ),
              child: Icon(icon, color: AppTheme.amberGold.withOpacity(0.9), size: 24),
            ),
            SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 15, 
                      fontWeight: FontWeight.bold,
                      color: AppTheme.inkText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 12,
                      color: AppTheme.inkText.withOpacity(0.72),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: AppTheme.amberGold.withOpacity(0.7)),
          ],
        ),
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
            ToastOverlay.show(
              context,
              message: context.l10n.unsupportedModelFormat,
              backgroundColor: Colors.orange,
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
              ToastOverlay.show(
                context,
                message: context.l10n.modelAddSuccess(name),
                backgroundColor: AppTheme.jadeGreen,
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ToastOverlay.show(
          context,
          message: context.l10n.modelAddFailed(e.toString()),
          backgroundColor: Colors.red,
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingLg),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: AppTheme.blurLg, sigmaY: AppTheme.blurLg),
            child: Container(
              padding: EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: AppTheme.liquidGlassBase,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                border: Border.all(
                  color: AppTheme.liquidGlassBorder,
                  width: AppTheme.borderThin,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.jadeGreen.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.modelNameTitle,
                    style: GoogleFonts.notoSerifSc(
                      color: AppTheme.warmYellow,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingMd),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: context.l10n.modelNameHint,
                    ),
                    autofocus: true,
                  ),
                  SizedBox(height: AppTheme.spacingMd),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: AppTheme.spacingMd,
                    runSpacing: AppTheme.spacingMd,
                    children: [
                      MysticButton(
                        text: context.l10n.cancel,
                        isOutline: true,
                        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingMd),
                        fontSize: 14,
                        letterSpacing: 1.0,
                        onPressed: () => Navigator.pop(context),
                      ),
                      MysticButton(
                        text: context.l10n.confirm,
                        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingMd),
                        fontSize: 14,
                        letterSpacing: 1.0,
                        onPressed: () => Navigator.pop(context, controller.text),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingLg),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: AppTheme.blurLg, sigmaY: AppTheme.blurLg),
            child: Container(
              padding: EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: AppTheme.liquidGlassBase,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                border: Border.all(
                  color: AppTheme.liquidGlassBorder,
                  width: AppTheme.borderThin,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.jadeGreen.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.renameModelTitle,
                    style: GoogleFonts.notoSerifSc(
                      color: AppTheme.warmYellow,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingMd),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: context.l10n.renameModelHint,
                    ),
                    autofocus: true,
                  ),
                  SizedBox(height: AppTheme.spacingMd),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: AppTheme.spacingMd,
                    runSpacing: AppTheme.spacingMd,
                    children: [
                      MysticButton(
                        text: context.l10n.cancel,
                        isOutline: true,
                        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingMd),
                        fontSize: 14,
                        letterSpacing: 1.0,
                        onPressed: () => Navigator.pop(context),
                      ),
                      MysticButton(
                        text: context.l10n.confirm,
                        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingMd),
                        fontSize: 14,
                        letterSpacing: 1.0,
                        onPressed: () => Navigator.pop(context, controller.text),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != model.name) {
      final success = await modelManager.updateModelName(model.id, newName);
      if (mounted) {
        ToastOverlay.show(
          context,
          message: success
              ? context.l10n.renameSuccess
              : context.l10n.renameFailed,
          backgroundColor: success ? AppTheme.jadeGreen : Colors.red,
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingLg),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: AppTheme.blurLg, sigmaY: AppTheme.blurLg),
            child: Container(
              padding: EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: AppTheme.liquidGlassBase,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                border: Border.all(
                  color: AppTheme.liquidGlassBorder,
                  width: AppTheme.borderThin,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.amberGold.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.deleteModelTitle,
                    style: GoogleFonts.notoSerifSc(
                      color: AppTheme.warmYellow,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingSm),
                  Text(
                    context.l10n.deleteModelConfirm(model.name),
                    style: TextStyle(color: AppTheme.inkText.withOpacity(0.9), height: 1.4),
                  ),
                  SizedBox(height: AppTheme.spacingMd),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: AppTheme.spacingMd,
                    runSpacing: AppTheme.spacingMd,
                    children: [
                      MysticButton(
                        text: context.l10n.cancel,
                        isOutline: true,
                        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingMd),
                        fontSize: 14,
                        letterSpacing: 1.0,
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingMd),
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        child: Text(context.l10n.delete),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (confirmed == true) {
      final success = await modelManager.deleteCustomModel(model.id);
      if (mounted) {
        ToastOverlay.show(
          context,
          message: success
              ? context.l10n.deleteSuccess
              : context.l10n.deleteFailed,
          backgroundColor: success ? AppTheme.jadeGreen : Colors.red,
        );
      }
    }
  }
}

