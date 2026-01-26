// 路由守卫：未登录时跳转到登录页。
import 'package:flutter/material.dart';

import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/services/auth_service.dart';
import 'package:primordial_spirit/widgets/common/mystic_background.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;
  final String redirectRoute;

  const AuthGuard({
    super.key,
    required this.child,
    this.redirectRoute = AppRoutes.login,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _allowed = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final hasSession = await AuthService().hasSession();
    if (!mounted) return;
    if (!hasSession) {
      Navigator.of(context).pushReplacementNamed(widget.redirectRoute);
      return;
    }
    setState(() => _allowed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_allowed) {
      return widget.child;
    }
    return Scaffold(
      body: MysticBackground(
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.fluorescentCyan,
            backgroundColor: AppTheme.scrollBorder,
          ),
        ),
      ),
    );
  }
}
