import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/user_models.dart';
import 'package:primordial_spirit/services/auth_service.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/widgets/common/themed_background.dart';
import 'package:primordial_spirit/l10n/l10n.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Tab State
  bool _isPhoneRegister = true;

  // Controllers
  final _phoneController = TextEditingController();
  final _verifyCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController(); // For "称谓"

  // Logic State
  bool _agreedToTerms = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _verifyCodeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.registerAgreeRequired)),
      );
      return;
    }

    // 根据注册方式进行验证
    final nickname = _nicknameController.text.trim();
    
    if (_isPhoneRegister) {
      // 手机注册验证
      final phone = _phoneController.text.trim();
      final code = _verifyCodeController.text.trim();
      if (nickname.isEmpty) {
        _showError(context.l10n.registerNicknameHint);
        return;
      }
      if (phone.isEmpty) {
        _showError(context.l10n.registerPhoneHint);
        return;
      }
      if (code.isEmpty) {
        _showError(context.l10n.registerCodeHint);
        return;
      }
      // TODO: 后端暂不支持手机验证码注册，提示用户使用邮箱注册
      _showError('手机注册功能开发中，请使用邮箱注册');
      return;
    } else {
      // 邮箱注册验证
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (nickname.isEmpty) {
        _showError(context.l10n.registerNicknameHint);
        return;
      }
      if (email.isEmpty) {
        _showError(context.l10n.registerEmailHint);
        return;
      }
      if (!_isValidEmail(email)) {
        _showError('请输入有效的邮箱地址');
        return;
      }
      if (password.isEmpty) {
        _showError(context.l10n.registerPasswordHint);
        return;
      }
      if (password.length < 6) {
        _showError('密码至少需要6位');
        return;
      }
    }

    setState(() => _isSubmitting = true);
    
    try {
      // 调用 AuthService 进行邮箱注册
      final authService = AuthService();
      final profile = UserProfile(displayName: nickname);
      
      await authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        profile: profile,
      );
      
      if (!mounted) return;
      // 注册成功后跳转到首页
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      // 提取错误信息
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }
      _showError(errorMsg);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: ThemedBackground(
        child: Stack(
          children: [
            SafeArea(
              child: SizedBox(
                height: size.height,
                width: size.width,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Back Button
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: AppTheme.inkText),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      
                      SizedBox(height: size.height * 0.05),
                      
                      // Title
                      Text(
                        context.l10n.registerTitle,
                        style: GoogleFonts.notoSerifSc(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.inkText,
                          letterSpacing: 2,
                          shadows: [
                            BoxShadow(
                              color: AppTheme.fluorescentCyan.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            )
                          ]
                        ),
                      ),
                      
                      SizedBox(height: size.height * 0.05),

                      // Main Card
                      GlassContainer(
                        borderRadius: BorderRadius.circular(24),
                        glowColor: AppTheme.jadeGreen.withOpacity(0.2), // Slightly different glow for register maybe? Or keep consistent.
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                             // 1. Tabs
                            _buildRegisterTabs(),
                            const SizedBox(height: 32),

                            // 2. Forms
                            // Added Nickname field common to both or specific? Usually common.
                            // Let's put nickname inside the specific forms or common at top if needed.
                            // Design wise, let's keep it simple.
                            if (_isPhoneRegister) _buildPhoneForm() else _buildEmailForm(),

                            const SizedBox(height: 16),

                            // 3. Agreement
                            _buildAgreementCheckbox(),

                            const SizedBox(height: 24),

                            // 4. Register Button
                            _buildRegisterButton(),

                            const SizedBox(height: 16),

                            // 5. Login Link
                            _buildLoginLink(),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterTabs() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppTheme.inkText.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              title: context.l10n.registerPhoneTab,
              isActive: _isPhoneRegister,
              onTap: () => setState(() => _isPhoneRegister = true),
            ),
          ),
          Expanded(
            child: _buildTabItem(
              title: context.l10n.registerEmailTab,
              isActive: !_isPhoneRegister,
              onTap: () => setState(() => _isPhoneRegister = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({required String title, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.scrollPaper : Colors.transparent,
          borderRadius: BorderRadius.circular(21),
          boxShadow: isActive ? [
             BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Text(
          title,
          style: GoogleFonts.notoSansSc(
            color: isActive ? AppTheme.inkText : AppTheme.inkText.withOpacity(0.5),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildInputContainer({required Widget child, double paddingRight = 0}) {
     return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppTheme.spiritGlass.withOpacity(0.5),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.scrollBorder.withOpacity(0.5)),
      ),
      padding: EdgeInsets.only(right: paddingRight),
      child: child,
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      children: [
        // Nickname
        _buildInputContainer(
          child: TextField(
            controller: _nicknameController,
            style: GoogleFonts.notoSansSc(color: AppTheme.inkText),
            decoration: InputDecoration(
              hintText: context.l10n.registerNicknameHint,
              hintStyle: GoogleFonts.notoSansSc(color: AppTheme.inkText.withOpacity(0.4)),
              icon: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(Icons.person_outline, color: AppTheme.inkText.withOpacity(0.4), size: 20),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              filled: false,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Phone
        _buildInputContainer(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Row(
                  children: [
                    Text('🇨🇳 +86', style: GoogleFonts.notoSansSc(color: AppTheme.inkText, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, color: AppTheme.inkText.withOpacity(0.5), size: 20),
                  ],
                ),
              ),
              Container(width: 1, height: 24, color: AppTheme.scrollBorder.withOpacity(0.5)),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.notoSansSc(color: AppTheme.inkText),
                  decoration: InputDecoration(
                    hintText: context.l10n.registerPhoneHint,
                    hintStyle: GoogleFonts.notoSansSc(color: AppTheme.inkText.withOpacity(0.4)),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    filled: false,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Verification Code
        _buildInputContainer(
          paddingRight: 6,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _verifyCodeController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.notoSansSc(color: AppTheme.inkText),
                  decoration: InputDecoration(
                    hintText: context.l10n.registerCodeHint,
                    hintStyle: GoogleFonts.notoSansSc(color: AppTheme.inkText.withOpacity(0.4)),
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Icon(Icons.lock_outline, color: AppTheme.inkText.withOpacity(0.4), size: 20),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    filled: false,
                  ),
                ),
              ),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.fluorescentCyan.withOpacity(0.8),
                      AppTheme.electricBlue.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    context.l10n.registerGetCode,
                    style: GoogleFonts.notoSansSc(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Column(
      children: [
         // Nickname
        _buildInputContainer(
          child: TextField(
            controller: _nicknameController,
            style: GoogleFonts.notoSansSc(color: AppTheme.inkText),
            decoration: InputDecoration(
              hintText: context.l10n.registerNicknameHint,
              hintStyle: GoogleFonts.notoSansSc(color: AppTheme.inkText.withOpacity(0.4)),
              icon: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(Icons.person_outline, color: AppTheme.inkText.withOpacity(0.4), size: 20),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              filled: false,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Email
        _buildInputContainer(
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.notoSansSc(color: AppTheme.inkText),
            decoration: InputDecoration(
              hintText: context.l10n.registerEmailHint,
              hintStyle: GoogleFonts.notoSansSc(color: AppTheme.inkText.withOpacity(0.4)),
              icon: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(Icons.email_outlined, color: AppTheme.inkText.withOpacity(0.4), size: 20),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              filled: false,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Password
        _buildInputContainer(
          paddingRight: 16,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.notoSansSc(color: AppTheme.inkText),
                  decoration: InputDecoration(
                    hintText: context.l10n.registerPasswordHint,
                    hintStyle: GoogleFonts.notoSansSc(color: AppTheme.inkText.withOpacity(0.4)),
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Icon(Icons.lock_outline, color: AppTheme.inkText.withOpacity(0.4), size: 20),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    filled: false,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                child: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.inkText.withOpacity(0.4),
                  size: 20,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgreementCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
            activeColor: AppTheme.fluorescentCyan,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: BorderSide(color: AppTheme.inkText.withOpacity(0.3)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.notoSansSc(
                  color: AppTheme.inkText.withOpacity(0.6),
                  fontSize: 12,
                ),
                children: [
                  TextSpan(text: context.l10n.registerAgreementPrefix),
                  TextSpan(
                    text: context.l10n.registerUserAgreement,
                    style: TextStyle(
                      color: AppTheme.electricBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: context.l10n.registerPrivacyPolicy,
                    style: TextStyle(
                      color: AppTheme.electricBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.fluorescentCyan,
            AppTheme.electricBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppTheme.electricBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                context.l10n.registerButton,
                style: GoogleFonts.notoSansSc(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(), // Go back to Login
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.registerHasAccount,
            style: GoogleFonts.notoSansSc(
              color: AppTheme.inkText.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            context.l10n.registerLoginNow,
            style: GoogleFonts.notoSansSc(
              color: AppTheme.electricBlue,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
