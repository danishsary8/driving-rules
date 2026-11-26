import 'package:get/get.dart';

import '../../core/models/question_model.dart';
import '../../core/models/sign_category.dart';
import '../../core/services/data_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/app_haptics.dart';

/// Reactive state for the Road Signs Flashcards interactive study mode.
class FlashcardsController extends GetxController {
  final DataService data = Get.find();
  final StorageService storage = Get.find();

  /// All sign questions bundled in the app.
  final allSignQuestions = <Question>[];

  /// Filtered questions based on the active sign category.
  final questions = <Question>[].obs;

  /// Active sign sub-category filter.
  final selectedType = SignType.all.obs;

  /// Current zero-based index of the active card.
  final currentIndex = 0.obs;

  /// Whether the active card is currently flipped showing the answer side.
  final isFlipped = false.obs;

  /// Set of question IDs marked as "Mastered" (I know this) during this session.
  final masteredIds = <String>{}.obs;

  /// Set of question IDs marked as "Needs Review" (Still confused) during this session.
  final reviewIds = <String>{}.obs;

  /// Reactive set of bookmarked question IDs.
  final bookmarkedIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    bookmarkedIds.assignAll(storage.readBookmarkIds());
    if (data.status.value == DataStatus.ready) {
      _loadDeck();
    } else {
      // Opened directly by URL before the startup load finished.
      _loadDeckWhenReady();
    }
  }

  Future<void> _loadDeckWhenReady() async {
    await data.ensureLoaded();
    if (!isClosed) _loadDeck();
  }

  void _loadDeck() {
    final signs = data.questionsFor(Category.sign);
    allSignQuestions.assignAll(signs);
    questions.assignAll(signs);
  }

  /// Filters flashcards by road sign sub-type.
  void filterByType(SignType type) {
    selectedType.value = type;
    isFlipped.value = false;
    currentIndex.value = 0;
    if (type == SignType.all) {
      questions.assignAll(allSignQuestions);
    } else {
      questions.assignAll(
        allSignQuestions.where((q) => SignTypeMeta.classify(q) == type),
      );
    }
    AppHaptics.selection();
  }

  /// The active [Question], or `null` if questions are empty.
  Question? get currentQuestion {
    if (questions.isEmpty || currentIndex.value >= questions.length) {
      return null;
    }
    return questions[currentIndex.value];
  }

  /// Fractional progress through the card deck (0.0 to 1.0).
  double get progress {
    if (questions.isEmpty) return 0.0;
    return (currentIndex.value + 1) / questions.length;
  }

  /// Total count of flashcards.
  int get totalCount => questions.length;

  /// Whether the user has reached the end of the flashcard deck.
  bool get isCompleted =>
      questions.isNotEmpty && currentIndex.value >= questions.length - 1;

  /// Toggles card flip between artwork front and explanation back.
  void flip() {
    isFlipped.toggle();
    AppHaptics.light();
  }

  /// Advances to the next card.
  void nextCard() {
    if (currentIndex.value < questions.length - 1) {
      isFlipped.value = false;
      currentIndex.value++;
      AppHaptics.selection();
    }
  }

  /// Moves back to the previous card.
  void prevCard() {
    if (currentIndex.value > 0) {
      isFlipped.value = false;
      currentIndex.value--;
      AppHaptics.light();
    }
  }

  /// Marks the current sign as mastered and advances.
  void markMastered() {
    final q = currentQuestion;
    if (q == null) return;
    masteredIds.add(q.id);
    reviewIds.remove(q.id);
    AppHaptics.success();
    if (!isCompleted) {
      nextCard();
    }
  }

  /// Marks the current sign as needing more review and advances.
  void markReview() {
    final q = currentQuestion;
    if (q == null) return;
    reviewIds.add(q.id);
    masteredIds.remove(q.id);
    AppHaptics.light();
    if (!isCompleted) {
      nextCard();
    }
  }

  /// Shuffles the questions deck into a fresh random order.
  void shuffleCards() {
    isFlipped.value = false;
    currentIndex.value = 0;
    final copy = List<Question>.from(questions)..shuffle();
    questions.assignAll(copy);
    AppHaptics.selection();
  }

  /// Restarts the deck from the beginning.
  void resetDeck() {
    isFlipped.value = false;
    currentIndex.value = 0;
    masteredIds.clear();
    reviewIds.clear();
    AppHaptics.selection();
  }

  /// Checks if current question is bookmarked.
  bool get isCurrentBookmarked {
    final q = currentQuestion;
    if (q == null) return false;
    return bookmarkedIds.contains(q.id);
  }

  /// Toggles bookmark on current card.
  Future<void> toggleCurrentBookmark() async {
    final q = currentQuestion;
    if (q == null) return;
    final nowSaved = await storage.toggleBookmark(q.id);
    if (nowSaved) {
      bookmarkedIds.add(q.id);
      AppHaptics.selection();
    } else {
      bookmarkedIds.remove(q.id);
      AppHaptics.light();
    }
  }
}
