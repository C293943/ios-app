import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/user_models.dart';
import 'package:primordial_spirit/services/auth_service.dart';
import 'package:primordial_spirit/widgets/common/themed_background.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/l10n/l10n.dart';

enum VoiceOption {
  defaultFemale,
  gentleFemale,
  magneticMale,
}

/// 个人信息页面
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  VoiceOption _selectedVoice = VoiceOption.defaultFemale;
  final AuthService _authService = AuthService();
  AppUser? _user;
  UserProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _authService.fetchProfile(preferCache: true);
    final user = await _authService.loadCachedUser();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _user = user;
      _loading = false;
    });

    final remote = await _authService.fetchProfile(preferCache: false);
    if (!mounted || remote == null) return;
    setState(() => _profile = remote);
  }

  String get _userIdLabel {
    if (_loading) return context.l10n.syncing;
    final id = _user?.id ?? '';
    if (id.isEmpty) return context.l10n.notLoggedIn;
    return id.length > 10 ? id.substring(0, 10).toUpperCase() : id.toUpperCase();
  }

  String get _emailLabel {
    if (_loading) return context.l10n.syncing;
    return _user?.email ?? context.l10n.notLoggedIn;
  }

  String get _profileStatusLabel {
    if (_loading) return context.l10n.syncing;
    if (_profile == null) return context.l10n.notSet;
    return _profile?.displayName?.isNotEmpty == true
        ? context.l10n.profileStatusSet
        : context.l10n.profileStatusSynced;
  }

  String get _profileSyncLabel {
    if (_loading) return context.l10n.syncing;
    return _profile?.updatedAt ?? context.l10n.notSynced;
  }

  String _voiceLabel(BuildContext context, VoiceOption option) {
    switch (option) {
      case VoiceOption.defaultFemale:
        return context.l10n.voiceDefaultFemale;
      case VoiceOption.gentleFemale:
        return context.l10n.voiceGentleFemale;
      case VoiceOption.magneticMale:
        return context.l10n.voiceMagneticMale;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          context.l10n.profileTitle,
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
          children: [
            // 用户编号
            _buildProfileItem(
              icon: Icons.person_outline,
              label: context.l10n.profileUserId,
              value: _userIdLabel,
            ),
            const SizedBox(height: 12),

            // 账号邮箱
            _buildProfileItem(
              icon: Icons.alternate_email,
              label: context.l10n.profileEmail,
              value: _emailLabel,
            ),
            const SizedBox(height: 12),

            // 用户等级
            _buildProfileItem(
              icon: Icons.star_outline,
              label: context.l10n.profileLevel,
              value: context.l10n.profileLevelValue,
            ),
            const SizedBox(height: 12),

            // 档案
            _buildProfileItem(
              icon: Icons.description_outlined,
              label: context.l10n.profileArchive,
              value: _profileStatusLabel,
              onTap: () => _showArchiveDialog(context),
            ),
            const SizedBox(height: 12),

            // 同步时间
            _buildProfileItem(
              icon: Icons.sync,
              label: context.l10n.profileSyncTime,
              value: _profileSyncLabel,
            ),
            const SizedBox(height: 12),

            // 会员充值
            _buildProfileItem(
              icon: Icons.card_giftcard,
              label: context.l10n.profileRecharge,
              value: context.l10n.profileRechargeAction,
              onTap: () => _showRechargeDialog(context),
            ),
            const SizedBox(height: 12),

            // 语音选择
            _buildProfileItem(
              icon: Icons.volume_up_outlined,
              label: context.l10n.profileVoice,
              value: _voiceLabel(context, _selectedVoice),
              onTap: () => _showVoiceDialog(context),
            ),
            const SizedBox(height: 12),

            // 用户反馈
            _buildProfileItem(
              icon: Icons.feedback_outlined,
              label: context.l10n.profileFeedback,
              value: context.l10n.profileFeedbackAction,
              onTap: () => _showFeedbackDialog(context),
            ),
            const SizedBox(height: 12),

            // 隐私协议
            _buildProfileItem(
              icon: Icons.privacy_tip_outlined,
              label: context.l10n.profilePrivacy,
              value: context.l10n.viewAction,
              onTap: () => _showPrivacyDialog(context),
            ),
            const SizedBox(height: 12),

            // 充值协议
            _buildProfileItem(
              icon: Icons.receipt_outlined,
              label: context.l10n.profileRechargeAgreement,
              value: context.l10n.viewAction,
              onTap: () => _showRechargeAgreementDialog(context),
            ),
            const SizedBox(height: 12),

            // 用户协议
            _buildProfileItem(
              icon: Icons.description,
              label: context.l10n.profileUserAgreement,
              value: context.l10n.viewAction,
              onTap: () => _showUserAgreementDialog(context),
            ),
            const SizedBox(height: 12),

            // 退出登录
            _buildProfileItem(
              icon: Icons.logout,
              label: context.l10n.logout,
              value: context.l10n.logoutAction,
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GlassContainer(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.warmYellow, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.notoSerifSc(
                      color: AppTheme.warmYellow,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.notoSerifSc(
                    color: AppTheme.fluorescentCyan,
                    fontSize: 13,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios,
                    color: AppTheme.fluorescentCyan,
                    size: 14,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showArchiveDialog(BuildContext context) {
    if (_profile == null) {
      _showProfileEditDialog(context);
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.voidBackground.withValues(alpha: 0.9),
        title: Text(
          context.l10n.profileArchiveTitle,
          style: GoogleFonts.notoSerifSc(color: AppTheme.warmYellow),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogItem(
                context.l10n.profileNameLabel,
                _profile?.displayName ?? context.l10n.notSet,
              ),
              _buildDialogItem(
                context.l10n.profileGenderLabel,
                _profile?.gender ?? context.l10n.notSet,
              ),
              _buildDialogItem(
                context.l10n.profileBirthCityLabel,
                _profile?.birthCity ?? context.l10n.notSet,
              ),
              _buildDialogItem(
                context.l10n.profileBirthTimeLabel,
                _birthDateLabel(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.close,
              style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showProfileEditDialog(context);
            },
            child: Text(
              context.l10n.edit,
              style: GoogleFonts.notoSerifSc(color: AppTheme.warmYellow),
            ),
          ),
        ],
      ),
    );
  }

  String _birthDateLabel() {
    if (_profile == null) return context.l10n.birthDatePlaceholder;
    final year = _profile?.birthYear;
    final month = _profile?.birthMonth;
    final day = _profile?.birthDay;
    final hour = _profile?.birthHour;
    final minute = _profile?.birthMinute;
    if (year == null || month == null || day == null || hour == null || minute == null) {
      return context.l10n.notSet;
    }
    final mm = minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$mm';
  }

  void _showProfileEditDialog(BuildContext context) {
    final nameController =
        TextEditingController(text: _profile?.displayName ?? '');
    final genderController =
        TextEditingController(text: _profile?.gender ?? '');
    final cityController =
        TextEditingController(text: _profile?.birthCity ?? '');
    final yearController = TextEditingController(
        text: _profile?.birthYear?.toString() ?? '');
    final monthController = TextEditingController(
        text: _profile?.birthMonth?.toString() ?? '');
    final dayController = TextEditingController(
        text: _profile?.birthDay?.toString() ?? '');
    final hourController = TextEditingController(
        text: _profile?.birthHour?.toString() ?? '');
    final minuteController = TextEditingController(
        text: _profile?.birthMinute?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.voidBackground.withValues(alpha: 0.92),
        title: Text(
          context.l10n.profileEditTitle,
          style: GoogleFonts.notoSerifSc(color: AppTheme.warmYellow),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(nameController, context.l10n.profileNameLabel),
              _buildTextField(genderController, context.l10n.profileGenderHint),
              _buildTextField(cityController, context.l10n.profileBirthCityLabel),
              _buildTextField(yearController, context.l10n.profileBirthYearLabel),
              _buildTextField(monthController, context.l10n.profileBirthMonthLabel),
              _buildTextField(dayController, context.l10n.profileBirthDayLabel),
              _buildTextField(hourController, context.l10n.profileBirthHourLabel),
              _buildTextField(minuteController, context.l10n.profileBirthMinuteLabel),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.cancel,
              style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
            ),
          ),
          TextButton(
            onPressed: () async {
              final updated = UserProfile(
                displayName: nameController.text.trim().isEmpty
                    ? null
                    : nameController.text.trim(),
                gender: genderController.text.trim().isEmpty
                    ? null
                    : genderController.text.trim(),
                birthCity: cityController.text.trim().isEmpty
                    ? null
                    : cityController.text.trim(),
                birthYear: _parseInt(yearController.text),
                birthMonth: _parseInt(monthController.text),
                birthDay: _parseInt(dayController.text),
                birthHour: _parseInt(hourController.text),
                birthMinute: _parseInt(minuteController.text),
              );

              final result = await _authService.updateProfile(updated);
              if (!mounted) return;
              if (result != null) {
                setState(() => _profile = result);
                Navigator.pop(context);
              }
            },
            child: Text(
              context.l10n.save,
              style: GoogleFonts.notoSerifSc(color: AppTheme.warmYellow),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: GoogleFonts.notoSansSc(color: AppTheme.inkText),
        decoration: InputDecoration(
          labelText: label,
        ),
      ),
    );
  }

  int? _parseInt(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.voidBackground.withValues(alpha: 0.9),
        title: Text(
          context.l10n.logout,
          style: GoogleFonts.notoSerifSc(color: AppTheme.warmYellow),
        ),
        content: Text(
          context.l10n.logoutConfirm,
          style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.cancel,
              style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _authService.logout();
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
            child: Text(
              context.l10n.logoutAction,
              style: GoogleFonts.notoSerifSc(color: AppTheme.warmYellow),
            ),
          ),
        ],
      ),
    );
  }

  void _showRechargeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.voidBackground.withValues(alpha: 0.9),
        title: Text(
          context.l10n.profileRecharge,
          style: GoogleFonts.notoSerifSc(color: AppTheme.warmYellow),
        ),
        content: Text(
          context.l10n.featureInProgress,
          style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.confirm,
              style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
            ),
          ),
        ],
      ),
    );
  }

  void _showVoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.voidBackground.withValues(alpha: 0.9),
        title: Text(
          context.l10n.voiceSelectionTitle,
          style: GoogleFonts.notoSerifSc(color: AppTheme.warmYellow),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildVoiceOption(VoiceOption.defaultFemale),
            _buildVoiceOption(VoiceOption.gentleFemale),
            _buildVoiceOption(VoiceOption.magneticMale),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.confirm,
              style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceOption(VoiceOption voice) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Radio<VoiceOption>(
            value: voice,
            groupValue: _selectedVoice,
            onChanged: (value) {
              setState(() => _selectedVoice = value ?? VoiceOption.defaultFemale);
              Navigator.pop(context);
            },
            activeColor: AppTheme.fluorescentCyan,
          ),
          Text(
            _voiceLabel(context, voice),
            style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.voidBackground.withValues(alpha: 0.9),
        title: Text(
          context.l10n.profileFeedback,
          style: GoogleFonts.notoSerifSc(color: AppTheme.warmYellow),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
          decoration: InputDecoration(
            hintText: context.l10n.feedbackHint,
            hintStyle: GoogleFonts.notoSerifSc(
              color: AppTheme.fluorescentCyan.withValues(alpha: 0.5),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.fluorescentCyan),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.cancel,
              style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.submit,
              style: GoogleFonts.notoSerifSc(color: AppTheme.warmYellow),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    _showAgreementDialog(
      context,
      context.l10n.privacyAgreementTitle,
      _getPrivacyContent(),
    );
  }

  void _showRechargeAgreementDialog(BuildContext context) {
    _showAgreementDialog(
      context,
      context.l10n.rechargeAgreementTitle,
      _getRechargeAgreementContent(),
    );
  }

  void _showUserAgreementDialog(BuildContext context) {
    _showAgreementDialog(
      context,
      context.l10n.userAgreementTitle,
      _getUserAgreementContent(),
    );
  }

  void _showAgreementDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.voidBackground.withValues(alpha: 0.9),
        title: Text(
          title,
          style: GoogleFonts.notoSerifSc(color: AppTheme.warmYellow),
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: GoogleFonts.notoSerifSc(
              color: AppTheme.fluorescentCyan,
              fontSize: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.close,
              style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
            ),
          ),
        ],
      ),
    );
  }

  String _getPrivacyContent() {
    return context.l10n.privacyPolicyContent;
  }

  String _getRechargeAgreementContent() {
    return context.l10n.rechargeAgreementContent;
  }

  String _getUserAgreementContent() {
    return context.l10n.userAgreementContent;
  }

  Widget _buildDialogItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.notoSerifSc(
              color: AppTheme.warmYellow,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
            ),
          ),
        ],
      ),
    );
  }
}

