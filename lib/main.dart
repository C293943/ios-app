import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/config/app_config.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化模型管理服务
  final modelManager = ModelManagerService();
  await modelManager.init();

  runApp(MyApp(modelManager: modelManager));
}

class MyApp extends StatelessWidget {
  final ModelManagerService modelManager;

  const MyApp({super.key, required this.modelManager});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: modelManager),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.mysticTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.home,
        routes: AppRoutes.getRoutes(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
