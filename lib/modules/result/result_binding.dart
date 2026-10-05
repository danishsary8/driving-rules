/// Dependency binding for the Result route.
///
/// Lazily registers a fresh [ResultController] each time the result route is
/// opened, so it reads the latest [Get.arguments] payload (the just-computed
/// [ExamResult]).
library;

import 'package:get/get.dart';

import 'result_controller.dart';

/// Registers the [ResultController] for the Result route.
class ResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ResultController());
  }
}
