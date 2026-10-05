/// Dependency binding for the Study route.
///
/// Lazily registers a fresh [StudyController] each time the Study route is
/// opened, so the controller reads the current `Get.arguments` category.
library;

import 'package:get/get.dart';

import 'study_controller.dart';

/// Registers the [StudyController] for the Study route.
class StudyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StudyController());
  }
}
