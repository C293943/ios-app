import 'dart:convert';

/// 单爻模型
/// 六爻卦象由六个爻组成，从下到上分别为初爻到上爻
class Yao {
  /// 爻的阴阳：true=阳爻(—)，false=阴爻(--)
  final bool isYang;
  
  /// 是否为动爻（变爻）
  final bool isChanging;

  const Yao({
    required this.isYang,
    this.isChanging = false,
  });

  /// 获取变化后的爻（动爻变化）
  Yao get changed => Yao(isYang: !isYang, isChanging: false);

  Map<String, dynamic> toJson() => {
    'is_yang': isYang,
    'is_changing': isChanging,
  };

  factory Yao.fromJson(Map<String, dynamic> json) => Yao(
    isYang: json['is_yang'] as bool,
    isChanging: json['is_changing'] as bool? ?? false,
  );

  @override
  String toString() => isYang ? (isChanging ? '○' : '—') : (isChanging ? '×' : '--');
}

/// 六爻卦象模型
class Hexagram {
  /// 卦名
  final String name;
  
  /// 六个爻，从下到上（索引0是初爻，索引5是上爻）
  final List<Yao> lines;
  
  /// 卦辞
  final String meaning;
  
  /// 上卦名（外卦）
  final String? upperTrigram;
  
  /// 下卦名（内卦）
  final String? lowerTrigram;

  const Hexagram({
    required this.name,
    required this.lines,
    this.meaning = '',
    this.upperTrigram,
    this.lowerTrigram,
  });

  /// 检查是否有动爻
  bool get hasChangingLines => lines.any((yao) => yao.isChanging);

  /// 获取变卦（所有动爻变化后的卦）
  Hexagram get changedHexagram {
    if (!hasChangingLines) return this;
    final newLines = lines.map((yao) => yao.isChanging ? yao.changed : yao).toList();
    return Hexagram(
      name: _findHexagramName(newLines),
      lines: newLines,
      meaning: _findHexagramMeaning(newLines),
    );
  }

  /// 根据爻象查找卦名
  static String _findHexagramName(List<Yao> lines) {
    final key = lines.map((y) => y.isYang ? '1' : '0').join();
    return HexagramData.nameByLines[key] ?? '未知';
  }

  /// 根据爻象查找卦辞
  static String _findHexagramMeaning(List<Yao> lines) {
    final key = lines.map((y) => y.isYang ? '1' : '0').join();
    final name = HexagramData.nameByLines[key];
    if (name != null) {
      return HexagramData.meanings[name] ?? '';
    }
    return '';
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'lines': lines.map((y) => y.toJson()).toList(),
    'meaning': meaning,
    if (upperTrigram != null) 'upper_trigram': upperTrigram,
    if (lowerTrigram != null) 'lower_trigram': lowerTrigram,
  };

  factory Hexagram.fromJson(Map<String, dynamic> json) => Hexagram(
    name: json['name'] as String,
    lines: (json['lines'] as List).map((y) => Yao.fromJson(y as Map<String, dynamic>)).toList(),
    meaning: json['meaning'] as String? ?? '',
    upperTrigram: json['upper_trigram'] as String?,
    lowerTrigram: json['lower_trigram'] as String?,
  );
}

/// 问卜结果模型
class DivinationResult {
  /// 唯一标识
  final String id;
  
  /// 用户的问题
  final String question;
  
  /// 本卦
  final Hexagram primaryHexagram;
  
  /// 变卦（如果有动爻）
  final Hexagram? changedHexagram;
  
  /// 问卜时间
  final DateTime createdAt;

  DivinationResult({
    required this.id,
    required this.question,
    required this.primaryHexagram,
    this.changedHexagram,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 是否有变卦
  bool get hasChanged => changedHexagram != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'primary_hexagram': primaryHexagram.toJson(),
    if (changedHexagram != null) 'changed_hexagram': changedHexagram!.toJson(),
    'created_at': createdAt.toIso8601String(),
  };

  factory DivinationResult.fromJson(Map<String, dynamic> json) => DivinationResult(
    id: json['id'] as String,
    question: json['question'] as String,
    primaryHexagram: Hexagram.fromJson(json['primary_hexagram'] as Map<String, dynamic>),
    changedHexagram: json['changed_hexagram'] != null
        ? Hexagram.fromJson(json['changed_hexagram'] as Map<String, dynamic>)
        : null,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  String toJsonString() => jsonEncode(toJson());

  factory DivinationResult.fromJsonString(String jsonString) =>
      DivinationResult.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}

/// 问卜会话消息
class DivinationMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  DivinationMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'text': text,
    'is_user': isUser,
    'timestamp': timestamp.toIso8601String(),
  };

  factory DivinationMessage.fromJson(Map<String, dynamic> json) => DivinationMessage(
    text: json['text'] as String,
    isUser: json['is_user'] as bool,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

/// 问卜会话模型（包含结果和对话历史）
class DivinationSession {
  /// 会话唯一标识
  final String id;
  
  /// 问卜结果
  final DivinationResult result;
  
  /// 对话消息列表
  final List<DivinationMessage> messages;
  
  /// 会话创建时间
  final DateTime createdAt;
  
  /// 会话更新时间
  DateTime updatedAt;

  DivinationSession({
    required this.id,
    required this.result,
    List<DivinationMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : messages = messages ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 添加消息
  void addMessage(DivinationMessage message) {
    messages.add(message);
    updatedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'result': result.toJson(),
    'messages': messages.map((m) => m.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory DivinationSession.fromJson(Map<String, dynamic> json) => DivinationSession(
    id: json['id'] as String,
    result: DivinationResult.fromJson(json['result'] as Map<String, dynamic>),
    messages: (json['messages'] as List?)
        ?.map((m) => DivinationMessage.fromJson(m as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  String toJsonString() => jsonEncode(toJson());

  factory DivinationSession.fromJsonString(String jsonString) =>
      DivinationSession.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}

/// 六十四卦数据
class HexagramData {
  HexagramData._();

  /// 八卦基础数据（三爻卦）
  static const Map<String, String> trigrams = {
    '111': '乾', // ☰
    '000': '坤', // ☷
    '100': '震', // ☳
    '010': '坎', // ☵
    '001': '艮', // ☶
    '110': '巽', // ☴
    '101': '离', // ☲
    '011': '兑', // ☱
  };

  /// 根据爻象（6位二进制字符串）查找卦名
  static const Map<String, String> nameByLines = {
    '111111': '乾',
    '000000': '坤',
    '100010': '屯',
    '010001': '蒙',
    '111010': '需',
    '010111': '讼',
    '010000': '师',
    '000010': '比',
    '111011': '小畜',
    '110111': '履',
    '111000': '泰',
    '000111': '否',
    '101111': '同人',
    '111101': '大有',
    '001000': '谦',
    '000100': '豫',
    '100110': '随',
    '011001': '蛊',
    '110000': '临',
    '000011': '观',
    '100101': '噬嗑',
    '101001': '贲',
    '000001': '剥',
    '100000': '复',
    '100111': '无妄',
    '111001': '大畜',
    '100001': '颐',
    '011110': '大过',
    '010010': '坎',
    '101101': '离',
    '001110': '咸',
    '011100': '恒',
    '001111': '遁',
    '111100': '大壮',
    '000101': '晋',
    '101000': '明夷',
    '101011': '家人',
    '110101': '睽',
    '001010': '蹇',
    '010100': '解',
    '110001': '损',
    '100011': '益',
    '111110': '夬',
    '011111': '姤',
    '000110': '萃',
    '011000': '升',
    '010110': '困',
    '011010': '井',
    '101110': '革',
    '011101': '鼎',
    '100100': '震',
    '001001': '艮',
    '001011': '渐',
    '110100': '归妹',
    '101100': '丰',
    '001101': '旅',
    '011011': '巽',
    '110110': '兑',
    '010011': '涣',
    '110010': '节',
    '110011': '中孚',
    '001100': '小过',
    '101010': '既济',
    '010101': '未济',
  };

  /// 卦辞
  static const Map<String, String> meanings = {
    '乾': '元亨利贞。乾为天，刚健中正，自强不息。',
    '坤': '元亨，利牝马之贞。坤为地，厚德载物，顺承天道。',
    '屯': '元亨利贞，勿用有攸往，利建侯。万物始生，艰难之象。',
    '蒙': '亨。匪我求童蒙，童蒙求我。启蒙教化，循序渐进。',
    '需': '有孚，光亨，贞吉，利涉大川。等待时机，蓄势待发。',
    '讼': '有孚窒，惕中吉，终凶。争讼之象，宜和为贵。',
    '师': '贞，丈人吉，无咎。众军之象，以正为本。',
    '比': '吉。原筮，元永贞，无咎。亲比和睦，团结友爱。',
    '小畜': '亨。密云不雨，自我西郊。积小成大，渐进蓄积。',
    '履': '履虎尾，不咥人，亨。谨慎行事，知进知退。',
    '泰': '小往大来，吉亨。天地交泰，万物通达。',
    '否': '否之匪人，不利君子贞，大往小来。天地不交，闭塞不通。',
    '同人': '同人于野，亨，利涉大川，利君子贞。志同道合，和衷共济。',
    '大有': '元亨。丰盛富足，光明正大。',
    '谦': '亨，君子有终。谦虚谨慎，受益无穷。',
    '豫': '利建侯行师。顺时而动，和乐安详。',
    '随': '元亨利贞，无咎。随时而变，因势利导。',
    '蛊': '元亨，利涉大川。振衰起弊，革故鼎新。',
    '临': '元亨利贞，至于八月有凶。居高临下，教化众生。',
    '观': '盥而不荐，有孚颙若。观察入微，以德化人。',
    '噬嗑': '亨，利用狱。明断是非，惩恶扬善。',
    '贲': '亨，小利有攸往。文饰修养，内实外华。',
    '剥': '不利有攸往。剥落衰落，静待时变。',
    '复': '亨。出入无疾，朋来无咎。一阳来复，生机萌动。',
    '无妄': '元亨利贞。无妄之行，真诚守正。',
    '大畜': '利贞，不家食吉，利涉大川。蓄德积才，厚积薄发。',
    '颐': '贞吉，观颐，自求口实。颐养正道，慎言节食。',
    '大过': '栋桡，利有攸往，亨。非常之时，非常之举。',
    '坎': '习坎，有孚，维心亨，行有尚。坎险重重，诚信可济。',
    '离': '利贞，亨，畜牝牛吉。光明附丽，柔顺以正。',
    '咸': '亨，利贞，取女吉。感应相通，阴阳和合。',
    '恒': '亨，无咎，利贞，利有攸往。恒久不变，持之以恒。',
    '遁': '亨，小利贞。退避隐遁，以守为攻。',
    '大壮': '利贞。刚强壮盛，正大光明。',
    '晋': '康侯用锡马蕃庶，昼日三接。进取向上，光明磊落。',
    '明夷': '利艰贞。韬光养晦，守正待时。',
    '家人': '利女贞。齐家治国，内外有别。',
    '睽': '小事吉。乖违睽异，求同存异。',
    '蹇': '利西南，不利东北，利见大人，贞吉。艰难险阻，知难而进。',
    '解': '利西南，无所往，其来复吉。解除困难，舒缓紧张。',
    '损': '有孚，元吉，无咎，可贞，利有攸往。损己利人，先损后益。',
    '益': '利有攸往，利涉大川。增益进取，自强不息。',
    '夬': '扬于王庭，孚号有厉，告自邑，不利即戎，利有攸往。决断果敢，刚健有为。',
    '姤': '女壮，勿用取女。邂逅相遇，一阴生于下。',
    '萃': '亨，王假有庙，利见大人，亨，利贞。聚集会合，众志成城。',
    '升': '元亨，用见大人，勿恤，南征吉。上升进取，循序渐进。',
    '困': '亨，贞，大人吉，无咎，有言不信。困境之中，守正待变。',
    '井': '改邑不改井，无丧无得，往来井井。养民济众，泽被苍生。',
    '革': '己日乃孚，元亨利贞，悔亡。变革更新，顺天应人。',
    '鼎': '元吉，亨。鼎新革故，成就大业。',
    '震': '亨，震来虩虩，笑言哑哑。震动奋发，警惕自省。',
    '艮': '艮其背，不获其身，行其庭，不见其人，无咎。止于至善，静定安止。',
    '渐': '女归吉，利贞。循序渐进，积少成多。',
    '归妹': '征凶，无攸利。归嫁之象，顺从以归。',
    '丰': '亨，王假之，勿忧，宜日中。丰盛鼎盛，盛极思危。',
    '旅': '小亨，旅贞吉。旅途之象，谨慎行事。',
    '巽': '小亨，利有攸往，利见大人。顺从入内，渗透感化。',
    '兑': '亨，利贞。喜悦和乐，以和为贵。',
    '涣': '亨，王假有庙，利涉大川，利贞。涣散流通，聚散有时。',
    '节': '亨，苦节不可贞。节制有度，不可过甚。',
    '中孚': '豚鱼吉，利涉大川，利贞。诚信感物，贯通天地。',
    '小过': '亨，利贞，可小事，不可大事。飞鸟之象，宜下不宜上。',
    '既济': '亨小，利贞，初吉终乱。功成名就，居安思危。',
    '未济': '亨，小狐汔济，濡其尾，无攸利。尚未完成，继续努力。',
  };

  /// 根据卦名获取爻象
  static List<Yao>? getLinesByName(String name) {
    final entry = nameByLines.entries.where((e) => e.value == name).firstOrNull;
    if (entry != null) {
      return entry.key.split('').map((c) => Yao(isYang: c == '1')).toList();
    }
    return null;
  }

  /// 根据卦名获取卦辞
  static String getMeaning(String name) {
    return meanings[name] ?? '';
  }
}
