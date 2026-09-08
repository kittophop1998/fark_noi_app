import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import 'app_bottom_nav.dart';

/// The four places you can go, and the one thing you can do.
///
/// Kept in one list rather than spelled out per screen, so the bar's order —
/// two tabs, the raised brand action, two tabs — cannot drift between routes.
/// The centre action is the product's whole thesis as one control, which is why
/// it is not a fifth tab.
class AppNavShell {
  AppNavShell._();

  static const List<AppNavDestination> destinations = [
    AppNavDestination(
      label: 'หน้าแรก',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      route: AppRoutes.home,
    ),
    AppNavDestination(
      label: 'ทริปของฉัน',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      route: AppRoutes.myTrips,
    ),
    AppNavDestination(
      label: 'แจ้งเตือน',
      icon: Icons.notifications_none_rounded,
      activeIcon: Icons.notifications_rounded,
      route: AppRoutes.notifications,
    ),
    AppNavDestination(
      label: 'โปรไฟล์',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      route: AppRoutes.profile,
    ),
  ];

  /// The bar for a root screen. [index] is the tab that screen *is*; a screen
  /// pushed on top of one passes the tab it belongs to.
  static Widget bar(BuildContext context, int index) {
    return AppBottomNav(
      destinations: destinations,
      currentIndex: index,
      onSelect: (i) {
        if (i == index) return;
        // `go` rather than `push`: a tab is a place, not a step, and pushing
        // one builds a back stack four screens deep out of ordinary browsing.
        context.go(destinations[i].route);
      },
      primaryLabel: 'เปิดทริป',
      primaryIcon: Icons.add_rounded,
      onPrimary: () => context.push(AppRoutes.postTrip),
    );
  }
}
