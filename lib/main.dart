import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:primordial_spirit/l10n/app_localizations.dart';
import 'package:primordial_spirit/config/app_config.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';
import 'package:primordial_spirit/services/cultivation_service.dart';
import 'package:primordial_spirit/services/task_manager_service.dart';
import 'package:primordial_spirit/services/theme_service.dart';
import 'package:primordial_spirit/services/language_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化模型管理服务
  final modelManager = ModelManagerService();
  await modelManager.init();

  // 初始化养成值服务
  final cultivationService = CultivationService();
  await cultivationService.initialize();

  // 初始化任务管理服务
  final taskManager = TaskManagerService();
  await taskManager.init();

  // 初始化主题服务
  final themeService = ThemeService();
  await themeService.init();

  // 初始化语言服务
  final languageService = LanguageService();
  await languageService.init();

  runApp(MyApp(
    modelManager: modelManager,
    cultivationService: cultivationService,
    taskManager: taskManager,
    themeService: themeService,
    languageService: languageService,
  ));
}

class MyApp extends StatelessWidget {
  final ModelManagerService modelManager;
  final CultivationService cultivationService;
  final TaskManagerService taskManager;
  final ThemeService themeService;
  final LanguageService languageService;

  const MyApp({
    super.key,
    required this.modelManager,
    required this.cultivationService,
    required this.taskManager,
    required this.themeService,
    required this.languageService,
  });

  @override
  Widget build(BuildContext context) {
    // 根据是否已完成首次设置决定初始路由
    final initialRoute = modelManager.hasCompletedSetup
        ? AppRoutes.home
        : AppRoutes.baziInput;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: modelManager),
        ChangeNotifierProvider.value(value: cultivationService),
        ChangeNotifierProvider.value(value: taskManager),
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: languageService),
      ],
      child: Consumer2<ThemeService, LanguageService>(
        builder: (context, themeService, languageService, _) {
          return MaterialApp(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)?.appName ?? AppConfig.appName,
            theme: AppTheme.mysticLightTheme,
            darkTheme: AppTheme.mysticTheme,
            themeMode:
                themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: languageService.currentLocale,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh'),
              Locale('en'),
            ],
            initialRoute: initialRoute,
            routes: AppRoutes.getRoutes(),
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}
