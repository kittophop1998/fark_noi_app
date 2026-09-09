// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProfileStore on _ProfileStore, Store {
  Computed<bool>? _$hasErrorComputed;

  @override
  bool get hasError => (_$hasErrorComputed ??=
          Computed<bool>(() => super.hasError, name: '_ProfileStore.hasError'))
      .value;

  late final _$reputationAtom =
      Atom(name: '_ProfileStore.reputation', context: context);

  @override
  ReputationEntity? get reputation {
    _$reputationAtom.reportRead();
    return super.reputation;
  }

  @override
  set reputation(ReputationEntity? value) {
    _$reputationAtom.reportWrite(value, super.reputation, () {
      super.reputation = value;
    });
  }

  late final _$creditsAtom =
      Atom(name: '_ProfileStore.credits', context: context);

  @override
  CreditBalanceEntity? get credits {
    _$creditsAtom.reportRead();
    return super.credits;
  }

  @override
  set credits(CreditBalanceEntity? value) {
    _$creditsAtom.reportWrite(value, super.credits, () {
      super.credits = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_ProfileStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_ProfileStore.errorMessage', context: context);

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

  late final _$loadAsyncAction =
      AsyncAction('_ProfileStore.load', context: context);

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  late final _$_ProfileStoreActionController =
      ActionController(name: '_ProfileStore', context: context);

  @override
  Future<void> signOut() {
    final _$actionInfo = _$_ProfileStoreActionController.startAction(
        name: '_ProfileStore.signOut');
    try {
      return super.signOut();
    } finally {
      _$_ProfileStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
reputation: ${reputation},
credits: ${credits},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
hasError: ${hasError}
    ''';
  }
}
