import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';

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

final sl = GetIt.instance;

Future<void> init() async {
  // ─── MobX Stores ──────────────────────────────────────
  sl.registerFactory(() => HomeStore(getHomeData: sl()));
  sl.registerFactory(() => PostTripStore(createPostTrip: sl()));

  // ─── Use Cases ────────────────────────────────────────
  sl.registerLazySingleton(() => GetHomeDataUseCase(sl()));
  sl.registerLazySingleton(() => CreatePostTripUseCase(sl()));

  // ─── Repositories ─────────────────────────────────────
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PostTripRepository>(
    () => PostTripRepositoryImpl(dataSource: sl()),
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

  // ─── Core ─────────────────────────────────────────────
  sl.registerLazySingleton(() => DioClient());
}

