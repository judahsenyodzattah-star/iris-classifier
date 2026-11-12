import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/iris_models.dart';

class LocalStore {
  LocalStore(this.prefs);
  final SharedPreferences prefs;
  static const _onboarding = 'onboarding_done', _theme = 'theme_mode', _history = 'iris_history';
  bool get onboardingDone => prefs.getBool(_onboarding) ?? false;
  Future<void> setOnboardingDone(bool value) async { await prefs.setBool(_onboarding, value); }
  String get themeName => prefs.getString(_theme) ?? 'system';
  Future<void> setThemeName(String value) async { await prefs.setString(_theme, value); }
  List<HistoryRecord> get history {
    final raw = prefs.getStringList(_history) ?? [];
    final records = <HistoryRecord>[];
    for (final item in raw) {
      try {
        final parsed = jsonDecode(item);
        if (parsed is Map<String, dynamic>) records.add(HistoryRecord.fromJson(parsed));
      } catch (_) { /* Ignore stale/corrupt record, keep usable records. */ }
    }
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }
  Future<void> saveRecord(HistoryRecord record) async {
    final entries = history.where((r) => r.id != record.id).toList()..insert(0, record);
    await prefs.setStringList(_history, entries.map((r) => r.encode()).toList());
  }
  Future<void> deleteRecord(String id) async {
    await prefs.setStringList(_history, history.where((r) => r.id != id).map((r) => r.encode()).toList());
  }
  Future<void> clearHistory() async { await prefs.remove(_history); }
}
