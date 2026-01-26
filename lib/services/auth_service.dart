// 认证服务：负责登录、注册、刷新与本地缓存。
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:primordial_spirit/config/app_config.dart';
import 'package:primordial_spirit/models/user_models.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final http.Client _client = http.Client();

  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _cachedUserKey = 'auth_user';
  static const String _cachedProfileKey = 'auth_profile';

  Future<AuthSession> register({
    required String email,
    required String password,
    UserProfile? profile,
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.authRegisterEndpoint}');
    final body = {
      'email': email,
      'password': password,
      if (profile != null) 'profile': _profilePayload(profile),
    };

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleSessionResponse(response);
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.authLoginEndpoint}');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleSessionResponse(response);
  }

  Future<AuthSession?> refresh() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.authRefreshEndpoint}');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode != 200) return null;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['success'] != true) return null;
    final data = json['data'] as Map<String, dynamic>? ?? {};

    final newAccess = data['access_token'] as String?;
    final newRefresh = data['refresh_token'] as String? ?? refreshToken;
    if (newAccess == null || newAccess.isEmpty) return null;

    await _storeTokens(newAccess, newRefresh);
    return AuthSession(
      accessToken: newAccess,
      refreshToken: newRefresh,
      user: await _loadCachedUser() ?? AppUser(id: '', email: ''),
      profile: await _loadCachedProfile(),
      expiresInMinutes: data['expires_in'] as int? ?? 0,
    );
  }

  Future<UserProfile?> fetchProfile({bool preferCache = true}) async {
    final cached = await _loadCachedProfile();
    if (preferCache && cached != null) {
      _fetchProfileRemote();
      return cached;
    }
    return await _fetchProfileRemote() ?? cached;
  }

  Future<UserProfile?> updateProfile(UserProfile profile) async {
    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.userMeEndpoint}');
    final headers = await _authorizedHeaders();
    if (headers == null) return null;

    final response = await _client.put(
      url,
      headers: headers,
      body: jsonEncode(_profilePayload(profile)),
    );

    final payload = await _parseProfileResponse(response);
    if (payload == null) return null;
    await _cacheProfile(payload);
    return payload;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_cachedUserKey);
    await prefs.remove(_cachedProfileKey);
  }

  Future<bool> hasSession() async {
    final access = await getAccessToken();
    final refresh = await getRefreshToken();
    return (access != null && access.isNotEmpty) ||
        (refresh != null && refresh.isNotEmpty);
  }

  Future<AppUser?> loadCachedUser() async {
    return _loadCachedUser();
  }

  Future<UserProfile?> loadCachedProfile() async {
    return _loadCachedProfile();
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<AuthSession> _handleSessionResponse(http.Response response) async {
    // 尝试解析响应体获取详细错误信息
    Map<String, dynamic>? json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      // 解析失败时使用状态码
      throw Exception('认证失败: HTTP ${response.statusCode}');
    }

    // 检查HTTP状态码和业务状态
    if (response.statusCode != 200 || json['success'] != true) {
      final message = json['message'] as String?;
      throw Exception(message ?? '认证失败: HTTP ${response.statusCode}');
    }

    final data = json['data'] as Map<String, dynamic>? ?? {};
    final session = AuthSession.fromJson(data);
    await _cacheSession(session);
    return session;
  }

  Future<Map<String, String>?> _authorizedHeaders() async {
    var token = await getAccessToken();
    if (token == null || token.isEmpty) {
      final refreshed = await refresh();
      token = refreshed?.accessToken;
    }
    if (token == null || token.isEmpty) {
      return null;
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<UserProfile?> _fetchProfileRemote() async {
    final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.userMeEndpoint}');
    var headers = await _authorizedHeaders();
    if (headers == null) return null;

    var response = await _client.get(url, headers: headers);
    if (response.statusCode == 401) {
      await refresh();
      headers = await _authorizedHeaders();
      if (headers == null) return null;
      response = await _client.get(url, headers: headers);
    }

    final profile = await _parseProfileResponse(response);
    if (profile != null) {
      await _cacheProfile(profile);
    }
    return profile;
  }

  Future<UserProfile?> _parseProfileResponse(http.Response response) async {
    if (response.statusCode != 200) return null;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['success'] != true) return null;
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final userJson = data['user'] as Map<String, dynamic>? ?? {};
    final profileJson = data['profile'] as Map<String, dynamic>? ?? {};
    final user = AppUser.fromJson(userJson);
    final profile = profileJson.isNotEmpty ? UserProfile.fromJson(profileJson) : null;

    await _cacheUser(user);
    if (profile != null) {
      await _cacheProfile(profile);
    }
    return profile;
  }

  Map<String, dynamic> _profilePayload(UserProfile profile) {
    return {
      if (profile.displayName != null) 'display_name': profile.displayName,
      if (profile.gender != null) 'gender': profile.gender,
      if (profile.birthYear != null) 'birth_year': profile.birthYear,
      if (profile.birthMonth != null) 'birth_month': profile.birthMonth,
      if (profile.birthDay != null) 'birth_day': profile.birthDay,
      if (profile.birthHour != null) 'birth_hour': profile.birthHour,
      if (profile.birthMinute != null) 'birth_minute': profile.birthMinute,
      if (profile.birthCity != null) 'birth_city': profile.birthCity,
    };
  }

  Future<void> _cacheSession(AuthSession session) async {
    await _storeTokens(session.accessToken, session.refreshToken);
    await _cacheUser(session.user);
    if (session.profile != null) {
      await _cacheProfile(session.profile!);
    }
  }

  Future<void> _storeTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<void> _cacheUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedUserKey, jsonEncode(user.toJson()));
  }

  Future<AppUser?> _loadCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cachedUserKey);
    if (raw == null || raw.isEmpty) return null;
    return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _cacheProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedProfileKey, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> _loadCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cachedProfileKey);
    if (raw == null || raw.isEmpty) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
