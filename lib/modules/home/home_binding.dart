/// Dependency binding for the Home route.
///
/// [HomeBinding] lazily provides a [HomeController] when the Home route is
/// opened, so the screen can resolve it via `Get.find` / `GetView`. The
/// app-lifetime services it depends on ([DataService], [StorageService]) are
/// registered separately at startup. (Req 4.x)
library;

import 'package:get/get.dart';

import 'home_controller.dart';

/// Registers [HomeController] for the Home route.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}
