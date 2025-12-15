import 'package:flutter/material.dart';
import 'package:primordial_spirit/screens/splash_screen.dart';
import 'package:primordial_spirit/screens/bazi_input_screen.dart';
import 'package:primordial_spirit/screens/avatar_generation_screen.dart';
import 'package:primordial_spirit/screens/chat_screen.dart';
import 'package:primordial_spirit/screens/home_screen.dart';
import 'package:primordial_spirit/screens/settings_screen.dart';

/// 路由配置
class AppRoutes {
  static const String splash = '/';
  static const String baziInput = '/bazi-input';
  static const String avatarGeneration = '/avatar-generation';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      baziInput: (context) => const BaziInputScreen(),
      avatarGeneration: (context) => const AvatarGenerationScreen(),
      home: (context) => const HomeScreen(),
      chat: (context) => const ChatScreen(),
      settings: (context) => const SettingsScreen(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case baziInput:
        return MaterialPageRoute(builder: (_) => const BaziInputScreen());
      case avatarGeneration:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AvatarGenerationScreen(baziData: args?['baziData']),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case chat:
        return MaterialPageRoute(builder: (_) => const ChatScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return null;
    }
  }
}