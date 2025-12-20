import 'dart:convert';

/// 出生信息
class BirthInfo {
  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final String city;
  final String gender;

  BirthInfo({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    this.city = '北京',
    required this.gender,
  });

  Map<String, dynamic> toJson() => {
        'year': year,
        'month': month,
        'day': day,
        'hour': hour,
        'minute': minute,
        'city': city,
        'gender': gender,
      };

  factory BirthInfo.fromJson(Map<String, dynamic> json) => BirthInfo(
        year: json['year'] as int,
        month: json['month'] as int,
        day: json['day'] as int,
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        city: json['city'] as String? ?? '北京',
        gender: json['gender'] as String,
      );

  /// 从本地存储的八字数据创建
  factory BirthInfo.fromStoredData(Map<String, dynamic> storedData) {
    final dateStr = storedData['date'] as String;
    final date = DateTime.parse(dateStr);
    return BirthInfo(
      year: date.year,
      month: date.month,
      day: date.day,
      hour: storedData['hour'] as int,
      minute: storedData['minute'] as int,
      gender: storedData['gender'] as String,
    );
  }
}

/// 八字信息
class BaziInfo {
  final String yearPillar;
  final String monthPillar;
  final String dayPillar;
  final String hourPillar;
  final String? dayMaster;
  final Map<String, int>? fiveElements; // 五行个数 {木:2, 火:1, ...}
  final Map<String, double>? fiveElementsStrength; // 五行力量百分比
  final Map<String, dynamic>? tenGods; // 十神
  final Map<String, List<String>>? hideGan; // 藏干
  final Map<String, String>? nayin; // 纳音
  final List<PatternInfo>? patterns; // 格局
  final Map<String, dynamic>? rawData;

  BaziInfo({
    required this.yearPillar,
    required this.monthPillar,
    required this.dayPillar,
    required this.hourPillar,
    this.dayMaster,
    this.fiveElements,
    this.fiveElementsStrength,
    this.tenGods,
    this.hideGan,
    this.nayin,
    this.patterns,
    this.rawData,
  });

  /// 获取日主（日干）
  String get dayGan => dayPillar.isNotEmpty ? dayPillar[0] : '';

  /// 获取五行强度描述
  String get dominantElement {
    if (fiveElementsStrength == null || fiveElementsStrength!.isEmpty) return '';
    final sorted = fiveElementsStrength!.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  Map<String, dynamic> toJson() {
    // 优先使用 rawData（包含完整数据，包括 dayun, liunian 等后端需要的字段）
    if (rawData != null) {
      return Map<String, dynamic>.from(rawData!);
    }
    // 否则构建基本结构
    final json = <String, dynamic>{};
    json['year_pillar'] = yearPillar;
    json['month_pillar'] = monthPillar;
    json['day_pillar'] = dayPillar;
    json['hour_pillar'] = hourPillar;
    if (dayMaster != null) json['day_master'] = dayMaster;
    if (fiveElements != null) json['five_elements'] = fiveElements;
    if (fiveElementsStrength != null) json['five_elements_strength'] = fiveElementsStrength;
    if (tenGods != null) json['ten_gods'] = tenGods;
    if (hideGan != null) json['hide_gan'] = hideGan;
    if (nayin != null) json['nayin'] = nayin;
    if (patterns != null) json['patterns'] = patterns!.map((p) => p.toJson()).toList();
    return json;
  }

  factory BaziInfo.fromJson(Map<String, dynamic> json) {
    // 解析五行个数
    Map<String, int>? fiveElements;
    if (json['five_elements'] != null && json['five_elements'] is Map) {
      fiveElements = (json['five_elements'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toInt()));
    }

    // 解析五行力量
    Map<String, double>? fiveElementsStrength;
    if (json['five_elements_strength'] != null && json['five_elements_strength'] is Map) {
      fiveElementsStrength = (json['five_elements_strength'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble()));
    }

    // 解析藏干
    Map<String, List<String>>? hideGan;
    if (json['hide_gan'] != null && json['hide_gan'] is Map) {
      hideGan = (json['hide_gan'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, (v as List).map((e) => e.toString()).toList()),
      );
    }

    // 解析纳音
    Map<String, String>? nayin;
    if (json['nayin'] != null && json['nayin'] is Map) {
      nayin = (json['nayin'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v.toString()));
    }

    // 解析格局
    List<PatternInfo>? patterns;
    if (json['patterns'] != null && json['patterns'] is List) {
      patterns = (json['patterns'] as List)
          .map((p) => PatternInfo.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    return BaziInfo(
      yearPillar: json['year_pillar'] as String? ?? '',
      monthPillar: json['month_pillar'] as String? ?? '',
      dayPillar: json['day_pillar'] as String? ?? '',
      hourPillar: json['hour_pillar'] as String? ?? '',
      dayMaster: json['day_master'] as String?,
      fiveElements: fiveElements,
      fiveElementsStrength: fiveElementsStrength,
      tenGods: json['ten_gods'] as Map<String, dynamic>?,
      hideGan: hideGan,
      nayin: nayin,
      patterns: patterns,
      rawData: json,
    );
  }
}

/// 格局信息
class PatternInfo {
  final String patternCode;
  final String patternName;
  final String description;
  final bool isFormed;
  final double formationScore;
  final List<String> formationDetails;
  final String level;
  final String levelName;
  final int levelScore;
  final int finalScore;
  final List<String> levelFeatures;
  final Map<String, dynamic>? coreFeatures;
  final Map<String, dynamic>? favorable;
  final Map<String, dynamic>? unfavorable;

  PatternInfo({
    required this.patternCode,
    required this.patternName,
    required this.description,
    this.isFormed = false,
    this.formationScore = 0.0,
    this.formationDetails = const [],
    this.level = '',
    this.levelName = '',
    this.levelScore = 0,
    this.finalScore = 0,
    this.levelFeatures = const [],
    this.coreFeatures,
    this.favorable,
    this.unfavorable,
  });

  /// 获取核心含义
  String? get coreMeaning => coreFeatures?['core_meaning'] as String?;

  /// 获取适合领域
  List<String> get suitableFields {
    final fields = coreFeatures?['suitable_fields'];
    if (fields is List) {
      return fields.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// 获取性格特征
  List<String> get traits {
    final t = coreFeatures?['traits'];
    if (t is List) {
      return t.map((e) => e.toString()).toList();
    } else if (t is String) {
      return [t];
    }
    return [];
  }

  Map<String, dynamic> toJson() => {
        'pattern_code': patternCode,
        'pattern_name': patternName,
        'description': description,
        'is_formed': isFormed,
        'formation_score': formationScore,
        'formation_details': formationDetails,
        'level': level,
        'level_name': levelName,
        'level_score': levelScore,
        'final_score': finalScore,
        'level_features': levelFeatures,
        if (coreFeatures != null) 'core_features': coreFeatures,
        if (favorable != null) 'favorable': favorable,
        if (unfavorable != null) 'unfavorable': unfavorable,
      };

  factory PatternInfo.fromJson(Map<String, dynamic> json) => PatternInfo(
        patternCode: json['pattern_code'] as String? ?? '',
        patternName: json['pattern_name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        isFormed: json['is_formed'] as bool? ?? false,
        formationScore: (json['formation_score'] as num?)?.toDouble() ?? 0.0,
        formationDetails: (json['formation_details'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [],
        level: json['level'] as String? ?? '',
        levelName: json['level_name'] as String? ?? '',
        levelScore: json['level_score'] as int? ?? 0,
        finalScore: json['final_score'] as int? ?? 0,
        levelFeatures: (json['level_features'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [],
        coreFeatures: json['core_features'] as Map<String, dynamic>?,
        favorable: json['favorable'] as Map<String, dynamic>?,
        unfavorable: json['unfavorable'] as Map<String, dynamic>?,
      );
}

/// 紫薇斗数信息
class ZiweiInfo {
  final String mingGong;
  final String shenGong;
  final Map<String, Map<String, dynamic>>? palaces;
  final Map<String, List<String>>? majorStars;
  final Map<String, dynamic>? sihua;
  final Map<String, dynamic>? daxian;
  final Map<String, dynamic>? liunian;
  final Map<String, dynamic>? liuyue;
  final Map<String, dynamic>? rawData;

  ZiweiInfo({
    required this.mingGong,
    this.shenGong = '',
    this.palaces,
    this.majorStars,
    this.sihua,
    this.daxian,
    this.liunian,
    this.liuyue,
    this.rawData,
  });

  Map<String, dynamic> toJson() {
    // 优先使用 rawData（包含完整数据），否则构建基本结构
    if (rawData != null) {
      return Map<String, dynamic>.from(rawData!);
    }
    return {
      'ming_gong': mingGong,
      'shen_gong': shenGong,
      if (palaces != null) 'palaces': palaces,
      if (majorStars != null) 'major_stars': majorStars,
      if (sihua != null) 'sihua': sihua,
      if (daxian != null) 'daxian': daxian,
      if (liunian != null) 'liunian': liunian,
      if (liuyue != null) 'liuyue': liuyue,
    };
  }

  factory ZiweiInfo.fromJson(Map<String, dynamic> json) {
    // 解析十二宫
    Map<String, Map<String, dynamic>>? palaces;
    if (json['palaces'] != null && json['palaces'] is Map) {
      palaces = (json['palaces'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)),
      );
    }

    // 解析主星
    Map<String, List<String>>? majorStars;
    if (json['major_stars'] != null && json['major_stars'] is Map) {
      majorStars = (json['major_stars'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, (v as List).map((e) => e.toString()).toList()),
      );
    }

    return ZiweiInfo(
      mingGong: json['ming_gong'] as String? ?? '',
      shenGong: json['shen_gong'] as String? ?? '',
      palaces: palaces,
      majorStars: majorStars,
      sihua: json['sihua'] as Map<String, dynamic>?,
      daxian: json['daxian'] as Map<String, dynamic>?,
      liunian: json['liunian'] as Map<String, dynamic>?,
      liuyue: json['liuyue'] as Map<String, dynamic>?,
      rawData: json,
    );
  }
}

/// 计算结果响应
class CalculateResponse {
  final bool success;
  final String message;
  final BaziInfo? baziInfo;
  final ZiweiInfo? ziweiInfo;
  final int? adjustedHour;
  final int? adjustedMinute;
  final double? timeOffset;

  CalculateResponse({
    required this.success,
    required this.message,
    this.baziInfo,
    this.ziweiInfo,
    this.adjustedHour,
    this.adjustedMinute,
    this.timeOffset,
  });

  factory CalculateResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return CalculateResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      baziInfo: data?['bazi_info'] != null
          ? BaziInfo.fromJson(data!['bazi_info'] as Map<String, dynamic>)
          : null,
      ziweiInfo: data?['ziwei_info'] != null
          ? ZiweiInfo.fromJson(data!['ziwei_info'] as Map<String, dynamic>)
          : null,
      adjustedHour: data?['adjusted_hour'] as int?,
      adjustedMinute: data?['adjusted_minute'] as int?,
      timeOffset: (data?['time_offset'] as num?)?.toDouble(),
    );
  }
}

/// 聊天消息
class ChatMessageModel {
  final String role;
  final String content;

  ChatMessageModel({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        role: json['role'] as String,
        content: json['content'] as String,
      );
}

/// 算命请求
class FortuneRequest {
  final BirthInfo birthInfo;
  final BaziInfo baziInfo;
  final ZiweiInfo ziweiInfo;
  final List<ChatMessageModel> messages;
  final String language;

  FortuneRequest({
    required this.birthInfo,
    required this.baziInfo,
    required this.ziweiInfo,
    required this.messages,
    this.language = '中文',
  });

  Map<String, dynamic> toJson() => {
        'birth_info': birthInfo.toJson(),
        'bazi_info': baziInfo.toJson(),
        'ziwei_info': ziweiInfo.toJson(),
        'messages': messages.map((m) => m.toJson()).toList(),
        'language': language,
      };
}

/// 命盘数据（包含所有计算结果，用于本地存储）
class FortuneData {
  final BirthInfo birthInfo;
  final BaziInfo baziInfo;
  final ZiweiInfo ziweiInfo;
  final DateTime calculatedAt;
  final Avatar3dInfo? avatar3dInfo; // 3D元神形象信息

  FortuneData({
    required this.birthInfo,
    required this.baziInfo,
    required this.ziweiInfo,
    required this.calculatedAt,
    this.avatar3dInfo,
  });

  /// 创建带有3D信息的副本
  FortuneData copyWith({
    BirthInfo? birthInfo,
    BaziInfo? baziInfo,
    ZiweiInfo? ziweiInfo,
    DateTime? calculatedAt,
    Avatar3dInfo? avatar3dInfo,
  }) {
    return FortuneData(
      birthInfo: birthInfo ?? this.birthInfo,
      baziInfo: baziInfo ?? this.baziInfo,
      ziweiInfo: ziweiInfo ?? this.ziweiInfo,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      avatar3dInfo: avatar3dInfo ?? this.avatar3dInfo,
    );
  }

  Map<String, dynamic> toJson() => {
        'birth_info': birthInfo.toJson(),
        'bazi_info': baziInfo.toJson(),
        'ziwei_info': ziweiInfo.toJson(),
        'calculated_at': calculatedAt.toIso8601String(),
        if (avatar3dInfo != null) 'avatar_3d_info': avatar3dInfo!.toJson(),
      };

  factory FortuneData.fromJson(Map<String, dynamic> json) => FortuneData(
        birthInfo: BirthInfo.fromJson(json['birth_info'] as Map<String, dynamic>),
        baziInfo: BaziInfo.fromJson(json['bazi_info'] as Map<String, dynamic>),
        ziweiInfo: ZiweiInfo.fromJson(json['ziwei_info'] as Map<String, dynamic>),
        calculatedAt: DateTime.parse(json['calculated_at'] as String),
        avatar3dInfo: json['avatar_3d_info'] != null
            ? Avatar3dInfo.fromJson(json['avatar_3d_info'] as Map<String, dynamic>)
            : null,
      );

  String toJsonString() => jsonEncode(toJson());

  factory FortuneData.fromJsonString(String jsonString) =>
      FortuneData.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}

/// 3D元神形象信息
class Avatar3dInfo {
  final String taskId;           // Meshy任务ID
  final String status;           // 任务状态
  final String? glbUrl;          // GLB模型URL
  final String? fbxUrl;          // FBX模型URL
  final String? objUrl;          // OBJ模型URL
  final String? usdzUrl;         // USDZ模型URL (iOS AR)
  final String? thumbnailUrl;    // 缩略图URL
  final String? videoUrl;        // 预览视频URL
  final String prompt;           // 生成使用的提示词
  final DateTime createdAt;      // 创建时间
  final bool isRefined;          // 是否是精细化后的模型（带贴图）
  final bool isRigged;           // 是否已绑定骨骼
  final bool hasAnimation;       // 是否有动画
  final String? rigTaskId;       // 骨骼绑定任务ID
  final String? animationTaskId; // 动画任务ID
  final RiggedModelInfo? riggedModel;  // 绑定后的模型信息
  final List<AnimationInfo>? animations; // 动画列表

  Avatar3dInfo({
    required this.taskId,
    required this.status,
    this.glbUrl,
    this.fbxUrl,
    this.objUrl,
    this.usdzUrl,
    this.thumbnailUrl,
    this.videoUrl,
    required this.prompt,
    required this.createdAt,
    this.isRefined = false,
    this.isRigged = false,
    this.hasAnimation = false,
    this.rigTaskId,
    this.animationTaskId,
    this.riggedModel,
    this.animations,
  });

  bool get isReady => status == 'SUCCEEDED' && glbUrl != null;

  /// 是否是完整的精细化模型（带贴图，可用于展示）
  bool get isFullModel => isReady && isRefined;

  /// 是否是完整的可动画模型（带骨骼绑定）
  bool get isAnimatableModel => isReady && isRigged && riggedModel != null;

  /// 获取最佳可用的GLB URL（优先使用绑定后的模型）
  String? get bestGlbUrl {
    if (riggedModel?.glbUrl != null) return riggedModel!.glbUrl;
    return glbUrl;
  }

  Map<String, dynamic> toJson() => {
        'task_id': taskId,
        'status': status,
        if (glbUrl != null) 'glb_url': glbUrl,
        if (fbxUrl != null) 'fbx_url': fbxUrl,
        if (objUrl != null) 'obj_url': objUrl,
        if (usdzUrl != null) 'usdz_url': usdzUrl,
        if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
        if (videoUrl != null) 'video_url': videoUrl,
        'prompt': prompt,
        'created_at': createdAt.toIso8601String(),
        'is_refined': isRefined,
        'is_rigged': isRigged,
        'has_animation': hasAnimation,
        if (rigTaskId != null) 'rig_task_id': rigTaskId,
        if (animationTaskId != null) 'animation_task_id': animationTaskId,
        if (riggedModel != null) 'rigged_model': riggedModel!.toJson(),
        if (animations != null) 'animations': animations!.map((a) => a.toJson()).toList(),
      };

  factory Avatar3dInfo.fromJson(Map<String, dynamic> json) => Avatar3dInfo(
        taskId: json['task_id'] as String,
        status: json['status'] as String,
        glbUrl: json['glb_url'] as String?,
        fbxUrl: json['fbx_url'] as String?,
        objUrl: json['obj_url'] as String?,
        usdzUrl: json['usdz_url'] as String?,
        thumbnailUrl: json['thumbnail_url'] as String?,
        videoUrl: json['video_url'] as String?,
        prompt: json['prompt'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
        isRefined: json['is_refined'] as bool? ?? false,
        isRigged: json['is_rigged'] as bool? ?? false,
        hasAnimation: json['has_animation'] as bool? ?? false,
        rigTaskId: json['rig_task_id'] as String?,
        animationTaskId: json['animation_task_id'] as String?,
        riggedModel: json['rigged_model'] != null
            ? RiggedModelInfo.fromJson(json['rigged_model'] as Map<String, dynamic>)
            : null,
        animations: json['animations'] != null
            ? (json['animations'] as List)
                .map((a) => AnimationInfo.fromJson(a as Map<String, dynamic>))
                .toList()
            : null,
      );

  /// 创建更新后的副本
  Avatar3dInfo copyWith({
    String? taskId,
    String? status,
    String? glbUrl,
    String? fbxUrl,
    String? objUrl,
    String? usdzUrl,
    String? thumbnailUrl,
    String? videoUrl,
    String? prompt,
    DateTime? createdAt,
    bool? isRefined,
    bool? isRigged,
    bool? hasAnimation,
    String? rigTaskId,
    String? animationTaskId,
    RiggedModelInfo? riggedModel,
    List<AnimationInfo>? animations,
  }) {
    return Avatar3dInfo(
      taskId: taskId ?? this.taskId,
      status: status ?? this.status,
      glbUrl: glbUrl ?? this.glbUrl,
      fbxUrl: fbxUrl ?? this.fbxUrl,
      objUrl: objUrl ?? this.objUrl,
      usdzUrl: usdzUrl ?? this.usdzUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      prompt: prompt ?? this.prompt,
      createdAt: createdAt ?? this.createdAt,
      isRefined: isRefined ?? this.isRefined,
      isRigged: isRigged ?? this.isRigged,
      hasAnimation: hasAnimation ?? this.hasAnimation,
      rigTaskId: rigTaskId ?? this.rigTaskId,
      animationTaskId: animationTaskId ?? this.animationTaskId,
      riggedModel: riggedModel ?? this.riggedModel,
      animations: animations ?? this.animations,
    );
  }
}

/// 骨骼绑定后的模型信息
class RiggedModelInfo {
  final String taskId;
  final String? glbUrl;
  final String? fbxUrl;
  final BasicAnimations? basicAnimations;  // 基础动画（行走/跑步）
  final DateTime? createdAt;

  RiggedModelInfo({
    required this.taskId,
    this.glbUrl,
    this.fbxUrl,
    this.basicAnimations,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'task_id': taskId,
        if (glbUrl != null) 'glb_url': glbUrl,
        if (fbxUrl != null) 'fbx_url': fbxUrl,
        if (basicAnimations != null) 'basic_animations': basicAnimations!.toJson(),
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  factory RiggedModelInfo.fromJson(Map<String, dynamic> json) => RiggedModelInfo(
        taskId: json['task_id'] as String,
        glbUrl: json['glb_url'] as String?,
        fbxUrl: json['fbx_url'] as String?,
        basicAnimations: json['basic_animations'] != null
            ? BasicAnimations.fromJson(json['basic_animations'] as Map<String, dynamic>)
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );
}

/// 基础动画（绑定时自动生成的行走/跑步动画）
class BasicAnimations {
  final String? walkingGlbUrl;
  final String? walkingFbxUrl;
  final String? walkingArmatureGlbUrl;
  final String? runningGlbUrl;
  final String? runningFbxUrl;
  final String? runningArmatureGlbUrl;

  BasicAnimations({
    this.walkingGlbUrl,
    this.walkingFbxUrl,
    this.walkingArmatureGlbUrl,
    this.runningGlbUrl,
    this.runningFbxUrl,
    this.runningArmatureGlbUrl,
  });

  Map<String, dynamic> toJson() => {
        if (walkingGlbUrl != null) 'walking_glb_url': walkingGlbUrl,
        if (walkingFbxUrl != null) 'walking_fbx_url': walkingFbxUrl,
        if (walkingArmatureGlbUrl != null) 'walking_armature_glb_url': walkingArmatureGlbUrl,
        if (runningGlbUrl != null) 'running_glb_url': runningGlbUrl,
        if (runningFbxUrl != null) 'running_fbx_url': runningFbxUrl,
        if (runningArmatureGlbUrl != null) 'running_armature_glb_url': runningArmatureGlbUrl,
      };

  factory BasicAnimations.fromJson(Map<String, dynamic> json) => BasicAnimations(
        walkingGlbUrl: json['walking_glb_url'] as String?,
        walkingFbxUrl: json['walking_fbx_url'] as String?,
        walkingArmatureGlbUrl: json['walking_armature_glb_url'] as String?,
        runningGlbUrl: json['running_glb_url'] as String?,
        runningFbxUrl: json['running_fbx_url'] as String?,
        runningArmatureGlbUrl: json['running_armature_glb_url'] as String?,
      );
}

/// 动画信息
class AnimationInfo {
  final String taskId;
  final int actionId;
  final String actionName;
  final String? glbUrl;
  final String? fbxUrl;
  final String? usdzUrl;
  final DateTime? createdAt;

  AnimationInfo({
    required this.taskId,
    required this.actionId,
    required this.actionName,
    this.glbUrl,
    this.fbxUrl,
    this.usdzUrl,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'task_id': taskId,
        'action_id': actionId,
        'action_name': actionName,
        if (glbUrl != null) 'glb_url': glbUrl,
        if (fbxUrl != null) 'fbx_url': fbxUrl,
        if (usdzUrl != null) 'usdz_url': usdzUrl,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  factory AnimationInfo.fromJson(Map<String, dynamic> json) => AnimationInfo(
        taskId: json['task_id'] as String,
        actionId: json['action_id'] as int,
        actionName: json['action_name'] as String? ?? '',
        glbUrl: json['glb_url'] as String?,
        fbxUrl: json['fbx_url'] as String?,
        usdzUrl: json['usdz_url'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );
}

/// 动画库项目
class AnimationLibraryItem {
  final int actionId;
  final String name;
  final String category;
  final String? subcategory;
  final String? description;
  final String? previewUrl;

  AnimationLibraryItem({
    required this.actionId,
    required this.name,
    required this.category,
    this.subcategory,
    this.description,
    this.previewUrl,
  });

  factory AnimationLibraryItem.fromJson(Map<String, dynamic> json) => AnimationLibraryItem(
        actionId: json['action_id'] as int,
        name: json['name'] as String,
        category: json['category'] as String,
        subcategory: json['subcategory'] as String?,
        description: json['description'] as String?,
        previewUrl: json['preview_url'] as String?,
      );
}

/// 推荐的动画配置（元神主题）
class RecommendedAnimations {
  static const List<Map<String, dynamic>> forYuanShen = [
    {'action_id': 0, 'name': 'Idle', 'description': '默认待机'},
    {'action_id': 125, 'name': 'CastingSpell_01', 'description': '施法动作1'},
    {'action_id': 126, 'name': 'CastingSpell_02', 'description': '施法动作2'},
    {'action_id': 41, 'name': 'Formal_Bow', 'description': '正式鞠躬'},
    {'action_id': 59, 'name': 'Victory_Cheer', 'description': '胜利欢呼'},
    {'action_id': 63, 'name': 'Hip_Hop_Dance_01', 'description': '舞蹈动作'},
  ];
}
