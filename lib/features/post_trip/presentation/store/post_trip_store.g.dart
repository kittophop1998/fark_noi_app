// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_trip_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PostTripStore on _PostTripStore, Store {
  Computed<bool>? _$hasErrorComputed;

  @override
  bool get hasError => (_$hasErrorComputed ??=
          Computed<bool>(() => super.hasError, name: '_PostTripStore.hasError'))
      .value;
  Computed<bool>? _$isTimeValidComputed;

  @override
  bool get isTimeValid =>
      (_$isTimeValidComputed ??= Computed<bool>(() => super.isTimeValid,
              name: '_PostTripStore.isTimeValid'))
          .value;
  Computed<bool>? _$hasDestinationComputed;

  @override
  bool get hasDestination =>
      (_$hasDestinationComputed ??= Computed<bool>(() => super.hasDestination,
              name: '_PostTripStore.hasDestination'))
          .value;

  late final _$destinationAtom =
      Atom(name: '_PostTripStore.destination', context: context);

  @override
  String get destination {
    _$destinationAtom.reportRead();
    return super.destination;
  }

  @override
  set destination(String value) {
    _$destinationAtom.reportWrite(value, super.destination, () {
      super.destination = value;
    });
  }

  late final _$selectedStoreAtom =
      Atom(name: '_PostTripStore.selectedStore', context: context);

  @override
  CatalogueStore? get selectedStore {
    _$selectedStoreAtom.reportRead();
    return super.selectedStore;
  }

  @override
  set selectedStore(CatalogueStore? value) {
    _$selectedStoreAtom.reportWrite(value, super.selectedStore, () {
      super.selectedStore = value;
    });
  }

  late final _$storeResultsAtom =
      Atom(name: '_PostTripStore.storeResults', context: context);

  @override
  ObservableList<CatalogueStore> get storeResults {
    _$storeResultsAtom.reportRead();
    return super.storeResults;
  }

  @override
  set storeResults(ObservableList<CatalogueStore> value) {
    _$storeResultsAtom.reportWrite(value, super.storeResults, () {
      super.storeResults = value;
    });
  }

  late final _$isSearchingStoresAtom =
      Atom(name: '_PostTripStore.isSearchingStores', context: context);

  @override
  bool get isSearchingStores {
    _$isSearchingStoresAtom.reportRead();
    return super.isSearchingStores;
  }

  @override
  set isSearchingStores(bool value) {
    _$isSearchingStoresAtom.reportWrite(value, super.isSearchingStores, () {
      super.isSearchingStores = value;
    });
  }

  late final _$feeAtom = Atom(name: '_PostTripStore.fee', context: context);

  @override
  String get fee {
    _$feeAtom.reportRead();
    return super.fee;
  }

  @override
  set fee(String value) {
    _$feeAtom.reportWrite(value, super.fee, () {
      super.fee = value;
    });
  }

  late final _$pickupPointAtom =
      Atom(name: '_PostTripStore.pickupPoint', context: context);

  @override
  String get pickupPoint {
    _$pickupPointAtom.reportRead();
    return super.pickupPoint;
  }

  @override
  set pickupPoint(String value) {
    _$pickupPointAtom.reportWrite(value, super.pickupPoint, () {
      super.pickupPoint = value;
    });
  }

  late final _$departureTimeAtom =
      Atom(name: '_PostTripStore.departureTime', context: context);

  @override
  TimeOfDay? get departureTime {
    _$departureTimeAtom.reportRead();
    return super.departureTime;
  }

  @override
  set departureTime(TimeOfDay? value) {
    _$departureTimeAtom.reportWrite(value, super.departureTime, () {
      super.departureTime = value;
    });
  }

  late final _$returnTimeAtom =
      Atom(name: '_PostTripStore.returnTime', context: context);

  @override
  TimeOfDay? get returnTime {
    _$returnTimeAtom.reportRead();
    return super.returnTime;
  }

  @override
  set returnTime(TimeOfDay? value) {
    _$returnTimeAtom.reportWrite(value, super.returnTime, () {
      super.returnTime = value;
    });
  }

  late final _$maxOrdersAtom =
      Atom(name: '_PostTripStore.maxOrders', context: context);

  @override
  int get maxOrders {
    _$maxOrdersAtom.reportRead();
    return super.maxOrders;
  }

  @override
  set maxOrders(int value) {
    _$maxOrdersAtom.reportWrite(value, super.maxOrders, () {
      super.maxOrders = value;
    });
  }

  late final _$selectedCategoriesAtom =
      Atom(name: '_PostTripStore.selectedCategories', context: context);

  @override
  ObservableSet<String> get selectedCategories {
    _$selectedCategoriesAtom.reportRead();
    return super.selectedCategories;
  }

  @override
  set selectedCategories(ObservableSet<String> value) {
    _$selectedCategoriesAtom.reportWrite(value, super.selectedCategories, () {
      super.selectedCategories = value;
    });
  }

  late final _$isSubmittingAtom =
      Atom(name: '_PostTripStore.isSubmitting', context: context);

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
      Atom(name: '_PostTripStore.isSubmitted', context: context);

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
      Atom(name: '_PostTripStore.errorMessage', context: context);

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

  late final _$searchStoresAsyncAction =
      AsyncAction('_PostTripStore.searchStores', context: context);

  @override
  Future<void> searchStores(String term) {
    return _$searchStoresAsyncAction.run(() => super.searchStores(term));
  }

  late final _$submitAsyncAction =
      AsyncAction('_PostTripStore.submit', context: context);

  @override
  Future<void> submit() {
    return _$submitAsyncAction.run(() => super.submit());
  }

  late final _$_PostTripStoreActionController =
      ActionController(name: '_PostTripStore', context: context);

  @override
  void setDestination(String v) {
    final _$actionInfo = _$_PostTripStoreActionController.startAction(
        name: '_PostTripStore.setDestination');
    try {
      return super.setDestination(v);
    } finally {
      _$_PostTripStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selectStore(CatalogueStore store) {
    final _$actionInfo = _$_PostTripStoreActionController.startAction(
        name: '_PostTripStore.selectStore');
    try {
      return super.selectStore(store);
    } finally {
      _$_PostTripStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFee(String v) {
    final _$actionInfo = _$_PostTripStoreActionController.startAction(
        name: '_PostTripStore.setFee');
    try {
      return super.setFee(v);
    } finally {
      _$_PostTripStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPickupPoint(String v) {
    final _$actionInfo = _$_PostTripStoreActionController.startAction(
        name: '_PostTripStore.setPickupPoint');
    try {
      return super.setPickupPoint(v);
    } finally {
      _$_PostTripStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDepartureTime(TimeOfDay t) {
    final _$actionInfo = _$_PostTripStoreActionController.startAction(
        name: '_PostTripStore.setDepartureTime');
    try {
      return super.setDepartureTime(t);
    } finally {
      _$_PostTripStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setReturnTime(TimeOfDay t) {
    final _$actionInfo = _$_PostTripStoreActionController.startAction(
        name: '_PostTripStore.setReturnTime');
    try {
      return super.setReturnTime(t);
    } finally {
      _$_PostTripStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMaxOrders(int v) {
    final _$actionInfo = _$_PostTripStoreActionController.startAction(
        name: '_PostTripStore.setMaxOrders');
    try {
      return super.setMaxOrders(v);
    } finally {
      _$_PostTripStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleCategory(String cat) {
    final _$actionInfo = _$_PostTripStoreActionController.startAction(
        name: '_PostTripStore.toggleCategory');
    try {
      return super.toggleCategory(cat);
    } finally {
      _$_PostTripStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_PostTripStoreActionController.startAction(
        name: '_PostTripStore.reset');
    try {
      return super.reset();
    } finally {
      _$_PostTripStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
destination: ${destination},
selectedStore: ${selectedStore},
storeResults: ${storeResults},
isSearchingStores: ${isSearchingStores},
fee: ${fee},
pickupPoint: ${pickupPoint},
departureTime: ${departureTime},
returnTime: ${returnTime},
maxOrders: ${maxOrders},
selectedCategories: ${selectedCategories},
isSubmitting: ${isSubmitting},
isSubmitted: ${isSubmitted},
errorMessage: ${errorMessage},
hasError: ${hasError},
isTimeValid: ${isTimeValid},
hasDestination: ${hasDestination}
    ''';
  }
}
