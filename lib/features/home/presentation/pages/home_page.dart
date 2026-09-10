import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_shape.dart';
import '../../../../shared/widgets/app_nav_shell.dart';
import '../../../../shared/widgets/app_page.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../my_trips/presentation/store/my_trips_store.dart';
import '../../../notifications/presentation/store/notifications_store.dart';
import '../store/home_store.dart';
import '../widgets/home_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeStore _store;

  /// The reader's own trip and their unread count are read here rather than
  /// inside the header, because the header is chrome on every route and the
  /// question "what is waiting for me" is answered once, by the screen that
  /// owns the session's landing page.
  late final MyTripsStore _myTrips;
  late final NotificationsStore _notifications;
  late final SessionController _session;

  @override
  void initState() {
    super.initState();
    _store = sl<HomeStore>();
    _myTrips = sl<MyTripsStore>();
    _notifications = sl<NotificationsStore>();
    _session = sl<SessionController>();
    _store.fetchHomeData();
    _store.loadBanners();
    _myTrips.load();
    _notifications.load();
  }

  Future<void> _refresh() async {
    // The permission dialog is not raised on a pull: the gesture asked for
    // fresher trips, not for a system prompt over the list it just tugged.
    await Future.wait([
      _store.fetchHomeData(askForLocation: false),
      _store.loadBanners(),
      _myTrips.load(),
      _notifications.load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => AppPage(
        // The header is one row and the same three slots on every route: what
        // is waiting for me, what screen is this, who am I signed in as.
        title: 'หน้าแรก',
        unreadCount: _notifications.unreadCount,
        onBellTap: () => context.push(AppRoutes.notifications),
        userName: _session.user?.displayName,
        userImageUrl: _session.user?.avatarUrl,
        onIdentityTap: () => context.push(AppRoutes.profile),
        bottomNavigationBar: AppNavShell.bar(context, 0),
        child: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_store.isLoading) {
      // A skeleton shaped like the content, never a spinner on an empty page —
      // the reader should be able to see what is arriving.
      return const Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpace.pageX,
          AppSpace.sectionGap,
          AppSpace.pageX,
          0,
        ),
        child: SkeletonList(),
      );
    }
    if (_store.hasError) {
      return ErrorState(
        message: _store.errorMessage!,
        onRetry: _store.fetchHomeData,
      );
    }
    if (_store.isEmpty) {
      return EmptyState(
        icon: Icons.storefront_outlined,
        title: 'ยังไม่มีใครออกไปซื้อของ',
        message: 'เปิดทริปของคุณเอง แล้วให้เพื่อนบ้านฝากซื้อระหว่างทาง',
        actionLabel: 'เปิดทริปของฉัน',
        onAction: () => context.push(AppRoutes.postTrip),
      );
    }
    return HomeContent(
      items: _store.items,
      banners: _store.banners,
      activeTrip: _myTrips.trip,
      onRefresh: _refresh,
    );
  }
}
