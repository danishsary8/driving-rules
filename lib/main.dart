library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/themes/app_theme.dart';
import 'app/translations/app_translations.dart';
import 'core/services/storage_service.dart';
import 'shared/app_scroll_behavior.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Read persisted preferences before the first build so the initial frame
  // honors them. This temporary StorageService is NOT put into GetX;
  // InitialBinding registers the permanent instance used at runtime.
  final storage = StorageService();
  final initialLocale = storage.readLocale() ?? const Locale('km', 'KH');
  final initialThemeMode = storage.readThemeMode() ?? ThemeMode.light;

  runApp(
    DrivingRulesApp(
      initialLocale: initialLocale,
      initialThemeMode: initialThemeMode,
    ),
  );
}

/// Root widget configuring GetX routing, translations, theming, and the
/// initial binding.
class DrivingRulesApp extends StatelessWidget {
  /// Creates the root app with the resolved startup [initialLocale] and
  /// [initialThemeMode].
  const DrivingRulesApp({
    super.key,
    required this.initialLocale,
    required this.initialThemeMode,
  });

  /// The locale used for the first build (persisted value or Khmer default).
  final Locale initialLocale;

  /// The theme mode used for the first build (persisted value or dark default).
  final ThemeMode initialThemeMode;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Driving Rules',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('en', 'US'),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: initialThemeMode,
      initialBinding: InitialBinding(),
      getPages: AppPages.routes,
      initialRoute: AppPages.initial,
    );
  }
}
