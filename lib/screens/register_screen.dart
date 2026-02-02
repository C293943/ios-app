import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/widgets/common/themed_background.dart';

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
        const SnackBar(content: Text('请先阅读并同意用户协议')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    // Mock Register Logic
    try {
        await Future.delayed(const Duration(seconds: 1)); // Simulating network
        if (!mounted) return;
        // After register, maybe go to home or back to login? 
        // Usually go to Home or Profile setup
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } catch (e) {
        // Error handling
    } finally {
        if (mounted) setState(() => _isSubmitting = false);
    }
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
                        '数字元神',
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
            child: _buildTabItem(title: '手机注册', isActive: _isPhoneRegister, onTap: () => setState(() => _isPhoneRegister = true)),
          ),
          Expanded(
            child: _buildTabItem(title: '邮箱注册', isActive: !_isPhoneRegister, onTap: () => setState(() => _isPhoneRegister = false)),
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
              hintText: '请输入称谓/道号',
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
                    hintText: '请输入手机号',
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
                    hintText: '请输入验证码',
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
                    '获取验证码',
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
              hintText: '请输入称谓/道号',
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
              hintText: '请输入邮箱',
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
                    hintText: '设置密码',
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
                  const TextSpan(text: '我已阅读并同意 '),
                  TextSpan(
                    text: '《用户协议》',
                    style: TextStyle(color: AppTheme.electricBlue, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: '《隐私政策》',
                    style: TextStyle(color: AppTheme.electricBlue, fontWeight: FontWeight.bold),
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
                '立即注册',
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
            '已有账号? ',
            style: GoogleFonts.notoSansSc(
              color: AppTheme.inkText.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            '立即登录',
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
