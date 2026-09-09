import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shape.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import 'app_avatar.dart';
import 'app_button.dart';

/// Which colour the band is painted.
///
/// Every coloured header in the product is the same `primary.700` fill with
/// white ink — there is no per-route tint. A ground that changes its texture
/// per route turns one component wearing seven tints into seven headers
/// sharing a file.
///
/// [neutral] is the quiet one: a white bar with a hairline, for a screen where
/// somebody is checking a figure or agreeing to something. **Lower the
/// decoration as the stakes rise.**
enum PageHeaderTone { brand, neutral }

/// The band at the top of every screen. **A screen never draws its own.**
///
/// Structure is fixed, it is one row, and only the fill changes:
///
/// ```
/// [safe area]
/// [bell]              [page title]              [name] [face]   ← 56px
/// ──────────────────────────────────────────────────────────    ← flat edge
/// ```
///
/// Three slots, three questions, and the same answer on every route. Left:
/// *what is waiting for me* — the notification bell, and nothing else. Middle:
/// *what screen is this* — the route's name, one line. Right: *who am I signed
/// in as* — the display name and the avatar, which is also the way into the
/// profile.
///
/// That is the whole band. A header is the one element on a phone guaranteed to
/// be read; 56px of it saying the same three things in the same three places is
/// worth more than a hero that has to be re-learned per route.
///
/// **No header draws a back control.** Most screens are reachable by several
/// paths, so an arrow at the top left points somewhere different depending on
/// how somebody arrived — the platform gesture and the tab bar are the ways
/// out. A screen genuinely pushed onto a stack (a detail, a form) is the one
/// exception and asks for [showBack].
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.tone = PageHeaderTone.brand,
    this.showBell = true,
    this.unreadCount = 0,
    this.onBellTap,
    this.userName,
    this.userImageUrl,
    this.onIdentityTap,
    this.showBack = false,
    this.onBack,
  });

  final String title;
  final PageHeaderTone tone;

  /// `false` on the notifications screen alone — a control that opens the
  /// identical list does nothing.
  final bool showBell;

  final int unreadCount;
  final VoidCallback? onBellTap;

  final String? userName;
  final String? userImageUrl;
  final VoidCallback? onIdentityTap;

  /// A pushed screen takes the bell's slot for a back control instead.
  final bool showBack;
  final VoidCallback? onBack;

  bool get _onDark => tone == PageHeaderTone.brand;

  Color get _ink => _onDark ? AppColors.headerOnBrand : AppColors.headerInk;

  Color get _inkMuted =>
      _onDark ? AppColors.headerOnBrandMuted : AppColors.headerInkMuted;

  Color get _controlPlate => _onDark
      ? AppColors.headerOnBrand.withOpacity(0.15)
      : AppColors.surfaceMuted;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _onDark ? AppTheme.brandOverlay : AppTheme.neutralOverlay,
      child: Container(
        padding: EdgeInsets.only(top: topInset),
        decoration: BoxDecoration(
          color: _onDark ? AppColors.headerBrand : AppColors.headerNeutral,
          // The seam is a straight line: no rounded bottom corners, no scrim,
          // no artwork layer.
          border: _onDark
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.borderSubtle),
                ),
        ),
        child: SizedBox(
          height: AppMetrics.headerHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.x2),
            child: Row(
              children: [
                // The outer rails are equal-width flexes with a 44px floor, so
                // an empty rail still reserves its half of the symmetry and the
                // title sits on the *viewport's* axis rather than between its
                // neighbours.
                Expanded(child: _leading()),
                Flexible(
                  flex: 0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      // 18px bold and one line — this is an app bar rather than
                      // a page heading.
                      style: AppText.title.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                  ),
                ),
                Expanded(child: _trailing()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _leading() {
    if (showBack) {
      return Align(
        alignment: Alignment.centerLeft,
        child: AppIconButton(
          icon: Icons.arrow_back_rounded,
          onPressed: onBack,
          background: _controlPlate,
          foreground: _ink,
          size: 40,
        ),
      );
    }
    if (!showBell) return const SizedBox(width: AppMetrics.touchTarget);

    return Align(
      alignment: Alignment.centerLeft,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AppIconButton(
            icon: Icons.notifications_none_rounded,
            onPressed: onBellTap,
            background: _controlPlate,
            foreground: _ink,
            size: 40,
          ),
          if (unreadCount > 0)
            Positioned(
              right: 4,
              top: 4,
              child: _UnreadDot(count: unreadCount, ring: _onDark
                  ? AppColors.headerBrand
                  : AppColors.surface),
            ),
        ],
      ),
    );
  }

  Widget _trailing() {
    if (userName == null) return const SizedBox(width: AppMetrics.touchTarget);

    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onIdentityTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: AppMetrics.touchTarget,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Everything in the rails truncates, and the name yields first: a
              // long Thai display name shortens itself rather than pushing the
              // title off centre.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 96),
                child: Text(
                  userName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption.copyWith(
                    color: _inkMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpace.x2),
              // A step below the bell's plate opposite it, so the two read as
              // one line of chrome rather than as the screen's subject.
              AppAvatar(name: userName!, imageUrl: userImageUrl, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot({required this.count, required this.ring});

  final int count;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 16),
      height: 16,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // The unread count is the one thing on the band allowed to be its own
        // colour: it is a state, and states come from the status families.
        color: AppColors.errorFill,
        borderRadius: AppRadius.brPill,
        border: Border.all(color: ring, width: 1.5),
      ),
      child: Text(
        label,
        style: AppText.overline.copyWith(
          color: AppColors.errorForeground,
          fontSize: 9,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
