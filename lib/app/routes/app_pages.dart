import 'package:get/get.dart';

import 'package:mumbai_train_quiz/app/routes/app_routes.dart';
import 'package:mumbai_train_quiz/modules/auth/views/login_screen.dart';
import 'package:mumbai_train_quiz/modules/auth/views/register_screen.dart';
import 'package:mumbai_train_quiz/modules/home/home_controller.dart';
import 'package:mumbai_train_quiz/modules/home/views/home_screen.dart';
import 'package:mumbai_train_quiz/modules/quiz/views/quiz_result_screen.dart';
import 'package:mumbai_train_quiz/modules/quiz/views/quiz_screen.dart';
import 'package:mumbai_train_quiz/modules/splash/views/splash_screen.dart';

abstract class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.register, page: () => const RegisterScreen()),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(name: AppRoutes.quiz, page: () => const QuizScreen()),
    GetPage(name: AppRoutes.quizResult, page: () => const QuizResultScreen()),
  ];
}
