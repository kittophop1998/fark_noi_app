// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CreateOrderStore on _CreateOrderStore, Store {
  Computed<bool>? _$hasErrorComputed;

  @override
  bool get hasError =>
      (_$hasErrorComputed ??= Computed<bool>(() => super.hasError,
              name: '_CreateOrderStore.hasError'))
          .value;

  late final _$isSubmittingAtom =
      Atom(name: '_CreateOrderStore.isSubmitting', context: context);

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

  late final _$isSubmittedAtom =
      Atom(name: '_CreateOrderStore.isSubmitted', context: context);

  @override
  bool get isSubmitted {
    _$isSubmittedAtom.reportRead();
    return super.isSubmitted;
  }

  @override
  set isSubmitted(bool value) {
    _$isSubmittedAtom.reportWrite(value, super.isSubmitted, () {
      super.isSubmitted = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_CreateOrderStore.errorMessage', context: context);

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

  late final _$submitAsyncAction =
      AsyncAction('_CreateOrderStore.submit', context: context);

  @override
  Future<bool> submit(
      {required HomeEntity trip,
      required String itemName,
      required int quantity,
      required int expectedPrice,
      required String note}) {
    return _$submitAsyncAction.run(() => super.submit(
        trip: trip,
        itemName: itemName,
        quantity: quantity,
        expectedPrice: expectedPrice,
        note: note));
  }

  late final _$_CreateOrderStoreActionController =
      ActionController(name: '_CreateOrderStore', context: context);

  @override
  void clearError() {
    final _$actionInfo = _$_CreateOrderStoreActionController.startAction(
        name: '_CreateOrderStore.clearError');
    try {
      return super.clearError();
    } finally {
      _$_CreateOrderStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isSubmitting: ${isSubmitting},
isSubmitted: ${isSubmitted},
errorMessage: ${errorMessage},
hasError: ${hasError}
    ''';
  }
}
