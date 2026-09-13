/// The 20 Western Line stations that make up the game's levels,
/// ordered the way the train runs: Virar (level 1) to Churchgate (level 20).
class Stations {
  static const List<StationInfo> all = [
    StationInfo(level: 1, name: 'Virar', code: 'VR', landmark: 'Creek, salt pans and the last of the open sky'),
    StationInfo(level: 2, name: 'Nallasopara', code: 'NSP', landmark: 'Crowded platforms and roadside markets'),
    StationInfo(level: 3, name: 'Vasai Road', code: 'BSR', landmark: 'Vasai Fort and the long creek bridge'),
    StationInfo(level: 4, name: 'Naigaon', code: 'NIG', landmark: 'Farmland, wetlands and flamingo season'),
    StationInfo(level: 5, name: 'Bhayandar', code: 'BYR', landmark: 'Salt pans and the Bhayandar creek'),
    StationInfo(level: 6, name: 'Mira Road', code: 'MIRA', landmark: 'New towers rising over open plots'),
    StationInfo(level: 7, name: 'Dahisar', code: 'DIC', landmark: 'The check naka and Dahisar river'),
    StationInfo(level: 8, name: 'Borivali', code: 'BO', landmark: 'Gateway to Sanjay Gandhi National Park'),
    StationInfo(level: 9, name: 'Kandivali', code: 'KILE', landmark: 'Charkop, Thakur village and the Poisar river'),
    StationInfo(level: 10, name: 'Malad', code: 'MDD', landmark: 'Mindspace, Inorbit and the Malad creek'),
    StationInfo(level: 11, name: 'Goregaon', code: 'GMN', landmark: 'Film City and Aarey Colony'),
    StationInfo(level: 12, name: 'Andheri', code: 'ADH', landmark: 'Metro overhead, the busiest junction on the line'),
    StationInfo(level: 13, name: 'Vile Parle', code: 'VLP', landmark: 'Aircraft on approach and the old Parle factory'),
    StationInfo(level: 14, name: 'Bandra', code: 'BA', landmark: 'The heritage station, Bandstand and the Sea Link'),
    StationInfo(level: 15, name: 'Dadar', code: 'DDR', landmark: 'Flower market, Shivaji Park and the big interchange'),
    StationInfo(level: 16, name: 'Lower Parel', code: 'PL', landmark: 'Old mill chimneys under new glass towers'),
    StationInfo(level: 17, name: 'Mahalaxmi', code: 'MX', landmark: 'Dhobi Ghat and the racecourse'),
    StationInfo(level: 18, name: 'Mumbai Central', code: 'BCT', landmark: 'The terminus and its long-distance platforms'),
    StationInfo(level: 19, name: 'Marine Lines', code: 'MEL', landmark: 'Wankhede, Marine Drive and the maidans'),
    StationInfo(level: 20, name: 'Churchgate', code: 'CCG', landmark: 'End of the line, Flora Fountain and Oval Maidan'),
  ];

  static StationInfo byLevel(int level) => all[level - 1];

  static String nameFor(int level) =>
      (level >= 1 && level <= all.length) ? all[level - 1].name : 'Virar';
}

class StationInfo {
  final int level;
  final String name;
  final String code;
  final String landmark;

  const StationInfo({
    required this.level,
    required this.name,
    required this.code,
    required this.landmark,
  });
}

class AppConstants {
  static const String appName = 'Mumbai Train Quiz';
  static const int totalLevels = 20;

  /// Questions drawn per level. If a level has fewer approved questions than
  /// this, the level simply runs short rather than blocking play.
  /// Drawn at random from everything approved for that level, so replaying a
  /// level is not the same round twice.
  static const int questionsPerLevel = 3;
  static const int minQuestionsToPlay = 1;

  static const int pointsPerCorrectAnswer = 100;
  static const int fastAnswerBonus = 50;
  static const int fastAnswerThresholdSeconds = 15;

  static const int questionSeconds = 30;

  /// Levels that act as safe checkpoints, KBC style.
  static const List<int> safeCheckpoints = [5, 10, 15, 20];
}
