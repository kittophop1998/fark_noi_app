import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shape.dart';
import '../../core/theme/app_typography.dart';

/// The tones every state in the product resolves to.
///
/// **The mapping from a backend enum to a tone does not live here** — it lives
/// beside the enum, in the feature, because a tone is a *product* judgement:
/// "ส่งของแล้ว" is a warning in this product because the goods arrived and the
/// money has not, and nothing in a design system knows that.
///
/// [AppTone.trust] is the teal one, and it is deliberately not a status:
/// `success` says a thing *finished*, `trust` says a thing is *vouched for* —
/// an identity confirmed, a payment handle, a safety note. A product that moves
/// money must not slur the two, so they are separate tones over separate hues.
enum AppTone { success, warning, error, info, neutral, brand, trust }

enum AppBadgeSize { small, medium }

/// A status you read. A chip is selectable; a badge is not — never both
/// concepts in one component.
///
/// Reach for one sparingly: a badge earns its place only when the status
/// changes what the user would *do*, and a card wearing three of them has told
/// the reader nothing except that the database has three columns.
///
/// The label is always human Thai — "กำลังซื้อ", never `PURCHASING`. Tone is
/// never the only signal, so the badge still works in greyscale.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.tone = AppTone.neutral,
    this.size = AppBadgeSize.medium,
    this.icon,
    this.outlined = false,
  });

  final String label;
  final AppTone tone;
  final AppBadgeSize size;
  final IconData? icon;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final small = size == AppBadgeSize.small;
    final ink = toneInk(tone);
    // Neither step goes under 12px: a status nobody can read is worse than no
    // status at all.
    final style = (small ? AppText.overline : AppText.caption).copyWith(
      color: ink,
      fontWeight: FontWeight.w600,
      height: 1,
    );

    return Container(
      height: small ? 24 : 28,
      padding: EdgeInsets.symmetric(horizontal: small ? 10 : AppSpace.x3),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : toneSoft(tone),
        borderRadius: AppRadius.brPill,
        border: outlined ? Border.all(color: toneBorder(tone)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: small ? 12 : 14, color: ink),
            const SizedBox(width: AppSpace.x1),
          ],
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
          ),
        ],
      ),
    );
  }
}

/// The tinted ground a badge or a notice sits on.
Color toneSoft(AppTone tone) {
  switch (tone) {
    case AppTone.success:
      return AppColors.successSoft;
    case AppTone.warning:
      return AppColors.warningSoft;
    case AppTone.error:
      return AppColors.errorSoft;
    case AppTone.info:
      return AppColors.infoSoft;
    case AppTone.neutral:
      return AppColors.surfaceMuted;
    case AppTone.brand:
      return AppColors.primarySoft;
    case AppTone.trust:
      return AppColors.trustSoft;
  }
}

/// Text on that ground.
Color toneInk(AppTone tone) {
  switch (tone) {
    case AppTone.success:
      return AppColors.successStrong;
    case AppTone.warning:
      return AppColors.warningStrong;
    case AppTone.error:
      return AppColors.errorStrong;
    case AppTone.info:
      return AppColors.infoStrong;
    case AppTone.neutral:
      return AppColors.muted;
    case AppTone.brand:
      return AppColors.primaryInk;
    case AppTone.trust:
      return AppColors.trustStrong;
  }
}

/// The colour itself — an icon, a dot, a bar.
Color toneColor(AppTone tone) {
  switch (tone) {
    case AppTone.success:
      return AppColors.success;
    case AppTone.warning:
      return AppColors.warning;
    case AppTone.error:
      return AppColors.error;
    case AppTone.info:
      return AppColors.info;
    case AppTone.neutral:
      return AppColors.faint;
    case AppTone.brand:
      return AppColors.brand;
    case AppTone.trust:
      return AppColors.trust;
  }
}

/// A hairline around it.
Color toneBorder(AppTone tone) {
  switch (tone) {
    case AppTone.success:
      return AppColors.successBorder;
    case AppTone.warning:
      return AppColors.warningBorder;
    case AppTone.error:
      return AppColors.errorBorder;
    case AppTone.info:
      return AppColors.infoBorder;
    case AppTone.neutral:
      return AppColors.border;
    case AppTone.brand:
      return AppColors.primaryBorder;
    case AppTone.trust:
      return AppColors.trustBorder;
  }
}
