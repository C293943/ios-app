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

  PatternInfo({
    required this.patternCode,
    required this.patternName,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'pattern_code': patternCode,
        'pattern_name': patternName,
        'description': description,
      };

  factory PatternInfo.fromJson(Map<String, dynamic> json) => PatternInfo(
        patternCode: json['pattern_code'] as String? ?? '',
        patternName: json['pattern_name'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );
}

/// 紫薇斗数信息
class ZiweiInfo {
  final String mingGong;
  final Map<String, dynamic>? rawData;

  ZiweiInfo({
    required this.mingGong,
    this.rawData,
  });

  Map<String, dynamic> toJson() {
    final json = rawData != null
        ? Map<String, dynamic>.from(rawData!)
        : <String, dynamic>{};
    json['ming_gong'] = mingGong;
    return json;
  }

  factory ZiweiInfo.fromJson(Map<String, dynamic> json) => ZiweiInfo(
        mingGong: json['ming_gong'] as String? ?? '',
        rawData: json,
      );
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

/// 算命响应（非流式）
class FortuneResponse {
  final bool success;
  final String message;
  final String? content;

  FortuneResponse({
    required this.success,
    required this.message,
    this.content,
  });

  factory FortuneResponse.fromJson(Map<String, dynamic> json) =>
      FortuneResponse(
        success: json['success'] as bool? ?? false,
        message: json['message'] as String? ?? '',
        // 后端返回 data.answer，兼容 data.content 和 content
        content: json['data']?['answer'] as String? ??
                 json['data']?['content'] as String? ??
                 json['answer'] as String? ??
                 json['content'] as String?,
      );
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
