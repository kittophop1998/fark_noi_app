import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/local_storage/hive_local_storage.dart';
import 'core/session/session_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Hive ────────────────────────────────────────────
  await Hive.initFlutter();
  await HiveLocalStorage.openBoxes();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await di.init();

  // The keystore is read, and any session in it confirmed against `/me`, before
  // the first frame. The router's guard branches on the answer, so resolving it
  // here is what stops a returning user from being shown the sign-in screen for
  // the half second it would otherwise take.
  await di.sl<SessionController>().bootstrap();

  runApp(const App());
}
