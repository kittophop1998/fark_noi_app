import '../../domain/entities/my_trip_entity.dart';
import '../../domain/repositories/my_trips_repository.dart';
import '../datasources/my_trips_datasource.dart';

class MyTripsRepositoryImpl implements MyTripsRepository {
  final MyTripsDataSource dataSource;

  MyTripsRepositoryImpl({required this.dataSource});

  @override
  Future<MyTripEntity?> getActiveTrip() async {
    return await dataSource.getActiveTrip();
  }

  @override
  Future<List<MyTripEntity>> getCompletedTrips() async {
    return await dataSource.getCompletedTrips();
  }
}
