import '../entities/home_banner_entity.dart';
import '../entities/home_entity.dart';

/// Abstract repository — domain layer จะ depend ตัวนี้เท่านั้น
abstract class HomeRepository {
  Future<List<HomeEntity>> getNearbyTrips({
    required double latitude,
    required double longitude,
  });

  Future<List<HomeBannerEntity>> getBanners();
}
