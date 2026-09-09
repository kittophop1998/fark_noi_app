import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/domain/entities/home_entity.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/trip_detail_page.dart';
import '../../features/my_trips/presentation/pages/my_trips_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/post_trip/presentation/pages/post_trip_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../di/injection_container.dart';
import '../session/session_controller.dart';

class AppRoutes {
  AppRoutes._();

  static const home = '/';
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const detail = '/detail';
  static const postTrip = '/post-trip';
  static const myTrips = '/my-trips';
  static const profile = '/profile';
  static const notifications = '/notifications';
}

class AppRouter {
  AppRouter._();

  static GoRouter? _instance;

  static GoRouter get router => _instance ??= _build(sl<SessionController>());

  static GoRouter _build(SessionController session) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,
      // The guard below re-runs whenever the session changes, which is what
      // makes signing in and signing out navigations nobody has to write: a
      // store adopts a session, and the redirect does the rest.
      refreshListenable: session,
      redirect: (context, state) {
        final location = state.matchedLocation;
        final onSplash = location == AppRoutes.splash;
        final onAuthScreen =
            location == AppRoutes.login || location == AppRoutes.register;

        // Still reading the keystore. Hold the splash rather than guess — a
        // returning user briefly shown a sign-in form is the bug this avoids.
        if (!session.isResolved) return onSplash ? null : AppRoutes.splash;

        if (!session.isAuthenticated) {
          return onAuthScreen ? null : AppRoutes.login;
        }
        // Signed in: the splash has nothing left to wait for and the sign-in
        // screens have nothing left to ask.
        return (onSplash || onAuthScreen) ? AppRoutes.home : null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.register,
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
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
}
