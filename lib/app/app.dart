import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import '../core/providers.dart';

class IrisClassifierApp extends ConsumerWidget {
  const IrisClassifierApp({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'Iris Classifier', debugShowCheckedModeBanner: false,
    theme: AppTheme.light(), darkTheme: AppTheme.dark(), themeMode: ref.watch(themeModeProvider),
    routerConfig: appRouter,
  );
}
