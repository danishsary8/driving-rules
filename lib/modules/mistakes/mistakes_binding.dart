import 'package:get/get.dart';
import 'mistakes_controller.dart';

class MistakesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MistakesController>(() => MistakesController());
  }
}
