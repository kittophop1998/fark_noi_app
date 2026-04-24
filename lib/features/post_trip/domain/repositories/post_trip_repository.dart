import '../entities/post_trip_entity.dart';

abstract class PostTripRepository {
  Future<void> createPostTrip(PostTripEntity entity);
}
