import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shape.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/route_line.dart';

/// When the trip leaves, and when it gets back.
///
/// **The journey is drawn, not listed.** These are the two ends of the same
/// line, so they are the same picture the trip card and the order timeline
/// draw: a hollow green mark where the runner sets off, a coral one where the
/// errand lands. The connector stays neutral — a route drawn *inside* a form is
/// context, and its job is to say the two rows belong together.
class PostTripTimeRow extends StatelessWidget {
  const PostTripTimeRow({
    super.key,
    required this.departureTime,
    required this.returnTime,
    required this.onTapDeparture,
    required this.onTapReturn,
  });

  final TimeOfDay? departureTime;
  final TimeOfDay? returnTime;
  final VoidCallback onTapDeparture;
  final VoidCallback onTapReturn;

  @override
  Widget build(BuildContext context) {
    return RouteLine(
      roomy: true,
      origin: _TimeField(
        label: 'ออกจากที่นี่',
        time: departureTime,
        onTap: onTapDeparture,
      ),
      destination: _TimeField(
        label: 'ถึงจุดนัดรับ',
        time: returnTime,
        onTap: onTapReturn,
      ),
    );
  }
}

/// A field that opens a picker rather than a keyboard, in the same 52px shell
/// every other control on the form wears.
class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final chosen = time != null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.label.copyWith(color: AppColors.text)),
          const SizedBox(height: AppSpace.x2),
          Container(
            height: AppMetrics.fieldHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.brMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: AppMetrics.icon,
                  color: chosen ? AppColors.primary : AppColors.faint,
                ),
                const SizedBox(width: AppSpace.x3),
                Expanded(
                  child: Text(
                    chosen ? time!.format(context) : 'เลือกเวลา',
                    style: AppText.body.copyWith(
                      color: chosen ? AppColors.text : AppColors.placeholder,
                      fontWeight:
                          chosen ? FontWeight.w600 : FontWeight.w400,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const Icon(
                  Icons.expand_more_rounded,
                  size: AppMetrics.icon,
                  color: AppColors.disabled,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
