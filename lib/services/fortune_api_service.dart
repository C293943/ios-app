import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:primordial_spirit/config/app_config.dart';
import 'package:primordial_spirit/models/fortune_models.dart';

/// 算命API服务
class FortuneApiService {
  static final FortuneApiService _instance = FortuneApiService._internal();
  factory FortuneApiService() => _instance;
  FortuneApiService._internal();

  final http.Client _client = http.Client();

  /// 请求状态回调
  Function(String status)? onStatusChanged;

  /// 步骤1：计算八字和紫薇
  /// POST /api/v1/calculate
  Future<CalculateResponse> calculate(BirthInfo birthInfo) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/v1/calculate');
    debugPrint('[API] 请求URL: $url');
    debugPrint('[API] 请求数据: ${jsonEncode({'birth_info': birthInfo.toJson()})}');
    onStatusChanged?.call('正在连接服务器...');

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'birth_info': birthInfo.toJson()}),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('[API] 响应状态码: ${response.statusCode}');
      debugPrint('[API] 响应内容: ${response.body}');

      if (response.statusCode == 200) {
        onStatusChanged?.call('计算成功，正在解析...');
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return CalculateResponse.fromJson(json);
      } else {
        onStatusChanged?.call('服务器错误: ${response.statusCode}');
        debugPrint('[API] Calculate API error: ${response.statusCode} - ${response.body}');
        return CalculateResponse(
          success: false,
          message: '计算失败: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      onStatusChanged?.call('请求超时，请检查网络');
      debugPrint('[API] Calculate API timeout');
      return CalculateResponse(
        success: false,
        message: '请求超时，请检查网络连接',
      );
    } catch (e) {
      onStatusChanged?.call('网络错误: $e');
      debugPrint('[API] Calculate API exception: $e');
      return CalculateResponse(
        success: false,
        message: '网络错误: $e',
      );
    }
  }

  /// 步骤2：算命（非流式）
  /// POST /api/v1/fortune
  Future<FortuneResponse> fortune(FortuneRequest request) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/api/v1/fortune');
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return FortuneResponse.fromJson(json);
      } else {
        debugPrint('Fortune API error: ${response.statusCode} - ${response.body}');
        return FortuneResponse(
          success: false,
          message: '请求失败: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Fortune API exception: $e');
      return FortuneResponse(
        success: false,
        message: '网络错误: $e',
      );
    }
  }

  /// 步骤3：算命（流式）
  /// POST /api/v1/fortune/stream
  /// 返回一个Stream，逐字返回AI回复
  Stream<String> fortuneStream(FortuneRequest request) async* {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/api/v1/fortune/stream');
      final httpRequest = http.Request('POST', url);
      httpRequest.headers['Content-Type'] = 'application/json';
      httpRequest.body = jsonEncode(request.toJson());

      final streamedResponse = await _client.send(httpRequest);

      if (streamedResponse.statusCode == 200) {
        // 处理SSE流
        await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
          // SSE格式: data: {"chunk": "文字"} 或 data: {"done": true}
          final lines = chunk.split('\n');
          for (final line in lines) {
            if (line.startsWith('data: ')) {
              final jsonStr = line.substring(6).trim();
              if (jsonStr.isEmpty) continue;

              try {
                final json = jsonDecode(jsonStr) as Map<String, dynamic>;
                if (json.containsKey('chunk')) {
                  yield json['chunk'] as String;
                } else if (json['done'] == true) {
                  // 流结束
                  return;
                }
              } catch (e) {
                debugPrint('Parse SSE chunk error: $e, line: $line');
              }
            }
          }
        }
      } else {
        debugPrint('Fortune stream API error: ${streamedResponse.statusCode}');
        yield '[错误] 请求失败: ${streamedResponse.statusCode}';
      }
    } catch (e) {
      debugPrint('Fortune stream API exception: $e');
      yield '[错误] 网络错误: $e';
    }
  }

  /// 关闭客户端
  void dispose() {
    _client.close();
  }
}
