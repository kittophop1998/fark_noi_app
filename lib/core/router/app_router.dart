import 'package:go_router/go_router.dart';

import '../../features/home/domain/entities/home_entity.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/trip_detail_page.dart';
import '../../features/my_trips/presentation/pages/my_trips_page.dart';
import '../../features/post_trip/presentation/pages/post_trip_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

class AppRoutes {
  AppRoutes._();

  static const home = '/';
  static const splash = '/splash';
  static const login = '/login';
  static const detail = '/detail';
  static const postTrip = '/post-trip';
  static const myTrips = '/my-trips';
  static const profile = '/profile';
  static const notifications = '/notifications';
}

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.postTrip,
        name: 'post-trip',
        builder: (context, state) => const PostTripPage(),
      ),
      GoRoute(
        path: AppRoutes.detail,
        name: 'detail',
        builder: (context, state) {
          final runner = state.extra as HomeEntity;
          return TripDetailPage(runner: runner);
        },
      ),
      GoRoute(
        path: AppRoutes.myTrips,
        name: 'my-trips',
        builder: (context, state) => const MyTripsPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
  );
}
