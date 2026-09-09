import '../entities/auth_user.dart';

abstract class AuthRepository {
  /// Email and password. Raises `INVALID_CREDENTIALS` for a wrong pair and
  /// `ACCOUNT_SUSPENDED` for an account an administrator has put beyond use —
  /// the second is not a retry, which is why the codes are distinct.
  Future<AuthSession> login({required String email, required String password});

  /// Mails a fresh sign-up code. Answers success whether or not the address
  /// already has an account, so this cannot be used to check who has signed up.
  Future<void> sendSignupOtp(String email);

  /// Checks a code and returns the one-time `otpToken` [register] requires.
  Future<String> verifySignupOtp({required String email, required String code});

  Future<AuthSession> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String otpToken,
  });

  /// The signed-in user's own record, including the fields only they see.
  Future<AuthUser> me();

  /// Forgets the session on this device. There is no server call: the API has
  /// no revoke endpoint, and the refresh token simply stops being presented.
  Future<void> logout();
}
