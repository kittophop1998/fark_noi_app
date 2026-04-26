import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../my_trips/data/my_trips_mock_data.dart';
import '../store/home_store.dart';
import '../widgets/home_content.dart';

// ── Palette shortcuts (10% rule: primary only on main CTA & active states)
const _kPrimary = Color(AppColors.primary); // Blue Violet — FAB, active bubble
const _kAction = AppColors.action; // Orange-Red — urgent noti badge

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeStore _store;

  @override
  void initState() {
    super.initState();
    _store = sl<HomeStore>();
    _store.fetchHomeData();
  }

  @override
  Widget build(BuildContext context) {
    final activeTrip = MyTripsMockData.getActiveTrip();

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
                    const _PulseDotGreen(),
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
                child: _NotiBadge(count: 2),
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
            return _ErrorView(
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

/// Pulsing green dot for the active trip bubble
class _PulseDotGreen extends StatefulWidget {
  const _PulseDotGreen();

  @override
  State<_PulseDotGreen> createState() => _PulseDotGreenState();
}

class _PulseDotGreenState extends State<_PulseDotGreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.4, end: 1.0).animate(_ctrl),
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('ลองอีกครั้ง'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Red dot / count badge for the notification bell icon.
/// Pass [count] = 0 to hide, 1 = red dot only, >1 = number badge.
class _NotiBadge extends StatelessWidget {
  final int count;
  const _NotiBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final showNumber = count > 1;
    return Container(
      width: showNumber ? null : 9,
      height: showNumber ? null : 9,
      padding: showNumber
          ? const EdgeInsets.symmetric(horizontal: 5, vertical: 1)
          : null,
      decoration: BoxDecoration(
        color: _kAction,
        shape: showNumber ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: showNumber ? BorderRadius.circular(8) : null,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: showNumber
          ? Text(
              count > 99 ? '99+' : '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            )
          : null,
    );
  }
}
