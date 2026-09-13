enum QuestionStatus { pending, approved, rejected }

enum QuestionDifficulty { easy, medium, hard }

class QuestionModel {
  final String id;

  /// 1-20, matching the station/level it belongs to.
  final int level;
  final String stationName;
  final String questionText;

  /// Always four entries.
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;
  final QuestionDifficulty difficulty;
  final QuestionStatus status;
  final String contributorId;
  final String? contributorName;
  final DateTime createdAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  /// True for questions shipped with the app, so they can be told apart from
  /// community submissions.
  final bool isSeed;

  /// False until the record has been pushed to the server.
  final bool synced;

  QuestionModel({
    required this.id,
    required this.level,
    required this.stationName,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
    this.difficulty = QuestionDifficulty.medium,
    this.status = QuestionStatus.pending,
    this.contributorId = 'system',
    this.contributorName,
    DateTime? createdAt,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
    this.isSeed = false,
    this.synced = false,
  }) : createdAt = createdAt ?? DateTime.now();

  QuestionModel copyWith({
    QuestionStatus? status,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? rejectionReason,
    bool? synced,
  }) {
    return QuestionModel(
      id: id,
      level: level,
      stationName: stationName,
      questionText: questionText,
      options: options,
      correctOptionIndex: correctOptionIndex,
      explanation: explanation,
      difficulty: difficulty,
      status: status ?? this.status,
      contributorId: contributorId,
      contributorName: contributorName,
      createdAt: createdAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      isSeed: isSeed,
      synced: synced ?? this.synced,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'level': level,
        'stationName': stationName,
        'questionText': questionText,
        'options': options,
        'correctOptionIndex': correctOptionIndex,
        'explanation': explanation,
        'difficulty': difficulty.name,
        'status': status.name,
        'contributorId': contributorId,
        'contributorName': contributorName,
        'createdAt': createdAt.toIso8601String(),
        'reviewedBy': reviewedBy,
        'reviewedAt': reviewedAt?.toIso8601String(),
        'rejectionReason': rejectionReason,
        'isSeed': isSeed,
        'synced': synced,
      };

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        id: json['id'] as String,
        level: json['level'] as int,
        stationName: json['stationName'] as String,
        questionText: json['questionText'] as String,
        options: (json['options'] as List).map((e) => e as String).toList(),
        correctOptionIndex: json['correctOptionIndex'] as int,
        explanation: json['explanation'] as String?,
        difficulty: QuestionDifficulty.values.firstWhere(
          (e) => e.name == json['difficulty'],
          orElse: () => QuestionDifficulty.medium,
        ),
        status: QuestionStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => QuestionStatus.pending,
        ),
        contributorId: json['contributorId'] as String? ?? 'system',
        contributorName: json['contributorName'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        reviewedBy: json['reviewedBy'] as String?,
        reviewedAt: json['reviewedAt'] != null
            ? DateTime.parse(json['reviewedAt'] as String)
            : null,
        rejectionReason: json['rejectionReason'] as String?,
        isSeed: json['isSeed'] as bool? ?? false,
        synced: json['synced'] as bool? ?? false,
      );
}
