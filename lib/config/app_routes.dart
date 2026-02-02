// 应用路由配置，统一管理页面跳转与参数传递。
import 'package:flutter/material.dart';
import 'package:primordial_spirit/screens/avatar_generation_screen.dart';
import 'package:primordial_spirit/screens/bazi_input_screen.dart';
import 'package:primordial_spirit/screens/chat_screen.dart';
import 'package:primordial_spirit/screens/home_screen.dart';
import 'package:primordial_spirit/screens/login_screen.dart';
import 'package:primordial_spirit/screens/register_screen.dart';
import 'package:primordial_spirit/screens/profile_screen.dart';
import 'package:primordial_spirit/models/relationship_models.dart';
import 'package:primordial_spirit/screens/relationship_chat_screen.dart';
import 'package:primordial_spirit/screens/relationship_form_screen.dart';
import 'package:primordial_spirit/screens/relationship_report_screen.dart';
import 'package:primordial_spirit/screens/relationship_select_screen.dart';
import 'package:primordial_spirit/screens/settings_screen.dart';
import 'package:primordial_spirit/widgets/auth_guard.dart';

/// 路由配置
class AppRoutes {
  static const String baziInput = '/bazi-input';
  static const String avatarGeneration = '/avatar-generation';
  static const String home = '/';
  static const String chat = '/chat';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String register = '/register';
  static const String relationshipSelect = '/relationship';
  static const String relationshipForm = '/relationship/form';
  static const String relationshipReport = '/relationship/report';
  static const String relationshipChat = '/relationship/chat';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      baziInput: (context) => const BaziInputScreen(),
      // avatarGeneration 需要参数，通过 onGenerateRoute 处理
      chat: (context) => const ChatScreen(),
      settings: (context) => const SettingsScreen(),
      profile: (context) => const AuthGuard(child: ProfileScreen()),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      relationshipSelect: (context) => const RelationshipSelectScreen(),
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
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: ProfileScreen()),
        );
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.relationshipForm:
        final args = settings.arguments as Map<String, dynamic>?;
        final relationType = args?['relationType'] as String?;
        if (relationType == null || relationType.isEmpty) {
          return MaterialPageRoute(builder: (_) => const RelationshipSelectScreen());
        }
        return MaterialPageRoute(
          builder: (_) => RelationshipFormScreen(relationType: relationType),
        );
      case AppRoutes.relationshipReport:
        final args = settings.arguments as Map<String, dynamic>?;
        final relationType = args?['relationType'] as String?;
        final report = args?['report'] as RelationshipReport?;
        final personA = args?['personA'] as RelationshipPerson?;
        final personB = args?['personB'] as RelationshipPerson?;
        if (relationType == null) {
          return MaterialPageRoute(builder: (_) => const RelationshipSelectScreen());
        }
        return MaterialPageRoute(
          builder: (_) => RelationshipReportScreen(
            relationType: relationType,
            report: report,
            personA: personA,
            personB: personB,
          ),
        );
      case AppRoutes.relationshipChat:
        final args = settings.arguments as Map<String, dynamic>?;
        final report = args?['report'] as RelationshipReport?;
        if (report == null) {
          return MaterialPageRoute(builder: (_) => const RelationshipSelectScreen());
        }
        return MaterialPageRoute(
          builder: (_) => RelationshipChatScreen(report: report),
        );
      default:
        return null;
    }
  }
}
