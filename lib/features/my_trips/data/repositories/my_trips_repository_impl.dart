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
}
