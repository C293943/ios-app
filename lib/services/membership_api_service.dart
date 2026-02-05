// 会员支付接口封装，负责套餐、订单与会员状态请求。
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:primordial_spirit/config/app_config.dart';
import 'package:primordial_spirit/models/membership_models.dart';
import 'package:primordial_spirit/services/auth_service.dart';

class MembershipApiException implements Exception {
  final String message;
  MembershipApiException(this.message);

  @override
  String toString() => message;
}

class MembershipApiService {
  final http.Client _client = http.Client();
  final AuthService _authService = AuthService();

  Future<List<MembershipPlan>> fetchPlans() async {
    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.membershipPlansEndpoint}');
    final response = await _client.get(url);
    final payload = _parseResponse(response);
    final data = payload['data'] as Map<String, dynamic>? ?? {};
    final plans = (data['plans'] as List<dynamic>? ?? []);
    return plans.map((item) => MembershipPlan.fromJson(item)).toList();
  }

  Future<PaymentOrder> createOrder({
    required String planId,
    required String paymentMethod,
  }) async {
    final headers = await _authService.authorizedHeaders();
    if (headers == null) {
      throw MembershipApiException('AUTH_REQUIRED');
    }
    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.membershipOrdersEndpoint}');
    final response = await _client.post(
      url,
      headers: headers,
      body: jsonEncode({
        'plan_id': planId,
        'payment_method': paymentMethod,
      }),
    );
    final payload = _parseResponse(response);
    final data = payload['data'] as Map<String, dynamic>? ?? {};
    return PaymentOrder.fromJson(data);
  }

  Future<PaymentOrderStatus> fetchOrderStatus(String orderId) async {
    final headers = await _authService.authorizedHeaders();
    if (headers == null) {
      throw MembershipApiException('AUTH_REQUIRED');
    }
    final url = Uri.parse(
      '${AppConfig.baseUrl}${AppConfig.membershipOrdersEndpoint}/$orderId',
    );
    final response = await _client.get(url, headers: headers);
    final payload = _parseResponse(response);
    final data = payload['data'] as Map<String, dynamic>? ?? {};
    return PaymentOrderStatus.fromJson(data);
  }

  Future<MembershipStatus> fetchMembershipStatus() async {
    final headers = await _authService.authorizedHeaders();
    if (headers == null) {
      throw MembershipApiException('AUTH_REQUIRED');
    }
    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.membershipStatusEndpoint}');
    final response = await _client.get(url, headers: headers);
    final payload = _parseResponse(response);
    final data = payload['data'] as Map<String, dynamic>? ?? {};
    return MembershipStatus.fromJson(data);
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    // 先检查 HTTP 状态码
    if (response.statusCode >= 500) {
      throw MembershipApiException('服务器错误(${response.statusCode})');
    }
    
    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw MembershipApiException('响应解析失败');
    }

    // 检查 HTTP 状态码 4xx 错误
    if (response.statusCode >= 400) {
      final message = json['message'] as String? ?? json['detail'] as String? ?? '请求失败(${response.statusCode})';
      throw MembershipApiException(message);
    }

    final success = json['success'] == true || json['code'] == 200;
    if (!success) {
      final message = json['message'] as String? ?? '请求失败';
      throw MembershipApiException(message);
    }
    return json;
  }
}
