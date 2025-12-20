import 'package:primordial_spirit/models/fortune_models.dart';

/// 八字到3D提示词转换服务
/// 根据八字信息和性别生成适合文生3D的提示词（精简版，适配600字符限制）
class BaziTo3dPromptService {
  static final BaziTo3dPromptService _instance =
      BaziTo3dPromptService._internal();
  factory BaziTo3dPromptService() => _instance;
  BaziTo3dPromptService._internal();

  /// 五行视觉元素（精简版）
  static const Map<String, ElementVisual> _elementVisuals = {
    '木': ElementVisual(color: 'jade green', aura: 'green nature aura', trait: 'gentle'),
    '火': ElementVisual(color: 'crimson red', aura: 'fiery red aura', trait: 'passionate'),
    '土': ElementVisual(color: 'golden brown', aura: 'golden earth aura', trait: 'stable'),
    '金': ElementVisual(color: 'silver white', aura: 'silver sharp aura', trait: 'noble'),
    '水': ElementVisual(color: 'deep blue', aura: 'blue flowing aura', trait: 'wise'),
  };

  /// 天干到五行映射
  static const Map<String, String> _stemToElement = {
    '甲': '木', '乙': '木', '丙': '火', '丁': '火', '戊': '土',
    '己': '土', '庚': '金', '辛': '金', '壬': '水', '癸': '水',
  };

  /// 生成3D提示词（控制在500字符以内）
  String generatePrompt({
    required BaziInfo baziInfo,
    required String gender,
  }) {
    final dayMaster = baziInfo.dayGan;
    final element = _getDominantElement(baziInfo);
    final visual = _elementVisuals[element] ?? _elementVisuals['土']!;

    final genderWord = gender == '男' ? 'male' : 'female';
    final genderTrait = gender == '男' ? 'masculine, strong' : 'feminine, elegant';

    // 精简提示词，确保不超过500字符
    return 'Chinese celestial $genderWord deity avatar, $genderTrait features, '
        'full body, ${visual.color} theme, $element element, '
        'ancient robes, ${visual.aura}, ${visual.trait} expression, '
        'fantasy style, ethereal glow, detailed face, symmetrical';
  }

  /// 生成贴图提示词（用于精细化阶段）
  String generateTexturePrompt({
    required BaziInfo baziInfo,
    required String gender,
  }) {
    final element = _getElementFromStem(baziInfo.dayGan);
    final visual = _elementVisuals[element] ?? _elementVisuals['土']!;

    return '${visual.color} celestial robes, ${visual.aura}, mystical patterns, detailed fabric';
  }

  /// 获取主导五行
  String _getDominantElement(BaziInfo baziInfo) {
    // 优先使用五行力量百分比
    if (baziInfo.fiveElementsStrength != null &&
        baziInfo.fiveElementsStrength!.isNotEmpty) {
      final sorted = baziInfo.fiveElementsStrength!.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return sorted.first.key;
    }

    // 其次使用五行个数
    if (baziInfo.fiveElements != null && baziInfo.fiveElements!.isNotEmpty) {
      final sorted = baziInfo.fiveElements!.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return sorted.first.key;
    }

    // 根据日干推断五行
    return _getElementFromStem(baziInfo.dayGan);
  }

  /// 根据天干获取五行
  String _getElementFromStem(String stem) {
    return _stemToElement[stem] ?? '土';
  }
}

/// 五行视觉元素（精简版）
class ElementVisual {
  final String color;
  final String aura;
  final String trait;

  const ElementVisual({
    required this.color,
    required this.aura,
    required this.trait,
  });
}
