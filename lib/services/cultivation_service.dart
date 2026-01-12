import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 养成值服务 - 管理角色养成进度
class CultivationService extends ChangeNotifier {
  static const String _keyCultivationValue = 'cultivation_value';
  static const String _keyIsAwakened = 'is_awakened';
  static const int _maxCultivationValue = 100; // 觉醒所需养成值

  int _cultivationValue = 0;
  bool _isAwakened = false;

  int get cultivationValue => _cultivationValue;
  int get maxCultivationValue => _maxCultivationValue;
  bool get isAwakened => _isAwakened;
  double get progress => _cultivationValue / _maxCultivationValue;

  /// 初始化 - 从持久化存储加载
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cultivationValue = prefs.getInt(_keyCultivationValue) ?? 0;
      _isAwakened = prefs.getBool(_keyIsAwakened) ?? false;

      debugPrint('[CultivationService] 初始化完成: 养成值=$_cultivationValue, 已觉醒=$_isAwakened');
      notifyListeners();
    } catch (e) {
      debugPrint('[CultivationService] 初始化失败: $e');
      // 使用默认值
      _cultivationValue = 0;
      _isAwakened = false;
    }
  }

  /// 增加养成值
  /// [amount] 增加的数量，默认为10
  /// 返回是否达到觉醒条件
  Future<bool> addCultivationValue([int amount = 10]) async {
    if (_isAwakened) {
      debugPrint('[CultivationService] 已经觉醒，无法继续增加养成值');
      return false;
    }

    final oldValue = _cultivationValue;
    _cultivationValue = (_cultivationValue + amount).clamp(0, _maxCultivationValue);

    // 保存到持久化存储
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCultivationValue, _cultivationValue);

    debugPrint('[CultivationService] 养成值增加: $oldValue → $_cultivationValue');

    // 检查是否达到觉醒条件
    if (_cultivationValue >= _maxCultivationValue && !_isAwakened) {
      debugPrint('[CultivationService] 达到觉醒条件！');
      return true; // 返回true表示应该触发觉醒
    }

    notifyListeners();
    return false;
  }

  /// 手动觉醒（用于测试或跳过）
  Future<void> awaken() async {
    if (_isAwakened) {
      debugPrint('[CultivationService] 已经觉醒');
      return;
    }

    _isAwakened = true;
    _cultivationValue = _maxCultivationValue;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsAwakened, _isAwakened);
    await prefs.setInt(_keyCultivationValue, _cultivationValue);

    debugPrint('[CultivationService] 觉醒完成！');
    notifyListeners();
  }

  /// 重置养成值（用于测试）
  Future<void> reset() async {
    _cultivationValue = 0;
    _isAwakened = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCultivationValue, _cultivationValue);
    await prefs.setBool(_keyIsAwakened, _isAwakened);

    debugPrint('[CultivationService] 重置完成');
    notifyListeners();
  }

  /// 设置养成值（用于测试）
  Future<void> setCultivationValue(int value) async {
    _cultivationValue = value.clamp(0, _maxCultivationValue);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCultivationValue, _cultivationValue);

    debugPrint('[CultivationService] 设置养成值: $_cultivationValue');
    notifyListeners();
  }

  /// 获取当前阶段描述
  String getStageDescription() {
    if (_isAwakened) return '元神已觉醒';

    if (_cultivationValue < 20) return '凡胎初醒';
    if (_cultivationValue < 40) return '灵气初聚';
    if (_cultivationValue < 60) return '凝气化神';
    if (_cultivationValue < 80) return '元神初成';
    return '破境在即';
  }

  /// 获取下一阶段所需养成值
  int getNextStageThreshold() {
    if (_isAwakened) return _maxCultivationValue;

    if (_cultivationValue < 20) return 20;
    if (_cultivationValue < 40) return 40;
    if (_cultivationValue < 60) return 60;
    if (_cultivationValue < 80) return 80;
    return _maxCultivationValue;
  }

  /// 获取到下一阶段的进度
  double getNextStageProgress() {
    if (_isAwakened) return 1.0;

    final current = _cultivationValue;
    final next = getNextStageThreshold();
    final prev = current < 20 ? 0 : (current < 40 ? 20 : (current < 60 ? 40 : (current < 80 ? 60 : 80)));

    if (next == prev) return 1.0;
    return (current - prev) / (next - prev);
  }
}
