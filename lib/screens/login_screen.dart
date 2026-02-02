import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/services/auth_service.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/widgets/common/themed_background.dart';
import 'package:primordial_spirit/l10n/l10n.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Tab State
  bool _isPhoneLogin = true;

  // Controllers
  final _phoneController = TextEditingController();
  final _verifyCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
    super.dispose();
  }

  void _submit() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.loginAgreeRequired)),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    // Mock Login Logic for Layout Demo
    // In real app, connect to AuthService based on _isPhoneLogin
    try {
        await Future.delayed(const Duration(seconds: 1)); // Simulating network
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } catch (e) {
        // Error handling
    } finally {
        if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen size for responsiveness
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      // No AppBar, using custom title in body
      body: ThemedBackground(
        child: Stack(
          children: [
            // Safe Area for content
            SafeArea(
              child: SizedBox(
                height: size.height,
                width: size.width,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.12),
                      
                      // Title: 数字元神
                      Text(
                        context.l10n.loginTitle,
                        style: GoogleFonts.notoSerifSc(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.inkText, // Using theme color
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
                      
                      SizedBox(height: size.height * 0.08),

                      // Main Card
                      GlassContainer(
                        borderRadius: BorderRadius.circular(24),
                        // Adjust opacity/color to match the lighter card in screenshot
                        // We use the theme's surface but ensure it's readable
                        glowColor: AppTheme.fluorescentCyan.withOpacity(0.2),
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. Tabs (Phone / Email)
                            _buildLoginTabs(),
                            const SizedBox(height: 32),

                            // 2. Forms
                            if (_isPhoneLogin) _buildPhoneForm() else _buildEmailForm(),

                            const SizedBox(height: 16),

                            // 3. Agreement Checkbox
                            _buildAgreementCheckbox(),

                            const SizedBox(height: 24),

                            // 4. Login Button
                            _buildLoginButton(),

                            const SizedBox(height: 16),

                            // 5. Register Link
                            _buildRegisterLink(),
                            
                            const SizedBox(height: 32),
                            
                            // 6. Social Icons
                            _buildSocialIcons(),
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

  Widget _buildLoginTabs() {
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
              title: context.l10n.loginPhoneTab,
              isActive: _isPhoneLogin,
              onTap: () => setState(() => _isPhoneLogin = true),
            ),
          ),
          Expanded(
            child: _buildTabItem(
              title: context.l10n.loginEmailTab,
              isActive: !_isPhoneLogin,
              onTap: () => setState(() => _isPhoneLogin = false),
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

  Widget _buildPhoneForm() {
    return Column(
      children: [
        // Phone Input with Country Code
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.spiritGlass.withOpacity(0.5),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppTheme.scrollBorder.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              // Country Code
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
                    hintText: context.l10n.loginPhoneHint,
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
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.spiritGlass.withOpacity(0.5),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppTheme.scrollBorder.withOpacity(0.5)),
          ),
          padding: const EdgeInsets.only(right: 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _verifyCodeController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.notoSansSc(color: AppTheme.inkText),
                  decoration: InputDecoration(
                    hintText: context.l10n.loginCodeHint,
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
                  onPressed: () {
                    // Send code logic
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    context.l10n.loginGetCode,
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
        // Email Input
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.spiritGlass.withOpacity(0.5),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppTheme.scrollBorder.withOpacity(0.5)),
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.notoSansSc(color: AppTheme.inkText),
            decoration: InputDecoration(
              hintText: context.l10n.loginEmailHint,
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
        // Password Input
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.spiritGlass.withOpacity(0.5),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppTheme.scrollBorder.withOpacity(0.5)),
          ),
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.notoSansSc(color: AppTheme.inkText),
                  decoration: InputDecoration(
                    hintText: context.l10n.loginPasswordHint,
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
                onTap: () {
                   // Forgot Password Logic
                },
                child: Text(
                  context.l10n.loginForgotPassword,
                  style: GoogleFonts.notoSansSc(
                    color: AppTheme.inkText.withOpacity(0.6),
                    fontSize: 13,
                  ),
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
            padding: const EdgeInsets.only(top: 4), // Align with checkbox visual center
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.notoSansSc(
                  color: AppTheme.inkText.withOpacity(0.6),
                  fontSize: 12,
                ),
                children: [
                  TextSpan(text: context.l10n.loginAgreementPrefix),
                  TextSpan(
                    text: context.l10n.loginUserAgreement,
                    style: TextStyle(
                      color: AppTheme.electricBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: context.l10n.loginPrivacyPolicy,
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

  Widget _buildLoginButton() {
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
                context.l10n.loginButton,
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

  Widget _buildRegisterLink() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.register);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.loginNoAccount,
            style: GoogleFonts.notoSansSc(
              color: AppTheme.inkText.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            context.l10n.loginRegisterNow,
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

  Widget _buildSocialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialIcon(Icons.chat_bubble_outline), // WeChat placeholder
        const SizedBox(width: 32),
        _socialIcon(Icons.catching_pokemon_outlined), // QQ placeholder (Tencent penguin-ish)
        const SizedBox(width: 32),
        _socialIcon(Icons.apple), // Apple
      ],
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.5), // Glassy white
        border: Border.all(color: AppTheme.scrollBorder.withOpacity(0.3)),
      ),
      child: Icon(
        icon,
        color: AppTheme.inkText.withOpacity(0.8),
        size: 24,
      ),
    );
  }
}
