import 'package:flutter/material.dart';

class AppTheme {
  static const green = Color(0xFF2E7D32), lavender = Color(0xFF9575CD), paper = Color(0xFFF8FAF7), ink = Color(0xFF263238), pale = Color(0xFFE8F5E9);
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);
  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(seedColor: green, brightness: brightness, primary: dark ? const Color(0xFF81C784) : green, secondary: lavender, surface: dark ? const Color(0xFF17211B) : Colors.white);
    return ThemeData(useMaterial3: true, brightness: brightness, colorScheme: scheme,
      scaffoldBackgroundColor: dark ? const Color(0xFF101713) : paper,
      appBarTheme: AppBarTheme(backgroundColor: dark ? const Color(0xFF101713) : paper, foregroundColor: dark ? Colors.white : ink, centerTitle: false, elevation: 0),
      cardTheme: CardThemeData(color: scheme.surface, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)), margin: EdgeInsets.zero),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: dark ? const Color(0xFF202B24) : const Color(0xFFF2F5F1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: green, width: 1.5)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
      navigationBarTheme: NavigationBarThemeData(backgroundColor: scheme.surface, indicatorColor: dark ? const Color(0xFF29442F) : pale, labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(fontSize: 12, fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500))));
  }
}
