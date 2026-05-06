import '../../domain/entities/my_trip_entity.dart';

/// Abstract datasource interface สำหรับ my_trips
abstract class MyTripsDataSource {
  Future<MyTripEntity?> getActiveTrip();
  Future<List<MyTripEntity>> getCompletedTrips();
}
