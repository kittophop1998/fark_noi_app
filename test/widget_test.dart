import 'package:fark_noi/app.dart';
import 'package:fark_noi/core/di/injection_container.dart' as di;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The router is built from the dependency graph — its guard reads the
  // session — so the container has to exist before `App` does. The keystore is
  // mocked rather than reached for: there is no platform channel under a widget
  // test, and this smoke test is about the app building, not about a session.
  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    await di.sl.reset();
    await di.init();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(App), findsOneWidget);
  });
}
