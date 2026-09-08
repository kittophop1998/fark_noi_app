import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shape.dart';
import '../../core/theme/app_typography.dart';

/// A titled block of a screen.
///
/// **Not everything is a card.** The question to ask first is whether this is a
/// real thing the user recognises — a trip, an order, a person. If it is not,
/// it is a heading and some space, which is what this draws.
class AppSection extends StatelessWidget {
  const AppSection({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.action,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final String? title;
  final String? subtitle;

  /// One control on the heading's row — "ดูทั้งหมด", a count, a refresh.
  final Widget? action;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            AppSectionHeader(
              title: title!,
              subtitle: subtitle,
              action: action,
            ),
            const SizedBox(height: AppSpace.x3),
          ],
          child,
        ],
      ),
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppText.heading3.copyWith(color: AppColors.text),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppText.bodySmall.copyWith(color: AppColors.muted),
                ),
              ],
            ],
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: AppSpace.x3),
          action!,
        ],
      ],
    );
  }
}
