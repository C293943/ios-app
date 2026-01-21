// 关系合盘相关数据模型，承载报告与对话结构。
class RelationshipPerson {
  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final String city;
  final String gender;

  RelationshipPerson({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.city,
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
}

class RelationshipReport {
  final String reportId;
  final String relationType;
  final int score;
  final String summary;
  final List<String> highlights;
  final List<String> advice;

  RelationshipReport({
    required this.reportId,
    required this.relationType,
    required this.score,
    required this.summary,
    required this.highlights,
    required this.advice,
  });

  factory RelationshipReport.fromJson(Map<String, dynamic> json) {
    return RelationshipReport(
      reportId: json['report_id'] as String? ?? '',
      relationType: json['relation_type'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      summary: json['summary'] as String? ?? '',
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      advice: (json['advice'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'report_id': reportId,
        'relation_type': relationType,
        'score': score,
        'summary': summary,
        'highlights': highlights,
        'advice': advice,
      };

  factory RelationshipReport.mock(String relationType) {
    return RelationshipReport(
      reportId: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      relationType: relationType,
      score: 78,
      summary: '你们的能量频率相近，情感回应较为顺畅，但需要更多耐心与沟通。',
      highlights: [
        '五行互补明显，互相支持',
        '价值观相近，适合长期相处',
        '情绪波动期需注意节奏',
      ],
      advice: [
        '保持高频沟通，及时表达需求',
        '在重大决策上保持一致节奏',
        '给彼此保留成长空间',
      ],
    );
  }
}

class RelationshipReportResponse {
  final bool success;
  final RelationshipReport? report;
  final String? message;

  RelationshipReportResponse({
    required this.success,
    this.report,
    this.message,
  });
}

class RelationshipChatMessage {
  final String role;
  final String content;

  RelationshipChatMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

class RelationshipChatRequest {
  final RelationshipReport report;
  final List<RelationshipChatMessage> messages;
  final String language;

  RelationshipChatRequest({
    required this.report,
    required this.messages,
    required this.language,
  });

  Map<String, dynamic> toJson() => {
        'report': report.toJson(),
        'messages': messages.map((m) => m.toJson()).toList(),
        'language': language,
      };
}
