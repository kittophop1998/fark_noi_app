import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shape.dart';
import '../../core/theme/app_typography.dart';
import 'app_button.dart';

/// Nothing here yet — and one thing to do about it.
///
/// An empty state is a screen's first impression as often as its last, so it
/// gets a shape rather than a sentence floating in the middle of a page: a
/// tinted plate, a line saying what is missing, a line saying why, and at most
/// one action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.x6,
          vertical: AppSpace.x10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primarySubtle,
                shape: BoxShape.circle,
              ),
              // The brand as a *shape*, which is the one job `brand` has.
              child: Icon(icon, size: 28, color: AppColors.brand),
            ),
            const SizedBox(height: AppSpace.x4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.title.copyWith(color: AppColors.text),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpace.x2),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppText.bodySmall.copyWith(color: AppColors.muted),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpace.x5),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: AppButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Something went wrong, and the way out is to try again.
///
/// Red is the icon, not the whole block: in a product that moves money an
/// alarm-coloured panel for a failed fetch spends a signal the app needs for
/// something worse.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.title = 'โหลดข้อมูลไม่สำเร็จ',
    this.retryLabel = 'ลองอีกครั้ง',
  });

  final String message;
  final VoidCallback? onRetry;
  final String title;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.x6,
          vertical: AppSpace.x10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.errorSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 28,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpace.x4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.title.copyWith(color: AppColors.text),
            ),
            const SizedBox(height: AppSpace.x2),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppText.bodySmall.copyWith(color: AppColors.muted),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpace.x5),
              AppButton(
                label: retryLabel,
                onPressed: onRetry,
                variant: AppButtonVariant.outline,
                icon: Icons.refresh_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A screen waiting on its own data shows a skeleton shaped like the content —
/// never a spinner in the middle of an empty page, which tells the reader
/// nothing about what is arriving.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.radius = AppRadius.brSm,
  });

  final double height;
  final double width;
  final BorderRadius radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      // Ends on its resting state in both directions, so a reduced-motion
      // setting that collapses the duration leaves a visible block rather than
      // an invisible one.
      opacity: Tween<double>(begin: 0.55, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
      ),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: AppColors.surfaceStrong,
          borderRadius: widget.radius,
        ),
      ),
    );
  }
}

/// A feed's loading state: cards the shape of the cards that are coming.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: AppSpace.x3),
          padding: const EdgeInsets.all(AppSpace.x5),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.brLg,
            border: Border.all(color: AppColors.borderWarm),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonBox(height: 40, width: 40, radius: AppRadius.brPill),
                  SizedBox(width: AppSpace.x3),
                  Expanded(child: SkeletonBox(height: 14, width: 120)),
                ],
              ),
              SizedBox(height: AppSpace.x4),
              SkeletonBox(height: 12, width: 100),
              SizedBox(height: AppSpace.x2),
              SkeletonBox(height: 18),
              SizedBox(height: AppSpace.x4),
              SkeletonBox(height: 44, radius: AppRadius.brMd),
            ],
          ),
        ),
      ),
    );
  }
}
