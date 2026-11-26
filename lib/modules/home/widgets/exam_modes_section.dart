import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/models/question_model.dart';
import '../../../core/utils/app_haptics.dart';
import '../home_controller.dart';
import 'learning_cards.dart';
import 'resume_exam_banner.dart';
import 'flashcards_banner.dart';
import 'bookmarks_banner.dart';
import 'mistakes_bank_banner.dart';

class ExamModesSection extends StatelessWidget {
  final HomeController controller;
  const ExamModesSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final realExam = Obx(
          () => RealExamCard(
            enabled: controller.canStartExam,
            onTap: () => controller.startExam(skipRules: true),
          ),
        );
        final practice = PracticeModeCard(
          onTap: () => controller.openStudy(Category.general),
        );

        return Column(
          children: [
            if (controller.storage.hasOngoingExam) ...[
              ResumeExamBanner(
                storage: controller.storage,
                onResume: () {
                  AppHaptics.selection();
                  Get.toNamed(
                    AppRoutes.exam,
                    arguments: {'resume': true, 'skipRules': true},
                  );
                },
                onDiscard: () async {
                  AppHaptics.light();
                  await controller.storage.clearOngoingExam();
                  (context as Element).markNeedsBuild();
                },
              ),
              const SizedBox(height: 18),
            ],
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: realExam),
                  const SizedBox(width: 18),
                  Expanded(child: practice),
                ],
              )
            else ...[
              realExam,
              const SizedBox(height: 16),
              practice,
            ],
            if (controller.storage.mistakeCount > 0) ...[
              const SizedBox(height: 16),
              MistakesBankBanner(count: controller.storage.mistakeCount),
            ],
            const SizedBox(height: 16),
            const FlashcardsBanner(),
            if (controller.storage.bookmarkCount > 0) ...[
              const SizedBox(height: 16),
              BookmarksBanner(count: controller.storage.bookmarkCount),
            ],
          ],
        );
      },
    );
  }
}
