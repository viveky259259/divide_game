import 'package:flutter_test/flutter_test.dart';

import 'package:mumbai_train_quiz/data/models/question_model.dart';
import 'package:mumbai_train_quiz/data/seed/seed_data.dart';
import 'package:mumbai_train_quiz/utils/constants.dart';

void main() {
  final questions = SeedData.questions();

  test('every station has enough approved questions to draw from', () {
    for (var level = 1; level <= AppConstants.totalLevels; level++) {
      final pool = questions.where((q) => q.level == level).toList();
      expect(pool.length, greaterThanOrEqualTo(AppConstants.questionsPerLevel),
          reason: 'level $level');
    }
  });

  test('seed questions are well formed and already approved', () {
    for (final q in questions) {
      expect(q.options.length, 4, reason: q.id);
      expect(q.correctOptionIndex, inInclusiveRange(0, 3), reason: q.id);
      expect(q.options.toSet().length, 4, reason: '${q.id} repeats an option');
      expect(q.status, QuestionStatus.approved);
    }
  });

  test('the line runs Virar to Churchgate across twenty stations', () {
    expect(Stations.all.length, AppConstants.totalLevels);
    expect(Stations.all.first.name, 'Virar');
    expect(Stations.all.last.name, 'Churchgate');
  });
}
