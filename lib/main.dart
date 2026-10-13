import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mumbai_train_quiz/app/routes/app_pages.dart';
import 'package:mumbai_train_quiz/app/routes/app_routes.dart';
import 'package:mumbai_train_quiz/app/theme/app_theme.dart';
import 'package:mumbai_train_quiz/data/local/hive_service.dart';
import 'package:mumbai_train_quiz/data/local/sync_service.dart';
import 'package:mumbai_train_quiz/modules/auth/auth_controller.dart';
import 'package:mumbai_train_quiz/modules/quiz/quiz_controller.dart';
import 'package:mumbai_train_quiz/utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local store first: everything the game does reads and writes it, so the
  // app is playable before — and without — any network.
  await HiveService.init();

  Get.put(SyncService(), permanent: true);
  Get.put(AuthController(), permanent: true);
  // Lives for the whole session: the result screen reads the finished round
  // off the same controller the quiz screen played it on.
  Get.put(QuizController(), permanent: true);

  runApp(const WindowSeatApp());
}

class WindowSeatApp extends StatelessWidget {
  const WindowSeatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
