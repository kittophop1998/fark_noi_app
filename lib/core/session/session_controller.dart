import 'package:flutter/foundation.dart';

import '../../features/auth/domain/entities/auth_user.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../local_storage/token_storage.dart';

/// Whether anybody is signed in, and who.
enum SessionStatus {
  /// Before [SessionController.bootstrap] has finished. The router holds the
  /// splash here rather than guessing — sending a returning user to the
  /// sign-in screen for the half second it takes to read the keystore is the
  /// bug this state exists to prevent.
  unknown,
  authenticated,
  unauthenticated,
}

/// The app's single answer to "who is signed in".
///
/// A [ChangeNotifier] rather than a MobX store, because its first consumer is
/// `GoRouter.refreshListenable` — the guard has to re-run the moment the answer
/// changes, and that is the interface go_router listens on. Everything else
/// reads it through the same notifier, so there is one source of truth and not
/// a store that has to be kept in step with the router.
class SessionController extends ChangeNotifier {
  SessionController({
    required AuthRepository repository,
    required TokenStorage tokens,
  })  : _repository = repository,
        _tokens = tokens;

  final AuthRepository _repository;
  final TokenStorage _tokens;

  SessionStatus _status = SessionStatus.unknown;
  AuthUser? _user;

  SessionStatus get status => _status;
  AuthUser? get user => _user;
  bool get isAuthenticated => _status == SessionStatus.authenticated;
  bool get isResolved => _status != SessionStatus.unknown;

  /// Reads the keystore and, if a session is there, confirms it against `/me`.
  ///
  /// The confirmation matters: a stored refresh token proves the device was
  /// signed in once, not that the account still exists or is still active. A
  /// `/me` that fails ends the session here rather than on the first screen
  /// that tried to draw it.
  Future<void> bootstrap() async {
    await _tokens.restore();
    if (!_tokens.hasSession) {
      _set(SessionStatus.unauthenticated, null);
      return;
    }
    try {
      _set(SessionStatus.authenticated, await _repository.me());
    } catch (_) {
      await _repository.logout();
      _set(SessionStatus.unauthenticated, null);
    }
  }

  /// Adopts a session a sign-in or sign-up just produced. The tokens are
  /// already in the keystore by the time this is called — the repository
  /// persists them — so this only publishes who it belongs to.
  void adopt(AuthSession session) {
    _set(SessionStatus.authenticated, session.user);
  }

  /// Re-reads `/me`, for the screens that edit it. Quiet on failure: a profile
  /// that could not be refreshed is a stale name, not a reason to sign out.
  Future<void> refreshUser() async {
    if (!isAuthenticated) return;
    try {
      _set(SessionStatus.authenticated, await _repository.me());
    } catch (_) {
      // Left as it was.
    }
  }

  Future<void> signOut() async {
    await _repository.logout();
    _set(SessionStatus.unauthenticated, null);
  }

  /// What `DioClient` calls when a renewal was refused. Same end state as
  /// [signOut]; separate so the reason is legible at the call site.
  Future<void> expire() async {
    if (_status == SessionStatus.unauthenticated) return;
    _set(SessionStatus.unauthenticated, null);
  }

  void _set(SessionStatus status, AuthUser? user) {
    if (_status == status && _user == user) return;
    _status = status;
    _user = user;
    notifyListeners();
  }
}
