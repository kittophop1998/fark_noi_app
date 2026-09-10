import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/home_banner_entity.dart';
import '../models/home_model.dart';

abstract class HomeRemoteDataSource {
  /// The 7 km feed around a coordinate. `GET /trips/nearby` refuses a request
  /// without one, which is why there is no zero-argument form.
  Future<List<HomeModel>> getNearbyTrips({
    required double latitude,
    required double longitude,
  });

  /// `GET /home-banners/active` — the carousel as it should be shown right now.
  Future<List<HomeBannerEntity>> getBanners();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl({required this.client});

  final DioClient client;

  @override
  Future<List<HomeModel>> getNearbyTrips({
    required double latitude,
    required double longitude,
  }) async {
    final response = await client.get(
      ApiEndpoints.nearbyTrips,
      queryParameters: {
        'lat': latitude,
        'lng': longitude,
        // The fixed-radius feed. PROVINCE is the wider one and answers 422
        // where no drawn zone reaches the caller, so it is not a default.
        'scope': 'RADIUS',
      },
    );
    return DioClient.unwrapList(response)
        .whereType<Map>()
        .map((item) => HomeModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<List<HomeBannerEntity>> getBanners() async {
    final response = await client.get(ApiEndpoints.homeBanners);
    return DioClient.unwrapList(response)
        .whereType<Map>()
        .map((item) =>
            HomeBannerEntity.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
