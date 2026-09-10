import '../../domain/entities/my_trip_entity.dart';
import '../../domain/repositories/my_trips_repository.dart';
import '../datasources/my_trips_datasource.dart';

class MyTripsRepositoryImpl implements MyTripsRepository {
  const MyTripsRepositoryImpl({required this.dataSource});

  final MyTripsDataSource dataSource;

  @override
  Future<MyTripEntity?> getActiveTrip() => dataSource.getActiveTrip();

  @override
  Future<List<MyTripEntity>> getCompletedTrips() =>
      dataSource.getCompletedTrips();

  @override
  Future<void> startTrip(String tripId) => dataSource.startTrip(tripId);

  @override
  Future<void> completeTrip(String tripId) => dataSource.completeTrip(tripId);

  @override
  Future<void> cancelTrip(String tripId) => dataSource.cancelTrip(tripId);

  @override
  Future<void> acceptOrder(String orderId) => dataSource.acceptOrder(orderId);

  @override
  Future<void> rejectOrder(String orderId, {String? reason}) =>
      dataSource.rejectOrder(orderId, reason: reason);

  @override
  Future<void> startPurchasing(
    String orderId, {
    double? latitude,
    double? longitude,
  }) =>
      dataSource.startPurchasing(
        orderId,
        latitude: latitude,
        longitude: longitude,
      );

  @override
  Future<void> completeOrder(String orderId) =>
      dataSource.completeOrder(orderId);

  @override
  Future<void> purchaseOrder(
    String orderId, {
    required String orderItemId,
    required double actualPrice,
    required List<String> proofMediaIds,
  }) =>
      dataSource.purchaseOrder(
        orderId,
        orderItemId: orderItemId,
        actualPrice: actualPrice,
        proofMediaIds: proofMediaIds,
      );

  @override
  Future<void> startDelivery(String orderId) =>
      dataSource.startDelivery(orderId);

  @override
  Future<void> deliverOrder(
    String orderId, {
    required List<String> proofMediaIds,
    required double latitude,
    required double longitude,
    double? accuracy,
  }) =>
      dataSource.deliverOrder(
        orderId,
        proofMediaIds: proofMediaIds,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
      );

  @override
  Future<void> cancelOrder(String orderId, {required String reason}) =>
      dataSource.cancelOrder(orderId, reason: reason);

  @override
  Future<void> reviewOrder(
    String orderId, {
    required int rating,
    String? comment,
  }) =>
      dataSource.reviewOrder(orderId, rating: rating, comment: comment);
}
