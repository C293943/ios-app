import 'package:flutter/material.dart';

/// 养成/羁绊值模型
/// 孵化值(0-100) -> 觉醒 -> 羁绊值(0-∞)
class CultivationModel {
  final int incubationValue; // 孵化值 0-100
  final int bondValue; // 羁绊值 (觉醒后)
  final bool isAwakened; // 是否已觉醒
  final DateTime lastUpdated;

  CultivationModel({
    required this.incubationValue,
    this.bondValue = 0,
    this.isAwakened = false,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// 获取当前显示的进度值
  double get displayProgress => isAwakened
      ? (bondValue % 1000) / 1000.0  // 羁绊值每1000为一个循环
      : incubationValue / 100.0;

  /// 获取当前等级
  int get currentLevel => isAwakened
      ? (bondValue / 1000).floor() + 1
      : 1;

  /// 增加孵化值
  CultivationModel addIncubation(int value) {
    final newValue = (incubationValue + value).clamp(0, 100);
    return CultivationModel(
      incubationValue: newValue,
      bondValue: bondValue,
      isAwakened: isAwakened,
      lastUpdated: DateTime.now(),
    );
  }

  /// 触发觉醒
  CultivationModel awaken() {
    if (incubationValue < 100) return this;
    return CultivationModel(
      incubationValue: 100,
      bondValue: 0,
      isAwakened: true,
      lastUpdated: DateTime.now(),
    );
  }

  /// 增加羁绊值
  CultivationModel addBond(int value) {
    if (!isAwakened) return this;
    return CultivationModel(
      incubationValue: incubationValue,
      bondValue: bondValue + value,
      isAwakened: true,
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'incubation_value': incubationValue,
        'bond_value': bondValue,
        'is_awakened': isAwakened,
        'last_updated': lastUpdated.toIso8601String(),
      };

  factory CultivationModel.fromJson(Map<String, dynamic> json) {
    return CultivationModel(
      incubationValue: json['incubation_value'] as int? ?? 0,
      bondValue: json['bond_value'] as int? ?? 0,
      isAwakened: json['is_awakened'] as bool? ?? false,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : null,
    );
  }

  /// 获取进度描述
  String get progressDescription {
    if (!isAwakened) {
      if (incubationValue < 30) return '灵气初现';
      if (incubationValue < 60) return '灵气汇聚';
      if (incubationValue < 90) return '即将觉醒';
      return '觉醒倒计时';
    } else {
      final level = currentLevel;
      if (level <= 3) return '初心元神';
      if (level <= 7) return '进阶元神';
      if (level <= 10) return '高阶元神';
      return '元神大师';
    }
  }
}

/// 五行占比模型
class FiveElementsModel {
  final Map<String, int> elements; // 木、火、土、金、水的占比
  final int totalQi; // 元气值总和

  FiveElementsModel({
    required this.elements,
    this.totalQi = 0,
  });

  /// 获取五行占比百分比
  Map<String, double> get percentages {
    if (totalQi == 0) {
      return {
        '木': 0.2,
        '火': 0.2,
        '土': 0.2,
        '金': 0.2,
        '水': 0.2,
      };
    }

    return elements.map((key, value) {
      return MapEntry(key, value / totalQi);
    });
  }

  /// 获取主导元素
  String get dominantElement {
    if (totalQi == 0) return '未定';
    final sorted = elements.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  /// 从八字数据创建五行模型
  factory FiveElementsModel.fromBazi(Map<String, int>? fiveElements) {
    if (fiveElements == null || fiveElements.isEmpty) {
      return FiveElementsModel(
        elements: {
          '木': 20,
          '火': 20,
          '土': 20,
          '金': 20,
          '水': 20,
        },
        totalQi: 100,
      );
    }

    final total = fiveElements.values.fold(0, (sum, val) => sum + val);
    return FiveElementsModel(
      elements: Map.from(fiveElements),
      totalQi: total,
    );
  }

  Map<String, dynamic> toJson() => {
        'elements': elements,
        'total_qi': totalQi,
      };

  factory FiveElementsModel.fromJson(Map<String, dynamic> json) {
    return FiveElementsModel(
      elements: Map<String, int>.from(json['elements'] as Map),
      totalQi: json['total_qi'] as int? ?? 0,
    );
  }

  /// 获取元素颜色
  static Color getElementColor(String element) {
    switch (element) {
      case '木':
        return const Color(0xFF4CAF50); // 绿色
      case '火':
        return const Color(0xFFFF5722); // 橙红色
      case '土':
        return const Color(0xFF795548); // 棕色
      case '金':
        return const Color(0xFFFFD700); // 金色
      case '水':
        return const Color(0xFF2196F3); // 蓝色
      default:
        return const Color(0xFF9E9E9E); // 灰色
    }
  }
}
