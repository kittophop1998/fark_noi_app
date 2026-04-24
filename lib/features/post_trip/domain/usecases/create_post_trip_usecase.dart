import '../entities/post_trip_entity.dart';
import '../repositories/post_trip_repository.dart';

class CreatePostTripUseCase {
  final PostTripRepository repository;

  const CreatePostTripUseCase(this.repository);

  Future<void> call(PostTripEntity entity) =>
      repository.createPostTrip(entity);
}
