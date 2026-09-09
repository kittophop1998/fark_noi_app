import '../../domain/entities/my_trip_entity.dart';

/// The runner's own side of the product: the trip they are running now, the
/// ones they have finished, and the milestones along the way.
abstract class MyTripsDataSource {
  /// The trip the runner is on — `OPEN` or `IN_PROGRESS` — with the errands
  /// accepted onto it. Null when they are not running one.
  Future<MyTripEntity?> getActiveTrip();

  Future<List<MyTripEntity>> getCompletedTrips();

  /// `POST /trips/{id}/start` — ปิดรับฝาก and set off. Past this the trip takes
  /// no new requests.
  Future<void> startTrip(String tripId);

  /// `POST /trips/{id}/complete` — the journey is over.
  Future<void> completeTrip(String tripId);

  /// `POST /trips/{id}/cancel`.
  Future<void> cancelTrip(String tripId);

  /// `POST /orders/{id}/accept` — รับคำฝาก. Takes one of the trip's seats.
  Future<void> acceptOrder(String orderId);

  /// `POST /orders/{id}/reject`.
  Future<void> rejectOrder(String orderId, {String? reason});

  /// `POST /orders/{id}/start-purchasing` — the runner is at the shop. The
  /// coordinate travels because "ถึงร้านแล้ว" is a claim about a place rather
  /// than the press of a button.
  Future<void> startPurchasing(
    String orderId, {
    double? latitude,
    double? longitude,
  });

  /// `POST /orders/{id}/complete` — the errand is settled.
  Future<void> completeOrder(String orderId);
}
