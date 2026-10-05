/// GetX translation registration and runtime locale management.
///
/// [AppTranslations] supplies GetX with the `en_US` and `km_KH` key maps so
/// `'key'.tr` resolves against the active locale (with English fallback).
/// [LocaleController] holds the two supported locales, exposes the current
/// locale (defaulting to Khmer), and toggles between them while persisting the
/// choice via [StorageService] (Req 13.1–13.6, 18.2, 18.4, 18.6).
library;

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/services/storage_service.dart';
import 'en_us.dart';
import 'km_kh.dart';

/// Registers the bilingual UI key maps with GetX.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en_US': enUS, 'km_KH': kmKH};
}

/// Manages the active UI locale and persists changes.
class LocaleController extends GetxController {
  /// English (United States) locale.
  static const en = Locale('en', 'US');

  /// Khmer (Cambodia) locale — the app default.
  static const km = Locale('km', 'KH');

  final StorageService _storage = Get.find();

  /// The active locale, defaulting to Khmer when none is set.
  Locale get current => Get.locale ?? km;

  /// Switches between Khmer and English, applying and persisting the new locale.
  Future<void> toggle() async {
    final next = current == km ? en : km;
    Get.updateLocale(next);
    await _storage.writeLocale(next);
  }
}
