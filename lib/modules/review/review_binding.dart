/// Dependency binding for the answer Review route.
library;

import 'package:get/get.dart';

import 'review_controller.dart';

/// Registers [ReviewController] for the Review route.
class ReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReviewController());
  }
}
