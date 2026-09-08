import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fark Noi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // There is no dark mode, and that is a decision rather than an omission:
      // the token layer is structured for one (roles, not values), but nothing
      // declares a dark palette, and half a dark mode is worse than none.
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
