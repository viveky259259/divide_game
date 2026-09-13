import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:mumbai_train_quiz/data/models/game_session_model.dart';
import 'package:mumbai_train_quiz/data/models/product_model.dart';
import 'package:mumbai_train_quiz/data/models/question_model.dart';
import 'package:mumbai_train_quiz/data/models/user_model.dart';

/// Everything the game reads and writes lives here first. The app is fully
/// playable against this store with no network; [SyncService] pushes the
/// backlog up whenever a connection appears.
///
/// Records are stored as JSON strings rather than generated TypeAdapters so
/// the models stay plain Dart and can be sent to a server unchanged.
class HiveService {
  static const _users = 'users';
  static const _questions = 'questions';
  static const _products = 'products';
  static const _sessions = 'sessions';
  static const _purchases = 'purchases';
  static const _settings = 'settings';
  static const _syncQueue = 'sync_queue';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<String>(_users),
      Hive.openBox<String>(_questions),
      Hive.openBox<String>(_products),
      Hive.openBox<String>(_sessions),
      Hive.openBox<String>(_purchases),
      Hive.openBox<dynamic>(_settings),
      Hive.openBox<String>(_syncQueue),
    ]);
  }

  static List<T> _decodeAll<T>(
    String boxName,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return Hive.box<String>(boxName)
        .values
        .map((raw) => fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList();
  }

  // ── Users ──────────────────────────────────────────────────────────────

  static Future<void> saveUser(UserModel user) =>
      Hive.box<String>(_users).put(user.id, jsonEncode(user.toJson()));

  static UserModel? getUser(String id) {
    final raw = Hive.box<String>(_users).get(id);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static List<UserModel> allUsers() => _decodeAll(_users, UserModel.fromJson);

  static UserModel? findUserByEmail(String email) {
    final target = email.trim().toLowerCase();
    for (final user in allUsers()) {
      if (user.email.toLowerCase() == target) return user;
    }
    return null;
  }

  static UserModel? currentUser() {
    final id = Hive.box<dynamic>(_settings).get('currentUserId') as String?;
    return id == null ? null : getUser(id);
  }

  static Future<void> setCurrentUser(String? id) async {
    final box = Hive.box<dynamic>(_settings);
    if (id == null) {
      await box.delete('currentUserId');
    } else {
      await box.put('currentUserId', id);
    }
  }

  // ── Questions ──────────────────────────────────────────────────────────

  static Future<void> saveQuestion(QuestionModel q) =>
      Hive.box<String>(_questions).put(q.id, jsonEncode(q.toJson()));

  static Future<void> saveQuestions(List<QuestionModel> questions) {
    return Hive.box<String>(_questions).putAll({
      for (final q in questions) q.id: jsonEncode(q.toJson()),
    });
  }

  static List<QuestionModel> allQuestions() =>
      _decodeAll(_questions, QuestionModel.fromJson);

  static List<QuestionModel> approvedForLevel(int level) => allQuestions()
      .where((q) => q.level == level && q.status == QuestionStatus.approved)
      .toList();

  static List<QuestionModel> pendingQuestions() => allQuestions()
      .where((q) => q.status == QuestionStatus.pending)
      .toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  static List<QuestionModel> questionsByContributor(String contributorId) =>
      allQuestions()
          .where((q) => q.contributorId == contributorId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // ── Products ───────────────────────────────────────────────────────────

  static Future<void> saveProduct(ProductModel p) =>
      Hive.box<String>(_products).put(p.id, jsonEncode(p.toJson()));

  static Future<void> saveProducts(List<ProductModel> products) {
    return Hive.box<String>(_products).putAll({
      for (final p in products) p.id: jsonEncode(p.toJson()),
    });
  }

  static List<ProductModel> allProducts() =>
      _decodeAll(_products, ProductModel.fromJson);

  static List<ProductModel> availableProducts() => allProducts()
      .where((p) => p.isActive && p.stock > 0)
      .toList()
    ..sort((a, b) => a.priceInPoints.compareTo(b.priceInPoints));

  static ProductModel? getProduct(String id) {
    final raw = Hive.box<String>(_products).get(id);
    if (raw == null) return null;
    return ProductModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  // ── Purchases ──────────────────────────────────────────────────────────

  static Future<void> savePurchase(PurchaseModel p) =>
      Hive.box<String>(_purchases).put(p.id, jsonEncode(p.toJson()));

  static List<PurchaseModel> purchasesFor(String userId) =>
      _decodeAll(_purchases, PurchaseModel.fromJson)
          .where((p) => p.userId == userId)
          .toList()
        ..sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));

  // ── Sessions ───────────────────────────────────────────────────────────

  static Future<void> saveSession(GameSessionModel s) =>
      Hive.box<String>(_sessions).put(s.id, jsonEncode(s.toJson()));

  static List<GameSessionModel> sessionsFor(String userId) =>
      _decodeAll(_sessions, GameSessionModel.fromJson)
          .where((s) => s.userId == userId)
          .toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  /// Best score the player has recorded at a level, or null if never played.
  static int? bestScoreForLevel(String userId, int level) {
    final scores = sessionsFor(userId)
        .where((s) => s.level == level)
        .map((s) => s.score);
    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a > b ? a : b);
  }

  // ── Sync queue ─────────────────────────────────────────────────────────

  static Future<void> enqueueSync(String type, Map<String, dynamic> payload) {
    final box = Hive.box<String>(_syncQueue);
    // Microsecond key keeps insertion order stable within a single run.
    final key = '${DateTime.now().microsecondsSinceEpoch}_$type';
    return box.put(key, jsonEncode({'type': type, 'payload': payload}));
  }

  static Map<String, Map<String, dynamic>> syncQueue() {
    final box = Hive.box<String>(_syncQueue);
    return {
      for (final key in box.keys)
        key as String:
            jsonDecode(box.get(key)!) as Map<String, dynamic>,
    };
  }

  static int pendingSyncCount() => Hive.box<String>(_syncQueue).length;

  static Future<void> removeFromSyncQueue(Iterable<String> keys) =>
      Hive.box<String>(_syncQueue).deleteAll(keys);

  // ── Settings ───────────────────────────────────────────────────────────

  static Future<void> setSetting(String key, dynamic value) =>
      Hive.box<dynamic>(_settings).put(key, value);

  static T? getSetting<T>(String key) =>
      Hive.box<dynamic>(_settings).get(key) as T?;

  static bool get isSeeded => getSetting<bool>('seeded') ?? false;

  static Future<void> markSeeded() => setSetting('seeded', true);
}
