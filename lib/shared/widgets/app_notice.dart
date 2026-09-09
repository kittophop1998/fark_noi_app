import 'package:flutter/material.dart';

import '../../core/theme/app_shape.dart';
import '../../core/theme/app_typography.dart';
import 'app_badge.dart';

/// Something the screen needs to say before the user acts — a condition, a
/// consequence, a rule about money.
///
/// A tint, a hairline and an icon in the family's own colour. Never a filled
/// block: a notice competing with the screen's one coral action is a notice
/// that has stopped being information and started being an alarm.
class AppNotice extends StatelessWidget {
  const AppNotice({
    super.key,
    required this.message,
    this.title,
    this.tone = AppTone.info,
    this.icon,
    this.action,
  });

  final String message;
  final String? title;
  final AppTone tone;
  final IconData? icon;

  /// One control at the foot — "ดูเงื่อนไข", "เข้าใจแล้ว".
  final Widget? action;

  IconData get _icon {
    if (icon != null) return icon!;
    switch (tone) {
      case AppTone.success:
        return Icons.check_circle_outline_rounded;
      case AppTone.warning:
        return Icons.warning_amber_rounded;
      case AppTone.error:
        return Icons.error_outline_rounded;
      // A trust notice is vouching for something, so it wears the shield
      // rather than the "i" every other neutral message wears.
      case AppTone.trust:
        return Icons.verified_user_outlined;
      case AppTone.info:
      case AppTone.neutral:
      case AppTone.brand:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(
        color: toneSoft(tone),
        borderRadius: AppRadius.brMd,
        border: Border.all(color: toneBorder(tone)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, size: AppMetrics.icon, color: toneColor(tone)),
          const SizedBox(width: AppSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: AppText.label.copyWith(color: toneInk(tone)),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: AppText.bodySmall.copyWith(color: toneInk(tone)),
                ),
                if (action != null) ...[
                  const SizedBox(height: AppSpace.x3),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
