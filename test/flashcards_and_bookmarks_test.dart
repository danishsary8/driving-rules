import 'package:driving_rule/core/models/question_model.dart';
import 'package:driving_rule/core/services/data_service.dart';
import 'package:driving_rule/core/services/storage_service.dart';
import 'package:driving_rule/modules/flashcards/flashcards_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _MockDataService extends DataService {
  @override
  List<Question> questionsFor(Category category) {
    if (category == Category.sign) {
      return List.generate(
        5,
        (i) => Question(
          id: 'sign_$i',
          prompt: 'sign_$i.png',
          options: ['Wrong 1', 'Wrong 2', 'Correct sign $i'],
          correctIndex: 2,
          category: Category.sign,
        ),
      );
    }
    return const [];
  }
}

class FakeStorageService extends StorageService {
  final Set<String> _bookmarks = <String>{};

  @override
  Set<String> readBookmarkIds() => Set.from(_bookmarks);

  @override
  bool isBookmarked(String id) => _bookmarks.contains(id);

  @override
  Future<bool> toggleBookmark(String id) async {
    if (_bookmarks.contains(id)) {
      _bookmarks.remove(id);
      return false;
    } else {
      _bookmarks.add(id);
      return true;
    }
  }

  @override
  Future<void> clearAllBookmarks() async {
    _bookmarks.clear();
  }

  @override
  int get bookmarkCount => _bookmarks.length;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bookmarks operations in StorageService', () {
    late FakeStorageService storage;

    setUp(() {
      storage = FakeStorageService();
    });

    test('Toggles bookmark on and off correctly', () async {
      expect(storage.isBookmarked('q1'), isFalse);
      expect(storage.bookmarkCount, 0);

      final added = await storage.toggleBookmark('q1');
      expect(added, isTrue);
      expect(storage.isBookmarked('q1'), isTrue);
      expect(storage.bookmarkCount, 1);
      expect(storage.readBookmarkIds(), contains('q1'));

      final removed = await storage.toggleBookmark('q1');
      expect(removed, isFalse);
      expect(storage.isBookmarked('q1'), isFalse);
      expect(storage.bookmarkCount, 0);
    });

    test('Clears all bookmarks', () async {
      await storage.toggleBookmark('q1');
      await storage.toggleBookmark('q2');
      expect(storage.bookmarkCount, 2);

      await storage.clearAllBookmarks();
      expect(storage.bookmarkCount, 0);
    });
  });

  group('FlashcardsController mechanics', () {
    late FlashcardsController controller;
    late FakeStorageService storage;

    setUp(() {
      Get.testMode = true;
      storage = FakeStorageService();
      Get.put<DataService>(_MockDataService());
      Get.put<StorageService>(storage);
      controller = Get.put(FlashcardsController());
    });

    tearDown(Get.reset);

    test('Initializes with loaded signs and un-flipped state', () {
      expect(controller.totalCount, 5);
      expect(controller.currentIndex.value, 0);
      expect(controller.isFlipped.value, isFalse);
      expect(controller.currentQuestion?.id, 'sign_0');
      expect(controller.progress, closeTo(1 / 5, 0.01));
    });

    test('Toggles card flip', () {
      expect(controller.isFlipped.value, isFalse);
      controller.flip();
      expect(controller.isFlipped.value, isTrue);
      controller.flip();
      expect(controller.isFlipped.value, isFalse);
    });

    test('Advances cards and marks mastery vs review', () {
      expect(controller.currentIndex.value, 0);
      controller.markMastered();
      expect(controller.masteredIds, contains('sign_0'));
      expect(controller.currentIndex.value, 1);

      controller.markReview();
      expect(controller.reviewIds, contains('sign_1'));
      expect(controller.currentIndex.value, 2);

      controller.prevCard();
      expect(controller.currentIndex.value, 1);
    });

    test('Resets deck back to beginning', () {
      controller.markMastered();
      controller.markReview();
      expect(controller.currentIndex.value, 2);

      controller.resetDeck();
      expect(controller.currentIndex.value, 0);
      expect(controller.masteredIds, isEmpty);
      expect(controller.reviewIds, isEmpty);
    });

    test('Toggles bookmark directly from flashcard', () async {
      expect(controller.isCurrentBookmarked, isFalse);
      await controller.toggleCurrentBookmark();
      expect(controller.isCurrentBookmarked, isTrue);
      expect(storage.isBookmarked('sign_0'), isTrue);
    });
  });
}
