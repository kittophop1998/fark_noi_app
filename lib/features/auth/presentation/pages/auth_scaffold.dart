import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shape.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';

/// The shape of the two screens that come before the app.
///
/// Deliberately not [AppPage]: the shell's header carries a bell, an avatar and
/// a tab bar, none of which exist yet for somebody who is not signed in. What
/// replaces it is the plainest possible frame — the warm page, the mark, a
/// title and the form — because this is the screen where the product has to
/// look trustworthy rather than lively.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.footer,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  /// The committing action, pinned above the keyboard rather than at the end of
  /// the scroll.
  final Widget? footer;

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.neutralOverlay,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              if (onBack != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.text,
                    onPressed: onBack,
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpace.pageX,
                    onBack == null ? AppSpace.x12 : AppSpace.x4,
                    AppSpace.pageX,
                    AppSpace.x8,
                  ),
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: AppBrandMark(),
                    ),
                    const SizedBox(height: AppSpace.x8),
                    Text(
                      title,
                      style: AppText.heading1.copyWith(color: AppColors.text),
                    ),
                    const SizedBox(height: AppSpace.x2),
                    Text(
                      subtitle,
                      style: AppText.bodySmall.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: AppSpace.x8),
                    ...children,
                  ],
                ),
              ),
              if (footer != null)
                Container(
                  padding: EdgeInsets.fromLTRB(
                    AppSpace.pageX,
                    AppSpace.x3,
                    AppSpace.pageX,
                    AppSpace.x3 + MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.borderSubtle),
                    ),
                    boxShadow: AppShadow.sm,
                  ),
                  child: footer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The logo plate. [AppColors.brand] rather than [AppColors.primary]: this is a
/// shape, and the bright step is what the mark is for — the filled coral is
/// spent on the button below it instead.
class AppBrandMark extends StatelessWidget {
  const AppBrandMark({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.brand,
        borderRadius: AppRadius.brXl,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.shopping_bag_rounded,
        size: size * 0.5,
        color: AppColors.onPrimary,
      ),
    );
  }
}
