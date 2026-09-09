// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_trips_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MyTripsStore on _MyTripsStore, Store {
  Computed<bool>? _$hasErrorComputed;

  @override
  bool get hasError => (_$hasErrorComputed ??=
          Computed<bool>(() => super.hasError, name: '_MyTripsStore.hasError'))
      .value;
  Computed<bool>? _$hasTripComputed;

  @override
  bool get hasTrip => (_$hasTripComputed ??=
          Computed<bool>(() => super.hasTrip, name: '_MyTripsStore.hasTrip'))
      .value;

  late final _$tripAtom = Atom(name: '_MyTripsStore.trip', context: context);

  @override
  MyTripEntity? get trip {
    _$tripAtom.reportRead();
    return super.trip;
  }

  @override
  set trip(MyTripEntity? value) {
    _$tripAtom.reportWrite(value, super.trip, () {
      super.trip = value;
    });
  }

  late final _$historyAtom =
      Atom(name: '_MyTripsStore.history', context: context);

  @override
  ObservableList<MyTripEntity> get history {
    _$historyAtom.reportRead();
    return super.history;
  }

  @override
  set history(ObservableList<MyTripEntity> value) {
    _$historyAtom.reportWrite(value, super.history, () {
      super.history = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_MyTripsStore.isLoading', context: context);

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

  late final _$isActingAtom =
      Atom(name: '_MyTripsStore.isActing', context: context);

  @override
  bool get isActing {
    _$isActingAtom.reportRead();
    return super.isActing;
  }

  @override
  set isActing(bool value) {
    _$isActingAtom.reportWrite(value, super.isActing, () {
      super.isActing = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_MyTripsStore.errorMessage', context: context);

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
      AsyncAction('_MyTripsStore.load', context: context);

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  late final _$loadHistoryAsyncAction =
      AsyncAction('_MyTripsStore.loadHistory', context: context);

  @override
  Future<void> loadHistory() {
    return _$loadHistoryAsyncAction.run(() => super.loadHistory());
  }

  late final _$_reloadAsyncAction =
      AsyncAction('_MyTripsStore._reload', context: context);

  @override
  Future<void> _reload() {
    return _$_reloadAsyncAction.run(() => super._reload());
  }

  late final _$_MyTripsStoreActionController =
      ActionController(name: '_MyTripsStore', context: context);

  @override
  Future<bool> startTrip() {
    final _$actionInfo = _$_MyTripsStoreActionController.startAction(
        name: '_MyTripsStore.startTrip');
    try {
      return super.startTrip();
    } finally {
      _$_MyTripsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  Future<bool> completeTrip() {
    final _$actionInfo = _$_MyTripsStoreActionController.startAction(
        name: '_MyTripsStore.completeTrip');
    try {
      return super.completeTrip();
    } finally {
      _$_MyTripsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  Future<bool> cancelTrip() {
    final _$actionInfo = _$_MyTripsStoreActionController.startAction(
        name: '_MyTripsStore.cancelTrip');
    try {
      return super.cancelTrip();
    } finally {
      _$_MyTripsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  Future<bool> acceptOrder(String orderId) {
    final _$actionInfo = _$_MyTripsStoreActionController.startAction(
        name: '_MyTripsStore.acceptOrder');
    try {
      return super.acceptOrder(orderId);
    } finally {
      _$_MyTripsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  Future<bool> rejectOrder(String orderId, {String? reason}) {
    final _$actionInfo = _$_MyTripsStoreActionController.startAction(
        name: '_MyTripsStore.rejectOrder');
    try {
      return super.rejectOrder(orderId, reason: reason);
    } finally {
      _$_MyTripsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  Future<bool> markArrivedAtStore(String orderId) {
    final _$actionInfo = _$_MyTripsStoreActionController.startAction(
        name: '_MyTripsStore.markArrivedAtStore');
    try {
      return super.markArrivedAtStore(orderId);
    } finally {
      _$_MyTripsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  Future<bool> completeOrder(String orderId) {
    final _$actionInfo = _$_MyTripsStoreActionController.startAction(
        name: '_MyTripsStore.completeOrder');
    try {
      return super.completeOrder(orderId);
    } finally {
      _$_MyTripsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void markArrivedAtPickup() {
    final _$actionInfo = _$_MyTripsStoreActionController.startAction(
        name: '_MyTripsStore.markArrivedAtPickup');
    try {
      return super.markArrivedAtPickup();
    } finally {
      _$_MyTripsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleChecked(MyOrderItem order) {
    final _$actionInfo = _$_MyTripsStoreActionController.startAction(
        name: '_MyTripsStore.toggleChecked');
    try {
      return super.toggleChecked(order);
    } finally {
      _$_MyTripsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleDelivered(MyOrderItem order) {
    final _$actionInfo = _$_MyTripsStoreActionController.startAction(
        name: '_MyTripsStore.toggleDelivered');
    try {
      return super.toggleDelivered(order);
    } finally {
      _$_MyTripsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFinalPrice(MyOrderItem order, double price) {
    final _$actionInfo = _$_MyTripsStoreActionController.startAction(
        name: '_MyTripsStore.setFinalPrice');
    try {
      return super.setFinalPrice(order, price);
    } finally {
      _$_MyTripsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$_MyTripsStoreActionController.startAction(
        name: '_MyTripsStore.clearError');
    try {
      return super.clearError();
    } finally {
      _$_MyTripsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
trip: ${trip},
history: ${history},
isLoading: ${isLoading},
isActing: ${isActing},
errorMessage: ${errorMessage},
hasError: ${hasError},
hasTrip: ${hasTrip}
    ''';
  }
}
