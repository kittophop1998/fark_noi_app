import 'package:get_it/get_it.dart';

import '../local_storage/hive_local_storage.dart';
import '../local_storage/local_storage_service.dart';
import '../local_storage/token_storage.dart';
import '../location/location_service.dart';
import '../network/dio_client.dart';
import '../session/session_controller.dart';

// ── Auth ────────────────────────────────────────────────────────────────────
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/store/auth_store.dart';

// ── Home ────────────────────────────────────────────────────────────────────
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
import '../../features/my_trips/data/datasources/my_trips_remote_datasource.dart';
import '../../features/my_trips/data/repositories/my_trips_repository_impl.dart';
import '../../features/my_trips/domain/repositories/my_trips_repository.dart';
import '../../features/my_trips/domain/usecases/get_my_trips_usecase.dart';
import '../../features/my_trips/presentation/store/my_trips_store.dart';

// ── Orders ──────────────────────────────────────────────────────────────────
import '../../features/orders/data/datasources/orders_datasource.dart';
import '../../features/orders/presentation/store/create_order_store.dart';

// ── Notifications ───────────────────────────────────────────────────────────
import '../../features/notifications/data/datasources/notifications_datasource.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/presentation/store/notifications_store.dart';

// ── Profile ─────────────────────────────────────────────────────────────────
import '../../features/profile/data/datasources/profile_datasource.dart';
import '../../features/profile/presentation/store/profile_store.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ─── Core ─────────────────────────────────────────────
  sl.registerLazySingleton(() => TokenStorage());
  sl.registerLazySingleton(() => LocationService());
  sl.registerLazySingleton<LocalStorageService>(() => HiveLocalStorage());

  // The client and the session know about each other, and the knot is tied
  // here rather than in either of them: a refused renewal has to end the
  // session, and ending the session has to clear the tokens the client sends.
  // The callback resolves the controller lazily, which is what keeps that from
  // being a cycle at construction time.
  sl.registerLazySingleton(
    () => DioClient(
      tokenStorage: sl(),
      onSessionExpired: () => sl<SessionController>().expire(),
    ),
  );

  // ─── Data Sources ─────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<PostTripDataSource>(
    () => PostTripRemoteDataSource(client: sl()),
  );
  sl.registerLazySingleton<MyTripsDataSource>(
    () => MyTripsRemoteDataSource(client: sl()),
  );
  sl.registerLazySingleton<OrdersDataSource>(
    () => OrdersRemoteDataSource(client: sl()),
  );
  sl.registerLazySingleton<NotificationsDataSource>(
    () => NotificationsRemoteDataSource(client: sl()),
  );
  sl.registerLazySingleton<ProfileDataSource>(
    () => ProfileRemoteDataSource(client: sl()),
  );

  // ─── Repositories ─────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl(), tokens: sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PostTripRepository>(
    () => PostTripRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<MyTripsRepository>(
    () => MyTripsRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(dataSource: sl()),
  );

  // ─── Session ──────────────────────────────────────────
  //
  // A singleton and not a factory: it is the router's `refreshListenable`, and
  // a second instance would be a second answer to "who is signed in".
  sl.registerLazySingleton(
    () => SessionController(repository: sl(), tokens: sl()),
  );

  // ─── Use Cases ────────────────────────────────────────
  sl.registerLazySingleton(() => GetHomeDataUseCase(sl(), sl()));
  sl.registerLazySingleton(() => CreatePostTripUseCase(sl()));
  sl.registerLazySingleton(() => SearchStoresUseCase(sl(), sl()));
  sl.registerLazySingleton(() => GetActiveTripUseCase(sl()));
  sl.registerLazySingleton(() => GetCompletedTripsUseCase(sl()));
  sl.registerLazySingleton(() => TripActionsUseCase(sl(), sl()));

  // ─── MobX Stores ──────────────────────────────────────
  //
  // Factories, so a screen opened twice does not inherit the first visit's
  // form state — except the ones whose state *is* shared, and there are none.
  sl.registerFactory(() => AuthStore(repository: sl(), session: sl()));
  sl.registerFactory(() => HomeStore(getHomeData: sl()));
  sl.registerFactory(
    () => PostTripStore(
      createPostTrip: sl(),
      searchStores: sl(),
      location: sl(),
    ),
  );
  sl.registerFactory(
    () => MyTripsStore(
      getActiveTrip: sl(),
      getCompletedTrips: sl(),
      actions: sl(),
    ),
  );
  sl.registerFactory(
    () => CreateOrderStore(dataSource: sl(), location: sl()),
  );
  sl.registerFactory(() => NotificationsStore(repository: sl()));
  sl.registerFactory(() => ProfileStore(dataSource: sl(), session: sl()));
}
