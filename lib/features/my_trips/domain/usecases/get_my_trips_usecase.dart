import '../entities/my_trip_entity.dart';
import '../repositories/my_trips_repository.dart';

class GetActiveTripUseCase {
  final MyTripsRepository repository;

  GetActiveTripUseCase(this.repository);

  Future<MyTripEntity?> call() async {
    return await repository.getActiveTrip();
  }
}

class GetCompletedTripsUseCase {
  final MyTripsRepository repository;

  GetCompletedTripsUseCase(this.repository);

  Future<List<MyTripEntity>> call() async {
    return await repository.getCompletedTrips();
  }
}
