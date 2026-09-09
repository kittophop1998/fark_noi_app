import 'package:mobx/mobx.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/session/session_controller.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_store.g.dart';

/// Where a sign-up currently is.
///
/// Two steps rather than three: the whole form is collected first and the code
/// is asked for last, so a person who mistypes their password finds out before
/// they have waited on an email rather than after.
enum SignupStep { form, otp }

class AuthStore = _AuthStore with _$AuthStore;

abstract class _AuthStore with Store {
  _AuthStore({
    required AuthRepository repository,
    required SessionController session,
  })  : _repository = repository,
        _session = session;

  final AuthRepository _repository;
  final SessionController _session;

  // ─── Sign in ─────────────────────────────────────────

  @observable
  String email = '';

  @observable
  String password = '';

  // ─── Sign up ─────────────────────────────────────────

  @observable
  SignupStep step = SignupStep.form;

  @observable
  String name = '';

  @observable
  String phone = '';

  @observable
  String otpCode = '';

  /// The one-time token `/auth/signup/otp/verify` hands back. Held rather than
  /// passed along, because `/auth/register` re-checks it against the server's
  /// own store — a client that "knows" the email is verified proves nothing.
  String _otpToken = '';

  // ─── Shared ──────────────────────────────────────────

  @observable
  bool isSubmitting = false;

  /// The sentence to show. Comes from the server's own catalogue where there is
  /// one, so it already agrees with what the web app says for the same failure.
  @observable
  String? errorMessage;

  /// The stable failure name beside it, for the few cases a screen acts rather
  /// than displays — an unverified email sending the user back a step.
  @observable
  String? errorCode;

  @computed
  bool get hasError => errorMessage != null;

  @computed
  bool get canSignIn =>
      email.trim().contains('@') && password.length >= 6 && !isSubmitting;

  @computed
  bool get canSubmitForm =>
      name.trim().isNotEmpty &&
      email.trim().contains('@') &&
      phone.trim().length >= 9 &&
      password.length >= 6 &&
      !isSubmitting;

  @computed
  bool get canVerifyOtp => otpCode.trim().length >= 4 && !isSubmitting;

  // ─── Actions ─────────────────────────────────────────

  @action
  void setEmail(String v) => email = v;

  @action
  void setPassword(String v) => password = v;

  @action
  void setName(String v) => name = v;

  @action
  void setPhone(String v) => phone = v;

  @action
  void setOtpCode(String v) => otpCode = v;

  @action
  void clearError() {
    errorMessage = null;
    errorCode = null;
  }

  @action
  void backToForm() {
    step = SignupStep.form;
    otpCode = '';
    clearError();
  }

  @action
  Future<bool> signIn() async {
    if (!canSignIn) return false;
    return _run(() async {
      _session.adopt(
        await _repository.login(email: email, password: password),
      );
      return true;
    });
  }

  /// Sends the code and moves to the second step. The step advances only on
  /// success — a cooldown or an unavailable mailer leaves the person on the
  /// form they can still edit.
  @action
  Future<bool> requestOtp() async {
    if (!canSubmitForm) return false;
    return _run(() async {
      await _repository.sendSignupOtp(email);
      step = SignupStep.otp;
      return true;
    });
  }

  /// Verifies the code and, with the token it returns, creates the account.
  ///
  /// One action for both calls because they are one thing to the person doing
  /// it: a verified code with no account behind it is a token that expires
  /// unused, and a second button would be a second way to lose it.
  @action
  Future<bool> verifyAndRegister() async {
    if (!canVerifyOtp) return false;
    return _run(() async {
      _otpToken = await _repository.verifySignupOtp(
        email: email,
        code: otpCode,
      );
      _session.adopt(await _repository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        otpToken: _otpToken,
      ));
      return true;
    });
  }

  @action
  Future<bool> resendOtp() async {
    return _run(() async {
      await _repository.sendSignupOtp(email);
      return true;
    });
  }

  @action
  void reset() {
    email = '';
    password = '';
    name = '';
    phone = '';
    otpCode = '';
    _otpToken = '';
    step = SignupStep.form;
    isSubmitting = false;
    clearError();
  }

  Future<bool> _run(Future<bool> Function() body) async {
    isSubmitting = true;
    clearError();
    try {
      return await body();
    } on AppException catch (e) {
      errorMessage = e.message;
      errorCode = e.code;
      return false;
    } catch (_) {
      errorMessage = 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
      return false;
    } finally {
      isSubmitting = false;
    }
  }
}
