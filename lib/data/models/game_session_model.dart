/// One attempt at one level.
class GameSessionModel {
  final String id;
  final String userId;
  final int level;
  final int score;
  final int totalCorrect;
  final int totalWrong;
  final List<AnswerRecord> answers;
  final bool clearedLevel;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final bool synced;

  GameSessionModel({
    required this.id,
    required this.userId,
    required this.level,
    this.score = 0,
    this.totalCorrect = 0,
    this.totalWrong = 0,
    this.answers = const [],
    this.clearedLevel = false,
    DateTime? startedAt,
    this.finishedAt,
    this.synced = false,
  }) : startedAt = startedAt ?? DateTime.now();

  GameSessionModel copyWith({
    int? score,
    int? totalCorrect,
    int? totalWrong,
    List<AnswerRecord>? answers,
    bool? clearedLevel,
    DateTime? finishedAt,
    bool? synced,
  }) {
    return GameSessionModel(
      id: id,
      userId: userId,
      level: level,
      score: score ?? this.score,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalWrong: totalWrong ?? this.totalWrong,
      answers: answers ?? this.answers,
      clearedLevel: clearedLevel ?? this.clearedLevel,
      startedAt: startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      synced: synced ?? this.synced,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'level': level,
        'score': score,
        'totalCorrect': totalCorrect,
        'totalWrong': totalWrong,
        'answers': answers.map((a) => a.toJson()).toList(),
        'clearedLevel': clearedLevel,
        'startedAt': startedAt.toIso8601String(),
        'finishedAt': finishedAt?.toIso8601String(),
        'synced': synced,
      };

  factory GameSessionModel.fromJson(Map<String, dynamic> json) =>
      GameSessionModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        level: json['level'] as int,
        score: json['score'] as int? ?? 0,
        totalCorrect: json['totalCorrect'] as int? ?? 0,
        totalWrong: json['totalWrong'] as int? ?? 0,
        answers: (json['answers'] as List?)
                ?.map((a) => AnswerRecord.fromJson(a as Map<String, dynamic>))
                .toList() ??
            const [],
        clearedLevel: json['clearedLevel'] as bool? ?? false,
        startedAt: DateTime.parse(json['startedAt'] as String),
        finishedAt: json['finishedAt'] != null
            ? DateTime.parse(json['finishedAt'] as String)
            : null,
        synced: json['synced'] as bool? ?? false,
      );
}

/// How a single question went. [selectedOption] is -1 when the timer ran out
/// and -2 when the player used the skip lifeline.
class AnswerRecord {
  final String questionId;
  final int selectedOption;
  final bool isCorrect;
  final int secondsTaken;
  final int pointsEarned;

  const AnswerRecord({
    required this.questionId,
    required this.selectedOption,
    required this.isCorrect,
    required this.secondsTaken,
    required this.pointsEarned,
  });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'selectedOption': selectedOption,
        'isCorrect': isCorrect,
        'secondsTaken': secondsTaken,
        'pointsEarned': pointsEarned,
      };

  factory AnswerRecord.fromJson(Map<String, dynamic> json) => AnswerRecord(
        questionId: json['questionId'] as String,
        selectedOption: json['selectedOption'] as int,
        isCorrect: json['isCorrect'] as bool,
        secondsTaken: json['secondsTaken'] as int,
        pointsEarned: json['pointsEarned'] as int,
      );
}
