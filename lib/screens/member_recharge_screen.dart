import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/l10n/l10n.dart';
import 'package:primordial_spirit/models/membership_models.dart';
import 'package:primordial_spirit/services/membership_api_service.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/widgets/common/toast_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

class MemberRechargeScreen extends StatefulWidget {
  const MemberRechargeScreen({super.key});

  @override
  State<MemberRechargeScreen> createState() => _MemberRechargeScreenState();
}

class _MemberRechargeScreenState extends State<MemberRechargeScreen> {
  int _selectedPlanIndex = 1; // Default to Monthly (Recommended)
  int _selectedPaymentMethod = 0; // 0: WeChat, 1: Alipay
  final MembershipApiService _membershipApi = MembershipApiService();
  final List<MembershipPlan> _plans = [];
  bool _isLoadingPlans = true;
  bool _isPaying = false;
  Timer? _pollTimer;
  bool _isPolling = false;
  int _pollAttempts = 0;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = 1;
    _loadPlans();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Define text colors based on theme
    final textColor = isDark ? Colors.white : AppTheme.inkText;

    // Light mode background gradient - Soft & Clean
    final lightBgGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFF8FAFC), // Slate 50
        Color(0xFFF1F5F9), // Slate 100
      ],
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: isDark ? [] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Icon(Icons.arrow_back_ios_new, size: 18, color: isDark ? Colors.white : AppTheme.inkText),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.l10n.memberRechargeTitle,
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.inkText, 
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: isDark ? AppTheme.voidGradient : lightBgGradient,
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCard(context, isDark),
                        const SizedBox(height: 30),
                        Text(
                          context.l10n.memberPlans,
                          style: TextStyle(
                            color: textColor.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPlansRow(context, isDark),
                        const SizedBox(height: 30),
                        Text(
                          context.l10n.paymentMethod,
                          style: TextStyle(
                            color: textColor.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPaymentMethod(context, isDark),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(context, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        // In light mode, use a clean gradient matching brand (Teal/Cyan)
        gradient: isDark 
            ? null 
            : LinearGradient(
                colors: [
                  AppTheme.jadeGreen,
                  AppTheme.jadeGreen.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isDark ? AppTheme.voidDeeper.withOpacity(0.8) : null,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.fluorescentCyan.withOpacity(0.3) : Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppTheme.jadeGreen).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.diamond_outlined,
            size: 40,
            color: isDark ? AppTheme.fluorescentCyan : Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.activateMember,
            style: TextStyle(
              color: isDark ? AppTheme.warmYellow : Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.unlockFeatures,
            style: TextStyle(
              color: isDark ? AppTheme.inkText.withOpacity(0.7) : Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansRow(BuildContext context, bool isDark) {
    if (_isLoadingPlans) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(
            color: isDark ? AppTheme.fluorescentCyan : AppTheme.jadeGreen,
          ),
        ),
      );
    }

    final plans = _displayPlans(context);
    final children = <Widget>[];
    for (var i = 0; i < plans.length; i++) {
      final plan = plans[i];
      final isGold = plan.recommended;
      children.add(
        Expanded(
          child: _buildPlanCard(
            context,
            index: i,
            title: plan.name,
            duration: _planDurationLabel(plan, context),
            benefits: plan.benefits,
            originalPrice: _formatPrice(plan.originalPrice),
            price: _formatPrice(plan.price),
            priceUnit: _planPriceUnitLabel(plan, context),
            dailyPrice: _planDailyPriceLabel(plan, context),
            tag: plan.recommended ? context.l10n.recommended : null,
            isGold: isGold,
            gradientColors: isDark
                ? [
                    isGold
                        ? const Color(0xFF3E2723).withOpacity(0.95)
                        : AppTheme.voidDeeper.withOpacity(0.8),
                    isGold
                        ? const Color(0xFF5D4037).withOpacity(0.8)
                        : AppTheme.inkGreen.withOpacity(0.6),
                  ]
                : [
                    isGold ? const Color(0xFFFFFBEB) : Colors.white,
                    isGold ? const Color(0xFFFFFBEB) : Colors.white,
                  ],
            textColor: isGold ? AppTheme.amberGold : Colors.white,
            isDark: isDark,
          ),
        ),
      );
      if (i < plans.length - 1) {
        children.add(const SizedBox(width: 8));
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: children,
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required int index,
    required String title,
    required String duration,
    required List<String> benefits,
    required String originalPrice,
    required String price,
    required String priceUnit,
    String? dailyPrice,
    String? tag,
    bool isGold = false,
    required List<Color> gradientColors,
    Color textColor = Colors.white,
    required bool isDark,
  }) {
    final isSelected = _selectedPlanIndex == index;
    
    // Determine Colors based on mode and card type
    Color effectiveTextColor;
    if (isDark) {
      effectiveTextColor = isGold ? textColor : AppTheme.inkText;
    } else {
      // Light mode text colors
      if (isGold) {
        effectiveTextColor = const Color(0xFF92400E); // Dark Amber
      } else {
        effectiveTextColor = isSelected ? AppTheme.jadeGreen : AppTheme.inkText; 
      }
    }
    
    // Gradients
    List<Color> effectiveGradient;
    if (isSelected && !isGold) {
      if (isDark) {
        effectiveGradient = [
          const Color(0xFF0F262A),
          const Color(0xFF163A3F),
        ];
      } else {
        effectiveGradient = [
          const Color(0xFFECFEFF), // Cyan 50
          const Color(0xFFECFEFF),
        ];
      }
    } else {
      effectiveGradient = gradientColors;
    }

    // Border
    Color borderColor;
    if (isSelected) {
      borderColor = isGold 
          ? AppTheme.amberGold 
          : (isDark ? AppTheme.fluorescentCyan : AppTheme.jadeGreen);
    } else {
      borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Main Card
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.fromLTRB(8, tag != null ? 24 : 16, 8, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: effectiveGradient,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: (isGold 
                            ? AppTheme.amberGold 
                            : (isDark ? AppTheme.fluorescentCyan : AppTheme.jadeGreen)).withOpacity(0.2),
                        blurRadius: 16,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                  ],
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: effectiveTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isGold 
                        ? (isDark ? AppTheme.amberGold.withOpacity(0.15) : Colors.white.withOpacity(0.6))
                        : (isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    duration,
                    style: TextStyle(
                      color: effectiveTextColor.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Benefits List
                ...benefits.map((benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          benefit,
                          style: TextStyle(
                            color: effectiveTextColor.withOpacity(0.7),
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 8), 
                Text(
                  '¥$originalPrice',
                  style: TextStyle(
                    color: effectiveTextColor.withOpacity(0.4),
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: effectiveTextColor.withOpacity(0.4),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '¥',
                        style: TextStyle(
                          color: effectiveTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: price,
                        style: TextStyle(
                          color: effectiveTextColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: priceUnit,
                        style: TextStyle(
                          color: effectiveTextColor.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (dailyPrice != null)
                  Text(
                    dailyPrice,
                    style: TextStyle(
                      color: effectiveTextColor.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          
          // Tag
          if (tag != null)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isGold 
                      ? [AppTheme.amberGold, const Color(0xFFFFDF00)]
                      : (isDark 
                          ? [AppTheme.fluorescentCyan, const Color(0xFF00897B)]
                          : [const Color(0xFF26A69A), const Color(0xFF80CBC4)]),
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    )
                  ],
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: isDark ? Color(0xFF101010) : Colors.white, 
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : AppTheme.inkText;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.voidDeeper.withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPaymentOption(
            context,
            index: 0,
            icon: Icons.chat_bubble, 
            iconColor: const Color(0xFF09B83E),
            label: context.l10n.wechatPay,
            textColor: textColor,
            isDark: isDark,
            enabled: false,
          ),
          _buildPaymentOption(
            context,
            index: 1,
            icon: Icons.payment,
            iconColor: const Color(0xFF1678FF),
            label: context.l10n.alipay,
            textColor: textColor,
            isDark: isDark,
            enabled: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentOption(
    BuildContext context, {
    required int index,
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color textColor,
    required bool isDark,
    required bool enabled,
  }) {
    final isSelected = _selectedPaymentMethod == index;
    final activeColor = isDark ? AppTheme.fluorescentCyan : const Color(0xFF009688);
    
    return GestureDetector(
      onTap: () {
        if (!enabled) {
          _showToast(context, context.l10n.paymentWechatUnavailable);
          return;
        }
        setState(() => _selectedPaymentMethod = index);
      },
      child: Row(
        children: [
          // Custom Radio Button
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected 
                  ? activeColor
                  : (isDark ? Colors.white.withOpacity(0.5) : Colors.grey.withOpacity(0.3)),
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: isSelected
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeColor,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Icon(icon, color: iconColor.withOpacity(enabled ? 1 : 0.4), size: 24),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(enabled ? 1 : 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isPaying ? null : () => _handlePayment(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 8,
                shadowColor: (isDark ? AppTheme.fluorescentCyan : const Color(0xFF26A69A)).withOpacity(0.4),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [
                          AppTheme.fluorescentCyan,
                          AppTheme.fluorescentCyan.withOpacity(0.7),
                          const Color(0xFFE0C3FC), 
                        ]
                      : [
                          const Color(0xFF26A69A), // Teal 400
                          const Color(0xFF80CBC4), // Teal 200
                        ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    _isPaying ? context.l10n.paymentProcessing : context.l10n.activateNow,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.agreementHint,
            style: TextStyle(
              color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.4),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoadingPlans = true);
    try {
      final plans = await _membershipApi.fetchPlans();
      if (mounted) {
        _plans
          ..clear()
          ..addAll(plans);
        _selectedPlanIndex = _recommendedPlanIndex(plans);
      }
    } catch (_) {
      if (mounted) {
        _showToast(context, context.l10n.paymentLoadPlansFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingPlans = false);
      }
    }
  }

  Future<void> _handlePayment(BuildContext context) async {
    if (_isPaying) return;
    if (_selectedPaymentMethod == 0) {
      _showToast(context, context.l10n.paymentWechatUnavailable);
      return;
    }

    final plans = _displayPlans(context);
    if (plans.isEmpty || _selectedPlanIndex >= plans.length) return;
    final selectedPlan = plans[_selectedPlanIndex];

    setState(() => _isPaying = true);
    try {
      final order = await _membershipApi.createOrder(
        planId: selectedPlan.id,
        paymentMethod: 'alipay',
      );

      final paymentUrl = order.paymentUrl;
      if (paymentUrl == null || paymentUrl.isEmpty) {
        throw MembershipApiException(context.l10n.paymentOrderFailed);
      }

      // 支付宝 App 支付返回的是订单字符串，需要转换为 URL Scheme
      // 格式：alipays://platformapi/startapp?appId=20000067&url=编码后的订单字符串
      final Uri launchUri;
      if (paymentUrl.startsWith('http://') || paymentUrl.startsWith('https://') || paymentUrl.startsWith('alipays://')) {
        // 已经是有效的 URL
        launchUri = Uri.parse(paymentUrl);
      } else {
        // 支付宝订单字符串，转换为 URL Scheme
        final encodedOrderString = Uri.encodeComponent(paymentUrl);
        launchUri = Uri.parse('alipays://platformapi/startapp?appId=20000067&url=$encodedOrderString');
      }

      final launched = await launchUrl(
        launchUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _showToast(context, context.l10n.paymentLaunchFailed);
        return;
      }

      _showToast(context, context.l10n.paymentOrderCreated);
      _startPolling(order.orderId);
    } on MembershipApiException catch (e) {
      if (e.message == 'AUTH_REQUIRED') {
        _showToast(context, context.l10n.paymentAuthRequired);
      } else {
        _showToast(context, e.message);
      }
    } catch (e) {
      debugPrint('支付错误: $e');
      _showToast(context, context.l10n.paymentOrderFailed);
    } finally {
      if (mounted) {
        setState(() => _isPaying = false);
      }
    }
  }

  void _startPolling(String orderId) {
    _pollTimer?.cancel();
    _pollAttempts = 0;
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_isPolling) return;
      _isPolling = true;
      _pollAttempts += 1;

      try {
        final status = await _membershipApi.fetchOrderStatus(orderId);
        if (status.status == 'paid') {
          await _membershipApi.fetchMembershipStatus();
          _showToast(context, context.l10n.paymentSuccess);
          timer.cancel();
        } else if (status.status == 'expired') {
          _showToast(context, context.l10n.paymentExpired);
          timer.cancel();
        } else if (status.status == 'cancelled') {
          _showToast(context, context.l10n.paymentCancelled);
          timer.cancel();
        }
      } catch (_) {
        // 忽略单次查询失败，等待下一次轮询
      } finally {
        _isPolling = false;
      }

      if (_pollAttempts >= 60) {
        _showToast(context, context.l10n.paymentStatusTimeout);
        timer.cancel();
      }
    });
  }

  List<MembershipPlan> _displayPlans(BuildContext context) {
    if (_plans.isNotEmpty) return _plans;
    return _fallbackPlans(context);
  }

  List<MembershipPlan> _fallbackPlans(BuildContext context) {
    return [
      MembershipPlan(
        id: 'weekly',
        name: context.l10n.weeklyPlan,
        durationDays: 7,
        originalPrice: 28,
        price: 19.9,
        benefits: [
          context.l10n.giftCoins('50'),
          context.l10n.dailyChatLimit('50'),
          context.l10n.exclusiveBadge,
        ],
        recommended: false,
        spiritStones: 50,
        dailyChatLimit: 50,
        badges: const ['vip_weekly'],
      ),
      MembershipPlan(
        id: 'monthly',
        name: context.l10n.monthlyPlan,
        durationDays: 30,
        originalPrice: 88,
        price: 58,
        benefits: [
          context.l10n.giftCoins('70'),
          context.l10n.dailyChatLimit('70'),
          context.l10n.exclusiveBadge,
          context.l10n.priorityExperience,
        ],
        recommended: true,
        spiritStones: 70,
        dailyChatLimit: 70,
        badges: const ['vip_monthly'],
      ),
      MembershipPlan(
        id: 'yearly',
        name: context.l10n.yearlyPlan,
        durationDays: 365,
        originalPrice: 588,
        price: 298,
        benefits: [
          context.l10n.giftCoins('100'),
          context.l10n.dailyChatLimit('100'),
          context.l10n.exclusiveBadge,
          context.l10n.priorityExperience,
          context.l10n.customerService,
        ],
        recommended: false,
        spiritStones: 100,
        dailyChatLimit: 100,
        badges: const ['vip_yearly'],
      ),
    ];
  }

  int _recommendedPlanIndex(List<MembershipPlan> plans) {
    for (var i = 0; i < plans.length; i++) {
      if (plans[i].recommended) return i;
    }
    return plans.isEmpty ? 0 : (plans.length > 1 ? 1 : 0);
  }

  String _planDurationLabel(MembershipPlan plan, BuildContext context) {
    if (plan.durationDays == 7) return context.l10n.days7;
    if (plan.durationDays == 30) return context.l10n.days30;
    if (plan.durationDays == 365) return context.l10n.days365;
    return '${plan.durationDays}天';
  }

  String _planPriceUnitLabel(MembershipPlan plan, BuildContext context) {
    if (plan.durationDays == 7) return '/${context.l10n.week}';
    if (plan.durationDays == 30) return '/${context.l10n.month}';
    if (plan.durationDays == 365) return '/${context.l10n.year}';
    return '/${plan.durationDays}天';
  }

  String? _planDailyPriceLabel(MembershipPlan plan, BuildContext context) {
    if (plan.durationDays < 30) return null;
    final pricePerDay = (plan.price / plan.durationDays).toStringAsFixed(2);
    return context.l10n.pricePerDay(pricePerDay);
  }

  String _formatPrice(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  void _showToast(BuildContext context, String message) {
    ToastOverlay.show(context, message: message, icon: Icons.info_outline);
  }
}
