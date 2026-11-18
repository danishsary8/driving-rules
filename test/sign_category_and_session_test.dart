import 'package:flutter_test/flutter_test.dart';
import 'package:driving_rule/core/models/question_model.dart';
import 'package:driving_rule/core/models/sign_category.dart';
import 'package:driving_rule/core/services/storage_service.dart';

class _InMemoryStorageService extends StorageService {
  final Map<String, dynamic> _store = {};

  @override
  bool get hasOngoingExam => _store.containsKey('ongoing_exam_session');

  @override
  Map<String, dynamic>? readOngoingExam() {
    final raw = _store['ongoing_exam_session'];
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  @override
  Future<void> saveOngoingExam({
    required List<String> questionIds,
    required int currentIndex,
    required int remainingSeconds,
    required Map<int, int> selectedAnswers,
  }) async {
    _store['ongoing_exam_session'] = {
      'questionIds': questionIds,
      'currentIndex': currentIndex,
      'remainingSeconds': remainingSeconds,
      'selectedAnswers': selectedAnswers.map((k, v) => MapEntry(k.toString(), v)),
      'savedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  @override
  Future<void> clearOngoingExam() async {
    _store.remove('ongoing_exam_session');
  }
}

void main() {
  group('SignTypeMeta Classification Tests', () {
    test('Correctly classifies Prohibitory signs (ហាមឃាត់ / ban / no)', () {
      const q1 = Question(
        id: '1',
        category: Category.sign,
        prompt: 'sign_ban_left.png',
        options: ['ហាមបត់ឆ្វេង', 'អនុញ្ញាតបត់ឆ្វេង', 'បត់ស្តាំ'],
        correctIndex: 0,
      );
      expect(SignTypeMeta.classify(q1), equals(SignType.prohibitory));

      const q2 = Question(
        id: '2',
        category: Category.sign,
        prompt: 'sign_no_entry.png',
        options: ['មិនអនុញ្ញាតឱ្យចូល', 'អនុញ្ញាតឱ្យចូល', 'ផ្លូវវាង'],
        correctIndex: 0,
      );
      expect(SignTypeMeta.classify(q2), equals(SignType.prohibitory));
    });

    test('Correctly classifies Danger / Warning signs (គ្រោះថ្នាក់ / warning / danger)', () {
      const q = Question(
        id: '10',
        category: Category.sign,
        prompt: 'danger_curve.png',
        options: ['ផ្លូវកោងគ្រោះថ្នាក់', 'ផ្លូវត្រង់', 'ផ្លូវប្រសព្វ'],
        correctIndex: 0,
      );
      expect(SignTypeMeta.classify(q), equals(SignType.danger));
    });

    test('Correctly classifies Mandatory signs (បញ្ជា / ត្រូវតែ / mandatory)', () {
      const q = Question(
        id: '20',
        category: Category.sign,
        prompt: 'mandatory_right.png',
        options: ['ត្រូវតែបត់ស្តាំ', 'ហាមបត់ស្តាំ', 'ចតនៅទីនេះ'],
        correctIndex: 0,
      );
      expect(SignTypeMeta.classify(q), equals(SignType.mandatory));
    });

    test('Defaults to Informative signs when general or informative', () {
      const q = Question(
        id: '30',
        category: Category.sign,
        prompt: 'parking.png',
        options: ['កន្លែងចតរថយន្ត', 'ស្ថានីយប្រេង', 'មន្ទីរពេទ្យ'],
        correctIndex: 0,
      );
      expect(SignTypeMeta.classify(q), equals(SignType.informative));
    });
  });

  group('Ongoing Exam Session Lifecycle', () {
    test('Saves, checks presence, retrieves, and clears ongoing exam', () async {
      final storage = _InMemoryStorageService();

      expect(storage.hasOngoingExam, isFalse);
      expect(storage.readOngoingExam(), isNull);

      await storage.saveOngoingExam(
        questionIds: ['1', '5', '12', '45'],
        currentIndex: 2,
        remainingSeconds: 2150,
        selectedAnswers: {0: 1, 1: 2},
      );

      expect(storage.hasOngoingExam, isTrue);
      final restored = storage.readOngoingExam();
      expect(restored, isNotNull);
      expect(restored!['currentIndex'], equals(2));
      expect(restored['remainingSeconds'], equals(2150));
      expect(restored['questionIds'], equals(['1', '5', '12', '45']));

      await storage.clearOngoingExam();
      expect(storage.hasOngoingExam, isFalse);
      expect(storage.readOngoingExam(), isNull);
    });
  });
}
