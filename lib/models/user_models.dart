// 用户认证与资料模型。
class AppUser {
  final String id;
  final String email;

  AppUser({
    required this.id,
    required this.email,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
      };
}

class UserProfile {
  final String? id;
  final String? userId;
  final String? displayName;
  final String? gender;
  final int? birthYear;
  final int? birthMonth;
  final int? birthDay;
  final int? birthHour;
  final int? birthMinute;
  final String? birthCity;
  final Map<String, dynamic>? baziResult;
  final Map<String, dynamic>? ziweiResult;
  final Map<String, dynamic>? fiveElements;
  final String? updatedAt;

  UserProfile({
    this.id,
    this.userId,
    this.displayName,
    this.gender,
    this.birthYear,
    this.birthMonth,
    this.birthDay,
    this.birthHour,
    this.birthMinute,
    this.birthCity,
    this.baziResult,
    this.ziweiResult,
    this.fiveElements,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      displayName: json['display_name'] as String?,
      gender: json['gender'] as String?,
      birthYear: json['birth_year'] as int?,
      birthMonth: json['birth_month'] as int?,
      birthDay: json['birth_day'] as int?,
      birthHour: json['birth_hour'] as int?,
      birthMinute: json['birth_minute'] as int?,
      birthCity: json['birth_city'] as String?,
      baziResult: (json['bazi_result'] as Map<String, dynamic>?),
      ziweiResult: (json['ziwei_result'] as Map<String, dynamic>?),
      fiveElements: (json['five_elements'] as Map<String, dynamic>?),
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'display_name': displayName,
        'gender': gender,
        'birth_year': birthYear,
        'birth_month': birthMonth,
        'birth_day': birthDay,
        'birth_hour': birthHour,
        'birth_minute': birthMinute,
        'birth_city': birthCity,
        'bazi_result': baziResult,
        'ziwei_result': ziweiResult,
        'five_elements': fiveElements,
        'updated_at': updatedAt,
      };

  UserProfile copyWith({
    String? displayName,
    String? gender,
    int? birthYear,
    int? birthMonth,
    int? birthDay,
    int? birthHour,
    int? birthMinute,
    String? birthCity,
    Map<String, dynamic>? baziResult,
    Map<String, dynamic>? ziweiResult,
    Map<String, dynamic>? fiveElements,
    String? updatedAt,
  }) {
    return UserProfile(
      id: id,
      userId: userId,
      displayName: displayName ?? this.displayName,
      gender: gender ?? this.gender,
      birthYear: birthYear ?? this.birthYear,
      birthMonth: birthMonth ?? this.birthMonth,
      birthDay: birthDay ?? this.birthDay,
      birthHour: birthHour ?? this.birthHour,
      birthMinute: birthMinute ?? this.birthMinute,
      birthCity: birthCity ?? this.birthCity,
      baziResult: baziResult ?? this.baziResult,
      ziweiResult: ziweiResult ?? this.ziweiResult,
      fiveElements: fiveElements ?? this.fiveElements,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final AppUser user;
  final UserProfile? profile;
  final int expiresInMinutes;

  AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.profile,
    required this.expiresInMinutes,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      expiresInMinutes: json['expires_in'] as int? ?? 0,
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }
}
