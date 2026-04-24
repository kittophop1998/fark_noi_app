import 'package:go_router/go_router.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/post_trip/presentation/pages/post_trip_page.dart';

class AppRoutes {
  AppRoutes._();

  static const home = '/';
  static const splash = '/splash';
  static const login = '/login';
  static const detail = '/detail';
  static const postTrip = '/post-trip';
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
      // TODO: Add more routes here
      // GoRoute(
      //   path: AppRoutes.login,
      //   name: 'login',
      //   builder: (context, state) => const LoginPage(),
      // ),
    ],
  );
}
