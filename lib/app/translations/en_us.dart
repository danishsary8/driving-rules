/// English (`en_US`) UI-chrome translation map.
///
/// [enUS] holds every bilingual UI key consumed by the app via GetX
/// translations (`'key'.tr`). All dynamic question/answer content remains in
/// Khmer regardless of locale; only this chrome (titles, navigation, buttons,
/// dialogs, result/error states) is translated. The key set here MUST stay
/// identical to [kmKH] in `km_kh.dart` so the English fallback covers every key
/// (Property 13 parity).
library;

/// English translations for all UI chrome keys.
const Map<String, String> enUS = {
  'study_zoom_image': 'Tap to view the illustration',
  'zoom_in': 'Zoom in',
  'zoom_out': 'Zoom out',
  'zoom_reset': 'Reset view',
  'close': 'Close',
  'hero_support': 'Built-in lessons. Real practice. Your own pace.',
  'guided_learning': 'Your road to confidence',
  'journey_title': 'Make your next move.',
  'journey_description':
      'A clear path from understanding the rules to feeling ready.',
  'journey_learn': 'Learn',
  'journey_learn_hint': 'Understand the rules.',
  'journey_practice_hint': 'Put your knowledge to work.',
  'journey_progress_hint': 'See how far you’ve come.',
  'local_study': 'Your learning studio',
  'workspace': 'Learning workspace',
  'overview': 'Overview',
  'lessons': 'Lessons',
  'practice': 'Practice',
  'progress': 'Progress',
  'practice_exam': 'Practice exam',
  'my_progress': 'My progress',
  'learning_library': 'LEARNING LIBRARY',
  'small_steps': 'Small steps. Safer roads.',
  'sidebar_tip': 'A little practice every day builds a lifetime of confidence.',
  'made_for_cambodia': 'Made for the roads of Cambodia',
  'progress_subtitle': 'Your practice, one step at a time.',
  'progress_empty':
      'Your first practice exam starts your story. Ready when you are.',
  'view_last_result': 'View last result',
  'your_learning_space': 'YOUR LEARNING SPACE',
  'welcome_heading': 'A better driver starts here.',
  'welcome_description':
      'Build your knowledge. Find your confidence. Enjoy the journey.',
  'self_paced': 'Learn at your own pace',
  'practice_questions': 'Practice questions',
  'learning_categories': 'Learning categories',
  'category_intro':
      'Pick a topic and take your next step toward safer driving.',
  'your_road_starts': 'YOUR ROAD STARTS HERE',
  'hero_title': 'A little practice.\nA lot of confidence.',
  'hero_description':
      'Master the rules, understand the signs, and get ready for your driving theory exam.',
  'start_learning': 'Start learning',
  'explore_signs': 'Explore road signs',
  'category_general_description':
      'The everyday rules that keep everyone moving safely.',
  'category_sign_description':
      'Learn the language of the road, one sign at a time.',
  'category_priority_description':
      'Know who goes first at every turn and intersection.',
  'category_technique_description':
      'Build the skills behind confident, responsible driving.',
  'category_emergency_description':
      'Stay calm, act quickly, and help when it matters most.',
  'ready_for_test': 'Ready for a test drive?',
  'exam_card_description':
      '45 questions · 45 minutes\nPut your knowledge into practice.',
  'learning_tip': 'A LITTLE ROAD WISDOM',
  'tip_title': 'Understand it. Don’t just memorize it.',
  'tip_description':
      'Picture yourself on the road as you study. It helps the rules feel natural.',
  'your_progress': 'YOUR JOURNEY SO FAR',
  'progress_first_step': 'Every journey begins with a first step.',
  'progress_description':
      'Take a practice exam to discover your strengths and what to learn next.',
  'footer_note': 'Built for better learning and safer journeys.',
  'splash_tagline': 'Your journey to confident driving.',
  'study_intro':
      'Read the rules, understand the signs, and learn at your pace.',
  'study_read_mode': 'Learning mode',
  'study_practice_hint':
      'Correct answers are shown directly. Use Practice to test yourself.',
  'study_image_read_hint':
      'Study the illustration and read the correct answer.',
  'study_all': 'All questions',
  'study_image_hint': 'Look at the illustration and choose the correct answer.',
  'study_empty_hint': 'Try a different keyword or clear your search.',
  'clear_search': 'Clear search',
  'exam_mode': 'PRACTICE SESSION',
  'exam_heading': 'One question at a time.',
  'exam_description': 'Take a breath, read carefully, and choose your answer.',
  'exam_select_one': 'Choose one answer',
  'exam_answered': 'Answered',
  'exam_remaining': 'Remaining',
  'exam_session': 'Your session',
  'exam_rules':
      '38 correct answers to pass. All 5 priority questions must be correct; advancing with an incorrect or unanswered priority question ends the exam.',
  'exam_priority_notice':
      'Priority question: a correct answer is required to continue.',
  'exam_finish_hint': 'Review your choice before moving to the next question.',
  'exam_leave': 'Exit practice',
  'result_eyebrow': 'YOUR PRACTICE RESULTS',
  'result_pass_heading': 'You’re on the right road.',
  'result_fail_heading': 'Progress starts with practice.',
  'result_pass_description':
      'Great work. Keep building on what you’ve learned.',
  'result_fail_description':
      'Every attempt teaches you something. Review your answers and try again.',
  'result_accuracy': 'Accuracy',
  'result_next_step': 'Your next step',
  'result_review_hint':
      'A closer look at your answers helps turn mistakes into understanding.',
  'review_intro': 'Reflect, understand, and keep moving forward.',
  'review_all': 'All answers',
  'review_mistakes': 'To revisit',
  'review_no_mistakes': 'All answers are correct. Great work!',
  // App identity
  'app_title': 'Driving Rules',
  'app_subtitle': 'Prepare for your driving theory exam',

  // Bottom-nav + category labels
  'nav_general': 'General',
  'nav_emergency': 'Emergency',
  'nav_technique': 'Technique',
  'nav_sign': 'Signs',
  'nav_priority': 'Priority',
  'nav_exam': 'Exam',

  // Home
  'home_title': 'Home',
  'home_choose_category': 'Choose a category',

  // Study
  'study_search_placeholder': 'Search lessons',
  'study_question_count': 'questions',
  'study_correct_answer': 'Correct answer',
  'no_results': 'No results found',

  // Exam navigation + flow
  'exam_start': 'Start Exam',
  'exam_next': 'Next',
  'exam_back': 'Back',
  'exam_finish': 'Finish',
  'exam_question_progress': 'Question',
  'exam_time_left': 'Time left',
  'exam_submit_confirm_title': 'Submit exam?',
  'exam_submit_confirm_body': 'Are you sure you want to submit your exam?',
  'exam_submit_confirm_yes': 'Submit',
  'exam_submit_confirm_no': 'Cancel',
  'exam_leave_confirm_title': 'Leave exam?',
  'exam_leave_confirm_body':
      'If you leave now, your progress will be lost. Leave anyway?',
  'exam_leave_yes': 'Leave',
  'exam_leave_no': 'Stay',

  // Result
  'result_passed': 'PASSED ✓',
  'result_failed': 'FAILED ✗',
  'result_score': 'Score',
  'result_score_out_of': 'out of',
  'result_breakdown_title': 'Score breakdown',
  'breakdown_general': 'General',
  'breakdown_sign': 'Signs',
  'breakdown_priority': 'Priority',
  'breakdown_technique': 'Technique',
  'breakdown_emergency': 'Emergency',
  'fail_reason_priority': 'Priority question answered incorrectly',
  'fail_reason_timeout': "Time's up",
  'fail_reason_below_38': 'Score below 38',
  'result_correct': 'Correct',
  'result_wrong': 'Wrong',
  'result_review_answers': 'Review Answers',
  'result_try_again': 'Try Again',
  'result_back_home': 'Back to Home',
  'result_celebrate': 'Congratulations, you passed!',
  'result_encourage': "Don't give up, try again!",

  // Answer review
  'review_title': 'Answer Review',
  'review_summary': 'Review summary',
  'review_correct': 'Correct',
  'review_wrong': 'Wrong',
  'review_your_answer': 'Your answer',
  'review_correct_answer': 'Correct answer',
  'review_your_correct_answer': 'Your correct answer',
  'review_no_answer': 'You did not answer this question',
  'review_empty': 'No answer review is available for this exam.',

  // Loading + error states
  'loading': 'Loading',
  'error_title': 'Something went wrong',
  'error_body': 'We could not load the questions. Please try again.',
  'error_retry': 'Retry',

  // Scores
  'best_score': 'Best score',
  'last_score': 'Last score',

  // Accessibility tooltips
  'theme_toggle_tooltip': 'Toggle theme',
  'language_toggle_tooltip': 'Toggle language',
};
