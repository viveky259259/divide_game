enum UserRole { player, contributor, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final int totalPoints;
  final int lifetimePoints;
  final int currentLevel;
  final int questionsContributed;
  final int questionsApproved;
  final List<int> completedLevels;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.player,
    this.totalPoints = 0,
    this.lifetimePoints = 0,
    this.currentLevel = 1,
    this.questionsContributed = 0,
    this.questionsApproved = 0,
    this.completedLevels = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  UserModel copyWith({
    String? name,
    UserRole? role,
    int? totalPoints,
    int? lifetimePoints,
    int? currentLevel,
    int? questionsContributed,
    int? questionsApproved,
    List<int>? completedLevels,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      role: role ?? this.role,
      totalPoints: totalPoints ?? this.totalPoints,
      lifetimePoints: lifetimePoints ?? this.lifetimePoints,
      currentLevel: currentLevel ?? this.currentLevel,
      questionsContributed: questionsContributed ?? this.questionsContributed,
      questionsApproved: questionsApproved ?? this.questionsApproved,
      completedLevels: completedLevels ?? this.completedLevels,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'totalPoints': totalPoints,
        'lifetimePoints': lifetimePoints,
        'currentLevel': currentLevel,
        'questionsContributed': questionsContributed,
        'questionsApproved': questionsApproved,
        'completedLevels': completedLevels,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: UserRole.values.firstWhere(
          (e) => e.name == json['role'],
          orElse: () => UserRole.player,
        ),
        totalPoints: json['totalPoints'] as int? ?? 0,
        lifetimePoints: json['lifetimePoints'] as int? ?? 0,
        currentLevel: json['currentLevel'] as int? ?? 1,
        questionsContributed: json['questionsContributed'] as int? ?? 0,
        questionsApproved: json['questionsApproved'] as int? ?? 0,
        completedLevels:
            (json['completedLevels'] as List?)?.map((e) => e as int).toList() ??
                const [],
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
