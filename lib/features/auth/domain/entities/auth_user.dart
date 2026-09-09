import 'package:equatable/equatable.dart';

/// The signed-in person, as `GET /api/v1/me` describes them.
///
/// Deliberately the same shape the login response's `user` carries, widened by
/// the two fields only the profile read returns — [phone] and [promptPayId].
/// Both are absent until the app has read `/me`, which is why they are
/// nullable rather than empty-string defaults: "not fetched yet" and "the user
/// has not set one" are different, and only the second may be drawn as
/// "ยังไม่ได้ตั้งค่า".
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.phone,
    this.promptPayId,
    this.status = 'ACTIVE',
    this.role = 'USER',
  });

  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? phone;

  /// The account this user is paid into when they run an errand. Returned in
  /// full only by `/me`, and only to its owner.
  final String? promptPayId;

  /// `ACTIVE` | `SUSPENDED` | `DELETED`.
  final String status;

  /// `USER` | `ADMIN`. Decides nothing here — every restricted call re-reads
  /// it server-side — but it is what the app uses to decide what to offer.
  final String role;

  bool get isAdmin => role == 'ADMIN';
  bool get hasPromptPay => (promptPayId ?? '').isNotEmpty;

  /// The single letter an avatar plate falls back to. Thai names are as likely
  /// as Latin ones here, so this takes the first *character* rather than an
  /// initial of a surname the API never sends.
  String get initial {
    final name = displayName.trim();
    return name.isEmpty ? '?' : String.fromCharCode(name.runes.first);
  }

  AuthUser copyWith({
    String? displayName,
    String? avatarUrl,
    String? phone,
    String? promptPayId,
  }) {
    return AuthUser(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      promptPayId: promptPayId ?? this.promptPayId,
      status: status,
      role: role,
    );
  }

  @override
  List<Object?> get props =>
      [id, email, displayName, avatarUrl, phone, promptPayId, status, role];
}

/// What a credential exchange hands back: the pair of tokens and who they
/// belong to. `AuthResult` on the wire.
class AuthSession extends Equatable {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AuthUser user;

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
