import 'package:get/get.dart';
import 'quiz_practice_controller.dart';

class QuizPracticeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuizPracticeController>(() => QuizPracticeController());
  }
}
