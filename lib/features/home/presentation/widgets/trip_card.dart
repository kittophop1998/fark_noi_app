import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shape.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/route_line.dart';
import '../../domain/entities/home_entity.dart';

/// One trip in the feed — the product's most important marketplace object.
///
/// This is the **only** drawing of a trip in the app. Home and a search result
/// having one each is how the same trip ends up with a countdown on one screen
/// and a clock time on the other.
///
/// **The journey is drawn, not listed.** It is the product's one recurring
/// image: a hollow green mark where they set off, a filled coral mark where
/// they are going, and the line joining them.
///
/// Reading order is the order the questions arrive in:
///
///   who is going    the runner, their face and their name, at the top — on a
///                   marketplace between strangers this is what decides whether
///                   the rest of the card is worth reading
///   are they any good  the rating, on its own line under the name rather than
///                   wedged beside it
///   where, and where to  the route block
///   when, is there room  one wrapping meta line
///   what do I tap   the action bar, at the foot
class TripCard extends StatelessWidget {
  const TripCard({super.key, required this.trip, this.onTap});

  final HomeEntity trip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final full = trip.isFull;

    return AppFeedCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserIdentity(
            name: trip.name,
            muted: full,
            // The rating goes under the name rather than beside it: a name and
            // a star competing for one row at 390px truncates the name, which
            // is the half a reader recognises somebody by.
            caption: RatingBadge(
              rating: trip.rating,
              // An unrated runner is drawn as new, never as zero — the line is
              // simply absent, because an absence spelled out on every card in
              // a feed reads as a warning about half the platform.
              rated: trip.reviewCount > 0,
              reviewCount: trip.reviewCount,
            ),
          ),
          const SizedBox(height: AppSpace.x4),

          // The trip card is the one surface whose *subject* is the journey, so
          // it is the one caller that gets the tinted connector.
          RouteLine(
            strongConnector: true,
            origin: Text(
              trip.dormitory,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption.copyWith(color: AppColors.muted),
            ),
            // Wraps rather than truncates: a destination is the one string on
            // this card that must arrive whole. Clamped at two lines only so a
            // pathological name cannot push the rest out of the card.
            destination: Text(
              trip.destination,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.heading3.copyWith(color: AppColors.text),
            ),
          ),
          const SizedBox(height: AppSpace.x4),

          // Departure, arrival and capacity as one scannable line that wraps on
          // the narrowest phone. Each carries its own glyph and they are set
          // apart by space rather than by a "·", which would be left dangling
          // at the end of the first line the moment the row wraps.
          Wrap(
            spacing: 14,
            runSpacing: AppSpace.x1 + 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Meta(icon: Icons.schedule_rounded, label: 'ออก ${trip.departureTime}'),
              if (trip.eta.isNotEmpty)
                _Meta(icon: Icons.home_outlined, label: 'ถึงหอ ${trip.eta}'),
              // Capacity is plain text while there is room and a badge once
              // there is not: a full trip is a row the reader should be able to
              // skip without finishing it, and that needs to survive a glance.
              if (full)
                const AppBadge(
                  label: 'เต็มแล้ว',
                  tone: AppTone.neutral,
                  size: AppBadgeSize.small,
                )
              else
                _Meta(
                  icon: Icons.inventory_2_outlined,
                  label: 'รับได้อีก ${trip.availableSlots} รายการ',
                ),
            ],
          ),

          if (trip.tags.isNotEmpty) ...[
            const SizedBox(height: AppSpace.x3),
            Wrap(
              spacing: AppSpace.x1 + 2,
              runSpacing: AppSpace.x1 + 2,
              children: [
                for (final tag in trip.tags.take(3))
                  AppBadge(
                    label: tag,
                    tone: AppTone.neutral,
                    size: AppBadgeSize.small,
                    outlined: true,
                  ),
              ],
            ),
          ],

          const SizedBox(height: AppSpace.x4),
          _ActionBar(open: !full),
        ],
      ),
    );
  }
}

/// One fact about the trip: a glyph and a phrase.
class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.faint),
        const SizedBox(width: AppSpace.x1 + 2),
        Text(label, style: AppText.caption.copyWith(color: AppColors.muted)),
      ],
    );
  }
}

/// **The action bar is a cue, not a button — but it is a filled one.**
///
/// The whole card is the tap target, so this is a painted row rather than a
/// second control: two tap targets on one row is how a feed starts mis-firing
/// under a thumb. It is still 44px tall, because that is what the thumb aims
/// at.
///
/// A trip closed to requests keeps a quiet bar: the card is still worth
/// opening, but nothing on it is an action any more.
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.open});

  final bool open;

  @override
  Widget build(BuildContext context) {
    final ink = open ? AppColors.onPrimary : AppColors.muted;

    return Container(
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // `surfaceStrong` rather than `surfaceMuted` when closed: a bar 2% off
        // white is not visibly a bar, and "this one is finished" has to be
        // legible at the same glance the live one is.
        color: open ? AppColors.primary : AppColors.surfaceStrong,
        borderRadius: AppRadius.brMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            open ? 'ดูเส้นทางและฝากซื้อ' : 'ดูรายละเอียดทริป',
            style: AppText.bodySmall.copyWith(
              color: ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppSpace.x1),
          Icon(Icons.chevron_right_rounded, size: 18, color: ink),
        ],
      ),
    );
  }
}
