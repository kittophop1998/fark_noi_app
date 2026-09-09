import '../../../../core/location/location_service.dart';
import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

/// The trips near the person asking.
///
/// The coordinate is resolved here rather than in the store, so "where am I"
/// and "what is near me" stay one question: a screen asks for the feed and does
/// not have to know that answering it needs a permission. [LocationService]
/// never fails — it falls back — so this has no location-shaped error to
/// report.
class GetHomeDataUseCase {
  const GetHomeDataUseCase(this.repository, this.location);

  final HomeRepository repository;
  final LocationService location;

  Future<List<HomeEntity>> call({bool askForLocation = true}) async {
    final at = await location.current(ask: askForLocation);
    return repository.getNearbyTrips(
      latitude: at.latitude,
      longitude: at.longitude,
    );
  }
}
