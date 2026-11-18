import 'package:get/get.dart';

import '../../core/models/exam_analytics_model.dart';
import '../../core/models/exam_result_model.dart';
import '../../core/services/data_service.dart';
import '../../core/services/storage_service.dart';

/// Reactive controller for the dedicated Progress & Analytics screen.
class ProgressController extends GetxController {
  final StorageService storage = Get.find();
  final DataService data = Get.find();

  final history = <ExamResult>[].obs;
  final readiness = Rxn<ExamReadiness>();
  final mastery = <CategoryMastery>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  /// Reloads exam history and re-computes analytics.
  void refreshData() {
    final list = storage.readExamHistory();
    history.assignAll(list);
    readiness.value = ExamAnalytics.calculateReadiness(list);
    mastery.assignAll(ExamAnalytics.calculateCategoryMastery(list).values);
  }

  int get bestScore => storage.bestScore;
  int get mistakeCount => storage.mistakeCount;
  int get bookmarkCount => storage.bookmarkCount;
  int get totalQuestionsCount => data.allQuestions.length;
}
