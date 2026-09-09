// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthStore on _AuthStore, Store {
  Computed<bool>? _$hasErrorComputed;

  @override
  bool get hasError => (_$hasErrorComputed ??=
          Computed<bool>(() => super.hasError, name: '_AuthStore.hasError'))
      .value;
  Computed<bool>? _$canSignInComputed;

  @override
  bool get canSignIn => (_$canSignInComputed ??=
          Computed<bool>(() => super.canSignIn, name: '_AuthStore.canSignIn'))
      .value;
  Computed<bool>? _$canSubmitFormComputed;

  @override
  bool get canSubmitForm =>
      (_$canSubmitFormComputed ??= Computed<bool>(() => super.canSubmitForm,
              name: '_AuthStore.canSubmitForm'))
          .value;
  Computed<bool>? _$canVerifyOtpComputed;

  @override
  bool get canVerifyOtp =>
      (_$canVerifyOtpComputed ??= Computed<bool>(() => super.canVerifyOtp,
              name: '_AuthStore.canVerifyOtp'))
          .value;

  late final _$emailAtom = Atom(name: '_AuthStore.email', context: context);

  @override
  String get email {
    _$emailAtom.reportRead();
    return super.email;
  }

  @override
  set email(String value) {
    _$emailAtom.reportWrite(value, super.email, () {
      super.email = value;
    });
  }

  late final _$passwordAtom =
      Atom(name: '_AuthStore.password', context: context);

  @override
  String get password {
    _$passwordAtom.reportRead();
    return super.password;
  }

  @override
  set password(String value) {
    _$passwordAtom.reportWrite(value, super.password, () {
      super.password = value;
    });
  }

  late final _$stepAtom = Atom(name: '_AuthStore.step', context: context);

  @override
  SignupStep get step {
    _$stepAtom.reportRead();
    return super.step;
  }

  @override
  set step(SignupStep value) {
    _$stepAtom.reportWrite(value, super.step, () {
      super.step = value;
    });
  }

  late final _$nameAtom = Atom(name: '_AuthStore.name', context: context);

  @override
  String get name {
    _$nameAtom.reportRead();
    return super.name;
  }

  @override
  set name(String value) {
    _$nameAtom.reportWrite(value, super.name, () {
      super.name = value;
    });
  }

  late final _$phoneAtom = Atom(name: '_AuthStore.phone', context: context);

  @override
  String get phone {
    _$phoneAtom.reportRead();
    return super.phone;
  }

  @override
  set phone(String value) {
    _$phoneAtom.reportWrite(value, super.phone, () {
      super.phone = value;
    });
  }

  late final _$otpCodeAtom = Atom(name: '_AuthStore.otpCode', context: context);

  @override
  String get otpCode {
    _$otpCodeAtom.reportRead();
    return super.otpCode;
  }

  @override
  set otpCode(String value) {
    _$otpCodeAtom.reportWrite(value, super.otpCode, () {
      super.otpCode = value;
    });
  }

  late final _$isSubmittingAtom =
      Atom(name: '_AuthStore.isSubmitting', context: context);

  @override
  bool get isSubmitting {
    _$isSubmittingAtom.reportRead();
    return super.isSubmitting;
  }

  @override
  set isSubmitting(bool value) {
    _$isSubmittingAtom.reportWrite(value, super.isSubmitting, () {
      super.isSubmitting = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_AuthStore.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$errorCodeAtom =
      Atom(name: '_AuthStore.errorCode', context: context);

  @override
  String? get errorCode {
    _$errorCodeAtom.reportRead();
    return super.errorCode;
  }

  @override
  set errorCode(String? value) {
    _$errorCodeAtom.reportWrite(value, super.errorCode, () {
      super.errorCode = value;
    });
  }

  late final _$signInAsyncAction =
      AsyncAction('_AuthStore.signIn', context: context);

  @override
  Future<bool> signIn() {
    return _$signInAsyncAction.run(() => super.signIn());
  }

  late final _$requestOtpAsyncAction =
      AsyncAction('_AuthStore.requestOtp', context: context);

  @override
  Future<bool> requestOtp() {
    return _$requestOtpAsyncAction.run(() => super.requestOtp());
  }

  late final _$verifyAndRegisterAsyncAction =
      AsyncAction('_AuthStore.verifyAndRegister', context: context);

  @override
  Future<bool> verifyAndRegister() {
    return _$verifyAndRegisterAsyncAction.run(() => super.verifyAndRegister());
  }

  late final _$resendOtpAsyncAction =
      AsyncAction('_AuthStore.resendOtp', context: context);

  @override
  Future<bool> resendOtp() {
    return _$resendOtpAsyncAction.run(() => super.resendOtp());
  }

  late final _$_AuthStoreActionController =
      ActionController(name: '_AuthStore', context: context);

  @override
  void setEmail(String v) {
    final _$actionInfo =
        _$_AuthStoreActionController.startAction(name: '_AuthStore.setEmail');
    try {
      return super.setEmail(v);
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPassword(String v) {
    final _$actionInfo = _$_AuthStoreActionController.startAction(
        name: '_AuthStore.setPassword');
    try {
      return super.setPassword(v);
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setName(String v) {
    final _$actionInfo =
        _$_AuthStoreActionController.startAction(name: '_AuthStore.setName');
    try {
      return super.setName(v);
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPhone(String v) {
    final _$actionInfo =
        _$_AuthStoreActionController.startAction(name: '_AuthStore.setPhone');
    try {
      return super.setPhone(v);
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOtpCode(String v) {
    final _$actionInfo =
        _$_AuthStoreActionController.startAction(name: '_AuthStore.setOtpCode');
    try {
      return super.setOtpCode(v);
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo =
        _$_AuthStoreActionController.startAction(name: '_AuthStore.clearError');
    try {
      return super.clearError();
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void backToForm() {
    final _$actionInfo =
        _$_AuthStoreActionController.startAction(name: '_AuthStore.backToForm');
    try {
      return super.backToForm();
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo =
        _$_AuthStoreActionController.startAction(name: '_AuthStore.reset');
    try {
      return super.reset();
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
email: ${email},
password: ${password},
step: ${step},
name: ${name},
phone: ${phone},
otpCode: ${otpCode},
isSubmitting: ${isSubmitting},
errorMessage: ${errorMessage},
errorCode: ${errorCode},
hasError: ${hasError},
canSignIn: ${canSignIn},
canSubmitForm: ${canSubmitForm},
canVerifyOtp: ${canVerifyOtp}
    ''';
  }
}
