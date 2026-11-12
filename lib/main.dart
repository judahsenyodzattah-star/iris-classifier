import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(<String>['iris_classifier'], '''
Botanical photographs used by J’Iris

Iris setosa 2.jpg — Tiia Monto, Wikimedia Commons
https://commons.wikimedia.org/wiki/File:Iris_setosa_2.jpg
Licensed under Creative Commons Attribution-ShareAlike 4.0 International
https://creativecommons.org/licenses/by-sa/4.0/

Iris versicolor L.jpg — Kevo, Wikimedia Commons
https://commons.wikimedia.org/wiki/File:Iris_versicolor_L.jpg
Licensed under Creative Commons Attribution-ShareAlike 3.0 Unported
https://creativecommons.org/licenses/by-sa/3.0/

Iris virginica.jpg — Frank Mayfield, Wikimedia Commons
https://commons.wikimedia.org/wiki/File:Iris_virginica.jpg
Licensed under Creative Commons Attribution-ShareAlike 2.0 Generic
https://creativecommons.org/licenses/by-sa/2.0/

The photographs are locally bundled and displayed with cropping for the app layout.
''');
  });
  final preferences = await SharedPreferences.getInstance();
  runApp(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const IrisClassifierApp()));
}
