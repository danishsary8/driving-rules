/// Application-wide dependency registration performed once at startup.
///
/// [InitialBinding] registers the app-lifetime services and global controllers
/// as permanent GetX dependencies, then fires off the initial data load. Order
/// matters: [StorageService] is registered first because both [ThemeController]
/// and [LocaleController] resolve it via `Get.find<StorageService>()` in their
/// fields/`onInit`. The data load is started fire-and-forget so the Home screen
/// can react to [DataService] status (loading → ready/error) without blocking
/// app construction (Req 1.4, 3.1, 18.3, 18.4).
library;

import 'package:get/get.dart';

import '../../core/services/data_service.dart';
import '../../core/services/storage_service.dart';
import '../themes/theme_controller.dart';
import '../translations/app_translations.dart';

/// Registers permanent services/controllers and triggers the startup data load.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // StorageService first: ThemeController and LocaleController depend on it.
    Get.put(StorageService(), permanent: true);

    // DataService and immediately kick off loading all categories.
    final data = Get.put(DataService(), permanent: true);

    // Global controllers that resolve StorageService on init.
    Get.put(ThemeController(), permanent: true);
    Get.put(LocaleController(), permanent: true);

    // Fire-and-forget: the Home screen reacts to DataService.status.
    data.loadAllCategories();
  }
}
