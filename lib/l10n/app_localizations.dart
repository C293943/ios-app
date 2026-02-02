import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In zh, this message translates to:
  /// **'鸿初元灵'**
  String get appName;

  /// No description provided for @accountSettings.
  ///
  /// In zh, this message translates to:
  /// **'账号设置'**
  String get accountSettings;

  /// No description provided for @languageSelection.
  ///
  /// In zh, this message translates to:
  /// **'语言选择'**
  String get languageSelection;

  /// No description provided for @languageFeatureInProgress.
  ///
  /// In zh, this message translates to:
  /// **'多语言功能开发中...'**
  String get languageFeatureInProgress;

  /// No description provided for @themeToggle.
  ///
  /// In zh, this message translates to:
  /// **'主题切换'**
  String get themeToggle;

  /// No description provided for @aboutUs.
  ///
  /// In zh, this message translates to:
  /// **'关于我们'**
  String get aboutUs;

  /// No description provided for @logout.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get logout;

  /// No description provided for @spiritName.
  ///
  /// In zh, this message translates to:
  /// **'元神'**
  String get spiritName;

  /// No description provided for @edit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// No description provided for @spiritStoneCount.
  ///
  /// In zh, this message translates to:
  /// **'灵石数量'**
  String get spiritStoneCount;

  /// No description provided for @dailyChatCount.
  ///
  /// In zh, this message translates to:
  /// **'每日对话次数'**
  String get dailyChatCount;

  /// No description provided for @recharge.
  ///
  /// In zh, this message translates to:
  /// **'充值'**
  String get recharge;

  /// No description provided for @spiritNotes.
  ///
  /// In zh, this message translates to:
  /// **'元神笔记'**
  String get spiritNotes;

  /// No description provided for @todayQiValue.
  ///
  /// In zh, this message translates to:
  /// **'今日元气值'**
  String get todayQiValue;

  /// No description provided for @luckyNumber.
  ///
  /// In zh, this message translates to:
  /// **'吉数'**
  String get luckyNumber;

  /// No description provided for @luckyColor.
  ///
  /// In zh, this message translates to:
  /// **'吉色'**
  String get luckyColor;

  /// No description provided for @luckyDirection.
  ///
  /// In zh, this message translates to:
  /// **'吉位'**
  String get luckyDirection;

  /// No description provided for @startSpiritChat.
  ///
  /// In zh, this message translates to:
  /// **'开启元神对话'**
  String get startSpiritChat;

  /// No description provided for @navFortune.
  ///
  /// In zh, this message translates to:
  /// **'运势'**
  String get navFortune;

  /// No description provided for @navBazi.
  ///
  /// In zh, this message translates to:
  /// **'八字'**
  String get navBazi;

  /// No description provided for @navRelationship.
  ///
  /// In zh, this message translates to:
  /// **'合盘'**
  String get navRelationship;

  /// No description provided for @loginAgreeRequired.
  ///
  /// In zh, this message translates to:
  /// **'请先阅读并同意用户协议'**
  String get loginAgreeRequired;

  /// No description provided for @loginTitle.
  ///
  /// In zh, this message translates to:
  /// **'数字元神'**
  String get loginTitle;

  /// No description provided for @loginPhoneTab.
  ///
  /// In zh, this message translates to:
  /// **'手机登录'**
  String get loginPhoneTab;

  /// No description provided for @loginEmailTab.
  ///
  /// In zh, this message translates to:
  /// **'邮箱登录'**
  String get loginEmailTab;

  /// No description provided for @loginPhoneHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入手机号'**
  String get loginPhoneHint;

  /// No description provided for @loginCodeHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入验证码'**
  String get loginCodeHint;

  /// No description provided for @loginGetCode.
  ///
  /// In zh, this message translates to:
  /// **'获取验证码'**
  String get loginGetCode;

  /// No description provided for @loginEmailHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入邮箱'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入密码'**
  String get loginPasswordHint;

  /// No description provided for @loginForgotPassword.
  ///
  /// In zh, this message translates to:
  /// **'忘记密码?'**
  String get loginForgotPassword;

  /// No description provided for @loginAgreementPrefix.
  ///
  /// In zh, this message translates to:
  /// **'我已阅读并同意'**
  String get loginAgreementPrefix;

  /// No description provided for @loginUserAgreement.
  ///
  /// In zh, this message translates to:
  /// **'《用户协议》'**
  String get loginUserAgreement;

  /// No description provided for @loginPrivacyPolicy.
  ///
  /// In zh, this message translates to:
  /// **'《隐私政策》'**
  String get loginPrivacyPolicy;

  /// No description provided for @loginButton.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get loginButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In zh, this message translates to:
  /// **'还没有账号? '**
  String get loginNoAccount;

  /// No description provided for @loginRegisterNow.
  ///
  /// In zh, this message translates to:
  /// **'立即注册'**
  String get loginRegisterNow;

  /// No description provided for @registerAgreeRequired.
  ///
  /// In zh, this message translates to:
  /// **'请先阅读并同意用户协议'**
  String get registerAgreeRequired;

  /// No description provided for @registerTitle.
  ///
  /// In zh, this message translates to:
  /// **'数字元神'**
  String get registerTitle;

  /// No description provided for @registerPhoneTab.
  ///
  /// In zh, this message translates to:
  /// **'手机注册'**
  String get registerPhoneTab;

  /// No description provided for @registerEmailTab.
  ///
  /// In zh, this message translates to:
  /// **'邮箱注册'**
  String get registerEmailTab;

  /// No description provided for @registerNicknameHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入称谓/道号'**
  String get registerNicknameHint;

  /// No description provided for @registerPhoneHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入手机号'**
  String get registerPhoneHint;

  /// No description provided for @registerCodeHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入验证码'**
  String get registerCodeHint;

  /// No description provided for @registerGetCode.
  ///
  /// In zh, this message translates to:
  /// **'获取验证码'**
  String get registerGetCode;

  /// No description provided for @registerEmailHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入邮箱'**
  String get registerEmailHint;

  /// No description provided for @registerPasswordHint.
  ///
  /// In zh, this message translates to:
  /// **'设置密码'**
  String get registerPasswordHint;

  /// No description provided for @registerAgreementPrefix.
  ///
  /// In zh, this message translates to:
  /// **'我已阅读并同意'**
  String get registerAgreementPrefix;

  /// No description provided for @registerUserAgreement.
  ///
  /// In zh, this message translates to:
  /// **'《用户协议》'**
  String get registerUserAgreement;

  /// No description provided for @registerPrivacyPolicy.
  ///
  /// In zh, this message translates to:
  /// **'《隐私政策》'**
  String get registerPrivacyPolicy;

  /// No description provided for @registerButton.
  ///
  /// In zh, this message translates to:
  /// **'立即注册'**
  String get registerButton;

  /// No description provided for @registerHasAccount.
  ///
  /// In zh, this message translates to:
  /// **'已有账号? '**
  String get registerHasAccount;

  /// No description provided for @registerLoginNow.
  ///
  /// In zh, this message translates to:
  /// **'立即登录'**
  String get registerLoginNow;

  /// No description provided for @aboutVersion.
  ///
  /// In zh, this message translates to:
  /// **'版本 {version}'**
  String aboutVersion(Object version);

  /// No description provided for @aboutDescription.
  ///
  /// In zh, this message translates to:
  /// **'以科技之力，探寻东方神秘文化。\\n为您提供个性化的运势分析与灵性陪伴。'**
  String get aboutDescription;

  /// No description provided for @aboutCopyright.
  ///
  /// In zh, this message translates to:
  /// **'© 2026 Primordial Spirit Team'**
  String get aboutCopyright;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @displayModeSection.
  ///
  /// In zh, this message translates to:
  /// **'显示模式'**
  String get displayModeSection;

  /// No description provided for @displayMode3d.
  ///
  /// In zh, this message translates to:
  /// **'3D 元灵'**
  String get displayMode3d;

  /// No description provided for @displayMode2d.
  ///
  /// In zh, this message translates to:
  /// **'2D 平面'**
  String get displayMode2d;

  /// No description provided for @displayModeLive2d.
  ///
  /// In zh, this message translates to:
  /// **'Live2D'**
  String get displayModeLive2d;

  /// No description provided for @themeSection.
  ///
  /// In zh, this message translates to:
  /// **'主题设置'**
  String get themeSection;

  /// No description provided for @themeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get themeDark;

  /// No description provided for @modelManagementSection.
  ///
  /// In zh, this message translates to:
  /// **'3D 模型管理'**
  String get modelManagementSection;

  /// No description provided for @builtInModels.
  ///
  /// In zh, this message translates to:
  /// **'内置模型'**
  String get builtInModels;

  /// No description provided for @customModels.
  ///
  /// In zh, this message translates to:
  /// **'自定义模型'**
  String get customModels;

  /// No description provided for @birthInfoSection.
  ///
  /// In zh, this message translates to:
  /// **'生辰信息'**
  String get birthInfoSection;

  /// No description provided for @resetBirthInfo.
  ///
  /// In zh, this message translates to:
  /// **'重新设置生辰'**
  String get resetBirthInfo;

  /// No description provided for @resetBirthInfoSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'修改出生日期、时辰和地点'**
  String get resetBirthInfoSubtitle;

  /// No description provided for @aboutSection.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get aboutSection;

  /// No description provided for @versionLabel.
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get versionLabel;

  /// No description provided for @addModelTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加 3D 模型'**
  String get addModelTitle;

  /// No description provided for @addModelFormatsHint.
  ///
  /// In zh, this message translates to:
  /// **'支持 .glb, .gltf, .obj 格式'**
  String get addModelFormatsHint;

  /// No description provided for @modelTagAnimated.
  ///
  /// In zh, this message translates to:
  /// **'带动画'**
  String get modelTagAnimated;

  /// No description provided for @modelTagStatic.
  ///
  /// In zh, this message translates to:
  /// **'静态'**
  String get modelTagStatic;

  /// No description provided for @modelTagBuiltIn.
  ///
  /// In zh, this message translates to:
  /// **'内置'**
  String get modelTagBuiltIn;

  /// No description provided for @modelTagCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get modelTagCustom;

  /// No description provided for @rename.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get rename;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @unsupportedModelFormat.
  ///
  /// In zh, this message translates to:
  /// **'不支持的文件格式，请选择 .glb, .gltf 或 .obj 文件'**
  String get unsupportedModelFormat;

  /// No description provided for @modelAddSuccess.
  ///
  /// In zh, this message translates to:
  /// **'模型 \"{name}\" 添加成功'**
  String modelAddSuccess(Object name);

  /// No description provided for @modelAddFailed.
  ///
  /// In zh, this message translates to:
  /// **'添加模型失败: {error}'**
  String modelAddFailed(Object error);

  /// No description provided for @modelNameTitle.
  ///
  /// In zh, this message translates to:
  /// **'模型名称'**
  String get modelNameTitle;

  /// No description provided for @modelNameHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入模型名称'**
  String get modelNameHint;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get confirm;

  /// No description provided for @renameModelTitle.
  ///
  /// In zh, this message translates to:
  /// **'重命名模型'**
  String get renameModelTitle;

  /// No description provided for @renameModelHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入新名称'**
  String get renameModelHint;

  /// No description provided for @renameSuccess.
  ///
  /// In zh, this message translates to:
  /// **'重命名成功'**
  String get renameSuccess;

  /// No description provided for @renameFailed.
  ///
  /// In zh, this message translates to:
  /// **'重命名失败'**
  String get renameFailed;

  /// No description provided for @deleteModelTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除模型'**
  String get deleteModelTitle;

  /// No description provided for @deleteModelConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除模型 \"{name}\" 吗？\\n此操作不可恢复。'**
  String deleteModelConfirm(Object name);

  /// No description provided for @deleteSuccess.
  ///
  /// In zh, this message translates to:
  /// **'删除成功'**
  String get deleteSuccess;

  /// No description provided for @deleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除失败'**
  String get deleteFailed;

  /// No description provided for @noteQiGain.
  ///
  /// In zh, this message translates to:
  /// **'今日元气值+10'**
  String get noteQiGain;

  /// No description provided for @noteSampleDate1.
  ///
  /// In zh, this message translates to:
  /// **'十月廿八 星期二'**
  String get noteSampleDate1;

  /// No description provided for @noteSampleDate2.
  ///
  /// In zh, this message translates to:
  /// **'十月廿八 星期三'**
  String get noteSampleDate2;

  /// No description provided for @noteSampleContent.
  ///
  /// In zh, this message translates to:
  /// **'今日与君畅谈，关于那些藏于心底的梦想。吾能感其炽热与期盼，遂告之，寻梦之路，吾亦常伴左右。'**
  String get noteSampleContent;

  /// No description provided for @syncing.
  ///
  /// In zh, this message translates to:
  /// **'同步中...'**
  String get syncing;

  /// No description provided for @notLoggedIn.
  ///
  /// In zh, this message translates to:
  /// **'未登录'**
  String get notLoggedIn;

  /// No description provided for @notSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get notSet;

  /// No description provided for @notSynced.
  ///
  /// In zh, this message translates to:
  /// **'未同步'**
  String get notSynced;

  /// No description provided for @profileStatusSet.
  ///
  /// In zh, this message translates to:
  /// **'已设置'**
  String get profileStatusSet;

  /// No description provided for @profileStatusSynced.
  ///
  /// In zh, this message translates to:
  /// **'已同步'**
  String get profileStatusSynced;

  /// No description provided for @profileTitle.
  ///
  /// In zh, this message translates to:
  /// **'个人信息'**
  String get profileTitle;

  /// No description provided for @profileUserId.
  ///
  /// In zh, this message translates to:
  /// **'用户编号'**
  String get profileUserId;

  /// No description provided for @profileEmail.
  ///
  /// In zh, this message translates to:
  /// **'账号邮箱'**
  String get profileEmail;

  /// No description provided for @profileLevel.
  ///
  /// In zh, this message translates to:
  /// **'用户等级'**
  String get profileLevel;

  /// No description provided for @profileLevelValue.
  ///
  /// In zh, this message translates to:
  /// **'VIP 0'**
  String get profileLevelValue;

  /// No description provided for @profileArchive.
  ///
  /// In zh, this message translates to:
  /// **'档案'**
  String get profileArchive;

  /// No description provided for @profileArchiveTitle.
  ///
  /// In zh, this message translates to:
  /// **'档案信息'**
  String get profileArchiveTitle;

  /// No description provided for @profileSyncTime.
  ///
  /// In zh, this message translates to:
  /// **'同步时间'**
  String get profileSyncTime;

  /// No description provided for @profileRecharge.
  ///
  /// In zh, this message translates to:
  /// **'会员充值'**
  String get profileRecharge;

  /// No description provided for @profileRechargeAction.
  ///
  /// In zh, this message translates to:
  /// **'前往充值'**
  String get profileRechargeAction;

  /// No description provided for @profileVoice.
  ///
  /// In zh, this message translates to:
  /// **'语音选择'**
  String get profileVoice;

  /// No description provided for @profileFeedback.
  ///
  /// In zh, this message translates to:
  /// **'用户反馈'**
  String get profileFeedback;

  /// No description provided for @profileFeedbackAction.
  ///
  /// In zh, this message translates to:
  /// **'提交反馈'**
  String get profileFeedbackAction;

  /// No description provided for @profilePrivacy.
  ///
  /// In zh, this message translates to:
  /// **'隐私协议'**
  String get profilePrivacy;

  /// No description provided for @profileRechargeAgreement.
  ///
  /// In zh, this message translates to:
  /// **'充值协议'**
  String get profileRechargeAgreement;

  /// No description provided for @profileUserAgreement.
  ///
  /// In zh, this message translates to:
  /// **'用户协议'**
  String get profileUserAgreement;

  /// No description provided for @viewAction.
  ///
  /// In zh, this message translates to:
  /// **'查看'**
  String get viewAction;

  /// No description provided for @logoutAction.
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get logoutAction;

  /// No description provided for @profileNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'姓名'**
  String get profileNameLabel;

  /// No description provided for @profileGenderLabel.
  ///
  /// In zh, this message translates to:
  /// **'性别'**
  String get profileGenderLabel;

  /// No description provided for @profileBirthCityLabel.
  ///
  /// In zh, this message translates to:
  /// **'出生地'**
  String get profileBirthCityLabel;

  /// No description provided for @profileBirthTimeLabel.
  ///
  /// In zh, this message translates to:
  /// **'出生时间'**
  String get profileBirthTimeLabel;

  /// No description provided for @birthDatePlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'-- -- -- --:--'**
  String get birthDatePlaceholder;

  /// No description provided for @profileEditTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑档案'**
  String get profileEditTitle;

  /// No description provided for @profileGenderHint.
  ///
  /// In zh, this message translates to:
  /// **'性别（男/女）'**
  String get profileGenderHint;

  /// No description provided for @profileBirthYearLabel.
  ///
  /// In zh, this message translates to:
  /// **'出生年'**
  String get profileBirthYearLabel;

  /// No description provided for @profileBirthMonthLabel.
  ///
  /// In zh, this message translates to:
  /// **'出生月'**
  String get profileBirthMonthLabel;

  /// No description provided for @profileBirthDayLabel.
  ///
  /// In zh, this message translates to:
  /// **'出生日'**
  String get profileBirthDayLabel;

  /// No description provided for @profileBirthHourLabel.
  ///
  /// In zh, this message translates to:
  /// **'出生时'**
  String get profileBirthHourLabel;

  /// No description provided for @profileBirthMinuteLabel.
  ///
  /// In zh, this message translates to:
  /// **'出生分'**
  String get profileBirthMinuteLabel;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @logoutConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要退出当前账号吗？'**
  String get logoutConfirm;

  /// No description provided for @featureInProgress.
  ///
  /// In zh, this message translates to:
  /// **'功能开发中...'**
  String get featureInProgress;

  /// No description provided for @voiceSelectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'语音选择'**
  String get voiceSelectionTitle;

  /// No description provided for @voiceDefaultFemale.
  ///
  /// In zh, this message translates to:
  /// **'默认女声'**
  String get voiceDefaultFemale;

  /// No description provided for @voiceGentleFemale.
  ///
  /// In zh, this message translates to:
  /// **'温柔女声'**
  String get voiceGentleFemale;

  /// No description provided for @voiceMagneticMale.
  ///
  /// In zh, this message translates to:
  /// **'磁性男声'**
  String get voiceMagneticMale;

  /// No description provided for @feedbackHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入您的反馈意见...'**
  String get feedbackHint;

  /// No description provided for @submit.
  ///
  /// In zh, this message translates to:
  /// **'提交'**
  String get submit;

  /// No description provided for @privacyAgreementTitle.
  ///
  /// In zh, this message translates to:
  /// **'隐私协议'**
  String get privacyAgreementTitle;

  /// No description provided for @rechargeAgreementTitle.
  ///
  /// In zh, this message translates to:
  /// **'充值协议'**
  String get rechargeAgreementTitle;

  /// No description provided for @userAgreementTitle.
  ///
  /// In zh, this message translates to:
  /// **'用户协议'**
  String get userAgreementTitle;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策\\n\\n本应用尊重并保护用户的隐私。我们承诺：\\n\\n1. 数据收集\\n   - 仅收集必要的个人信息\\n   - 不会未经同意收集敏感信息\\n\\n2. 数据使用\\n   - 仅用于提供服务\\n   - 不会用于商业目的\\n\\n3. 数据保护\\n   - 采用加密技术保护数据\\n   - 定期进行安全审计\\n\\n4. 用户权利\\n   - 有权查看个人数据\\n   - 有权要求删除数据\\n\\n如有疑问，请联系我们。'**
  String get privacyPolicyContent;

  /// No description provided for @rechargeAgreementContent.
  ///
  /// In zh, this message translates to:
  /// **'充值协议\\n\\n1. 充值说明\\n   - 充值金额为虚拟货币\\n   - 不支持退款\\n\\n2. 充值方式\\n   - 支持多种支付方式\\n   - 实时到账\\n\\n3. 充值权益\\n   - 获得相应虚拟货币\\n   - 享受会员权益\\n\\n4. 免责声明\\n   - 因网络问题导致的充值延迟不承担责任\\n   - 用户自行保管账户信息\\n\\n5. 其他\\n   - 本协议最终解释权归本应用所有\\n   - 保留修改权利'**
  String get rechargeAgreementContent;

  /// No description provided for @userAgreementContent.
  ///
  /// In zh, this message translates to:
  /// **'用户协议\\n\\n1. 服务条款\\n   - 本应用提供占卜、命理等娱乐服务\\n   - 仅供娱乐参考，不作为决策依据\\n\\n2. 用户责任\\n   - 用户应遵守法律法规\\n   - 不得进行违法违规操作\\n\\n3. 知识产权\\n   - 所有内容版权归本应用所有\\n   - 未经许可不得转载\\n\\n4. 免责声明\\n   - 本应用不对服务结果负责\\n   - 用户自行承担使用风险\\n\\n5. 服务变更\\n   - 保留随时修改或终止服务的权利\\n   - 将提前通知用户\\n\\n6. 联系方式\\n   - 如有问题，请通过反馈功能联系我们'**
  String get userAgreementContent;

  /// No description provided for @memberRechargeTitle.
  ///
  /// In zh, this message translates to:
  /// **'会员充值'**
  String get memberRechargeTitle;

  /// No description provided for @activateMember.
  ///
  /// In zh, this message translates to:
  /// **'开通会员 畅享权益'**
  String get activateMember;

  /// No description provided for @unlockFeatures.
  ///
  /// In zh, this message translates to:
  /// **'解锁更多对话次数与专属功能'**
  String get unlockFeatures;

  /// No description provided for @memberPlans.
  ///
  /// In zh, this message translates to:
  /// **'会员计划'**
  String get memberPlans;

  /// No description provided for @weeklyPlan.
  ///
  /// In zh, this message translates to:
  /// **'周会员'**
  String get weeklyPlan;

  /// No description provided for @monthlyPlan.
  ///
  /// In zh, this message translates to:
  /// **'月会员'**
  String get monthlyPlan;

  /// No description provided for @yearlyPlan.
  ///
  /// In zh, this message translates to:
  /// **'年会员'**
  String get yearlyPlan;

  /// No description provided for @week.
  ///
  /// In zh, this message translates to:
  /// **'周'**
  String get week;

  /// No description provided for @month.
  ///
  /// In zh, this message translates to:
  /// **'月'**
  String get month;

  /// No description provided for @year.
  ///
  /// In zh, this message translates to:
  /// **'年'**
  String get year;

  /// No description provided for @days7.
  ///
  /// In zh, this message translates to:
  /// **'7天'**
  String get days7;

  /// No description provided for @days30.
  ///
  /// In zh, this message translates to:
  /// **'30天'**
  String get days30;

  /// No description provided for @days365.
  ///
  /// In zh, this message translates to:
  /// **'365天'**
  String get days365;

  /// No description provided for @giftCoins.
  ///
  /// In zh, this message translates to:
  /// **'赠送{amount}灵石'**
  String giftCoins(Object amount);

  /// No description provided for @dailyChatLimit.
  ///
  /// In zh, this message translates to:
  /// **'每日对话{count}次'**
  String dailyChatLimit(Object count);

  /// No description provided for @exclusiveBadge.
  ///
  /// In zh, this message translates to:
  /// **'专属会员标识'**
  String get exclusiveBadge;

  /// No description provided for @priorityExperience.
  ///
  /// In zh, this message translates to:
  /// **'优先体验新功能'**
  String get priorityExperience;

  /// No description provided for @customerService.
  ///
  /// In zh, this message translates to:
  /// **'专属客服支持'**
  String get customerService;

  /// No description provided for @recommended.
  ///
  /// In zh, this message translates to:
  /// **'推荐'**
  String get recommended;

  /// No description provided for @bestValue.
  ///
  /// In zh, this message translates to:
  /// **'最划算'**
  String get bestValue;

  /// No description provided for @pricePerDay.
  ///
  /// In zh, this message translates to:
  /// **'仅¥{price}/天'**
  String pricePerDay(Object price);

  /// No description provided for @paymentMethod.
  ///
  /// In zh, this message translates to:
  /// **'支付方式'**
  String get paymentMethod;

  /// No description provided for @wechatPay.
  ///
  /// In zh, this message translates to:
  /// **'微信支付'**
  String get wechatPay;

  /// No description provided for @alipay.
  ///
  /// In zh, this message translates to:
  /// **'支付宝'**
  String get alipay;

  /// No description provided for @activateNow.
  ///
  /// In zh, this message translates to:
  /// **'立即开通'**
  String get activateNow;

  /// No description provided for @agreementHint.
  ///
  /// In zh, this message translates to:
  /// **'开通即同意《会员服务协议》'**
  String get agreementHint;

  /// No description provided for @baziStartTitle.
  ///
  /// In zh, this message translates to:
  /// **'开启命轮'**
  String get baziStartTitle;

  /// No description provided for @baziPromptTitle.
  ///
  /// In zh, this message translates to:
  /// **'请输入生辰信息'**
  String get baziPromptTitle;

  /// No description provided for @baziPromptSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'唤醒您的五行守护灵'**
  String get baziPromptSubtitle;

  /// No description provided for @baziGenderLabel.
  ///
  /// In zh, this message translates to:
  /// **'阴阳 (Gender)'**
  String get baziGenderLabel;

  /// No description provided for @genderMale.
  ///
  /// In zh, this message translates to:
  /// **'男'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In zh, this message translates to:
  /// **'女'**
  String get genderFemale;

  /// No description provided for @baziDateLabel.
  ///
  /// In zh, this message translates to:
  /// **'天干 (Date)'**
  String get baziDateLabel;

  /// No description provided for @selectBirthDate.
  ///
  /// In zh, this message translates to:
  /// **'选择出生日期'**
  String get selectBirthDate;

  /// No description provided for @birthDateFormat.
  ///
  /// In zh, this message translates to:
  /// **'{year}年{month}月{day}日'**
  String birthDateFormat(Object year, Object month, Object day);

  /// No description provided for @birthDateRequired.
  ///
  /// In zh, this message translates to:
  /// **'请选择出生日期'**
  String get birthDateRequired;

  /// No description provided for @baziTimeLabel.
  ///
  /// In zh, this message translates to:
  /// **'地支 (Time)'**
  String get baziTimeLabel;

  /// No description provided for @selectBirthTime.
  ///
  /// In zh, this message translates to:
  /// **'选择出生时辰'**
  String get selectBirthTime;

  /// No description provided for @birthTimeFormat.
  ///
  /// In zh, this message translates to:
  /// **'{hour}:{minute}'**
  String birthTimeFormat(Object hour, Object minute);

  /// No description provided for @birthTimeRequired.
  ///
  /// In zh, this message translates to:
  /// **'请选择出生时辰'**
  String get birthTimeRequired;

  /// No description provided for @baziCityLabel.
  ///
  /// In zh, this message translates to:
  /// **'出生地 (City)'**
  String get baziCityLabel;

  /// No description provided for @selectBirthCity.
  ///
  /// In zh, this message translates to:
  /// **'选择出生城市'**
  String get selectBirthCity;

  /// No description provided for @baziSubmit.
  ///
  /// In zh, this message translates to:
  /// **'凝 聚 灵 体'**
  String get baziSubmit;

  /// No description provided for @birthInfoIncomplete.
  ///
  /// In zh, this message translates to:
  /// **'请完整填写出生时间，以便推算命格'**
  String get birthInfoIncomplete;

  /// No description provided for @avatarAnalyzingBazi.
  ///
  /// In zh, this message translates to:
  /// **'正在分析八字...'**
  String get avatarAnalyzingBazi;

  /// No description provided for @avatarMissingBirthInfo.
  ///
  /// In zh, this message translates to:
  /// **'缺少生辰信息'**
  String get avatarMissingBirthInfo;

  /// No description provided for @avatarBirthInfo.
  ///
  /// In zh, this message translates to:
  /// **'出生: {date} {time}'**
  String avatarBirthInfo(Object date, Object time);

  /// No description provided for @avatarConnecting.
  ///
  /// In zh, this message translates to:
  /// **'正在连接 {baseUrl}...'**
  String avatarConnecting(Object baseUrl);

  /// No description provided for @avatarParsingFiveElements.
  ///
  /// In zh, this message translates to:
  /// **'正在解析五行属性...'**
  String get avatarParsingFiveElements;

  /// No description provided for @avatarBaziSummary.
  ///
  /// In zh, this message translates to:
  /// **'八字: {yearPillar} {monthPillar} {dayPillar} {hourPillar}'**
  String avatarBaziSummary(
    Object yearPillar,
    Object monthPillar,
    Object dayPillar,
    Object hourPillar,
  );

  /// No description provided for @avatarElementsSummary.
  ///
  /// In zh, this message translates to:
  /// **'五行: 木{wood} 火{fire} 土{earth} 金{metal} 水{water}'**
  String avatarElementsSummary(
    Object wood,
    Object fire,
    Object earth,
    Object metal,
    Object water,
  );

  /// No description provided for @avatarPatternSummary.
  ///
  /// In zh, this message translates to:
  /// **'格局: {pattern}'**
  String avatarPatternSummary(Object pattern);

  /// No description provided for @avatarPreparing2d.
  ///
  /// In zh, this message translates to:
  /// **'正在准备2D形象...'**
  String get avatarPreparing2d;

  /// No description provided for @avatarPreparing3d.
  ///
  /// In zh, this message translates to:
  /// **'正在准备3D元神形象...'**
  String get avatarPreparing3d;

  /// No description provided for @avatarMingGong.
  ///
  /// In zh, this message translates to:
  /// **'命宫: {value}'**
  String avatarMingGong(Object value);

  /// No description provided for @avatarDayMaster.
  ///
  /// In zh, this message translates to:
  /// **'日主: {value}'**
  String avatarDayMaster(Object value);

  /// No description provided for @avatarDone.
  ///
  /// In zh, this message translates to:
  /// **'生成完成!'**
  String get avatarDone;

  /// No description provided for @avatarReady.
  ///
  /// In zh, this message translates to:
  /// **'元神形象已就绪'**
  String get avatarReady;

  /// No description provided for @avatarCalculationFailed.
  ///
  /// In zh, this message translates to:
  /// **'命盘计算失败'**
  String get avatarCalculationFailed;

  /// No description provided for @avatarGenerating3d.
  ///
  /// In zh, this message translates to:
  /// **'正在生成3D形象...'**
  String get avatarGenerating3d;

  /// No description provided for @offlineMode.
  ///
  /// In zh, this message translates to:
  /// **'(离线模式)'**
  String get offlineMode;

  /// No description provided for @avatarTaskSubmitted.
  ///
  /// In zh, this message translates to:
  /// **'生成任务已提交'**
  String get avatarTaskSubmitted;

  /// No description provided for @avatarTaskBackground.
  ///
  /// In zh, this message translates to:
  /// **'形象正在后台绘制中...'**
  String get avatarTaskBackground;

  /// No description provided for @avatarConverging.
  ///
  /// In zh, this message translates to:
  /// **'正在凝聚元神...'**
  String get avatarConverging;

  /// No description provided for @avatarConvergingDetail.
  ///
  /// In zh, this message translates to:
  /// **'根据八字生成专属形象'**
  String get avatarConvergingDetail;

  /// No description provided for @avatarServiceUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'3D生成服务暂时不可用'**
  String get avatarServiceUnavailable;

  /// No description provided for @avatarConvergingSpirit.
  ///
  /// In zh, this message translates to:
  /// **'元神正在凝聚...'**
  String get avatarConvergingSpirit;

  /// No description provided for @avatarPreviewConnecting.
  ///
  /// In zh, this message translates to:
  /// **'预览阶段：连接中...'**
  String get avatarPreviewConnecting;

  /// No description provided for @avatarTotalProgress.
  ///
  /// In zh, this message translates to:
  /// **'总进度: {progress}%'**
  String avatarTotalProgress(Object progress);

  /// No description provided for @avatarGeneratingMesh.
  ///
  /// In zh, this message translates to:
  /// **'正在生成3D网格...'**
  String get avatarGeneratingMesh;

  /// No description provided for @avatarPreviewStage.
  ///
  /// In zh, this message translates to:
  /// **'预览阶段'**
  String get avatarPreviewStage;

  /// No description provided for @avatarApplyingTextures.
  ///
  /// In zh, this message translates to:
  /// **'正在添加贴图...'**
  String get avatarApplyingTextures;

  /// No description provided for @avatarRefineStage.
  ///
  /// In zh, this message translates to:
  /// **'精细化阶段（预览模型已就绪）'**
  String get avatarRefineStage;

  /// No description provided for @avatarPreviewReady.
  ///
  /// In zh, this message translates to:
  /// **'预览模型已就绪'**
  String get avatarPreviewReady;

  /// No description provided for @avatarRefining.
  ///
  /// In zh, this message translates to:
  /// **'正在进行精细化处理...'**
  String get avatarRefining;

  /// No description provided for @avatarRefineFailedUsePreview.
  ///
  /// In zh, this message translates to:
  /// **'精细化失败，使用预览模型'**
  String get avatarRefineFailedUsePreview;

  /// No description provided for @avatarFailed.
  ///
  /// In zh, this message translates to:
  /// **'生成失败'**
  String get avatarFailed;

  /// No description provided for @avatarConnectionInterrupted.
  ///
  /// In zh, this message translates to:
  /// **'连接中断，使用预览模型'**
  String get avatarConnectionInterrupted;

  /// No description provided for @avatar3dError.
  ///
  /// In zh, this message translates to:
  /// **'3D生成出错: {error}'**
  String avatar3dError(Object error);

  /// No description provided for @avatarStageRefine.
  ///
  /// In zh, this message translates to:
  /// **'精细化'**
  String get avatarStageRefine;

  /// No description provided for @avatarStagePreview.
  ///
  /// In zh, this message translates to:
  /// **'预览'**
  String get avatarStagePreview;

  /// No description provided for @avatarStagePending.
  ///
  /// In zh, this message translates to:
  /// **'{stage}排队中...'**
  String avatarStagePending(Object stage);

  /// No description provided for @avatarPreviewToRefine.
  ///
  /// In zh, this message translates to:
  /// **'预览完成，开始精细化...'**
  String get avatarPreviewToRefine;

  /// No description provided for @avatarStageFailed.
  ///
  /// In zh, this message translates to:
  /// **'{stage}失败'**
  String avatarStageFailed(Object stage);

  /// No description provided for @canceled.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get canceled;

  /// No description provided for @processing.
  ///
  /// In zh, this message translates to:
  /// **'处理中...'**
  String get processing;

  /// No description provided for @queueing.
  ///
  /// In zh, this message translates to:
  /// **'排队中...'**
  String get queueing;

  /// No description provided for @generating.
  ///
  /// In zh, this message translates to:
  /// **'正在生成...'**
  String get generating;

  /// No description provided for @previewQueueing.
  ///
  /// In zh, this message translates to:
  /// **'预览排队中...'**
  String get previewQueueing;

  /// No description provided for @refineQueueing.
  ///
  /// In zh, this message translates to:
  /// **'精细化排队中...'**
  String get refineQueueing;

  /// No description provided for @avatarHint.
  ///
  /// In zh, this message translates to:
  /// **'基于您的八字信息\\n正在凝聚专属元神...'**
  String get avatarHint;

  /// No description provided for @relationshipSelectTitle.
  ///
  /// In zh, this message translates to:
  /// **'关系合盘'**
  String get relationshipSelectTitle;

  /// No description provided for @relationshipLover.
  ///
  /// In zh, this message translates to:
  /// **'恋人'**
  String get relationshipLover;

  /// No description provided for @relationshipLoverSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'感情发展与磨合'**
  String get relationshipLoverSubtitle;

  /// No description provided for @relationshipSpouse.
  ///
  /// In zh, this message translates to:
  /// **'夫妻'**
  String get relationshipSpouse;

  /// No description provided for @relationshipSpouseSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'长期相处与家庭节奏'**
  String get relationshipSpouseSubtitle;

  /// No description provided for @relationshipFriend.
  ///
  /// In zh, this message translates to:
  /// **'朋友'**
  String get relationshipFriend;

  /// No description provided for @relationshipFriendSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'性格互补与信任'**
  String get relationshipFriendSubtitle;

  /// No description provided for @relationshipParentChild.
  ///
  /// In zh, this message translates to:
  /// **'亲子'**
  String get relationshipParentChild;

  /// No description provided for @relationshipParentChildSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'陪伴与成长'**
  String get relationshipParentChildSubtitle;

  /// No description provided for @relationshipColleague.
  ///
  /// In zh, this message translates to:
  /// **'同事'**
  String get relationshipColleague;

  /// No description provided for @relationshipColleagueSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'协作与共识'**
  String get relationshipColleagueSubtitle;

  /// No description provided for @relationshipFormTitle.
  ///
  /// In zh, this message translates to:
  /// **'{relationType}合盘'**
  String relationshipFormTitle(Object relationType);

  /// No description provided for @relationshipPersonATitle.
  ///
  /// In zh, this message translates to:
  /// **'甲方信息'**
  String get relationshipPersonATitle;

  /// No description provided for @relationshipPersonBTitle.
  ///
  /// In zh, this message translates to:
  /// **'乙方信息'**
  String get relationshipPersonBTitle;

  /// No description provided for @relationshipGenerateReport.
  ///
  /// In zh, this message translates to:
  /// **'生成合盘报告'**
  String get relationshipGenerateReport;

  /// No description provided for @birthDateLabel.
  ///
  /// In zh, this message translates to:
  /// **'出生日期'**
  String get birthDateLabel;

  /// No description provided for @selectDate.
  ///
  /// In zh, this message translates to:
  /// **'请选择日期'**
  String get selectDate;

  /// No description provided for @birthTimeLabel.
  ///
  /// In zh, this message translates to:
  /// **'出生时辰'**
  String get birthTimeLabel;

  /// No description provided for @selectTime.
  ///
  /// In zh, this message translates to:
  /// **'请选择时辰'**
  String get selectTime;

  /// No description provided for @birthCityLabel.
  ///
  /// In zh, this message translates to:
  /// **'出生城市'**
  String get birthCityLabel;

  /// No description provided for @selectorLabelValue.
  ///
  /// In zh, this message translates to:
  /// **'{label}: {value}'**
  String selectorLabelValue(Object label, Object value);

  /// No description provided for @relationshipBirthInfoIncomplete.
  ///
  /// In zh, this message translates to:
  /// **'请完整填写双方出生日期与时辰'**
  String get relationshipBirthInfoIncomplete;

  /// No description provided for @relationshipReportGenerating.
  ///
  /// In zh, this message translates to:
  /// **'正在生成合盘报告...'**
  String get relationshipReportGenerating;

  /// No description provided for @relationshipReportMissingInfo.
  ///
  /// In zh, this message translates to:
  /// **'缺少合盘信息'**
  String get relationshipReportMissingInfo;

  /// No description provided for @relationshipReportReady.
  ///
  /// In zh, this message translates to:
  /// **'报告已生成'**
  String get relationshipReportReady;

  /// No description provided for @relationshipReportTitle.
  ///
  /// In zh, this message translates to:
  /// **'合盘报告'**
  String get relationshipReportTitle;

  /// No description provided for @relationshipSummary.
  ///
  /// In zh, this message translates to:
  /// **'合盘概要'**
  String get relationshipSummary;

  /// No description provided for @relationshipHighlights.
  ///
  /// In zh, this message translates to:
  /// **'亮点'**
  String get relationshipHighlights;

  /// No description provided for @relationshipAdvice.
  ///
  /// In zh, this message translates to:
  /// **'建议'**
  String get relationshipAdvice;

  /// No description provided for @relationshipEnterChat.
  ///
  /// In zh, this message translates to:
  /// **'进入合盘对话'**
  String get relationshipEnterChat;

  /// No description provided for @relationshipMatchScore.
  ///
  /// In zh, this message translates to:
  /// **'合盘匹配度'**
  String get relationshipMatchScore;

  /// No description provided for @relationshipChatTitle.
  ///
  /// In zh, this message translates to:
  /// **'合盘对话'**
  String get relationshipChatTitle;

  /// No description provided for @relationshipChatHint.
  ///
  /// In zh, this message translates to:
  /// **'继续咨询合盘细节...'**
  String get relationshipChatHint;

  /// No description provided for @relationshipChatUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'抱歉，合盘对话暂时不可用。'**
  String get relationshipChatUnavailable;

  /// No description provided for @relationshipSummaryMessage.
  ///
  /// In zh, this message translates to:
  /// **'合盘概要：{summary}'**
  String relationshipSummaryMessage(Object summary);

  /// No description provided for @languageName.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get languageName;

  /// No description provided for @chatWelcomeMessage.
  ///
  /// In zh, this message translates to:
  /// **'你好,我是你的专属元灵。我会陪伴你,倾听你的心声,也会在需要时给你一些人生的建议。'**
  String get chatWelcomeMessage;

  /// No description provided for @chatStatusOnline.
  ///
  /// In zh, this message translates to:
  /// **'在线'**
  String get chatStatusOnline;

  /// No description provided for @chatSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'你的专属命理伙伴'**
  String get chatSubtitle;

  /// No description provided for @chatInputHint.
  ///
  /// In zh, this message translates to:
  /// **'与元灵对话...'**
  String get chatInputHint;

  /// No description provided for @chatCanceled.
  ///
  /// In zh, this message translates to:
  /// **'[已取消]'**
  String get chatCanceled;

  /// No description provided for @chatErrorResponse.
  ///
  /// In zh, this message translates to:
  /// **'抱歉，我暂时无法回应。请稍后再试。'**
  String get chatErrorResponse;

  /// No description provided for @chatImageLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'图片加载失败'**
  String get chatImageLoadFailed;

  /// No description provided for @chatClear.
  ///
  /// In zh, this message translates to:
  /// **'清空对话'**
  String get chatClear;

  /// No description provided for @chatHistory.
  ///
  /// In zh, this message translates to:
  /// **'对话历史'**
  String get chatHistory;

  /// No description provided for @chatMockReply1.
  ///
  /// In zh, this message translates to:
  /// **'我理解你的感受,让我们一起来探讨一下这个问题。'**
  String get chatMockReply1;

  /// No description provided for @chatMockReply2.
  ///
  /// In zh, this message translates to:
  /// **'从你的八字来看,这个阶段确实需要更多的耐心和坚持。'**
  String get chatMockReply2;

  /// No description provided for @chatMockReply3.
  ///
  /// In zh, this message translates to:
  /// **'我一直在这里陪伴你,无论什么时候你都可以和我分享你的想法。'**
  String get chatMockReply3;

  /// No description provided for @chatMockReply4.
  ///
  /// In zh, this message translates to:
  /// **'根据你的命理,现在是一个适合思考和规划的时期。'**
  String get chatMockReply4;

  /// No description provided for @chatMockReply5.
  ///
  /// In zh, this message translates to:
  /// **'每个人都会遇到困难,重要的是如何面对它们。你做得很好。'**
  String get chatMockReply5;

  /// No description provided for @timeJustNow.
  ///
  /// In zh, this message translates to:
  /// **'刚刚'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In zh, this message translates to:
  /// **'{minutes}分钟前'**
  String timeMinutesAgo(Object minutes);

  /// No description provided for @timeHourMinute.
  ///
  /// In zh, this message translates to:
  /// **'{hour}:{minute}'**
  String timeHourMinute(Object hour, Object minute);

  /// No description provided for @timeMonthDay.
  ///
  /// In zh, this message translates to:
  /// **'{month}月{day}日'**
  String timeMonthDay(Object month, Object day);

  /// No description provided for @chatOverlayWelcomeMessage.
  ///
  /// In zh, this message translates to:
  /// **'在存亮透过的瞬息，谢谢结缘的距离？\\n元神的经过的瞬息，意不如型诚语...'**
  String get chatOverlayWelcomeMessage;

  /// No description provided for @chatOverlayInputHint.
  ///
  /// In zh, this message translates to:
  /// **'向元灵倾诉...'**
  String get chatOverlayInputHint;

  /// No description provided for @chatOverlayMockReply.
  ///
  /// In zh, this message translates to:
  /// **'我听到了你的心声... \\n风起于青萍之末，浪成于微澜之间。此刻的迷茫，或许是觉醒的前奏。'**
  String get chatOverlayMockReply;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
