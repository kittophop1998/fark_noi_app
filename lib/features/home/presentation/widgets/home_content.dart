import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shape.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/app_page.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../my_trips/domain/entities/my_trip_entity.dart';
import '../../domain/entities/home_banner_entity.dart';
import '../../domain/entities/home_entity.dart';
import 'home_banner_carousel.dart';
import 'trip_card.dart';

/// The categories a feed can be narrowed to.
///
/// A chip is selectable and a badge is not, so these are chips — and they are a
/// tint when chosen rather than a filled coral, because a row of filled coral
/// filters would spend the screen's one loud thing before the reader reaches a
/// single trip.
const _categories = <_Category>[
  _Category(key: 'all', label: 'ทั้งหมด', icon: Icons.apps_rounded),
  _Category(key: 'food', label: 'ของกิน', icon: Icons.restaurant_rounded),
  _Category(key: 'mart', label: 'ห้าง/ตลาด', icon: Icons.storefront_rounded),
  _Category(key: 'pharmacy', label: 'ร้านยา', icon: Icons.medical_services_outlined),
  _Category(key: 'drink', label: 'ชานม', icon: Icons.local_cafe_rounded),
];

class _Category {
  const _Category({required this.key, required this.label, required this.icon});

  final String key;
  final String label;
  final IconData icon;
}

class HomeContent extends StatefulWidget {
  const HomeContent({
    super.key,
    required this.items,
    this.banners = const [],
    this.activeTrip,
    this.onRefresh,
  });

  final List<HomeEntity> items;
  final List<HomeBannerEntity> banners;

  /// The reader's own open trip, if they are running one. It sits at the top of
  /// the page rather than in the header band: it is the screen's content, and a
  /// header is chrome.
  final MyTripEntity? activeTrip;

  final Future<void> Function()? onRefresh;

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _selected = 'all';

  List<HomeEntity> get _filtered => _selected == 'all'
      ? widget.items
      : widget.items.where((t) => t.category == _selected).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final activeTrip = widget.activeTrip;

    return AppPageContent(
      onRefresh: widget.onRefresh,
      // The gutter is cancelled for the chip row alone, so the last chip
      // scrolls past the page edge instead of looking clipped by it.
      padding: const EdgeInsets.only(
        top: AppSpace.sectionGap,
        bottom: AppSpace.x12,
      ),
      children: [
        if (activeTrip != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.pageX),
            child: _ActiveTripCard(trip: activeTrip),
          ),
          const SizedBox(height: AppSpace.sectionGap),
        ],

        if (widget.banners.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.pageX),
            child: HomeBannerCarousel(banners: widget.banners),
          ),
          const SizedBox(height: AppSpace.sectionGap),
        ],

        AppChoiceChipRow(
          children: [
            for (final category in _categories)
              AppChoiceChip(
                label: category.label,
                icon: category.icon,
                selected: _selected == category.key,
                onTap: () => setState(() => _selected = category.key),
              ),
          ],
        ),
        const SizedBox(height: AppSpace.sectionGap),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.pageX),
          child: AppSection(
            title: 'ทริปใกล้คุณ',
            subtitle: 'คนที่กำลังจะออกไปซื้อของ แตะเพื่อฝากซื้อ',
            action: AppBadge(
              label: '${filtered.length} ทริป',
              tone: AppTone.brand,
              size: AppBadgeSize.small,
            ),
            child: filtered.isEmpty
                ? const EmptyState(
                    icon: Icons.storefront_outlined,
                    title: 'ยังไม่มีทริปในหมวดนี้',
                    message: 'ลองดูหมวดอื่น หรือเปิดทริปของคุณเองแล้วให้คนอื่นมาฝากซื้อ',
                  )
                : Column(
                    children: [
                      for (final trip in filtered)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpace.x3),
                          child: TripCard(
                            trip: trip,
                            onTap: () => context.push(
                              AppRoutes.detail,
                              extra: trip,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

/// The reader's own trip, when they are the one going.
///
/// The screen's one brand-tinted block — a coral ground says "this is yours"
/// without becoming a second filled action beside the tab bar's.
class _ActiveTripCard extends StatelessWidget {
  const _ActiveTripCard({required this.trip});

  final MyTripEntity trip;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.accent,
      padding: AppSpace.x4,
      onTap: () => context.push(AppRoutes.myTrips),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.brMd,
            ),
            child: const Icon(
              Icons.storefront_rounded,
              // The brand as a shape, which is the one job that step has.
              color: AppColors.brand,
              size: AppMetrics.iconLg,
            ),
          ),
          const SizedBox(width: AppSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ทริปของคุณ · ${trip.destination}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.label.copyWith(
                    color: AppColors.primaryInkStrong,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${trip.filledSlots}/${trip.totalSlots} รายการ · ${trip.status.label}',
                  style: AppText.caption.copyWith(
                    color: AppColors.primaryInkStrong,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primaryInkStrong,
            size: AppMetrics.icon,
          ),
        ],
      ),
    );
  }
}
