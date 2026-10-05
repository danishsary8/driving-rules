/// Controller for the single, reusable Study screen.
///
/// [StudyController] holds the active [Category] (passed via `Get.arguments`
/// from Home), the full question list for that category, a reactive search
/// term, and a computed, filtered view of the questions. Image-category
/// search matches only visible learning content: the question text and correct
/// answer. Image filenames and incorrect exam options are excluded.
library;

import 'package:get/get.dart';

import '../../core/models/question_model.dart';
import '../../core/services/data_service.dart';

/// Reactive state for the Study screen, scoped per route entry by
/// [StudyBinding].
class StudyController extends GetxController {
  /// App-lifetime data service providing the loaded, validated questions.
  final DataService data = Get.find();

  /// The category being studied, taken from `Get.arguments`.
  ///
  /// Guards against a missing/invalid argument by defaulting to
  /// [Category.general].
  final _category = Category.general.obs;
  Category get category => _category.value;

  void changeCategory(Category value) {
    _category.value = value;
    searchTerm.value = '';
  }

  /// Current search term; an empty/whitespace value means "no filter".
  final searchTerm = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    _category.value = args is Category ? args : Category.general;
  }

  /// All questions for the active [category] (read-only, may be empty).
  List<Question> get _all => data.questionsFor(category);

  /// Total number of questions in this category. (Req 5.4)
  int get totalCount => _all.length;

  /// Questions matching the current [searchTerm].
  ///
  /// An empty term returns the full list; otherwise only visible text matches.
  List<Question> get filtered {
    final t = searchTerm.value.trim().toLowerCase();
    if (t.isEmpty) return _all;
    return _all.where((q) {
      return q.correctAnswer.toLowerCase().contains(t) ||
          (!q.isImagePrompt && q.prompt.toLowerCase().contains(t));
    }).toList();
  }

  /// Whether the current filter yields at least one result. (Req 7.4)
  bool get hasResults => filtered.isNotEmpty;

  /// Updates the reactive search term, re-driving [filtered]. (Req 7.1)
  void setSearch(String term) => searchTerm.value = term;
}
