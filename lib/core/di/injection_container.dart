import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../local_storage/hive_local_storage.dart';
import '../local_storage/local_storage_service.dart';

// ── Home ────────────────────────────────────────────────────────────────────
import '../../features/home/data/datasources/home_mock_datasource.dart';
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_data_usecase.dart';
import '../../features/home/presentation/store/home_store.dart';

// ── Post Trip ───────────────────────────────────────────────────────────────
import '../../features/post_trip/data/datasources/post_trip_datasource.dart';
import '../../features/post_trip/data/repositories/post_trip_repository_impl.dart';
import '../../features/post_trip/domain/repositories/post_trip_repository.dart';
import '../../features/post_trip/domain/usecases/create_post_trip_usecase.dart';
import '../../features/post_trip/presentation/store/post_trip_store.dart';

// ── My Trips ────────────────────────────────────────────────────────────────
import '../../features/my_trips/data/datasources/my_trips_datasource.dart';
import '../../features/my_trips/data/datasources/my_trips_mock_datasource.dart';
import '../../features/my_trips/data/repositories/my_trips_repository_impl.dart';
import '../../features/my_trips/domain/repositories/my_trips_repository.dart';
import '../../features/my_trips/domain/usecases/get_my_trips_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ─── MobX Stores ──────────────────────────────────────
  sl.registerFactory(() => HomeStore(getHomeData: sl()));
  sl.registerFactory(() => PostTripStore(createPostTrip: sl()));

  // ─── Use Cases ────────────────────────────────────────
  sl.registerLazySingleton(() => GetHomeDataUseCase(sl()));
  sl.registerLazySingleton(() => CreatePostTripUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveTripUseCase(sl()));
  sl.registerLazySingleton(() => GetCompletedTripsUseCase(sl()));

  // ─── Repositories ─────────────────────────────────────
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PostTripRepository>(
    () => PostTripRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<MyTripsRepository>(
    () => MyTripsRepositoryImpl(dataSource: sl()),
  );

  // ─── Data Sources ─────────────────────────────────────
  // TODO: เปลี่ยนเป็น HomeRemoteDataSourceImpl เมื่อพร้อม connect backend
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeMockDataSource(),
  );
  // TODO: เปลี่ยนเป็น PostTripRemoteDataSource เมื่อพร้อม connect backend
  sl.registerLazySingleton<PostTripDataSource>(
    () => PostTripMockDataSource(),
  );
  // TODO: เปลี่ยนเป็น MyTripsRemoteDataSource เมื่อพร้อม connect backend
  sl.registerLazySingleton<MyTripsDataSource>(
    () => MyTripsMockDataSource(),
  );

  // ─── Core ─────────────────────────────────────────────
  sl.registerLazySingleton(() => DioClient());

  // ─── Local Storage ────────────────────────────────────
  sl.registerLazySingleton<LocalStorageService>(() => HiveLocalStorage());
}
