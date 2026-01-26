// 登录与注册界面。
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/user_models.dart';
import 'package:primordial_spirit/services/auth_service.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/widgets/common/mystic_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isRegister = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorText = '请输入邮箱与密码');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      final authService = AuthService();
      if (_isRegister) {
        final displayName = _displayNameController.text.trim();
        await authService.register(
          email: email,
          password: password,
          profile: displayName.isNotEmpty
              ? UserProfile(displayName: displayName)
              : null,
        );
      } else {
        await authService.login(email: email, password: password);
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } catch (e) {
      // 移除 "Exception: " 前缀，直接显示错误信息
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      setState(() => _errorText = errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _isRegister ? '创建灵契' : '灵契入世',
          style: GoogleFonts.notoSerifSc(
            color: AppTheme.warmYellow,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: MysticBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSwitch(),
                    const SizedBox(height: 18),
                    Text(
                      _isRegister ? '以邮箱为引，缔结契印' : '凭灵契进入你的命盘',
                      style: GoogleFonts.notoSerifSc(
                        color: AppTheme.fluorescentCyan,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (_isRegister) ...[
                      TextField(
                        controller: _displayNameController,
                        style: GoogleFonts.notoSansSc(color: AppTheme.inkText),
                        decoration: const InputDecoration(
                          labelText: '称谓（可选）',
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.notoSansSc(color: AppTheme.inkText),
                      decoration: const InputDecoration(
                        labelText: '邮箱',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.notoSansSc(color: AppTheme.inkText),
                      decoration: InputDecoration(
                        labelText: '密码',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppTheme.fluorescentCyan,
                          ),
                          onPressed: () => setState(() {
                            _obscurePassword = !_obscurePassword;
                          }),
                        ),
                      ),
                    ),
                    if (_errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorText!,
                        style: GoogleFonts.notoSansSc(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppTheme.fluorescentCyan,
                        foregroundColor: AppTheme.primaryBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _isRegister ? '创建灵契' : '进入',
                              style: GoogleFonts.notoSerifSc(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch() {
    return Row(
      children: [
        Expanded(
          child: _buildSwitchButton(
            label: '登录',
            active: !_isRegister,
            onTap: () => setState(() => _isRegister = false),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSwitchButton(
            label: '注册',
            active: _isRegister,
            onTap: () => setState(() => _isRegister = true),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppTheme.warmYellow.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? AppTheme.warmYellow : AppTheme.scrollBorder,
            width: 0.9,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSerifSc(
            color: active ? AppTheme.warmYellow : AppTheme.inkText.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
