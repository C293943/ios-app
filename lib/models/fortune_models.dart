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
  final String? fiveElements;
  final Map<String, dynamic>? rawData;

  BaziInfo({
    required this.yearPillar,
    required this.monthPillar,
    required this.dayPillar,
    required this.hourPillar,
    this.dayMaster,
    this.fiveElements,
    this.rawData,
  });

  Map<String, dynamic> toJson() {
    final json = rawData ?? <String, dynamic>{};
    json['year_pillar'] = yearPillar;
    json['month_pillar'] = monthPillar;
    json['day_pillar'] = dayPillar;
    json['hour_pillar'] = hourPillar;
    if (dayMaster != null) json['day_master'] = dayMaster;
    if (fiveElements != null) json['five_elements'] = fiveElements;
    return json;
  }

  factory BaziInfo.fromJson(Map<String, dynamic> json) => BaziInfo(
        yearPillar: json['year_pillar'] as String? ?? '',
        monthPillar: json['month_pillar'] as String? ?? '',
        dayPillar: json['day_pillar'] as String? ?? '',
        hourPillar: json['hour_pillar'] as String? ?? '',
        dayMaster: json['day_master'] as String?,
        fiveElements: json['five_elements'] as String?,
        rawData: json,
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
        content: json['data']?['content'] as String? ?? json['content'] as String?,
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
