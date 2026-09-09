import '../../domain/entities/home_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({required this.remoteDataSource});

  final HomeRemoteDataSource remoteDataSource;

  @override
  Future<List<HomeEntity>> getNearbyTrips({
    required double latitude,
    required double longitude,
  }) {
    return remoteDataSource.getNearbyTrips(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
