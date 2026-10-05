/// The GetX route table for the app.
///
/// [AppPages] lists every navigable [GetPage], pairing each route name from
/// [AppRoutes] with its screen and the module [Bindings] that provisions the
/// screen's controller. The route table is consumed by `GetMaterialApp`
/// (`getPages` + `initialRoute`) in `main.dart` (Req 4.3, 4.4, 12.1, 12.12,
/// 12.13).
///
/// Routes share a short fade and vertical transition that respects the user's
/// reduced-motion preference.
library;

import 'package:get/get.dart';

import '../../modules/exam/exam_binding.dart';
import '../../modules/exam/exam_screen.dart';
import '../../modules/home/home_binding.dart';
import '../../modules/home/home_screen.dart';
import '../../modules/result/result_binding.dart';
import '../../modules/result/result_screen.dart';
import '../../modules/review/review_binding.dart';
import '../../modules/review/review_screen.dart';
import '../../modules/study/study_binding.dart';
import '../../modules/study/study_screen.dart';
import '../../modules/splash/splash_screen.dart';
import 'app_routes.dart';
import '../../shared/widgets/app_motion.dart';

/// The app's GetX page/route definitions.
class AppPages {
  AppPages._();

  /// The route shown on cold start.
  static const initial = AppRoutes.splash;

  /// All navigable routes with their screens and bindings.
  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      customTransition: AppPageTransition(),
      transitionDuration: AppMotion.page,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      customTransition: AppPageTransition(),
      transitionDuration: AppMotion.page,
    ),
    GetPage(
      name: AppRoutes.study,
      page: () => const StudyScreen(),
      binding: StudyBinding(),
      customTransition: AppPageTransition(),
      transitionDuration: AppMotion.page,
    ),
    GetPage(
      name: AppRoutes.exam,
      page: () => const ExamScreen(),
      binding: ExamBinding(),
      customTransition: AppPageTransition(),
      transitionDuration: AppMotion.page,
    ),
    GetPage(
      name: AppRoutes.result,
      page: () => const ResultScreen(),
      binding: ResultBinding(),
      customTransition: AppPageTransition(),
      transitionDuration: AppMotion.page,
    ),
    GetPage(
      name: AppRoutes.review,
      page: () => const ReviewScreen(),
      binding: ReviewBinding(),
      customTransition: AppPageTransition(),
      transitionDuration: AppMotion.page,
    ),
  ];
}
