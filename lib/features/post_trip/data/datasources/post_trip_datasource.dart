import '../models/post_trip_model.dart';

abstract class PostTripDataSource {
  Future<void> createPostTrip(PostTripModel model);
}

/// Mock implementation – replace with real API call when backend is ready
class PostTripMockDataSource implements PostTripDataSource {
  @override
  Future<void> createPostTrip(PostTripModel model) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: replace with actual API call
  }
}
