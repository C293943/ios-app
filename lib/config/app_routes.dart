import 'package:flutter/material.dart';
import 'package:primordial_spirit/screens/bazi_input_screen.dart';
import 'package:primordial_spirit/screens/avatar_generation_screen.dart';
import 'package:primordial_spirit/screens/chat_screen.dart';
import 'package:primordial_spirit/screens/home_screen.dart';
import 'package:primordial_spirit/screens/settings_screen.dart';
import 'package:primordial_spirit/screens/profile_screen.dart';

/// 路由配置
class AppRoutes {
  static const String baziInput = '/bazi-input';
  static const String avatarGeneration = '/avatar-generation';
  static const String home = '/';
  static const String chat = '/chat';
  static const String settings = '/settings';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      baziInput: (context) => const BaziInputScreen(),
      // avatarGeneration 需要参数，通过 onGenerateRoute 处理
      chat: (context) => const ChatScreen(),
      settings: (context) => const SettingsScreen(),
      profile: (context) => const ProfileScreen(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case baziInput:
        return MaterialPageRoute(builder: (_) => const BaziInputScreen());
      case avatarGeneration:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AvatarGenerationScreen(baziData: args?['baziData']),
        );
      case chat:
        return MaterialPageRoute(builder: (_) => const ChatScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return null;
    }
  }
}