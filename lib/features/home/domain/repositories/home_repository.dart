import '../entities/home_entity.dart';

/// Abstract repository — domain layer จะ depend ตัวนี้เท่านั้น
abstract class HomeRepository {
  Future<List<HomeEntity>> getHomeData();
}
