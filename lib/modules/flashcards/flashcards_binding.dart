import 'package:get/get.dart';
import 'flashcards_controller.dart';

/// Binds [FlashcardsController] to the `/flashcards` route.
class FlashcardsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FlashcardsController>(() => FlashcardsController());
  }
}
