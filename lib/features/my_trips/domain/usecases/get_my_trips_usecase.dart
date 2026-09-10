import '../../../../core/errors/exceptions.dart';
import '../../../../core/location/location_service.dart';
import '../entities/my_trip_entity.dart';
import '../repositories/my_trips_repository.dart';

class GetActiveTripUseCase {
  const GetActiveTripUseCase(this.repository);

  final MyTripsRepository repository;

  Future<MyTripEntity?> call() => repository.getActiveTrip();
}

class GetCompletedTripsUseCase {
  const GetCompletedTripsUseCase(this.repository);

  final MyTripsRepository repository;

  Future<List<MyTripEntity>> call() => repository.getCompletedTrips();
}

/// The runner's milestones, as one use case rather than seven.
///
/// They are grouped because they are one job — running a trip — and a class per
/// verb here would be seven files whose whole content is a single forwarded
/// call. The location is resolved inside [markArrivedAtStore] for the same
/// reason it is in the home feed's use case: the screen asks for the milestone
/// and does not have to know that recording it needs a coordinate.
class TripActionsUseCase {
  const TripActionsUseCase(this.repository, this.location);

  final MyTripsRepository repository;
  final LocationService location;

  Future<void> startTrip(String tripId) => repository.startTrip(tripId);

  Future<void> completeTrip(String tripId) => repository.completeTrip(tripId);

  Future<void> cancelTrip(String tripId) => repository.cancelTrip(tripId);

  Future<void> acceptOrder(String orderId) => repository.acceptOrder(orderId);

  Future<void> rejectOrder(String orderId, {String? reason}) =>
      repository.rejectOrder(orderId, reason: reason);

  /// The server checks this against a ~10 m radius of the order's own shop
  /// coordinate (`TOO_FAR_FROM_STORE`), so a fix has to actually be asked for
  /// here rather than reused from the coarse one the feed keeps around.
  Future<void> markArrivedAtStore(String orderId) async {
    final at = await location.currentPrecise();
    if (at == null) {
      throw const AppException(
        'หาตำแหน่งไม่ได้ กรุณาเปิด GPS แล้วลองใหม่อีกครั้ง',
      );
    }
    return repository.startPurchasing(
      orderId,
      latitude: at.latitude,
      longitude: at.longitude,
    );
  }

  Future<void> completeOrder(String orderId) =>
      repository.completeOrder(orderId);

  Future<void> purchaseOrder(
    String orderId, {
    required String orderItemId,
    required double actualPrice,
    required List<String> proofMediaIds,
  }) =>
      repository.purchaseOrder(
        orderId,
        orderItemId: orderItemId,
        actualPrice: actualPrice,
        proofMediaIds: proofMediaIds,
      );

  Future<void> startDelivery(String orderId) =>
      repository.startDelivery(orderId);

  /// Gated the same way arrival at the shop is — `TOO_FAR_FROM_DELIVERY_POINT`
  /// on the far side needs the same precise fix.
  Future<void> deliverOrder(
    String orderId, {
    required List<String> proofMediaIds,
  }) async {
    final at = await location.currentPrecise();
    if (at == null) {
      throw const AppException(
        'หาตำแหน่งไม่ได้ กรุณาเปิด GPS แล้วลองใหม่อีกครั้ง',
      );
    }
    return repository.deliverOrder(
      orderId,
      proofMediaIds: proofMediaIds,
      latitude: at.latitude,
      longitude: at.longitude,
      accuracy: at.accuracy,
    );
  }

  Future<void> cancelOrder(String orderId, {required String reason}) =>
      repository.cancelOrder(orderId, reason: reason);

  Future<void> reviewOrder(
    String orderId, {
    required int rating,
    String? comment,
  }) =>
      repository.reviewOrder(orderId, rating: rating, comment: comment);
}
