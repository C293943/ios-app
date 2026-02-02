import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/l10n/l10n.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';

class MemberRechargeScreen extends StatefulWidget {
  const MemberRechargeScreen({super.key});

  @override
  State<MemberRechargeScreen> createState() => _MemberRechargeScreenState();
}

class _MemberRechargeScreenState extends State<MemberRechargeScreen> {
  int _selectedPlanIndex = 1; // Default to Monthly (Recommended)
  int _selectedPaymentMethod = 0; // 0: WeChat, 1: Alipay

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.l10n.memberRechargeTitle,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.voidGradient,
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
                        _buildHeaderCard(context),
                        const SizedBox(height: 30),
                        Text(
                          context.l10n.memberPlans,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPlansRow(context),
                        const SizedBox(height: 30),
                        Text(
                          context.l10n.paymentMethod,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPaymentMethod(context),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.voidDeeper.withOpacity(0.6), // Deep dark background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.fluorescentCyan.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.diamond_outlined,
            size: 40,
            color: AppTheme.fluorescentCyan,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.activateMember,
            style: TextStyle(
              color: AppTheme.warmYellow,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.unlockFeatures,
            style: TextStyle(
              color: AppTheme.inkText.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _buildPlanCard(
            context,
            index: 0,
            title: context.l10n.weeklyPlan,
            duration: context.l10n.days7,
            benefits: [
              context.l10n.giftCoins('50'),
              context.l10n.dailyChatLimit('50'),
              context.l10n.exclusiveBadge,
            ],
            originalPrice: '28',
            price: '19.9',
            priceUnit: '/${context.l10n.week}',
            tag: null,
            gradientColors: [
              AppTheme.voidDeeper.withOpacity(0.8),
              AppTheme.inkGreen.withOpacity(0.6),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildPlanCard(
            context,
            index: 1,
            title: context.l10n.monthlyPlan,
            duration: context.l10n.days30,
            benefits: [
              context.l10n.giftCoins('70'),
              context.l10n.dailyChatLimit('70'),
              context.l10n.exclusiveBadge,
              context.l10n.priorityExperience,
            ],
            originalPrice: '88',
            price: '58',
            priceUnit: '/${context.l10n.month}',
            tag: context.l10n.recommended,
            isGold: true,
            gradientColors: [
              const Color(0xFF2D1F18).withOpacity(0.9), // Deep bronze/black
              const Color(0xFF4A3420).withOpacity(0.8), // Dark bronze
            ],
            textColor: AppTheme.amberGold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildPlanCard(
            context,
            index: 2,
            title: context.l10n.yearlyPlan,
            duration: context.l10n.days365,
            benefits: [
              context.l10n.giftCoins('100'),
              context.l10n.dailyChatLimit('100'),
              context.l10n.exclusiveBadge,
              context.l10n.priorityExperience,
              context.l10n.customerService,
            ],
            originalPrice: '588',
            price: '298',
            priceUnit: '/${context.l10n.year}',
            dailyPrice: context.l10n.pricePerDay('0.82'),
            tag: context.l10n.bestValue,
            gradientColors: [
              AppTheme.voidDeeper.withOpacity(0.8),
              AppTheme.inkGreen.withOpacity(0.6),
            ],
          ),
        ),
      ],
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
  }) {
    final isSelected = _selectedPlanIndex == index;
    final baseTextColor = isGold ? textColor : AppTheme.inkText;
    
    // Use darker, richer gradients for selected states
    final effectiveGradient = isSelected && !isGold 
        ? [
            const Color(0xFF0F262A), // Dark cyan/black
            const Color(0xFF163A3F), // Slightly lighter
          ]
        : gradientColors;

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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                    ? (isGold ? AppTheme.amberGold : AppTheme.fluorescentCyan) 
                    : Colors.white.withOpacity(0.1),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: (isGold ? AppTheme.amberGold : AppTheme.fluorescentCyan).withOpacity(0.15),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isGold ? textColor : (isSelected ? AppTheme.fluorescentCyan : baseTextColor),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isGold ? AppTheme.amberGold.withOpacity(0.1) : Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isGold ? AppTheme.amberGold.withOpacity(0.2) : Colors.transparent,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    duration,
                    style: TextStyle(
                      color: baseTextColor.withOpacity(0.8),
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
                            color: baseTextColor.withOpacity(0.6),
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
                    color: baseTextColor.withOpacity(0.3),
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: baseTextColor.withOpacity(0.3),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '¥',
                        style: TextStyle(
                          color: isGold ? textColor : (isSelected ? AppTheme.fluorescentCyan : baseTextColor),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: price,
                        style: TextStyle(
                          color: isGold ? textColor : (isSelected ? AppTheme.fluorescentCyan : baseTextColor),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: priceUnit,
                        style: TextStyle(
                          color: baseTextColor.withOpacity(0.6),
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
                      color: baseTextColor.withOpacity(0.5),
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
                      ? [AppTheme.amberGold, const Color(0xFFC6A700)]
                      : [AppTheme.fluorescentCyan, const Color(0xFF00897B)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    )
                  ],
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Color(0xFF101010), 
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

  Widget _buildPaymentMethod(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.voidDeeper.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
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
          ),
          _buildPaymentOption(
            context,
            index: 1,
            icon: Icons.payment,
            iconColor: const Color(0xFF1678FF),
            label: context.l10n.alipay,
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
  }) {
    final isSelected = _selectedPaymentMethod == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      child: Row(
        children: [
          // Custom Radio Button
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppTheme.fluorescentCyan : Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: isSelected
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.fluorescentCyan,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      // Glass effect for bottom bar? Or just transparent? 
      // Image shows it floating.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // Handle payment logic
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 8,
                shadowColor: AppTheme.fluorescentCyan.withOpacity(0.4),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.fluorescentCyan,
                      AppTheme.fluorescentCyan.withOpacity(0.7),
                      const Color(0xFFE0C3FC), // Light purple hint
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    context.l10n.activateNow,
                    style: const TextStyle(
                      color: Color(0xFF1A1A2E), // Dark text on bright button
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
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
