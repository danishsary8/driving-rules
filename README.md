# Driving Rules

A responsive Flutter learning app for Cambodia’s driving theory exam. Lessons, fonts and question illustrations are bundled with the app; preferences and exam summaries are saved locally.

## Run in VS Code

Open this folder and install the Flutter extension (which also installs Dart).

```powershell
flutter pub get
flutter run -d edge
```

For Chrome, use `flutter run -d chrome`. Alternatively, select **Driving Rules · Edge** or **Driving Rules · Chrome** in VS Code’s Run and Debug panel and press **F5**.

## Frontend design

- Fresh neutral surfaces, teal navigation accents, warm amber actions and a high contrast hero with an animated road illustration.
- Matching browser loading screen and Flutter splash, followed by the learning dashboard.
- Desktop sidebar from 1050 px; bottom navigation on smaller screens. Content grids adapt to available space.
- A guided learning path and searchable reading lessons with category switching. Each lesson shows only its correct answer, with no quiz options or reveal controls. Search matches the visible question and correct answer.
- Enlarged road-sign illustrations with pinch, pan, wheel and button zoom controls.
- Focused exam layout with a timer, fixed navigation controls and a desktop session overview.
- Score breakdown, saved result summary and answer review with a mistakes filter.
- Khmer and English interface controls; question content remains in its original Khmer.
- Larger body text, stronger secondary text contrast, and complete category descriptions.
- Light mode by default, with a persistent dark mode toggle and bundled Khmer fonts.
- Reusable motion components for staggered entrances, route transitions, card hover/press feedback, answer feedback, score counters and the road illustration. Animations are finite and respect the system’s reduced-motion preference.

Core exam composition, priority rules and scoring are retained. No account or backend is required.

## Check and build

```powershell
flutter analyze
flutter test
node --test test/web/mobile_scroll_test.cjs
flutter build web
```

The tests cover core question/scoring behavior and the splash → dashboard → lessons → exam → results → review flow at 320, 390, 768, 844, 1050, 1280, 1440 and 1920 px, across both languages and themes. They exercise short portrait and landscape screens, passing/failing results, enlarged Khmer text, image zoom, live theme changes and reduced motion. Learning checks verify that only the correct answer appears, search excludes hidden exam choices and image filenames, and reading text has strong contrast in both themes.

Browser screenshots are available in [design-preview](design-preview/), including desktop and mobile dashboard, lessons, exam, results and review screens.

## Mobile browser scrolling

The web page contains document overscroll and uses clamped Flutter scrolling.
Answer text remains selectable without a nested editable scroll view. Search
supports drag-to-dismiss, and bottom navigation hides while the keyboard is open.
The search field has its own semantic boundary so screen readers expose only
the input area as editable, rather than the whole lesson header.

Telegram's ordinary in-app browser needs a native gesture bridge because Flutter
scrolls its canvas rather than an HTML document. `web/mobile-scroll.js` uses the
injected Telegram proxy: Android's `allowScroll` event keeps gestures in the page;
iOS's `cancellingTouch` event cancels the browser sheet gesture. Both listeners
are passive and scoped to the Flutter view, preserving taps, selection and pinch
zoom. No Telegram SDK is required. See [Telegram's browser events](https://core.telegram.org/api/web-events)
and its [iOS browser implementation](https://github.com/TelegramMessenger/Telegram-iOS/blob/master/submodules/BrowserUI/Sources/BrowserWebContent.swift).

After deploying, close and reopen the page in Telegram to load the updated host
script. Browser emulation and automated checks cannot replace a physical iPhone
check of Telegram's native sheet gestures; older host apps may need an update.
