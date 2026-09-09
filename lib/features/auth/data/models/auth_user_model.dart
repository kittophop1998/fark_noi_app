import '../../domain/entities/auth_user.dart';

/// `Profile` and the login response's `user`, read into one entity.
///
/// The two shapes overlap rather than nest: `/me` adds `phone`, `promptPayId`
/// and `status`, and the login payload sends only the four fields a header
/// needs. One reader covers both — an absent key becomes null, which is
/// exactly what [AuthUser] means by it.
class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.avatarUrl,
    super.phone,
    super.promptPayId,
    super.status,
    super.role,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: _orNull(json['avatarUrl']),
      phone: _orNull(json['phone']),
      promptPayId: _orNull(json['promptPayId']),
      status: json['status'] as String? ?? 'ACTIVE',
      role: json['role'] as String? ?? 'USER',
    );
  }

  /// The Go handlers use `omitempty`, so an unset string is absent — but a few
  /// paths still send `""`. Both mean "not set", and only null says so to the
  /// rest of the app.
  static String? _orNull(dynamic value) {
    if (value is String && value.isNotEmpty) return value;
    return null;
  }
}

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.accessToken,
    required super.refreshToken,
    required super.user,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      user: AuthUserModel.fromJson(
        json['user'] is Map
            ? Map<String, dynamic>.from(json['user'] as Map)
            : const {},
      ),
    );
  }
}
