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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Define text colors based on theme
    final textColor = isDark ? Colors.white : AppTheme.inkText;
    final subTextColor = isDark ? Colors.white.withOpacity(0.7) : AppTheme.inkText.withOpacity(0.6);

    // Light mode background gradient
    final lightBgGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFF5F7FA), // Very light grey-blue
        Color(0xFFE8EAF6), // Light indigo tint
        Color(0xFFE0F2F1), // Light teal tint
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
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
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
        // In light mode, use a colorful gradient to make it pop against the light background
        gradient: isDark 
            ? null 
            : const LinearGradient(
                colors: [Color(0xFF29B6F6), Color(0xFFAB47BC)], // Light Blue to Purple
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isDark ? AppTheme.voidDeeper.withOpacity(0.8) : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.fluorescentCyan.withOpacity(0.3) : Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.4) : const Color(0xFFAB47BC).withOpacity(0.3),
            blurRadius: 15,
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
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                )
              ],
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
            gradientColors: isDark 
              ? [
                  AppTheme.voidDeeper.withOpacity(0.8),
                  AppTheme.inkGreen.withOpacity(0.6),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF5F5F5),
                ],
            isDark: isDark,
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
            gradientColors: isDark
              ? [
                  const Color(0xFF3E2723).withOpacity(0.95), // Deep brown
                  const Color(0xFF5D4037).withOpacity(0.8),
                ]
              : [
                  const Color(0xFFFFF8E1), // Light Amber
                  const Color(0xFFFFECB3),
                ],
            textColor: AppTheme.amberGold,
            isDark: isDark,
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
            gradientColors: isDark
              ? [
                  AppTheme.voidDeeper.withOpacity(0.8),
                  AppTheme.inkGreen.withOpacity(0.6),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF5F5F5),
                ],
            isDark: isDark,
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
        effectiveTextColor = const Color(0xFF5D4037); // Dark brown
      } else {
        effectiveTextColor = isSelected ? const Color(0xFF00695C) : const Color(0xFF455A64); // Teal or Grey
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
          const Color(0xFFE0F7FA), // Light Cyan
          const Color(0xFFB2EBF2),
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
          : (isDark ? AppTheme.fluorescentCyan : const Color(0xFF26A69A));
    } else {
      borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2);
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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: (isGold 
                            ? AppTheme.amberGold 
                            : (isDark ? AppTheme.fluorescentCyan : const Color(0xFF26A69A))).withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 6,
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
          ),
          _buildPaymentOption(
            context,
            index: 1,
            icon: Icons.payment,
            iconColor: const Color(0xFF1678FF),
            label: context.l10n.alipay,
            textColor: textColor,
            isDark: isDark,
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
  }) {
    final isSelected = _selectedPaymentMethod == index;
    final activeColor = isDark ? AppTheme.fluorescentCyan : const Color(0xFF009688);
    
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
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
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
              onPressed: () {
                // Handle payment logic
              },
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
                    context.l10n.activateNow,
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
}
