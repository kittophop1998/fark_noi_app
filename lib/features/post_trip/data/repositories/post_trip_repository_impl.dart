import '../../../../shared/models/catalogue_store.dart';
import '../../domain/entities/post_trip_entity.dart';
import '../../domain/repositories/post_trip_repository.dart';
import '../datasources/post_trip_datasource.dart';

class PostTripRepositoryImpl implements PostTripRepository {
  const PostTripRepositoryImpl({required this.dataSource});

  final PostTripDataSource dataSource;

  @override
  Future<void> createPostTrip(PostTripEntity entity) =>
      dataSource.createPostTrip(entity);

  @override
  Future<List<CatalogueStore>> searchStores({
    String term = '',
    double? latitude,
    double? longitude,
  }) =>
      dataSource.searchStores(
        term: term,
        latitude: latitude,
        longitude: longitude,
      );
}
