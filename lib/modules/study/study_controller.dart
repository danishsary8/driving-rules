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
import '../../core/services/storage_service.dart';
import '../../core/utils/app_haptics.dart';

/// Reactive state for the Study screen, scoped per route entry by
/// [StudyBinding].
class StudyController extends GetxController {
  /// App-lifetime data service providing the loaded, validated questions.
  final DataService data = Get.find();

  /// App-lifetime storage service for user preferences and bookmarks (optional in unit tests).
  StorageService? get _storage =>
      Get.isRegistered<StorageService>() ? Get.find<StorageService>() : null;

  /// The category being studied, taken from `Get.arguments`.
  ///
  /// Guards against a missing/invalid argument by defaulting to
  /// [Category.general].
  final _category = Category.general.obs;
  Category get category => _category.value;

  void changeCategory(Category value) {
    showOnlyBookmarks.value = false;
    _category.value = value;
    searchTerm.value = '';
  }

  /// Current search term; an empty/whitespace value means "no filter".
  final searchTerm = ''.obs;

  /// Reactive set of question IDs currently bookmarked by the user.
  final bookmarkedIds = <String>{}.obs;

  /// Whether the study view is filtered to show only bookmarked questions.
  final showOnlyBookmarks = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    _category.value = args is Category ? args : Category.general;
    refreshBookmarks();
  }

  /// Reloads bookmark IDs from storage into reactive state.
  void refreshBookmarks() {
    final s = _storage;
    if (s != null) {
      bookmarkedIds.assignAll(s.readBookmarkIds());
    }
  }

  /// Checks if [questionId] is currently bookmarked.
  bool isBookmarked(String questionId) => bookmarkedIds.contains(questionId);

  /// Toggles the bookmark status for [questionId] with tactile haptic feedback.
  Future<void> toggleBookmark(String questionId) async {
    final s = _storage;
    if (s != null) {
      final nowSaved = await s.toggleBookmark(questionId);
      if (nowSaved) {
        bookmarkedIds.add(questionId);
        AppHaptics.selection();
      } else {
        bookmarkedIds.remove(questionId);
        AppHaptics.light();
      }
    }
  }

  /// Toggles the "Bookmarked only" filter mode.
  void toggleBookmarkFilter() {
    showOnlyBookmarks.toggle();
    searchTerm.value = '';
    AppHaptics.selection();
  }

  /// All questions for the active view (either bookmarked across all categories
  /// or all questions in the active [category]).
  List<Question> get _all {
    if (showOnlyBookmarks.value) {
      return data.allQuestions
          .where((q) => bookmarkedIds.contains(q.id))
          .toList();
    }
    return data.questionsFor(category);
  }

  /// Total number of questions in this category or bookmark view. (Req 5.4)
  int get totalCount => _all.length;

  /// Total bookmarks saved across the entire app.
  int get totalBookmarksCount => bookmarkedIds.length;

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
