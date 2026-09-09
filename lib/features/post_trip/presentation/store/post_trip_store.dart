import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/location/location_service.dart';
import '../../../../shared/models/catalogue_store.dart';
import '../../domain/entities/post_trip_entity.dart';
import '../../domain/usecases/create_post_trip_usecase.dart';

part 'post_trip_store.g.dart';

class PostTripStore = _PostTripStore with _$PostTripStore;

abstract class _PostTripStore with Store {
  _PostTripStore({
    required CreatePostTripUseCase createPostTrip,
    required SearchStoresUseCase searchStores,
    required LocationService location,
  })  : _createPostTrip = createPostTrip,
        _searchStores = searchStores,
        _location = location;

  final CreatePostTripUseCase _createPostTrip;
  final SearchStoresUseCase _searchStores;
  final LocationService _location;

  // ─── Observable State ────────────────────────────────

  @observable
  String destination = '';

  /// The shop the trip is going to, once one has been chosen.
  ///
  /// A trip needs a *coordinate* at both ends — `POST /trips` refuses a request
  /// without one — and the catalogue is where a destination's coordinate comes
  /// from. Typing a name is how the list is narrowed; it is not, on its own, a
  /// destination.
  @observable
  CatalogueStore? selectedStore;

  @observable
  ObservableList<CatalogueStore> storeResults = ObservableList<CatalogueStore>();

  @observable
  bool isSearchingStores = false;

  @observable
  String fee = '';

  @observable
  String pickupPoint = '';

  @observable
  TimeOfDay? departureTime;

  @observable
  TimeOfDay? returnTime;

  @observable
  int maxOrders = 3;

  @observable
  ObservableSet<String> selectedCategories = ObservableSet();

  @observable
  bool isSubmitting = false;

  @observable
  bool isSubmitted = false;

  @observable
  String? errorMessage;

  /// Debounces the picker: one request per pause in typing, not one per letter.
  Timer? _searchDebounce;

  // ─── Computed ────────────────────────────────────────

  @computed
  bool get hasError => errorMessage != null;

  @computed
  bool get isTimeValid => departureTime != null && returnTime != null;

  @computed
  bool get hasDestination => selectedStore != null;

  // ─── Actions ─────────────────────────────────────────

  @action
  void setDestination(String v) {
    destination = v;
    // Editing the name after picking a shop un-picks it: the coordinate that
    // would be sent belongs to the shop, and a name that no longer matches it
    // would announce a trip to the wrong place.
    if (selectedStore != null && v.trim() != selectedStore!.label) {
      selectedStore = null;
    }
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => searchStores(v),
    );
  }

  @action
  void selectStore(CatalogueStore store) {
    selectedStore = store;
    destination = store.label;
  }

  @action
  Future<void> searchStores(String term) async {
    isSearchingStores = true;
    try {
      storeResults = ObservableList.of(await _searchStores(term: term));
    } catch (_) {
      // A picker that could not load is an empty picker, not an error screen —
      // the rest of the form is still fillable.
      storeResults = ObservableList.of(const <CatalogueStore>[]);
    } finally {
      isSearchingStores = false;
    }
  }

  @action
  void setFee(String v) => fee = v;

  @action
  void setPickupPoint(String v) => pickupPoint = v;

  @action
  void setDepartureTime(TimeOfDay t) => departureTime = t;

  @action
  void setReturnTime(TimeOfDay t) => returnTime = t;

  @action
  void setMaxOrders(int v) => maxOrders = v;

  @action
  void toggleCategory(String cat) {
    if (selectedCategories.contains(cat)) {
      selectedCategories.remove(cat);
    } else {
      selectedCategories.add(cat);
    }
  }

  @action
  Future<void> submit() async {
    if (!isTimeValid) return;
    final store = selectedStore;
    if (store == null) {
      errorMessage = 'เลือกร้านปลายทางจากรายการก่อนเปิดทริป';
      return;
    }

    isSubmitting = true;
    errorMessage = null;
    try {
      // Where the runner is standing. The meeting point they typed is the
      // origin's *name*; the coordinate is the device's, because the trip is
      // announced from where they are leaving.
      final at = await _location.current();
      await _createPostTrip(
        PostTripEntity(
          destination: store,
          originName: pickupPoint.trim().isEmpty
              ? 'จุดนัดรับของผู้เดินทาง'
              : pickupPoint.trim(),
          originLatitude: at.latitude,
          originLongitude: at.longitude,
          departureAt: _departureMoment(departureTime!),
          maxOrders: maxOrders,
          feePerOrder: int.tryParse(fee.trim()) ?? 0,
          note: _note(),
        ),
      );
      isSubmitted = true;
    } on AppException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'เปิดทริปไม่สำเร็จ กรุณาลองใหม่อีกครั้ง';
    } finally {
      isSubmitting = false;
    }
  }

  @action
  void reset() {
    destination = '';
    selectedStore = null;
    storeResults = ObservableList<CatalogueStore>();
    fee = '';
    pickupPoint = '';
    departureTime = null;
    returnTime = null;
    maxOrders = 3;
    selectedCategories.clear();
    isSubmitted = false;
    errorMessage = null;
  }

  void dispose() => _searchDebounce?.cancel();

  // ─── Helpers ─────────────────────────────────────────

  /// The wall clock the form collects, as an absolute moment.
  ///
  /// A time that has already passed today is read as tomorrow — somebody
  /// opening a trip at 23:50 for "00:30" means the half hour away, not the one
  /// almost a day behind them.
  DateTime _departureMoment(TimeOfDay time) {
    final now = DateTime.now();
    var moment = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (moment.isBefore(now)) {
      moment = moment.add(const Duration(days: 1));
    }
    return moment;
  }

  /// The categories and the return time as one sentence.
  ///
  /// A trip has no category field on the wire — it is a journey, not a shop —
  /// and the API publishes no return time either. Both are things a requester
  /// genuinely needs before they ask, so they go where a requester will read
  /// them: the trip's own note.
  String _note() {
    final parts = <String>[];
    if (selectedCategories.isNotEmpty) {
      parts.add('รับหิ้ว: ${selectedCategories.join(", ")}');
    }
    final back = returnTime;
    if (back != null) {
      final hour = back.hour.toString().padLeft(2, '0');
      final minute = back.minute.toString().padLeft(2, '0');
      parts.add('ถึงจุดนัดรับประมาณ $hour:$minute น.');
    }
    if (pickupPoint.trim().isNotEmpty) {
      parts.add('จุดนัดรับ: ${pickupPoint.trim()}');
    }
    // The API caps a trip note at 300 characters and answers a longer one with
    // a bare 400, so it is trimmed here rather than refused there.
    final note = parts.join(' · ');
    return note.length <= 300 ? note : note.substring(0, 300);
  }
}
