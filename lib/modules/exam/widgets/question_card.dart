import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/question_model.dart';
import 'question_image.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final String? imageHint;
  const QuestionCard({super.key, required this.question, this.imageHint});
  @override
  Widget build(BuildContext context) {
    if (!question.isImagePrompt) {
      return Text(
        question.prompt,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontFamily: 'NotoSansKhmer',
          fontSize: 20,
          height: 1.8,
          letterSpacing: 0,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          imageHint ?? 'study_image_hint'.tr,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        QuestionImage(filename: question.prompt),
      ],
    );
  }
}
