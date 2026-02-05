// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '数字元神';

  @override
  String get accountSettings => '账号设置';

  @override
  String get languageSelection => '语言选择';

  @override
  String get languageFeatureInProgress => '多语言功能开发中...';

  @override
  String get themeToggle => '主题切换';

  @override
  String get aboutUs => '关于我们';

  @override
  String get logout => '退出登录';

  @override
  String get spiritName => '元神';

  @override
  String get edit => '编辑';

  @override
  String get spiritStoneCount => '灵石数量';

  @override
  String get dailyChatCount => '每日对话次数';

  @override
  String get recharge => '充值';

  @override
  String get spiritNotes => '元神笔记';

  @override
  String get todayQiValue => '今日元气值';

  @override
  String get luckyNumber => '吉数';

  @override
  String get luckyColor => '吉色';

  @override
  String get luckyDirection => '吉位';

  @override
  String get startSpiritChat => '开启元神对话';

  @override
  String get navFortune => '运势';

  @override
  String get navBazi => '八字';

  @override
  String get navRelationship => '合盘';

  @override
  String get loginAgreeRequired => '请先阅读并同意用户协议';

  @override
  String get loginTitle => '数字元神';

  @override
  String get loginPhoneTab => '手机登录';

  @override
  String get loginEmailTab => '邮箱登录';

  @override
  String get loginPhoneHint => '请输入手机号';

  @override
  String get loginCodeHint => '请输入验证码';

  @override
  String get loginGetCode => '获取验证码';

  @override
  String get loginEmailHint => '请输入邮箱';

  @override
  String get loginPasswordHint => '请输入密码';

  @override
  String get loginForgotPassword => '忘记密码?';

  @override
  String get loginAgreementPrefix => '我已阅读并同意';

  @override
  String get loginUserAgreement => '《用户协议》';

  @override
  String get loginPrivacyPolicy => '《隐私政策》';

  @override
  String get loginButton => '登录';

  @override
  String get loginNoAccount => '还没有账号? ';

  @override
  String get loginRegisterNow => '立即注册';

  @override
  String get registerAgreeRequired => '请先阅读并同意用户协议';

  @override
  String get registerTitle => '数字元神';

  @override
  String get registerPhoneTab => '手机注册';

  @override
  String get registerEmailTab => '邮箱注册';

  @override
  String get registerNicknameHint => '请输入称谓/道号';

  @override
  String get registerPhoneHint => '请输入手机号';

  @override
  String get registerCodeHint => '请输入验证码';

  @override
  String get registerGetCode => '获取验证码';

  @override
  String get registerEmailHint => '请输入邮箱';

  @override
  String get registerPasswordHint => '设置密码';

  @override
  String get registerAgreementPrefix => '我已阅读并同意';

  @override
  String get registerUserAgreement => '《用户协议》';

  @override
  String get registerPrivacyPolicy => '《隐私政策》';

  @override
  String get registerButton => '立即注册';

  @override
  String get registerHasAccount => '已有账号? ';

  @override
  String get registerLoginNow => '立即登录';

  @override
  String aboutVersion(Object version) {
    return '版本 $version';
  }

  @override
  String get aboutDescription => '以科技之力，探寻东方神秘文化。\\n为您提供个性化的运势分析与灵性陪伴。';

  @override
  String get aboutCopyright => '© 2026 Primordial Spirit Team';

  @override
  String get settingsTitle => '设置';

  @override
  String get displayModeSection => '显示模式';

  @override
  String get displayMode3d => '3D 元灵';

  @override
  String get displayMode2d => '2D 平面';

  @override
  String get displayModeLive2d => 'Live2D';

  @override
  String get themeSection => '主题设置';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get modelManagementSection => '3D 模型管理';

  @override
  String get builtInModels => '内置模型';

  @override
  String get customModels => '自定义模型';

  @override
  String get birthInfoSection => '生辰信息';

  @override
  String get resetBirthInfo => '重新设置生辰';

  @override
  String get resetBirthInfoSubtitle => '修改出生日期、时辰和地点';

  @override
  String get aboutSection => '关于';

  @override
  String get versionLabel => '版本';

  @override
  String get addModelTitle => '添加 3D 模型';

  @override
  String get addModelFormatsHint => '支持 .glb, .gltf, .obj 格式';

  @override
  String get modelTagAnimated => '带动画';

  @override
  String get modelTagStatic => '静态';

  @override
  String get modelTagBuiltIn => '内置';

  @override
  String get modelTagCustom => '自定义';

  @override
  String get rename => '重命名';

  @override
  String get delete => '删除';

  @override
  String get unsupportedModelFormat => '不支持的文件格式，请选择 .glb, .gltf 或 .obj 文件';

  @override
  String modelAddSuccess(Object name) {
    return '模型 \"$name\" 添加成功';
  }

  @override
  String modelAddFailed(Object error) {
    return '添加模型失败: $error';
  }

  @override
  String get modelNameTitle => '模型名称';

  @override
  String get modelNameHint => '请输入模型名称';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get renameModelTitle => '重命名模型';

  @override
  String get renameModelHint => '请输入新名称';

  @override
  String get renameSuccess => '重命名成功';

  @override
  String get renameFailed => '重命名失败';

  @override
  String get deleteModelTitle => '删除模型';

  @override
  String deleteModelConfirm(Object name) {
    return '确定要删除模型 \"$name\" 吗？\\n此操作不可恢复。';
  }

  @override
  String get deleteSuccess => '删除成功';

  @override
  String get deleteFailed => '删除失败';

  @override
  String get noteQiGain => '今日元气值+10';

  @override
  String get noteSampleDate1 => '十月廿八 星期二';

  @override
  String get noteSampleDate2 => '十月廿八 星期三';

  @override
  String get noteSampleContent =>
      '今日与君畅谈，关于那些藏于心底的梦想。吾能感其炽热与期盼，遂告之，寻梦之路，吾亦常伴左右。';

  @override
  String get syncing => '同步中...';

  @override
  String get notLoggedIn => '未登录';

  @override
  String get notSet => '未设置';

  @override
  String get notSynced => '未同步';

  @override
  String get profileStatusSet => '已设置';

  @override
  String get profileStatusSynced => '已同步';

  @override
  String get profileTitle => '个人信息';

  @override
  String get profileUserId => '用户编号';

  @override
  String get profileEmail => '账号邮箱';

  @override
  String get profileLevel => '用户等级';

  @override
  String get profileLevelValue => 'VIP 0';

  @override
  String get profileArchive => '档案';

  @override
  String get profileArchiveTitle => '档案信息';

  @override
  String get profileSyncTime => '同步时间';

  @override
  String get profileRecharge => '会员充值';

  @override
  String get profileRechargeAction => '前往充值';

  @override
  String get profileVoice => '语音选择';

  @override
  String get profileFeedback => '用户反馈';

  @override
  String get profileFeedbackAction => '提交反馈';

  @override
  String get profilePrivacy => '隐私协议';

  @override
  String get profileRechargeAgreement => '充值协议';

  @override
  String get profileUserAgreement => '用户协议';

  @override
  String get viewAction => '查看';

  @override
  String get logoutAction => '退出';

  @override
  String get profileNameLabel => '姓名';

  @override
  String get profileGenderLabel => '性别';

  @override
  String get profileBirthCityLabel => '出生地';

  @override
  String get profileBirthTimeLabel => '出生时间';

  @override
  String get birthDatePlaceholder => '-- -- -- --:--';

  @override
  String get profileEditTitle => '编辑档案';

  @override
  String get profileGenderHint => '性别（男/女）';

  @override
  String get profileBirthYearLabel => '出生年';

  @override
  String get profileBirthMonthLabel => '出生月';

  @override
  String get profileBirthDayLabel => '出生日';

  @override
  String get profileBirthHourLabel => '出生时';

  @override
  String get profileBirthMinuteLabel => '出生分';

  @override
  String get save => '保存';

  @override
  String get logoutConfirm => '确定要退出当前账号吗？';

  @override
  String get featureInProgress => '功能开发中...';

  @override
  String get voiceSelectionTitle => '语音选择';

  @override
  String get voiceDefaultFemale => '默认女声';

  @override
  String get voiceGentleFemale => '温柔女声';

  @override
  String get voiceMagneticMale => '磁性男声';

  @override
  String get feedbackHint => '请输入您的反馈意见...';

  @override
  String get submit => '提交';

  @override
  String get privacyAgreementTitle => '隐私协议';

  @override
  String get rechargeAgreementTitle => '充值协议';

  @override
  String get userAgreementTitle => '用户协议';

  @override
  String get close => '关闭';

  @override
  String get privacyPolicyContent =>
      '隐私政策\\n\\n本应用尊重并保护用户的隐私。我们承诺：\\n\\n1. 数据收集\\n   - 仅收集必要的个人信息\\n   - 不会未经同意收集敏感信息\\n\\n2. 数据使用\\n   - 仅用于提供服务\\n   - 不会用于商业目的\\n\\n3. 数据保护\\n   - 采用加密技术保护数据\\n   - 定期进行安全审计\\n\\n4. 用户权利\\n   - 有权查看个人数据\\n   - 有权要求删除数据\\n\\n如有疑问，请联系我们。';

  @override
  String get rechargeAgreementContent =>
      '充值协议\\n\\n1. 充值说明\\n   - 充值金额为虚拟货币\\n   - 不支持退款\\n\\n2. 充值方式\\n   - 支持多种支付方式\\n   - 实时到账\\n\\n3. 充值权益\\n   - 获得相应虚拟货币\\n   - 享受会员权益\\n\\n4. 免责声明\\n   - 因网络问题导致的充值延迟不承担责任\\n   - 用户自行保管账户信息\\n\\n5. 其他\\n   - 本协议最终解释权归本应用所有\\n   - 保留修改权利';

  @override
  String get userAgreementContent =>
      '用户协议\\n\\n1. 服务条款\\n   - 本应用提供占卜、命理等娱乐服务\\n   - 仅供娱乐参考，不作为决策依据\\n\\n2. 用户责任\\n   - 用户应遵守法律法规\\n   - 不得进行违法违规操作\\n\\n3. 知识产权\\n   - 所有内容版权归本应用所有\\n   - 未经许可不得转载\\n\\n4. 免责声明\\n   - 本应用不对服务结果负责\\n   - 用户自行承担使用风险\\n\\n5. 服务变更\\n   - 保留随时修改或终止服务的权利\\n   - 将提前通知用户\\n\\n6. 联系方式\\n   - 如有问题，请通过反馈功能联系我们';

  @override
  String get memberRechargeTitle => '会员充值';

  @override
  String get activateMember => '开通会员 畅享权益';

  @override
  String get unlockFeatures => '解锁更多对话次数与专属功能';

  @override
  String get memberPlans => '会员计划';

  @override
  String get weeklyPlan => '周会员';

  @override
  String get monthlyPlan => '月会员';

  @override
  String get yearlyPlan => '年会员';

  @override
  String get week => '周';

  @override
  String get month => '月';

  @override
  String get year => '年';

  @override
  String get days7 => '7天';

  @override
  String get days30 => '30天';

  @override
  String get days365 => '365天';

  @override
  String giftCoins(Object amount) {
    return '赠送$amount灵石';
  }

  @override
  String dailyChatLimit(Object count) {
    return '每日对话$count次';
  }

  @override
  String get exclusiveBadge => '专属会员标识';

  @override
  String get priorityExperience => '优先体验新功能';

  @override
  String get customerService => '专属客服支持';

  @override
  String get recommended => '推荐';

  @override
  String get bestValue => '最划算';

  @override
  String pricePerDay(Object price) {
    return '仅¥$price/天';
  }

  @override
  String get paymentMethod => '支付方式';

  @override
  String get wechatPay => '微信支付';

  @override
  String get alipay => '支付宝';

  @override
  String get activateNow => '立即开通';

  @override
  String get paymentProcessing => '支付处理中...';

  @override
  String get paymentWechatUnavailable => '微信支付暂未开放';

  @override
  String get paymentLoadPlansFailed => '套餐加载失败，已使用默认套餐';

  @override
  String get paymentAuthRequired => '请先登录后再支付';

  @override
  String get paymentOrderCreated => '已唤起支付宝，请完成支付';

  @override
  String get paymentLaunchFailed => '无法唤起支付宝，请检查是否安装';

  @override
  String get paymentOrderFailed => '创建订单失败';

  @override
  String get paymentSuccess => '支付成功，会员已开通';

  @override
  String get paymentExpired => '订单已过期';

  @override
  String get paymentCancelled => '订单已取消';

  @override
  String get paymentStatusTimeout => '订单状态查询超时';

  @override
  String get agreementHint => '开通即同意《会员服务协议》';

  @override
  String get baziStartTitle => '开启命轮';

  @override
  String get baziPromptTitle => '请输入生辰信息';

  @override
  String get baziPromptSubtitle => '唤醒您的五行守护灵';

  @override
  String get baziGenderLabel => '阴阳 (Gender)';

  @override
  String get genderMale => '男';

  @override
  String get genderFemale => '女';

  @override
  String get baziDateLabel => '天干 (Date)';

  @override
  String get selectBirthDate => '选择出生日期';

  @override
  String birthDateFormat(Object year, Object month, Object day) {
    return '$year年$month月$day日';
  }

  @override
  String get birthDateRequired => '请选择出生日期';

  @override
  String get baziTimeLabel => '地支 (Time)';

  @override
  String get selectBirthTime => '选择出生时辰';

  @override
  String birthTimeFormat(Object hour, Object minute) {
    return '$hour:$minute';
  }

  @override
  String get birthTimeRequired => '请选择出生时辰';

  @override
  String get baziCityLabel => '出生地 (City)';

  @override
  String get selectBirthCity => '选择出生城市';

  @override
  String get baziSubmit => '凝 聚 灵 体';

  @override
  String get birthInfoIncomplete => '请完整填写出生时间，以便推算命格';

  @override
  String get avatarAnalyzingBazi => '正在分析八字...';

  @override
  String get avatarMissingBirthInfo => '缺少生辰信息';

  @override
  String avatarBirthInfo(Object date, Object time) {
    return '出生: $date $time';
  }

  @override
  String avatarConnecting(Object baseUrl) {
    return '正在连接 $baseUrl...';
  }

  @override
  String get avatarParsingFiveElements => '正在解析五行属性...';

  @override
  String avatarBaziSummary(
    Object yearPillar,
    Object monthPillar,
    Object dayPillar,
    Object hourPillar,
  ) {
    return '八字: $yearPillar $monthPillar $dayPillar $hourPillar';
  }

  @override
  String avatarElementsSummary(
    Object wood,
    Object fire,
    Object earth,
    Object metal,
    Object water,
  ) {
    return '五行: 木$wood 火$fire 土$earth 金$metal 水$water';
  }

  @override
  String avatarPatternSummary(Object pattern) {
    return '格局: $pattern';
  }

  @override
  String get avatarPreparing2d => '正在准备2D形象...';

  @override
  String get avatarPreparing3d => '正在准备3D元神形象...';

  @override
  String avatarMingGong(Object value) {
    return '命宫: $value';
  }

  @override
  String avatarDayMaster(Object value) {
    return '日主: $value';
  }

  @override
  String get avatarDone => '生成完成!';

  @override
  String get avatarReady => '元神形象已就绪';

  @override
  String get avatarCalculationFailed => '命盘计算失败';

  @override
  String get avatarGenerating3d => '正在生成3D形象...';

  @override
  String get offlineMode => '(离线模式)';

  @override
  String get avatarTaskSubmitted => '生成任务已提交';

  @override
  String get avatarTaskBackground => '形象正在后台绘制中...';

  @override
  String get avatarConverging => '正在凝聚元神...';

  @override
  String get avatarConvergingDetail => '根据八字生成专属形象';

  @override
  String get avatarServiceUnavailable => '3D生成服务暂时不可用';

  @override
  String get avatarConvergingSpirit => '元神正在凝聚...';

  @override
  String get avatarPreviewConnecting => '预览阶段：连接中...';

  @override
  String avatarTotalProgress(Object progress) {
    return '总进度: $progress%';
  }

  @override
  String get avatarGeneratingMesh => '正在生成3D网格...';

  @override
  String get avatarPreviewStage => '预览阶段';

  @override
  String get avatarApplyingTextures => '正在添加贴图...';

  @override
  String get avatarRefineStage => '精细化阶段（预览模型已就绪）';

  @override
  String get avatarPreviewReady => '预览模型已就绪';

  @override
  String get avatarRefining => '正在进行精细化处理...';

  @override
  String get avatarRefineFailedUsePreview => '精细化失败，使用预览模型';

  @override
  String get avatarFailed => '生成失败';

  @override
  String get avatarConnectionInterrupted => '连接中断，使用预览模型';

  @override
  String avatar3dError(Object error) {
    return '3D生成出错: $error';
  }

  @override
  String get avatarStageRefine => '精细化';

  @override
  String get avatarStagePreview => '预览';

  @override
  String avatarStagePending(Object stage) {
    return '$stage排队中...';
  }

  @override
  String get avatarPreviewToRefine => '预览完成，开始精细化...';

  @override
  String avatarStageFailed(Object stage) {
    return '$stage失败';
  }

  @override
  String get canceled => '已取消';

  @override
  String get processing => '处理中...';

  @override
  String get queueing => '排队中...';

  @override
  String get generating => '正在生成...';

  @override
  String get previewQueueing => '预览排队中...';

  @override
  String get refineQueueing => '精细化排队中...';

  @override
  String get avatarHint => '基于您的八字信息\\n正在凝聚专属元神...';

  @override
  String get relationshipSelectTitle => '关系合盘';

  @override
  String get relationshipLover => '恋人';

  @override
  String get relationshipLoverSubtitle => '感情发展与磨合';

  @override
  String get relationshipSpouse => '夫妻';

  @override
  String get relationshipSpouseSubtitle => '长期相处与家庭节奏';

  @override
  String get relationshipFriend => '朋友';

  @override
  String get relationshipFriendSubtitle => '性格互补与信任';

  @override
  String get relationshipParentChild => '亲子';

  @override
  String get relationshipParentChildSubtitle => '陪伴与成长';

  @override
  String get relationshipColleague => '同事';

  @override
  String get relationshipColleagueSubtitle => '协作与共识';

  @override
  String relationshipFormTitle(Object relationType) {
    return '$relationType合盘';
  }

  @override
  String get relationshipPersonATitle => '甲方信息';

  @override
  String get relationshipPersonBTitle => '乙方信息';

  @override
  String get relationshipGenerateReport => '生成合盘报告';

  @override
  String get birthDateLabel => '出生日期';

  @override
  String get selectDate => '请选择日期';

  @override
  String get birthTimeLabel => '出生时辰';

  @override
  String get selectTime => '请选择时辰';

  @override
  String get birthCityLabel => '出生城市';

  @override
  String selectorLabelValue(Object label, Object value) {
    return '$label: $value';
  }

  @override
  String get relationshipBirthInfoIncomplete => '请完整填写双方出生日期与时辰';

  @override
  String get relationshipReportGenerating => '正在生成合盘报告...';

  @override
  String get relationshipReportMissingInfo => '缺少合盘信息';

  @override
  String get relationshipReportReady => '报告已生成';

  @override
  String get relationshipReportTitle => '合盘报告';

  @override
  String get relationshipSummary => '合盘概要';

  @override
  String get relationshipHighlights => '亮点';

  @override
  String get relationshipAdvice => '建议';

  @override
  String get relationshipEnterChat => '进入合盘对话';

  @override
  String get relationshipMatchScore => '合盘匹配度';

  @override
  String get relationshipChatTitle => '合盘对话';

  @override
  String get relationshipChatHint => '继续咨询合盘细节...';

  @override
  String get relationshipChatUnavailable => '抱歉，合盘对话暂时不可用。';

  @override
  String relationshipSummaryMessage(Object summary) {
    return '合盘概要：$summary';
  }

  @override
  String get languageName => '中文';

  @override
  String get chatWelcomeMessage => '你好,我是你的专属元灵。我会陪伴你,倾听你的心声,也会在需要时给你一些人生的建议。';

  @override
  String get chatStatusOnline => '在线';

  @override
  String get chatSubtitle => '你的专属命理伙伴';

  @override
  String get chatInputHint => '与元灵对话...';

  @override
  String get chatCanceled => '[已取消]';

  @override
  String get chatErrorResponse => '抱歉，我暂时无法回应。请稍后再试。';

  @override
  String get chatImageLoadFailed => '图片加载失败';

  @override
  String get chatClear => '清空对话';

  @override
  String get chatHistory => '对话历史';

  @override
  String get chatMockReply1 => '我理解你的感受,让我们一起来探讨一下这个问题。';

  @override
  String get chatMockReply2 => '从你的八字来看,这个阶段确实需要更多的耐心和坚持。';

  @override
  String get chatMockReply3 => '我一直在这里陪伴你,无论什么时候你都可以和我分享你的想法。';

  @override
  String get chatMockReply4 => '根据你的命理,现在是一个适合思考和规划的时期。';

  @override
  String get chatMockReply5 => '每个人都会遇到困难,重要的是如何面对它们。你做得很好。';

  @override
  String get timeJustNow => '刚刚';

  @override
  String timeMinutesAgo(Object minutes) {
    return '$minutes分钟前';
  }

  @override
  String timeHourMinute(Object hour, Object minute) {
    return '$hour:$minute';
  }

  @override
  String timeMonthDay(Object month, Object day) {
    return '$month月$day日';
  }

  @override
  String get chatOverlayWelcomeMessage =>
      '在存亮透过的瞬息，谢谢结缘的距离？\\n元神的经过的瞬息，意不如型诚语...';

  @override
  String get chatOverlayInputHint => '向元灵倾诉...';

  @override
  String get chatOverlayMockReply =>
      '我听到了你的心声... \\n风起于青萍之末，浪成于微澜之间。此刻的迷茫，或许是觉醒的前奏。';

  @override
  String get divinationTitle => '问卜';

  @override
  String get divinationHistoryTitle => '历史记录';

  @override
  String get divinationWelcomeTitle => '请诚心默念您的问题';

  @override
  String get divinationWelcomeSubtitle => '然后在下方输入';

  @override
  String get divinationTip1 => '问卜需诚心正意';

  @override
  String get divinationTip2 => '每日同一事宜只问一次';

  @override
  String get divinationTip3 => '问题越具体，解读越精准';

  @override
  String get divinationCasting => '摇卦中，请稍候...';

  @override
  String get divinationInputHint => '请输入您想问卜的问题...';

  @override
  String get divinationContinueHint => '继续提问...';

  @override
  String get divinationPrimaryHexagram => '本卦';

  @override
  String get divinationChangedHexagram => '变卦';

  @override
  String get divinationNoHistory => '暂无问卜记录';

  @override
  String get divinationNoHistorySubtitle => '开始您的第一次问卜吧';

  @override
  String get divinationDeleteTitle => '删除记录';

  @override
  String get divinationDeleteConfirm => '确定要删除这条问卜记录吗？';

  @override
  String get divinationClearTitle => '清空记录';

  @override
  String get divinationClearConfirm => '确定要清空所有问卜记录吗？此操作不可撤销。';

  @override
  String get divinationDeleted => '记录已删除';

  @override
  String get divinationCleared => '记录已清空';

  @override
  String get divinationFailed => '问卜失败，请重试';

  @override
  String get divinationInterpretFailed => '解读失败，请重试';

  @override
  String get divinationReplyFailed => '回复失败，请重试';
}
