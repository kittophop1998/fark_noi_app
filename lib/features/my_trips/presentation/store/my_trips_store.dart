import 'package:mobx/mobx.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/my_trip_entity.dart';
import '../../domain/usecases/get_my_trips_usecase.dart';

part 'my_trips_store.g.dart';

class MyTripsStore = _MyTripsStore with _$MyTripsStore;

/// The runner's own trip, and the milestones along it.
///
/// Two kinds of state live here and they are deliberately different:
///
///  * **the trip** is the server's, re-read after every milestone — a
///    transition can move more than the thing it was called on, so nothing is
///    patched locally into a shape the server did not confirm;
///  * **the checklist** ([toggleChecked]) is the runner's own, and has no
///    server call behind it. Ticking "ซื้อแล้ว" while standing in a shop is a
///    note to oneself; the errand's real `PURCHASED` milestone needs a receipt
///    photograph, which is a different action with a different consequence.
abstract class _MyTripsStore with Store {
  _MyTripsStore({
    required GetActiveTripUseCase getActiveTrip,
    required GetCompletedTripsUseCase getCompletedTrips,
    required TripActionsUseCase actions,
  })  : _getActiveTrip = getActiveTrip,
        _getCompletedTrips = getCompletedTrips,
        _actions = actions;

  final GetActiveTripUseCase _getActiveTrip;
  final GetCompletedTripsUseCase _getCompletedTrips;
  final TripActionsUseCase _actions;

  // ─── Observable state ────────────────────────────────

  @observable
  MyTripEntity? trip;

  @observable
  ObservableList<MyTripEntity> history = ObservableList<MyTripEntity>();

  @observable
  bool isLoading = false;

  /// A milestone in flight. Separate from [isLoading] so tapping "จบทริป" shows
  /// a spinner on the button rather than replacing the whole screen with one.
  @observable
  bool isActing = false;

  @observable
  String? errorMessage;

  @computed
  bool get hasError => errorMessage != null;

  @computed
  bool get hasTrip => trip != null;

  // ─── Reads ───────────────────────────────────────────

  @action
  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    try {
      trip = await _getActiveTrip();
    } on AppException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'โหลดทริปไม่สำเร็จ กรุณาลองใหม่อีกครั้ง';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> loadHistory() async {
    try {
      history = ObservableList.of(await _getCompletedTrips());
    } catch (_) {
      // A history that would not load is not worth an error screen over the
      // live trip beside it.
    }
  }

  /// Re-reads the trip without the loading state, so a milestone does not blank
  /// the screen it just changed.
  @action
  Future<void> _reload() async {
    try {
      trip = await _getActiveTrip();
    } catch (_) {
      // Left as it was; the milestone itself already succeeded.
    }
  }

  // ─── Milestones ──────────────────────────────────────

  /// ปิดรับฝาก and set off. `OPEN` → `IN_PROGRESS`.
  @action
  Future<bool> startTrip() => _act((id) => _actions.startTrip(id));

  @action
  Future<bool> completeTrip() => _act((id) => _actions.completeTrip(id));

  @action
  Future<bool> cancelTrip() => _act((id) => _actions.cancelTrip(id));

  @action
  Future<bool> acceptOrder(String orderId) =>
      _act((_) => _actions.acceptOrder(orderId));

  @action
  Future<bool> rejectOrder(String orderId, {String? reason}) =>
      _act((_) => _actions.rejectOrder(orderId, reason: reason));

  @action
  Future<bool> markArrivedAtStore(String orderId) =>
      _act((_) => _actions.markArrivedAtStore(orderId));

  @action
  Future<bool> completeOrder(String orderId) =>
      _act((_) => _actions.completeOrder(orderId));

  /// "ถึงจุดนัดรับแล้ว" — the app's own milestone, and the one the runner
  /// announces to everybody waiting. The server has no trip-level state for it
  /// (see [TripStatus.delivering]), so it is recorded here.
  @action
  void markArrivedAtPickup() {
    final current = trip;
    if (current == null) return;
    trip = current.copyWith(
      status: TripStatus.delivering,
      arrivedAt: DateTime.now(),
    );
  }

  // ─── The runner's own checklist ──────────────────────

  @action
  void toggleChecked(MyOrderItem order) {
    _replace(order, order.copyWith(isChecked: !order.isChecked));
  }

  @action
  void toggleDelivered(MyOrderItem order) {
    _replace(order, order.copyWith(isDelivered: !order.isDelivered));
  }

  @action
  void setFinalPrice(MyOrderItem order, double price) {
    _replace(order, order.copyWith(finalPrice: price));
  }

  @action
  void clearError() => errorMessage = null;

  // ─── Plumbing ────────────────────────────────────────

  void _replace(MyOrderItem order, MyOrderItem updated) {
    final current = trip;
    if (current == null) return;
    final index = current.orders.indexWhere((o) => o.id == order.id);
    if (index < 0) return;
    final orders = [...current.orders]..[index] = updated;
    trip = current.copyWith(orders: orders);
  }

  Future<bool> _act(Future<void> Function(String tripId) body) async {
    final id = trip?.id;
    if (id == null) return false;
    isActing = true;
    errorMessage = null;
    try {
      await body(id);
      await _reload();
      return true;
    } on AppException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (_) {
      errorMessage = 'ทำรายการไม่สำเร็จ กรุณาลองใหม่อีกครั้ง';
      return false;
    } finally {
      isActing = false;
    }
  }
}
