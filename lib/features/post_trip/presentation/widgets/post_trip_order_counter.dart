import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shape.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../../../../shared/widgets/pressable.dart';

/// How many requests this trip will take.
///
/// A stepper rather than a field: the range is 1–20 and every value is one tap
/// away, so a keyboard here would be a keyboard for two digits.
class PostTripOrderCounter extends StatelessWidget {
  const PostTripOrderCounter({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 20,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    // A group of controls is not an object, so this is the *soft* card: a
    // recess on the page rather than a second white surface floating on it.
    return AppCard(
      variant: AppCardVariant.soft,
      padding: AppSpace.x4,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'รับได้สูงสุด',
                  style: AppText.label.copyWith(color: AppColors.text),
                ),
                const SizedBox(height: 2),
                Text(
                  'เผื่อไม่ให้ของหนักเกินไปตอนแบกกลับ',
                  style: AppText.caption.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          _StepButton(
            icon: Icons.remove_rounded,
            onTap: value > min ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 56,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppText.priceLarge.copyWith(color: AppColors.text),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            onTap: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Pressable(
      onTap: onTap,
      scale: 0.92,
      child: Container(
        width: AppMetrics.controlSm,
        height: AppMetrics.controlSm,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? AppColors.border : AppColors.borderSubtle,
          ),
        ),
        child: Icon(
          icon,
          size: AppMetrics.iconSm,
          // A disabled step keeps its shape and loses its ink, so the range's
          // ends are visible rather than guessed at.
          color: enabled ? AppColors.text : AppColors.disabled,
        ),
      ),
    );
  }
}
