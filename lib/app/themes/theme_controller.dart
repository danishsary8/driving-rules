/// Global theme-mode controller for the app.
///
/// [ThemeController] owns the active [ThemeMode] as a reactive value, defaulting
/// to [ThemeMode.light] when no preference has been persisted. It
/// applies the resolved mode to GetX on initialization and exposes a [toggle]
/// that flips between light and dark, applies the change live via
/// [Get.changeThemeMode], and persists it through [StorageService]
/// (Req 14.5, 14.6, 14.7, 18.1, 18.3).
///
/// Registered as a permanent controller so the [GetMaterialApp] `themeMode`
/// and the AppBar theme toggle share a single source of truth.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/storage_service.dart';

/// Reactive holder for the app's [ThemeMode] with persistence.
class ThemeController extends GetxController {
  final StorageService _storage = Get.find();

  /// The active theme mode; initialized in [onInit] from storage or the
  /// light default.
  late final Rx<ThemeMode> mode;

  @override
  void onInit() {
    super.onInit();
    mode = (_storage.readThemeMode() ?? ThemeMode.light).obs;
    Get.changeThemeMode(mode.value);
  }

  /// Whether the current mode is dark.
  bool get isDark => mode.value == ThemeMode.dark;

  /// Flips between dark and light, applies it live, and persists the choice.
  Future<void> toggle() async {
    mode.value = isDark ? ThemeMode.light : ThemeMode.dark;
    Get.changeThemeMode(mode.value);
    await _storage.writeThemeMode(mode.value);
  }
}
