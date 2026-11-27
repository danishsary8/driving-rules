// Each data file numbers its questions from 1, so raw ids repeat across
// categories. Bookmarks, mistakes and saved exam sessions store question ids,
// so ids must be unique app-wide or they point at the wrong question.
import 'package:driving_rule/core/models/question_model.dart';
import 'package:driving_rule/core/services/data_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every bundled question has a unique id that finds itself', () async {
    final data = DataService();
    await data.ensureLoaded();
    final all = data.allQuestions;

    expect(all, hasLength(249));
    expect(all.map((q) => q.id).toSet(), hasLength(all.length));
    for (final q in all) {
      expect(identical(data.findQuestionById(q.id), q), isTrue, reason: q.id);
    }
  });

  test('the same raw number in two categories gives two ids', () {
    expect(
      Question.qualifiedId(Category.general, '1'),
      isNot(Question.qualifiedId(Category.sign, '1')),
    );
    expect(Question.qualifiedId(Category.sign, '12'), 'sign-12');
  });
}
