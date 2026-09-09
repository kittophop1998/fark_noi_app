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

  Future<void> markArrivedAtStore(String orderId) async {
    final at = await location.current(ask: false);
    return repository.startPurchasing(
      orderId,
      latitude: at.latitude,
      longitude: at.longitude,
    );
  }

  Future<void> completeOrder(String orderId) =>
      repository.completeOrder(orderId);
}
