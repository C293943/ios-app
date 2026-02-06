import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:primordial_spirit/models/divination_models.dart';
import 'package:primordial_spirit/models/fortune_models.dart';
import 'package:primordial_spirit/services/fortune_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 单次掷币结果
class CoinCastResult {
  final List<bool> coinResults; // 三枚铜钱结果：true=阳（字面），false=阴（花面）
  final Yao yao;
  final int yaoIndex; // 0-5，初爻到上爻

  CoinCastResult({
    required this.coinResults,
    required this.yao,
    required this.yaoIndex,
  });
}

/// 问卜服务
/// 负责六爻卦象生成、解读获取和历史记录管理
class DivinationService {
  static final DivinationService _instance = DivinationService._internal();
  factory DivinationService() => _instance;
  DivinationService._internal();

  final FortuneApiService _fortuneApi = FortuneApiService();
  final Random _random = Random();

  // 本地存储键
  static const String _historyKey = 'divination_history';
  static const int _maxHistoryCount = 50;

  /// 流式生成六爻卦象
  /// 每次掷币返回一爻，配合动画同步显示
  Stream<CoinCastResult> generateHexagramStream(String question) async* {
    for (int i = 0; i < 6; i++) {
      // 模拟后端请求延迟
      if (i == 0) {
        // 首次短延迟，让UI准备好
        await Future.delayed(const Duration(milliseconds: 100));
      } else {
        // 后续等待动画完成：掷币动画2000ms + 爻显示动画600ms + 缓冲400ms
        await Future.delayed(const Duration(milliseconds: 3000));
      }
      
      // 生成三枚铜钱的结果
      final coinResults = <bool>[];
      int sum = 0;
      for (int j = 0; j < 3; j++) {
        final isYang = _random.nextBool();
        coinResults.add(isYang);
        sum += isYang ? 3 : 2; // 字面（阳）为3，花面（阴）为2
      }
      
      // 根据铜钱总数确定爻
      final yao = _sumToYao(sum);
      
      yield CoinCastResult(
        coinResults: coinResults,
        yao: yao,
        yaoIndex: i,
      );
    }
  }

  /// 生成六爻卦象（一次性返回，用于历史恢复等场景）
  Future<DivinationResult> generateHexagram(String question) async {
    // 生成六个爻
    final lines = <Yao>[];
    for (int i = 0; i < 6; i++) {
      final yao = _castYao();
      lines.add(yao);
    }

    return _buildResultFromLines(question, lines);
  }

  /// 从已生成的爻列表构建结果
  DivinationResult buildResultFromLines(String question, List<Yao> lines) {
    return _buildResultFromLines(question, lines);
  }

  DivinationResult _buildResultFromLines(String question, List<Yao> lines) {
    // 根据爻象确定卦名
    final linesKey = lines.map((y) => y.isYang ? '1' : '0').join();
    final hexagramName = HexagramData.nameByLines[linesKey] ?? '未知';
    final hexagramMeaning = HexagramData.getMeaning(hexagramName);

    // 创建本卦
    final primaryHexagram = Hexagram(
      name: hexagramName,
      lines: lines,
      meaning: hexagramMeaning,
    );

    // 如果有动爻，生成变卦
    Hexagram? changedHexagram;
    if (primaryHexagram.hasChangingLines) {
      changedHexagram = primaryHexagram.changedHexagram;
    }

    return DivinationResult(
      id: _generateId(),
      question: question,
      primaryHexagram: primaryHexagram,
      changedHexagram: changedHexagram,
    );
  }

  /// 根据铜钱总数确定爻
  Yao _sumToYao(int sum) {
    switch (sum) {
      case 6: // 老阴 - 阴爻且为动爻
        return const Yao(isYang: false, isChanging: true);
      case 7: // 少阳 - 阳爻
        return const Yao(isYang: true, isChanging: false);
      case 8: // 少阴 - 阴爻
        return const Yao(isYang: false, isChanging: false);
      case 9: // 老阳 - 阳爻且为动爻
        return const Yao(isYang: true, isChanging: true);
      default:
        return const Yao(isYang: true, isChanging: false);
    }
  }

  /// 模拟铜钱法生成单爻（兼容旧代码）
  Yao _castYao() {
    int sum = 0;
    for (int i = 0; i < 3; i++) {
      sum += _random.nextBool() ? 3 : 2;
    }
    return _sumToYao(sum);
  }

  /// 获取卦象解读（流式返回）
  /// 调用现有的 fortune API 进行 AI 解读
  Stream<String> getInterpretation(
    DivinationResult result,
    List<DivinationMessage> chatHistory, {
    FortuneData? fortuneData,
    String language = '中文',
  }) async* {
    // 构建解读提示
    final prompt = _buildInterpretationPrompt(result, chatHistory);

    // 如果有命盘数据，使用 fortune API
    if (fortuneData != null) {
      final messages = <ChatMessageModel>[
        ChatMessageModel(role: 'system', content: _getSystemPrompt()),
        ...chatHistory.map((m) => ChatMessageModel(
              role: m.isUser ? 'user' : 'assistant',
              content: m.text,
            )),
        ChatMessageModel(role: 'user', content: prompt),
      ];

      final request = FortuneRequest(
        birthInfo: fortuneData.birthInfo,
        baziInfo: fortuneData.baziInfo,
        ziweiInfo: fortuneData.ziweiInfo,
        messages: messages,
        language: language,
      );

      yield* _fortuneApi.fortuneStream(
        request,
        connectionId: 'divination_${result.id}',
      );
    } else {
      // 没有命盘数据，使用 Mock 解读
      yield* _mockInterpretation(result, chatHistory);
    }
  }

  /// 构建解读提示
  String _buildInterpretationPrompt(
    DivinationResult result,
    List<DivinationMessage> chatHistory,
  ) {
    final buffer = StringBuffer();

    if (chatHistory.isEmpty) {
      // 首次解读
      buffer.writeln('请根据以下六爻卦象为我解读：');
      buffer.writeln();
      buffer.writeln('【问题】${result.question}');
      buffer.writeln();
      buffer.writeln('【本卦】${result.primaryHexagram.name}');
      buffer.writeln('卦象：${_formatHexagram(result.primaryHexagram)}');
      buffer.writeln('卦辞：${result.primaryHexagram.meaning}');

      if (result.changedHexagram != null) {
        buffer.writeln();
        buffer.writeln('【变卦】${result.changedHexagram!.name}');
        buffer.writeln('卦象：${_formatHexagram(result.changedHexagram!)}');
        buffer.writeln('卦辞：${result.changedHexagram!.meaning}');
      }

      buffer.writeln();
      buffer.writeln('请从以下方面进行解读：');
      buffer.writeln('1. 卦象总体寓意');
      buffer.writeln('2. 针对所问问题的具体指导');
      buffer.writeln('3. 需要注意的事项');
      buffer.writeln('4. 吉凶趋势与建议');
    } else {
      // 后续追问
      buffer.writeln('基于之前的卦象解读，请继续回答我的问题。');
    }

    return buffer.toString();
  }

  /// 格式化卦象为文字描述
  String _formatHexagram(Hexagram hexagram) {
    final lines = hexagram.lines.reversed.map((yao) {
      if (yao.isYang) {
        return yao.isChanging ? '老阳○' : '阳—';
      } else {
        return yao.isChanging ? '老阴×' : '阴--';
      }
    }).join(' | ');
    return lines;
  }

  /// 系统提示词
  String _getSystemPrompt() {
    return '''
你是一位精通周易六爻的智慧长者。你需要根据用户摇出的卦象，为其解读吉凶、指点迷津。

解读原则：
1. 结合卦象本身的含义和用户的具体问题
2. 如有变卦，需解读本卦到变卦的变化趋势
3. 语言要温和智慧，给予正面引导
4. 可以适当引用卦辞和爻辞
5. 保持神秘感但不要迷信，注重实际建议

请用流畅优雅的中文进行解读。
''';
  }

  /// Mock 解读（无命盘数据时使用）
  Stream<String> _mockInterpretation(
    DivinationResult result,
    List<DivinationMessage> chatHistory,
  ) async* {
    final hexName = result.primaryHexagram.name;
    final meaning = result.primaryHexagram.meaning;
    final hasChanged = result.changedHexagram != null;

    if (chatHistory.isEmpty) {
      // 首次解读
      final interpretations = [
        '观此卦象，$hexName卦现于眼前。',
        '\n\n$meaning',
        '\n\n针对您所问"${result.question}"，',
        '此卦显示目前的态势',
        hasChanged ? '正处于变化之中。' : '较为稳定。',
        '\n\n',
        _getSpecificInterpretation(hexName),
        '\n\n综合来看，',
        _getOverallAdvice(hexName, hasChanged),
        '\n\n如有疑问，请继续询问。',
      ];

      for (final chunk in interpretations) {
        await Future.delayed(const Duration(milliseconds: 200));
        yield chunk;
      }
    } else {
      // 后续追问的模拟回复
      final responses = [
        '根据您的追问，再观此卦，',
        '可以进一步说明：',
        '\n\n$hexName卦的核心要义在于',
        _getHexagramKeyPoint(hexName),
        '\n\n建议您',
        _getActionAdvice(hexName),
      ];

      for (final chunk in responses) {
        await Future.delayed(const Duration(milliseconds: 150));
        yield chunk;
      }
    }
  }

  String _getSpecificInterpretation(String hexName) {
    final interpretations = {
      '乾': '乾为天，主刚健进取。此时宜自强不息，积极行动，但需注意不可过于冒进。',
      '坤': '坤为地，主厚德载物。此时宜柔顺谦逊，稳扎稳打，静待时机。',
      '屯': '屯卦象征初生之困，万事开头难。需有耐心，循序渐进。',
      '蒙': '蒙卦启示启蒙之道，宜虚心学习，请教高人。',
      '需': '需卦示意等待时机，不可急躁，静候佳音。',
      '讼': '讼卦警示争讼之凶，宜和为贵，避免冲突。',
      '师': '师卦象征众军出征，行事需正，方可成功。',
      '比': '比卦主亲比和睦，宜广结善缘，团结合作。',
    };
    return interpretations[hexName] ?? 
        '此卦寓意深远，需结合具体情况仔细体会。当前形势变化中孕育着机遇。';
  }

  String _getOverallAdvice(String hexName, bool hasChanged) {
    if (hasChanged) {
      return '卦有变爻，表明事态正在转变。宜顺势而为，把握变化中的机遇，同时做好应对准备。';
    }
    return '卦象稳定，表明当前态势明朗。可按既定方向稳步推进，保持定力。';
  }

  String _getHexagramKeyPoint(String hexName) {
    final keyPoints = {
      '乾': '天行健，君子以自强不息。',
      '坤': '地势坤，君子以厚德载物。',
      '泰': '天地交泰，阴阳和谐。',
      '否': '天地不交，闭塞不通，需耐心等待。',
    };
    return keyPoints[hexName] ?? '顺应天时，审时度势。';
  }

  String _getActionAdvice(String hexName) {
    final advices = {
      '乾': '把握时机，果断行动，但需量力而行。',
      '坤': '韬光养晦，积蓄力量，静待天时。',
      '泰': '趁势而上，广开合作，共创佳绩。',
      '否': '退守观望，保存实力，以待转机。',
    };
    return advices[hexName] ?? '审慎行事，进退有度，吉无不利。';
  }

  /// 取消解读流
  void cancelInterpretation(String resultId) {
    _fortuneApi.cancelFortuneStream(connectionId: 'divination_$resultId');
  }

  // ============ 历史记录管理 ============

  /// 保存会话到本地
  Future<void> saveSession(DivinationSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      
      List<DivinationSession> history = [];
      if (historyJson != null) {
        final historyList = jsonDecode(historyJson) as List;
        history = historyList
            .map((item) => DivinationSession.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      // 更新或添加会话
      final existingIndex = history.indexWhere((s) => s.id == session.id);
      if (existingIndex >= 0) {
        history[existingIndex] = session;
      } else {
        history.insert(0, session);
      }

      // 限制历史记录数量
      if (history.length > _maxHistoryCount) {
        history = history.sublist(0, _maxHistoryCount);
      }

      // 保存
      final newHistoryJson = jsonEncode(history.map((s) => s.toJson()).toList());
      await prefs.setString(_historyKey, newHistoryJson);
      
      debugPrint('[DivinationService] 会话已保存: ${session.id}');
    } catch (e) {
      debugPrint('[DivinationService] 保存会话失败: $e');
    }
  }

  /// 获取历史记录
  Future<List<DivinationSession>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      
      if (historyJson == null) return [];

      final historyList = jsonDecode(historyJson) as List;
      return historyList
          .map((item) => DivinationSession.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[DivinationService] 获取历史记录失败: $e');
      return [];
    }
  }

  /// 删除单条历史记录
  Future<void> deleteSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      
      if (historyJson == null) return;

      final historyList = jsonDecode(historyJson) as List;
      final history = historyList
          .map((item) => DivinationSession.fromJson(item as Map<String, dynamic>))
          .where((s) => s.id != sessionId)
          .toList();

      final newHistoryJson = jsonEncode(history.map((s) => s.toJson()).toList());
      await prefs.setString(_historyKey, newHistoryJson);
      
      debugPrint('[DivinationService] 会话已删除: $sessionId');
    } catch (e) {
      debugPrint('[DivinationService] 删除会话失败: $e');
    }
  }

  /// 清空所有历史记录
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      debugPrint('[DivinationService] 历史记录已清空');
    } catch (e) {
      debugPrint('[DivinationService] 清空历史记录失败: $e');
    }
  }

  /// 生成唯一 ID
  String _generateId() {
    return 'div_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}';
  }
}
