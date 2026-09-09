import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shape.dart';

/// FarkNoi's one recurring picture: a line between two places with something
/// happening on it.
///
/// ```
/// origin ●─────────────────● destination
///  green         line          coral
/// ```
///
/// Naming the ends as roles is what stops a trip card, a create-trip form and
/// an order timeline from each inventing their own colour for "where this is
/// going". These are separate from the status palette on purpose: nothing has
/// *succeeded* because a trip has an origin.
enum RoutePointKind {
  /// Where the traveller set off. Drawn **hollow** — they are no longer there.
  origin,

  /// The point of the errand, and what a reader scans a feed for. Filled.
  destination,

  /// Where somebody is **now**. Same blue as the device dot on a map.
  current,

  /// A shop on the way: a pause, not an end. A smaller mark than either
  /// terminus.
  stop,
}

/// The mark alone, for a caller doing its own layout — a legend, a key, a row.
class RouteMarker extends StatelessWidget {
  const RouteMarker({super.key, required this.kind});

  final RoutePointKind kind;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case RoutePointKind.origin:
        return _dot(
          size: 10,
          color: AppColors.surface,
          border: Border.all(color: AppColors.routeOrigin, width: 2),
        );
      case RoutePointKind.destination:
        return _dot(size: 10, color: AppColors.routeDestination);
      case RoutePointKind.current:
        // A halo, so "here, now" reads as live rather than as a third terminus.
        return _dot(
          size: 10,
          color: AppColors.routeCurrent,
          shadow: [
            BoxShadow(
              color: AppColors.routeCurrent.withOpacity(0.22),
              spreadRadius: 4,
            ),
          ],
        );
      case RoutePointKind.stop:
        return _dot(size: 8, color: AppColors.routeStop);
    }
  }

  Widget _dot({
    required double size,
    required Color color,
    BoxBorder? border,
    List<BoxShadow>? shadow,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border,
        boxShadow: shadow,
      ),
    );
  }
}

/// Where a journey starts and where it ends, with the connector between them.
///
/// The connector's weight is the one decision a caller makes. `strong` tints
/// the line toward the destination it arrives at and belongs to the **trip
/// card alone** — the one surface whose *subject* is the journey. A route drawn
/// inside something else (a form's two location fields, an order's timeline) is
/// context, and its connector's whole job is to say the two rows belong
/// together: that is the neutral line, and it stays neutral.
class RouteLine extends StatelessWidget {
  const RouteLine({
    super.key,
    required this.origin,
    required this.destination,
    this.originMeta,
    this.destinationMeta,
    this.strongConnector = false,
    this.roomy = false,
  });

  final Widget origin;
  final Widget destination;

  /// Right-aligned on the origin's row — usually a departure time.
  final Widget? originMeta;

  /// Right-aligned on the destination's row — usually a distance.
  final Widget? destinationMeta;

  final bool strongConnector;

  /// Gives each end room to hold a control instead of a line of text.
  final bool roomy;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The rail: two marks and the line joining them, on one 16px column so
        // both rows' text starts on the same axis.
        SizedBox(
          width: AppSpace.x4,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 7),
                child: RouteMarker(kind: RoutePointKind.origin),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    width: 2,
                    constraints: BoxConstraints(minHeight: roomy ? 24 : 14),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      // The connector must never out-weigh its ends, which is
                      // why even `strong` is a 200 step rather than the brand.
                      color: strongConnector
                          ? AppColors.routeLineStrong
                          : AppColors.routeLine,
                      borderRadius: AppRadius.brPill,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 7),
                child: RouteMarker(kind: RoutePointKind.destination),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpace.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Row(child: origin, meta: originMeta),
              SizedBox(height: roomy ? AppSpace.x6 : AppSpace.x2),
              _Row(child: destination, meta: destinationMeta),
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.child, this.meta});

  final Widget child;
  final Widget? meta;

  @override
  Widget build(BuildContext context) {
    if (meta == null) return child;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: child),
        const SizedBox(width: AppSpace.x3),
        meta!,
      ],
    );
  }
}

/// The journey on **one line**, for a row too tight to draw the rail — a
/// notification, a history entry, a summary strip.
class RouteSummary extends StatelessWidget {
  const RouteSummary({
    super.key,
    required this.origin,
    required this.destination,
  });

  final Widget origin;
  final Widget destination;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const RouteMarker(kind: RoutePointKind.origin),
        const SizedBox(width: AppSpace.x2),
        Flexible(child: origin),
        const SizedBox(width: AppSpace.x2),
        Expanded(
          child: Container(
            height: 1,
            constraints: const BoxConstraints(minWidth: AppSpace.x6),
            color: AppColors.routeLine,
          ),
        ),
        const SizedBox(width: AppSpace.x2),
        const RouteMarker(kind: RoutePointKind.destination),
        const SizedBox(width: AppSpace.x2),
        Flexible(child: destination),
      ],
    );
  }
}
