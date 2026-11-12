import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iris_classifier/app/app.dart';
import 'package:iris_classifier/core/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('first launch reaches onboarding and advances pages', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)], child: const IrisClassifierApp()));
    await tester.pumpAndSettle();
    expect(find.text('A closer look at Iris'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Four simple measurements'), findsOneWidget);
  });
}
