import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A blocking wait over a screen that is already drawn — a submit in flight, a
/// payment being confirmed.
///
/// It is the scrim from the token layer rather than a black wash: the page
/// underneath should still be readable, because what the user is waiting for is
/// the thing they can see.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          const ColoredBox(
            color: AppColors.scrim,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}
