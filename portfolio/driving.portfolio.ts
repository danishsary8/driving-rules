/**
 * Driving Rules — portfolio entry, ready to paste.
 *
 * Shaped like the Bookly entry in Danish_portfolio/src/content/portfolio.ts
 * (same `Project` + `CaseStudy` fields), so it drops in next to it.
 * The "How I built it" parts (steps, practices, challenges, lessons) are left
 * empty on purpose: this case study shows the problem, what was built, the
 * screens, the numbers and what comes next.
 *
 * This is a Flutter app made for phones, so every screen is a phone shot only
 * (no laptop). `desktop` is left out of each screen; see step 3 below.
 *
 * Every number below was checked against the code on 27 Nov 2026:
 *   249 questions in driving_rules_data/*.json (72 general, 100 signs,
 *   31 priority, 31 technique, 15 emergency), all with a valid answer;
 *   exam = 45 questions, 2,700 s (45 min), pass at 38, priority questions
 *   26–30 must all be right (ExamBuilder / ExamScorer);
 *   speed quiz = 10 questions, 15 s each, 3 lives (QuizPracticeController);
 *   333 UI strings in both en_us.dart and km_kh.dart (same keys);
 *   71 automated tests passing (`flutter test`).
 */

// 1) In src/lib/assets.ts, next to the Bookly glob:
//
//   const dr = import.meta.glob("@/assets/projects/driving/*.webp", {
//     eager: true,
//     import: "default",
//   }) as Record<string, string>;
//   const driving = (name: string) => dr[`/src/assets/projects/driving/${name}.webp`] ?? "";
//
//   and inside ASSETS.projects:
//     drivingShot: driving,
//     drivingShots: { phoneHome: driving("m-home"), phoneResult: driving("m-result") },
//
// 2) Copy portfolio/screens/*.webp into src/assets/projects/driving/
//    and portfolio/cover/*.webp wherever the covers live.
//
// 3) CaseStudy.screens: make `desktop` optional (`desktop?: string`) and, when it
//    is missing, show the phone on its own. Widen `group` to include
//    "Learn" | "Exam" | "Practice".

export const drivingProject = {
  id: "driving",
  title: "Driving Rules",
  coverLine: "Pass the driving theory exam",
  kind: "Driving theory app · Flutter",
  summary:
    "An offline, bilingual Khmer/English app for Cambodia's driving theory exam: lessons for all 249 questions, road-sign flashcards, a timed practice exam with the real pass rules, a speed quiz, and a mistakes bank. I built it on my own; later rounds of fixes, refactors and tests were done with an AI coding assistant.",
  highlights: [
    "Practice exam with the real rules: 45 questions, 45 minutes, 38 to pass",
    "Every screen in Khmer and English, with Khmer text tuned for readability",
    "Works offline: questions and progress stay on the device",
  ],
  stack: ["Flutter", "Dart", "GetX", "GetStorage"],
  hosting: "Netlify",
  liveUrl: "https://drivingruletest.netlify.app/",
  githubUrl: "https://github.com/danishsary8/driving-rules",
  imageAlt: "Driving Rules home screen and a passed practice exam on two phones",

  caseStudy: {
    pitch:
      "Learn Cambodia's road rules in Khmer or English, then take a practice exam that works like the real one: 45 questions, 45 minutes, and no mistakes allowed on right of way.",

    facts: [
      { label: "Role", value: "Solo, Flutter" },
      { label: "Platform", value: "Phone-first, works offline" },
      { label: "Languages", value: "English · ខ្មែរ" },
      { label: "Exam", value: "45 questions · 38 to pass" },
    ],

    problem:
      "Learners prepare for the theory exam from printed question lists. There's no easy way to practise under real exam rules, and nothing shows which questions you keep getting wrong.",

    solution:
      "A phone app that works offline: lessons for every question, road-sign flashcards, a timed exam with the real pass rules, and a mistakes bank that brings back what you got wrong.",

    // Left empty on purpose (no "How I built it" section).
    steps: [],

    // Phone only: 430×932, shot at 1.2×, saved 516×1118.
    screens: [
      {
        group: "Learn",
        title: "Home",
        text: "Start learning, open the road signs, or jump into an exam from one place.",
        phone: "m-home",
      },
      {
        group: "Learn",
        title: "Lessons",
        text: "Every question with its correct answer, grouped into five topics.",
        phone: "m-lessons",
      },
      {
        group: "Learn",
        title: "Road-sign flashcards",
        text: "100 signs to learn, filtered by type: prohibitory, warning, mandatory, information.",
        phone: "m-flashcards",
      },
      {
        group: "Learn",
        title: "Card back",
        text: "Flip a card to see what the sign means, then mark it mastered or to review.",
        phone: "m-flashcard-back",
      },
      {
        group: "Learn",
        title: "In Khmer",
        text: "Every screen switches to Khmer with one tap.",
        phone: "m-home-km",
      },
      {
        group: "Exam",
        title: "Exam rules",
        text: "Four short slides explain the rules before the timer starts.",
        phone: "m-exam-rules",
      },
      {
        group: "Exam",
        title: "Exam question",
        text: "One question at a time, with a 45-minute timer and progress saved if the page reloads.",
        phone: "m-exam",
      },
      {
        group: "Exam",
        title: "Priority question",
        text: "Questions 26 to 30 test right of way. One wrong answer ends the exam.",
        phone: "m-priority",
      },
      {
        group: "Exam",
        title: "Result",
        text: "Pass or not, the score, and how many more correct answers were needed.",
        phone: "m-result",
      },
      {
        group: "Exam",
        title: "Practice certificate",
        text: "A pass earns a practice certificate to download or share, clearly not an official one.",
        phone: "m-certificate",
      },
      {
        group: "Exam",
        title: "Answer review",
        text: "Go back through the exam, filtered to the questions you got wrong.",
        phone: "m-review",
      },
      {
        group: "Practice",
        title: "Speed quiz",
        text: "Ten questions, 15 seconds each, three lives.",
        phone: "m-speed-quiz",
      },
      {
        group: "Practice",
        title: "Mistakes bank",
        text: "Every wrong answer is saved here until you get it right.",
        phone: "m-mistakes",
      },
      {
        group: "Practice",
        title: "Progress",
        text: "A readiness score from your last five exams, and every score so far.",
        phone: "m-progress",
      },
    ],

    stats: [
      { value: 249, label: "practice questions" },
      { value: 100, label: "road-sign questions" },
      { value: 333, label: "strings in Khmer" },
      { value: 71, label: "automated tests" },
    ],

    // Left empty on purpose (no "How I built it" section).
    practices: [],
    challenges: [],
    lessons: [],

    // Future development plan.
    next: [
      "Publish on Google Play and the App Store",
      "Have a driving instructor check every answer's explanation",
      "Read questions aloud in Khmer",
      "Bring mistakes back on a schedule (spaced repetition)",
    ],
  },
} as const;
