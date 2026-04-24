import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

import '../../domain/entities/post_trip_entity.dart';
import '../../domain/usecases/create_post_trip_usecase.dart';

part 'post_trip_store.g.dart';

class PostTripStore = _PostTripStore with _$PostTripStore;

abstract class _PostTripStore with Store {
  final CreatePostTripUseCase _createPostTrip;

  _PostTripStore({required CreatePostTripUseCase createPostTrip})
      : _createPostTrip = createPostTrip;

  // ─── Observable State ────────────────────────────────

  @observable
  String destination = '';

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

  // ─── Computed ────────────────────────────────────────

  @computed
  bool get hasError => errorMessage != null;

  @computed
  bool get isTimeValid => departureTime != null && returnTime != null;

  // ─── Actions ─────────────────────────────────────────

  @action
  void setDestination(String v) => destination = v;

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
    isSubmitting = true;
    errorMessage = null;
    try {
      await _createPostTrip(
        PostTripEntity(
          destination: destination,
          departureTime: _formatTime(departureTime!),
          returnTime: _formatTime(returnTime!),
          maxOrders: maxOrders,
          feePerOrder: int.tryParse(fee) ?? 0,
          categories: selectedCategories.toList(),
          pickupPoint: pickupPoint,
        ),
      );
      isSubmitted = true;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isSubmitting = false;
    }
  }

  @action
  void reset() {
    destination = '';
    fee = '';
    pickupPoint = '';
    departureTime = null;
    returnTime = null;
    maxOrders = 3;
    selectedCategories.clear();
    isSubmitted = false;
    errorMessage = null;
  }

  // ─── Helpers ─────────────────────────────────────────

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
