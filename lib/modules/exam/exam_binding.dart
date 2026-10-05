/// Dependency binding for the Exam route.
///
/// Lazily registers a fresh [ExamController] each time the exam route is
/// opened, so every entry builds a brand-new exam session in its `onInit`
/// (Req 8.9, 10.6).
library;

import 'package:get/get.dart';

import 'exam_controller.dart';

/// Registers the [ExamController] for the Exam route.
class ExamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExamController());
  }
}
