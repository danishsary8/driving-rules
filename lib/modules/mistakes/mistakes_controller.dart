import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../core/models/question_model.dart';
import '../../core/services/data_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/app_haptics.dart';

/// Controller managing the Smart Mistakes Bank (identifying, reviewing,
/// and re-testing weak-area questions until 100% mastery).
class MistakesController extends GetxController {
  final DataService dataService = Get.find();
  final StorageService storageService = Get.find();

  /// Loaded Question objects currently stored in the Mistakes Bank.
  final questions = <Question>[].obs;

  /// Whether questions are currently loading or ready.
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadMistakes();
  }

  /// Reloads all questions from the stored mistake IDs.
  void loadMistakes() {
    isLoading.value = true;
    final ids = storageService.readMistakeIds();
    final allQuestions = dataService.all.values.expand((list) => list).toList();

    final matched = allQuestions.where((q) => ids.contains(q.id)).toList();
    questions.value = matched;
    isLoading.value = false;
  }

  /// Removes a question after the learner masters it.
  Future<void> removeMistake(String id) async {
    AppHaptics.success();
    await storageService.removeMistakeId(id);
    questions.removeWhere((q) => q.id == id);
  }

  /// Clears all questions from the Mistakes Bank.
  Future<void> clearAll() async {
    AppHaptics.light();
    await storageService.clearAllMistakes();
    questions.clear();
  }

  /// Launches Speed Quiz Challenge or practice round using only these mistake questions.
  void drillMistakes() {
    if (questions.isEmpty) return;
    AppHaptics.light();
    Get.toNamed(AppRoutes.quizPractice);
  }
}
