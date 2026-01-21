// 应用全局配置与API端点集中管理。
import 'dart:io';

/// APP全局配置
class AppConfig {
  // 应用名称
  static const String appName = '鸿初元灵';

  // ============ 服务器配置 ============
  // 生产环境服务器地址（上线后使用）
  static const String productionBaseUrl = 'http://192.168.31.200:8848';

  // 开发环境服务器地址（本地调试时的电脑 IP）
  static const String developmentServerIp = '192.168.31.249';

  // 是否为生产环境（上线时改为 true）
  static const bool isProduction = false;

  // API配置
  // Android模拟器使用10.0.2.2访问主机localhost
  // iOS模拟器使用localhost
  // 真机调试需要使用电脑的实际IP地址
  static String get baseUrl {
    // 生产环境直接返回生产服务器地址
    if (isProduction) {
      return productionBaseUrl;
    }

    // 开发环境
    if (Platform.isAndroid) {
      // Android模拟器: 10.0.2.2 映射到主机的 localhost
      // 真机调试时使用实际IP地址
      return 'http://$developmentServerIp:8848';
    } else if (Platform.isIOS) {
      // iOS 真机和模拟器都使用实际 IP 地址
      // 注意：iOS 真机无法访问 localhost，必须使用实际 IP
      return 'http://$developmentServerIp:8848';
    }
    // 其他平台（Web、桌面等）
    return 'http://localhost:8848';
  }
  static const String calculateEndpoint = '/api/v1/calculate';
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

  // 3D 元神形象 API 端点（通过后端调用 Meshy API）
  // ============ 基础生成流程 ============
  // POST /api/v1/avatar3d/create - 创建任务（预览 + 精细化）
  // GET /api/v1/avatar3d/status/{task_id} - 查询状态
  // GET /api/v1/avatar3d/stream/{task_id} - SSE 流式获取进度
  static const String avatar3dCreateEndpoint = '/api/v1/avatar3d/create';
  static const String avatar3dStatusEndpoint = '/api/v1/avatar3d/status';
  static const String avatar3dStreamEndpoint = '/api/v1/avatar3d/stream';

  // ============ 换皮肤/换材质 (Retexture) ============
  // POST /api/v1/avatar3d/retexture - 创建换皮肤任务
  // GET /api/v1/avatar3d/retexture/{task_id} - 查询换皮肤状态
  // GET /api/v1/avatar3d/retexture/{task_id}/stream - SSE 流式获取进度
  static const String avatar3dRetextureEndpoint = '/api/v1/avatar3d/retexture';

  // ============ 骨骼绑定 (Rigging) ============
  // POST /api/v1/avatar3d/rig - 创建骨骼绑定任务
  // GET /api/v1/avatar3d/rig/{task_id} - 查询绑定状态
  // GET /api/v1/avatar3d/rig/{task_id}/stream - SSE 流式获取进度
  static const String avatar3dRigEndpoint = '/api/v1/avatar3d/rig';

  // ============ 动画绑定 (Animation) ============
  // POST /api/v1/avatar3d/animate - 创建动画任务
  // GET /api/v1/avatar3d/animate/{task_id} - 查询动画状态
  // GET /api/v1/avatar3d/animate/{task_id}/stream - SSE 流式获取进度
  // GET /api/v1/avatar3d/animations - 获取动画库列表
  static const String avatar3dAnimateEndpoint = '/api/v1/avatar3d/animate';
  static const String avatar3dAnimationLibraryEndpoint = '/api/v1/avatar3d/animations';

  // ============ 完整流程（一键生成） ============
  // POST /api/v1/avatar3d/create-full - 完整流程：预览→精细化→绑定→动画
  // GET /api/v1/avatar3d/full/{task_id}/stream - SSE 流式获取完整流程进度
  static const String avatar3dCreateFullEndpoint = '/api/v1/avatar3d/create-full';

  // ============ 图片生成 API ============
  // POST /api/v1/generate - 异步生成图片
  // GET /api/v1/status/{task_id} - 查询生成状态
  // GET /api/v1/stream/{task_id} - SSE 流式获取进度
  // POST /api/v1/generate/sync - 同步生成图片
  static const String imageGenerateEndpoint = '/api/v1/generate';
  static const String imageStatusEndpoint = '/api/v1/status';
  static const String imageStreamEndpoint = '/api/v1/stream';
  static const String imageGenerateSyncEndpoint = '/api/v1/generate/sync';

  // ============ 关系合盘 ============
  static const String relationshipReportEndpoint = '/api/v1/relationship/report';
  static const String relationshipStreamEndpoint = '/api/v1/relationship/stream';

  // 缓存配置
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration cacheValidDuration = Duration(days: 7);
}
