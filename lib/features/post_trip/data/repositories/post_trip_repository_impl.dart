import '../../domain/entities/post_trip_entity.dart';
import '../../domain/repositories/post_trip_repository.dart';
import '../datasources/post_trip_datasource.dart';
import '../models/post_trip_model.dart';

class PostTripRepositoryImpl implements PostTripRepository {
  final PostTripDataSource dataSource;

  const PostTripRepositoryImpl({required this.dataSource});

  @override
  Future<void> createPostTrip(PostTripEntity entity) async {
    final model = PostTripModel.fromEntity(entity);
    await dataSource.createPostTrip(model);
  }
}
