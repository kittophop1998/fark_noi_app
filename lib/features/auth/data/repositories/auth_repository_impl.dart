import '../../../../core/local_storage/token_storage.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remote,
    required this.tokens,
  });

  final AuthRemoteDataSource remote;
  final TokenStorage tokens;

  /// Persisting the pair is the repository's job rather than the store's: a
  /// session that exists in memory but not in the keystore is one the next
  /// launch has silently lost, and every path that produces one — sign-in and
  /// sign-up alike — goes through here.
  Future<AuthSession> _persist(AuthSession session) async {
    await tokens.save(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    return session;
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return _persist(await remote.login(email: email, password: password));
  }

  @override
  Future<void> sendSignupOtp(String email) => remote.sendSignupOtp(email);

  @override
  Future<String> verifySignupOtp({
    required String email,
    required String code,
  }) =>
      remote.verifySignupOtp(email: email, code: code);

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String otpToken,
  }) async {
    return _persist(await remote.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      otpToken: otpToken,
    ));
  }

  @override
  Future<AuthUser> me() => remote.me();

  @override
  Future<void> logout() => tokens.clear();
}
