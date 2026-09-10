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

  /// `POST /orders/{id}/purchase` — records what was actually bought and its
  /// real price, backed by the runner's own receipt photographs.
  /// `PURCHASING` -> `PURCHASED`.
  Future<void> purchaseOrder(
    String orderId, {
    required String orderItemId,
    required double actualPrice,
    required List<String> proofMediaIds,
  });

  /// `POST /orders/{id}/start-delivery` — `PURCHASED` -> `DELIVERING`.
  Future<void> startDelivery(String orderId);

  /// `POST /orders/{id}/delivered` — the handover, evidenced by photographs
  /// and gated on the runner's own coordinate. `DELIVERING` -> `DELIVERED`.
  Future<void> deliverOrder(
    String orderId, {
    required List<String> proofMediaIds,
    required double latitude,
    required double longitude,
    double? accuracy,
  });

  /// `POST /orders/{id}/cancel`. A reason is required by the API.
  Future<void> cancelOrder(String orderId, {required String reason});

  /// `POST /orders/{id}/review` — the runner's own rating of the requester,
  /// once the errand is `COMPLETED`.
  Future<void> reviewOrder(
    String orderId, {
    required int rating,
    String? comment,
  });
}
