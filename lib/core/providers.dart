import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/iris_models.dart';
import 'storage/local_store.dart';
import '../services/prediction_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());
final localStoreProvider = Provider<LocalStore>((ref) => LocalStore(ref.watch(sharedPreferencesProvider)));
final predictionServiceProvider = Provider<PredictionService>((ref) {
  const baseUrl = String.fromEnvironment('IRIS_API_BASE_URL');
  return baseUrl.isEmpty ? const UnavailablePredictionService() : DioPredictionService(baseUrl: baseUrl);
});
final historyProvider = StateNotifierProvider<HistoryNotifier, List<HistoryRecord>>((ref) => HistoryNotifier(ref.watch(localStoreProvider)));
class HistoryNotifier extends StateNotifier<List<HistoryRecord>> {
  HistoryNotifier(this.store) : super(store.history);
  final LocalStore store;
  Future<void> save(HistoryRecord item) async { await store.saveRecord(item); state = store.history; }
  Future<void> delete(String id) async { await store.deleteRecord(id); state = store.history; }
  Future<void> clear() async { await store.clearHistory(); state = []; }
}
final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) => ThemeNotifier(ref.watch(localStoreProvider)));
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(this.store) : super(_parse(store.themeName));
  final LocalStore store;
  static ThemeMode _parse(String s) => switch (s) {'light' => ThemeMode.light, 'dark' => ThemeMode.dark, _ => ThemeMode.system};
  Future<void> set(ThemeMode mode) async { state = mode; await store.setThemeName(switch (mode) {ThemeMode.light => 'light', ThemeMode.dark => 'dark', _ => 'system'}); }
}
