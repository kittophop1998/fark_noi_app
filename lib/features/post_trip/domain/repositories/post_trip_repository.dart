import '../../../../shared/models/catalogue_store.dart';
import '../entities/post_trip_entity.dart';

abstract class PostTripRepository {
  Future<void> createPostTrip(PostTripEntity entity);

  Future<List<CatalogueStore>> searchStores({
    String term,
    double? latitude,
    double? longitude,
  });
}
