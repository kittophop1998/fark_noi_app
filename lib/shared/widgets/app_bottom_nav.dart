import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shape.dart';
import '../../core/theme/app_typography.dart';
import 'pressable.dart';

class AppNavDestination {
  const AppNavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
}

/// The tab bar.
///
/// **The central action carries stronger visual treatment because it is the
/// product's whole thesis rendered as one control**: somebody near you is
/// already going that way, and you can ask them. So it is raised out of the bar
/// — a 56px brand circle sitting proud of the row, ringed in the bar's own
/// surface so it reads as *on top of* the navigation rather than punched
/// through it.
///
/// The tabs beside it are deliberately not scaled to match. A tab bar where
/// every item competes is an admin toolbar; here there is one thing to do and
/// four places to go, and the sizes say so.
///
/// Two tabs each side, so the centre button stays centred.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onSelect,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimary,
  });

  final List<AppNavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        // A hairline, not the default border: at the bottom of a warm page a
        // full-strength rule reads as a table footer.
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SizedBox(
        height: AppMetrics.bottomNavHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tab(0),
            _tab(1),
            Expanded(child: _primary()),
            _tab(2),
            _tab(3),
          ],
        ),
      ),
    );
  }

  Widget _tab(int index) {
    final destination = destinations[index];
    final active = currentIndex == index;

    return Expanded(
      child: Pressable(
        onTap: () => onSelect(index),
        scale: 0.94,
        child: SizedBox(
          height: AppMetrics.bottomNavHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 24px: the tab bar is the one place icons step up from the
              // product's 20px, because they carry the label's job as much as
              // the label does. The active tab is both brand-coloured *and*
              // heavier, so the current destination is legible without relying
              // on colour alone.
              Icon(
                active ? destination.activeIcon : destination.icon,
                size: AppMetrics.navIconSize,
                color: active ? AppColors.navActive : AppColors.navInactive,
              ),
              const SizedBox(height: AppSpace.x1 + 2),
              // Truncated rather than allowed to wrap: a wrapped Thai label
              // would grow the bar's height and push the page's own sticky
              // action off the bottom of the screen, and that failure is
              // silent.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.overline.copyWith(
                    height: 1,
                    letterSpacing: 0,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: active ? AppColors.navActive : AppColors.navInactive,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _primary() {
    return Pressable(
      onTap: onPrimary,
      scale: 0.95,
      child: Transform.translate(
        offset: const Offset(0, -20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: AppShadow.sm,
                // Ringed in the bar's own surface, which is what makes it read
                // as sitting on top of the navigation.
                border: Border.all(color: AppColors.surface, width: 4),
              ),
              child: Icon(
                primaryIcon,
                size: AppMetrics.iconLg,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: AppSpace.x1),
            Text(
              primaryLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.overline.copyWith(
                height: 1,
                letterSpacing: 0,
                color: AppColors.navInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
