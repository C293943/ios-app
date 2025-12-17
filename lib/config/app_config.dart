import 'dart:io';

/// APP全局配置
class AppConfig {
  // 应用名称
  static const String appName = '鸿初元灵';

  // API配置
  // Android模拟器使用10.0.2.2访问主机localhost
  // iOS模拟器使用localhost
  // 真机调试需要使用电脑的实际IP地址
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Android模拟器: 10.0.2.2 映射到主机的 localhost
      // 真机调试时请替换为电脑的实际IP地址，如: 'http://192.168.1.100:8000'
      return 'http://192.168.31.249:8000';
    } else if (Platform.isIOS) {
      // iOS模拟器可以直接使用localhost
      return 'http://localhost:8000';
    }
    // 其他平台（Web、桌面等）
    return 'http://localhost:8000';
  }
  static const String calculateEndpoint = '/api/v1/calculate';
  static const String fortuneEndpoint = '/api/v1/fortune';
  static const String fortuneStreamEndpoint = '/api/v1/fortune/stream';

  // 默认语言
  static const String defaultLanguage = '中文';
  
  // 八字配置
  static const List<String> heavenlyStems = [
    '甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'
  ];
  
  static const List<String> earthlyBranches = [
    '子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'
  ];
  
  // 五行配置
  static const Map<String, String> fiveElements = {
    '木': '0xFF4CAF50',
    '火': '0xFFF44336',
    '土': '0xFFFF9800',
    '金': '0xFFFFEB3B',
    '水': '0xFF2196F3',
  };
  
  // 对话配置
  static const double emotionalCompanionshipRatio = 0.8; // 情感陪伴占比80%
  static const double guidanceRatio = 0.2; // 指引建议占比20%
  
  // 3D配置
  static const String defaultModelPath = 'assets/3d_models/default_avatar.obj';
  
  // 缓存配置
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration cacheValidDuration = Duration(days: 7);
}