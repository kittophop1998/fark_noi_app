import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_shape.dart';
import '../../../../shared/widgets/app_nav_shell.dart';
import '../../../../shared/widgets/app_page.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../my_trips/data/datasources/my_trips_mock_datasource.dart';
import '../../../my_trips/domain/entities/my_trip_entity.dart';
import '../store/home_store.dart';
import '../widgets/home_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeStore _store;
  MyTripEntity? _activeTrip;

  @override
  void initState() {
    super.initState();
    _store = sl<HomeStore>();
    _store.fetchHomeData();
    _loadActiveTrip();
  }

  Future<void> _loadActiveTrip() async {
    final trip = await MyTripsMockDataSource().getActiveTrip();
    if (!mounted) return;
    setState(() => _activeTrip = trip);
  }

  Future<void> _refresh() async {
    await _store.fetchHomeData();
    await _loadActiveTrip();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      // The header is one row and the same three slots on every route: what is
      // waiting for me, what screen is this, who am I signed in as.
      title: 'หน้าแรก',
      unreadCount: 2,
      onBellTap: () => context.push(AppRoutes.notifications),
      userName: 'มิน สมใจ',
      onIdentityTap: () => context.push(AppRoutes.profile),
      bottomNavigationBar: AppNavShell.bar(context, 0),
      child: Observer(
        builder: (_) {
          if (_store.isLoading) {
            // A skeleton shaped like the content, never a spinner on an empty
            // page — the reader should be able to see what is arriving.
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
            activeTrip: _activeTrip,
            onRefresh: _refresh,
          );
        },
      ),
    );
  }
}
