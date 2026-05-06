import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../my_trips/domain/entities/my_trip_entity.dart';
import '../../../my_trips/data/datasources/my_trips_mock_datasource.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/noti_badge.dart';
import '../../../../shared/widgets/pulse_dot_widget.dart';
import '../store/home_store.dart';
import '../widgets/home_content.dart';

// ── Palette shortcuts (10% rule: primary only on main CTA & active states)
const _kPrimary = Color(AppColors.primary); // Blue Violet — FAB, active bubble

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

  @override
  Widget build(BuildContext context) {
    final activeTrip = _activeTrip;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        actions: [
          // ── Active Trip Bubble ──
          if (activeTrip != null)
            GestureDetector(
              onTap: () => context.push(AppRoutes.myTrips),
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _kPrimary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _kPrimary.withOpacity(0.30),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PulseDotWidget(),
                    const SizedBox(width: 5),
                    Text(
                      'เปิดรับ ${activeTrip.filledSlots}/${activeTrip.totalSlots} คิว',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded,
                color: Color(AppColors.textPrimary)),
            onPressed: () => context.push(AppRoutes.profile),
          ),
          // ── Notification Bell with Badge ──
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Color(AppColors.textPrimary)),
                onPressed: () => context.push(AppRoutes.notifications),
              ),
              // Red badge — replace count with 0 to hide
              Positioned(
                right: 8,
                top: 8,
                child: NotiBadge(count: 2),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Observer(
        builder: (_) {
          if (_store.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _kPrimary),
            );
          }
          if (_store.hasError) {
            return AppErrorView(
              message: _store.errorMessage!,
              onRetry: _store.fetchHomeData,
            );
          }
          if (_store.isEmpty) {
            return const Center(child: Text('ยังไม่มีคนจะไปซื้อของ'));
          }
          return HomeContent(items: _store.items);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          child: FloatingActionButton.extended(
            onPressed: () {
              context.push(AppRoutes.postTrip);
            },
            backgroundColor: _kPrimary,
            foregroundColor: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
            label: const Text(
              'เปิดรับฝาก — ฉันจะไปซื้อของ',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}

