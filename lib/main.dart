import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/config/app_config.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';
import 'package:primordial_spirit/services/cultivation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化模型管理服务
  final modelManager = ModelManagerService();
  await modelManager.init();

  // 初始化养成值服务
  final cultivationService = CultivationService();
  await cultivationService.initialize();

  runApp(MyApp(
    modelManager: modelManager,
    cultivationService: cultivationService,
  ));
}

class MyApp extends StatelessWidget {
  final ModelManagerService modelManager;
  final CultivationService cultivationService;

  const MyApp({
    super.key,
    required this.modelManager,
    required this.cultivationService,
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
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.mysticTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
        routes: AppRoutes.getRoutes(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
