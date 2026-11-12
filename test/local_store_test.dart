import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iris_classifier/core/models/iris_models.dart';
import 'package:iris_classifier/core/storage/local_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LocalStore store;
  const m = Measurements(sepalLength: 5.1, sepalWidth: 3.5, petalLength: 1.4, petalWidth: 0.2);
  setUp(() async { SharedPreferences.setMockInitialValues({}); store = LocalStore(await SharedPreferences.getInstance()); });
  test('onboarding completion and theme preference persist', () async {
    expect(store.onboardingDone, isFalse); await store.setOnboardingDone(true); expect(store.onboardingDone, isTrue);
    await store.setThemeName('dark'); expect(store.themeName, 'dark');
  });
  test('history saves in chronological order and supports deletion and clear', () async {
    final first = HistoryRecord(id: '1', species: 'setosa', measurements: m, createdAt: DateTime(2025));
    final next = HistoryRecord(id: '2', species: 'virginica', measurements: m, createdAt: DateTime(2026));
    await store.saveRecord(first); await store.saveRecord(next);
    expect(store.history.map((r) => r.id), ['2', '1']);
    await store.deleteRecord('2'); expect(store.history.single.id, '1');
    await store.clearHistory(); expect(store.history, isEmpty);
  });
  test('malformed stored records are ignored without losing valid records', () async {
    await store.saveRecord(HistoryRecord(id: 'ok', species: 'setosa', measurements: m, createdAt: DateTime(2025)));
    await store.prefs.setStringList('iris_history', [...store.prefs.getStringList('iris_history')!, '{bad json']);
    expect(store.history.length, 1);
  });
}
