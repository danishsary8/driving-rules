import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import '../../core/models/question_model.dart';
import '../../core/services/data_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/app_haptics.dart';

/// Game state controller for the interactive Speed Quiz Practice mode.
class QuizPracticeController extends GetxController {
  final DataService dataService = Get.find();
  final StorageService storageService = Get.find();

  /// 15 seconds per question for the speed challenge.
  static const double kQuestionDuration = 15.0;

  /// Total questions per round.
  static const int kQuestionsPerRound = 10;

  /// Maximum hearts/lives.
  static const int kMaxHearts = 3;

  /// Filtered questions for this round.
  final questions = <Question>[].obs;

  /// Current question index (0..questions.length - 1).
  final currentIndex = 0.obs;

  /// Remaining lives/hearts.
  final hearts = kMaxHearts.obs;

  /// Total game score accumulated with speed bonuses.
  final score = 0.obs;

  /// Current consecutive correct streak.
  final streak = 0.obs;

  /// Highest streak achieved during this session.
  final bestStreak = 0.obs;

  /// Remaining seconds on the current question timer.
  final secondsLeft = kQuestionDuration.obs;

  /// Currently selected option index, or null if unanswered.
  final selectedOption = Rxn<int>();

  /// Whether the user has submitted/tapped an answer for the current question.
  final isAnswerChecked = false.obs;

  /// Whether the user's answer was correct.
  final isCorrect = false.obs;

  /// Game over flag when lives hit zero.
  final isGameOver = false.obs;

  /// Game won flag when round is completed.
  final isGameWon = false.obs;

  /// Bonus points awarded for the latest answer.
  final latestBonus = 0.obs;

  /// Active category filter, or null for all categories.
  Category? filterCategory;
  List<Question>? _customPool;

  Timer? _ticker;

  Question get currentQuestion => questions[currentIndex.value];

  bool get hasImage => currentQuestion.isImagePrompt;

  double get timerProgress => (secondsLeft.value / kQuestionDuration).clamp(0.0, 1.0);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is List<Question>) {
      _customPool = args;
    } else if (args is Category) {
      filterCategory = args;
    }
    _setupRound();
  }

  void _setupRound() {
    final pool = _customPool != null && _customPool!.isNotEmpty
        ? _customPool!
        : (filterCategory != null
            ? dataService.questionsFor(filterCategory!)
            : dataService.all.values.expand((list) => list).toList());

    if (pool.isEmpty) return;

    final shuffled = List<Question>.from(pool)..shuffle(Random());
    questions.value = shuffled.take(kQuestionsPerRound).toList();

    currentIndex.value = 0;
    hearts.value = kMaxHearts;
    score.value = 0;
    streak.value = 0;
    bestStreak.value = 0;
    isGameOver.value = false;
    isGameWon.value = false;

    _resetQuestionState();
    _startTimer();
  }

  void _resetQuestionState() {
    selectedOption.value = null;
    isAnswerChecked.value = false;
    isCorrect.value = false;
    latestBonus.value = 0;
    secondsLeft.value = kQuestionDuration;
  }

  void _startTimer() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (secondsLeft.value <= 0.1) {
        timer.cancel();
        _onTimeExpired();
      } else {
        secondsLeft.value -= 0.1;
      }
    });
  }

  void _onTimeExpired() {
    if (isAnswerChecked.value) return;

    AppHaptics.error();
    storageService.addMistakeId(currentQuestion.id);
    isAnswerChecked.value = true;
    isCorrect.value = false;
    streak.value = 0;
    latestBonus.value = 0;

    hearts.value = max(0, hearts.value - 1);
    if (hearts.value <= 0) {
      isGameOver.value = true;
    }
  }

  /// Called when the player taps an answer option.
  void submitAnswer(int optionIndex) {
    if (isAnswerChecked.value || isGameOver.value || isGameWon.value) return;

    _ticker?.cancel();
    selectedOption.value = optionIndex;
    isAnswerChecked.value = true;

    final correct = optionIndex == currentQuestion.correctIndex;
    isCorrect.value = correct;

    if (correct) {
      streak.value++;
      if (streak.value > bestStreak.value) {
        bestStreak.value = streak.value;
      }

      if (streak.value >= 3) {
        AppHaptics.warning();
      } else {
        AppHaptics.success();
      }

      // Base 100 XP + up to 150 speed bonus + streak multiplier
      final speedMultiplier = (secondsLeft.value * 10).round();
      final streakMultiplier = streak.value > 1 ? (streak.value * 25) : 0;
      final bonus = 100 + speedMultiplier + streakMultiplier;

      latestBonus.value = bonus;
      score.value += bonus;
    } else {
      AppHaptics.error();
      storageService.addMistakeId(currentQuestion.id);
      streak.value = 0;
      latestBonus.value = 0;
      hearts.value = max(0, hearts.value - 1);

      if (hearts.value <= 0) {
        isGameOver.value = true;
      }
    }
  }

  /// Advance to the next question or complete the round.
  void nextQuestion() {
    if (isGameOver.value) return;
    AppHaptics.light();

    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;
      _resetQuestionState();
      _startTimer();
    } else {
      isGameWon.value = true;
      AppHaptics.success();
    }
  }

  /// Restart a brand new round.
  void restart() {
    AppHaptics.light();
    _setupRound();
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }
}
