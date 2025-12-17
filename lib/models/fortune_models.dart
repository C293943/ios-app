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

  FortuneData({
    required this.birthInfo,
    required this.baziInfo,
    required this.ziweiInfo,
    required this.calculatedAt,
  });

  Map<String, dynamic> toJson() => {
        'birth_info': birthInfo.toJson(),
        'bazi_info': baziInfo.toJson(),
        'ziwei_info': ziweiInfo.toJson(),
        'calculated_at': calculatedAt.toIso8601String(),
      };

  factory FortuneData.fromJson(Map<String, dynamic> json) => FortuneData(
        birthInfo: BirthInfo.fromJson(json['birth_info'] as Map<String, dynamic>),
        baziInfo: BaziInfo.fromJson(json['bazi_info'] as Map<String, dynamic>),
        ziweiInfo: ZiweiInfo.fromJson(json['ziwei_info'] as Map<String, dynamic>),
        calculatedAt: DateTime.parse(json['calculated_at'] as String),
      );

  String toJsonString() => jsonEncode(toJson());

  factory FortuneData.fromJsonString(String jsonString) =>
      FortuneData.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
