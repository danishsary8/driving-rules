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

  // Exam modes: Practice vs Real Exam
  'real_exam': 'Real Exam Simulation',
  'real_exam_desc':
      '45 questions · 45 mins · 38 to pass · Strict priority auto-fail',
  'practice_mode': 'Practice Mode',
  'practice_mode_desc':
      'Self-paced category learning without timer pressure or auto-fail',
  'official_simulation': 'Official Simulation',
  'free_practice': 'Free Practice',
  'start_real_exam': 'Start Real Exam',
  'start_practice': 'Start Practice',
  'journey_exam': 'Real Exam',
  'journey_exam_hint': 'Pass with 38+ and 100% priority.',

  // Exam Rules Modal & Reminders
  'exam_rules_title': 'Official Theory Exam Rules',
  'exam_rules_subtitle':
      'Please read and remember the requirements before starting',
  'rule_pass_title': 'Passing Score: 38 / 45 (84%)',
  'rule_pass_desc':
      'You must correctly answer at least 38 out of 45 questions to pass the exam.',
  'rule_priority_title': 'CRITICAL: Priority Questions (Zero Tolerance)',
  'rule_priority_desc':
      'Questions 25 to 29 test Right-of-Way. You cannot fail even ONE! A wrong or unanswered priority question triggers IMMEDIATE AUTO-FAIL and routes directly to Results.',
  'rule_time_title': 'Time Limit: 45 Minutes',
  'rule_time_desc':
      'Official 45-minute countdown. When time expires, your exam will be automatically submitted.',
  'rule_nav_title': 'Navigation & Review',
  'rule_nav_desc':
      'You can review and change your answers, but priority questions must be answered correctly before moving forward.',
  'exam_rules_confirm': 'I Understand the Rules • Start Exam',
  'exam_rules_pill': 'Exam Rules',
  'exam_rules_quick': 'Pass 38+ • Priority 0-Error',
  'priority_warning_banner':
      'PRIORITY QUESTION: Zero error allowed! 1 wrong answer = Immediate Auto-Fail.',
  'fail_reason_priority_detail':
      'Disqualified due to an incorrect or skipped Priority question (Q25–Q29 require 100% accuracy).',

  // Quiz Game Mode
  'quiz_game_title': 'Speed Quiz Challenge',
  'quiz_game_subtitle':
      'Answer before time runs out! Keep your hearts alive.',
  'quiz_score': 'Score',
  'quiz_streak': 'Streak',
  'quiz_combo': 'Combo',
  'quiz_hearts': 'Lives',
  'quiz_game_over': 'Out of Lives!',
  'quiz_game_over_desc':
      "Don't worry, every mistake is a chance to learn.",
  'quiz_victory': 'Round Complete!',
  'quiz_victory_desc':
      'Outstanding! You completed the challenge with flying colors.',
  'quiz_play_again': 'Play Again',
  'quiz_continue': 'Continue',
  'quiz_time_up': "Time's up!",
  'quiz_speed_bonus': 'Speed Bonus',
  'quiz_mode_blitz': '10-Question Blitz',
  'quiz_mode_survival': 'Survival Run',
  'quiz_select_game_mode': 'Practice Options',
  'quiz_choose_mode_hint': 'Choose how you want to learn today',
  'quiz_mode_study_title': 'Study Mode (Direct Answers)',
  'quiz_mode_study_desc':
      'Browse questions and learn with correct answers directly revealed.',
  'quiz_mode_game_title': 'Speed Quiz Game (Interactive)',
  'quiz_mode_game_desc':
      '15-second timer, combo streaks, 3 hearts, and instant feedback.',
  'quiz_correct_feedback': 'Correct! Well done.',
  'quiz_wrong_feedback': 'Incorrect. Learn from this answer.',

  // Exam Readiness & History Analytics
  'exam_readiness': 'Exam Readiness',
  'readiness_gauge': 'Readiness Gauge',
  'readiness_unrated': 'Not Tested Yet',
  'readiness_unrated_tip':
      'Take a mock exam simulation to measure your test readiness!',
  'readiness_ready': 'Exam Ready',
  'readiness_ready_tip':
      'Outstanding! You consistently hit the passing mark with zero priority violations.',
  'readiness_moderate': 'Moderate Progress',
  'readiness_moderate_tip':
      'Good foundation! Keep practicing Priority and Technique questions to secure your pass.',
  'readiness_practice': 'Needs Practice',
  'readiness_practice_tip':
      'Focus on the 38+ passing threshold and memorize all priority right-of-way rules.',
  'recent_attempts': 'Recent Attempts',
  'category_mastery': 'Category Mastery',
  'mastery_strong': 'Strong',
  'mastery_moderate': 'Review',
  'mastery_weak': 'Needs Work',
  'no_attempts_yet': 'No mock exam attempts yet.',
  'exam_status_pass': 'Passed',
  'exam_status_fail': 'Failed',
  'priority_error_penalty': 'Priority Violation Penalty',
  'attempts_count': 'Attempts',
  'pass_rate': 'Pass Rate',

  // Official Driver Pass Certificate
  'certificate_title': 'Driver Theory Pass Credential',
  'certificate_subtitle': 'Official Theory Test Competency Certificate',
  'certificate_pass_badge': 'OFFICIAL PASS',
  'certificate_score_label': 'Final Score',
  'certificate_priority_cleared': '100% Priority Right-of-Way Cleared',
  'certificate_certified': 'Certified Competent in Traffic Rules & Safety',
  'certificate_serial': 'Credential ID',
  'certificate_date': 'Issue Date',
  'view_certificate': 'View Pass Certificate',
  'share_certificate': 'Share Credential',
  'certificate_copied': 'Credential ID copied to clipboard!',

  // Smart Mistakes Bank
  'mistakes_bank': 'Mistakes Bank',
  'mistakes_bank_desc': 'Drill questions you missed until you reach 100% mastery',
  'mistakes_empty_title': 'No Mistakes Recorded!',
  'mistakes_empty_desc': 'Outstanding driving knowledge. Take an exam to test yourself!',
  'drill_mistakes': 'Drill Mistakes',
  'study_mistakes': 'Review Explanations',
  'clear_all_mistakes': 'Clear Bank',
  'clear_all_confirm': 'Are you sure you want to clear all questions from the Mistakes Bank?',
  'mistake_mastered': 'Mastered & Removed!',
  'questions_to_master': 'Questions to Master',
  'practice_mistakes': 'Practice Mistakes',
};
