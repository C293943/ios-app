// 会员套餐、订单与状态的数据模型。
class MembershipPlan {
  final String id;
  final String name;
  final int durationDays;
  final double originalPrice;
  final double price;
  final List<String> benefits;
  final bool recommended;
  final int spiritStones;
  final int dailyChatLimit;
  final List<String> badges;

  MembershipPlan({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.originalPrice,
    required this.price,
    required this.benefits,
    required this.recommended,
    required this.spiritStones,
    required this.dailyChatLimit,
    required this.badges,
  });

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    return MembershipPlan(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      durationDays: json['duration_days'] as int? ?? 0,
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      benefits: (json['benefits'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      recommended: json['recommended'] as bool? ?? false,
      spiritStones: json['spirit_stones'] as int? ?? 0,
      dailyChatLimit: json['daily_chat_limit'] as int? ?? 0,
      badges: (json['badges'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

class PaymentOrder {
  final String orderId;
  final String planId;
  final String planName;
  final double amount;
  final String paymentMethod;
  final String? paymentUrl;
  final String? qrCodeUrl;
  final String expiresAt;

  PaymentOrder({
    required this.orderId,
    required this.planId,
    required this.planName,
    required this.amount,
    required this.paymentMethod,
    this.paymentUrl,
    this.qrCodeUrl,
    required this.expiresAt,
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    return PaymentOrder(
      orderId: json['order_id'] as String? ?? '',
      planId: json['plan_id'] as String? ?? '',
      planName: json['plan_name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['payment_method'] as String? ?? '',
      paymentUrl: json['payment_url'] as String?,
      qrCodeUrl: json['qr_code_url'] as String?,
      expiresAt: json['expires_at'] as String? ?? '',
    );
  }
}

class PaymentOrderStatus {
  final String orderId;
  final String status;
  final String planId;
  final String planName;
  final double amount;
  final String paymentMethod;
  final String? paidAt;
  final String createdAt;

  PaymentOrderStatus({
    required this.orderId,
    required this.status,
    required this.planId,
    required this.planName,
    required this.amount,
    required this.paymentMethod,
    this.paidAt,
    required this.createdAt,
  });

  factory PaymentOrderStatus.fromJson(Map<String, dynamic> json) {
    return PaymentOrderStatus(
      orderId: json['order_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      planId: json['plan_id'] as String? ?? '',
      planName: json['plan_name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['payment_method'] as String? ?? '',
      paidAt: json['paid_at'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class MembershipStatus {
  final bool isMember;
  final String? planId;
  final String? planName;
  final String? startDate;
  final String? expireDate;
  final int remainingDays;
  final int spiritStones;
  final int dailyChatLimit;
  final int dailyChatUsed;
  final List<String> badges;

  MembershipStatus({
    required this.isMember,
    this.planId,
    this.planName,
    this.startDate,
    this.expireDate,
    required this.remainingDays,
    required this.spiritStones,
    required this.dailyChatLimit,
    required this.dailyChatUsed,
    required this.badges,
  });

  factory MembershipStatus.fromJson(Map<String, dynamic> json) {
    return MembershipStatus(
      isMember: json['is_member'] as bool? ?? false,
      planId: json['plan_id'] as String?,
      planName: json['plan_name'] as String?,
      startDate: json['start_date'] as String?,
      expireDate: json['expire_date'] as String?,
      remainingDays: json['remaining_days'] as int? ?? 0,
      spiritStones: json['spirit_stones'] as int? ?? 0,
      dailyChatLimit: json['daily_chat_limit'] as int? ?? 0,
      dailyChatUsed: json['daily_chat_used'] as int? ?? 0,
      badges: (json['badges'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}
