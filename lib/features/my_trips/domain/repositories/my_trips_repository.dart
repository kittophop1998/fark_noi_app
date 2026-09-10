import '../entities/my_trip_entity.dart';

/// Abstract repository สำหรับ my_trips feature
abstract class MyTripsRepository {
  /// ดึงทริปที่กำลัง active อยู่ (null = ไม่มีทริปที่เปิดอยู่)
  Future<MyTripEntity?> getActiveTrip();

  /// ดึงประวัติทริปที่จบแล้ว
  Future<List<MyTripEntity>> getCompletedTrips();

  // ── Milestones ────────────────────────────────────────────────────────
  //
  // Every one of these is a state change the server owns. None of them return
  // the new trip: the screen re-reads instead, because a transition can move
  // more than the thing it was called on — starting a trip closes it to new
  // requests, and completing one settles every errand on it.

  Future<void> startTrip(String tripId);
  Future<void> completeTrip(String tripId);
  Future<void> cancelTrip(String tripId);

  Future<void> acceptOrder(String orderId);
  Future<void> rejectOrder(String orderId, {String? reason});
  Future<void> startPurchasing(
    String orderId, {
    double? latitude,
    double? longitude,
  });
  Future<void> completeOrder(String orderId);

  Future<void> purchaseOrder(
    String orderId, {
    required String orderItemId,
    required double actualPrice,
    required List<String> proofMediaIds,
  });

  Future<void> startDelivery(String orderId);

  Future<void> deliverOrder(
    String orderId, {
    required List<String> proofMediaIds,
    required double latitude,
    required double longitude,
    double? accuracy,
  });

  Future<void> cancelOrder(String orderId, {required String reason});

  Future<void> reviewOrder(
    String orderId, {
    required int rating,
    String? comment,
  });
}
