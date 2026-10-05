/// Controller backing the Home screen.
///
/// [HomeController] exposes the category entries to render, an exam-availability
/// flag derived from the live [DataService] load status, and the persisted
/// last/best score view data from [StorageService]. It also owns the two
/// navigation intents the Home screen triggers: opening a category in Study
/// mode and starting a fresh exam. (Req 3.3, 4.4, 19.3, 19.4)
library;

import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/models/exam_result_model.dart';
import '../../core/models/question_model.dart';
import '../../core/services/data_service.dart';
import '../../core/services/storage_service.dart';

/// Reactive state + navigation intents for the Home screen.
class HomeController extends GetxController {
  /// App-lifetime data service; its reactive [DataService.status] drives the
  /// Home screen's loading/error/ready states.
  final DataService data = Get.find();

  /// App-lifetime persistence used for the last/best score strip.
  final StorageService storage = Get.find();

  /// The five categories rendered as Home entries, in enum order.
  List<Category> get categories => Category.values;

  /// `true` only when category data has finished loading successfully, so the
  /// exam can be started. Stays `false` while loading or on error. (Req 3.3,
  /// 4.4)
  bool get canStartExam => data.status.value == DataStatus.ready;

  /// The most recently persisted [ExamResult], or `null` when none exists so
  /// the Home score strip can be omitted. (Req 19.3, 19.4)
  ExamResult? get lastResult => storage.readLastResult();

  /// The best (highest) correct-answer count persisted so far; `0` if none.
  int get bestScore => storage.bestScore;

  /// Opens the Study screen for [c], passing the category as the route
  /// argument. (Req 4.3)
  void openStudy(Category c) => Get.toNamed(AppRoutes.study, arguments: c);

  /// Starts a fresh exam when data is ready, routing to the exam screen (the
  /// ExamController builds the session in its `onInit`). No-op while loading or
  /// on error. (Req 4.4)
  void startExam() {
    if (!canStartExam) return;
    Get.toNamed(AppRoutes.exam);
  }
}
