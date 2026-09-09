import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shape.dart';
import '../../../../core/theme/app_typography.dart';
import 'auth_scaffold.dart';

/// The half second the keystore takes to answer.
///
/// It exists so the router never has to guess: while the session is `unknown`
/// this is what is on screen, and a returning user is not shown a sign-in form
/// they are about to be redirected out of.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppBrandMark(size: 72),
            const SizedBox(height: AppSpace.x6),
            Text(
              'ฝากหน่อย',
              style: AppText.heading2.copyWith(color: AppColors.text),
            ),
            const SizedBox(height: AppSpace.x8),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
