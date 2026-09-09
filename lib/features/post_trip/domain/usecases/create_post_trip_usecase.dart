import '../../../../core/location/location_service.dart';
import '../../../../shared/models/catalogue_store.dart';
import '../entities/post_trip_entity.dart';
import '../repositories/post_trip_repository.dart';

class CreatePostTripUseCase {
  const CreatePostTripUseCase(this.repository);

  final PostTripRepository repository;

  Future<void> call(PostTripEntity entity) =>
      repository.createPostTrip(entity);
}

/// The shops offered as a destination.
///
/// The coordinate is resolved here so the picker is nearest-first without the
/// screen having to ask for a permission first — and a caller with no fix still
/// gets the alphabetical list rather than nothing.
class SearchStoresUseCase {
  const SearchStoresUseCase(this.repository, this.location);

  final PostTripRepository repository;
  final LocationService location;

  Future<List<CatalogueStore>> call({String term = ''}) async {
    final at = await location.current(ask: false);
    return repository.searchStores(
      term: term,
      latitude: at.latitude,
      longitude: at.longitude,
    );
  }
}
