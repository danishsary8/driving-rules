/* Flutter owns scrolling inside its view. Telegram must not turn those
 * canvas gestures into a browser-sheet dismissal. No touch events are blocked:
 * Flutter still receives scrolling, taps, text selection and pinch gestures.
 */
(() => {
  'use strict';

  function postEvent(name, data) {
    const proxy = window.TelegramWebviewProxy;
    if (typeof proxy?.postEvent !== 'function') return;
    try {
      proxy.postEvent(name, JSON.stringify(data));
    } catch (_) {
      // A closing or older host bridge must never interrupt the web app.
    }
  }

  function isFlutterTouch(event) {
    return event.composedPath().some(node =>
      node.tagName === 'FLUTTER-VIEW' || node.tagName === 'FLT-GLASS-PANE');
  }

  let firstMove = true;
  const isIosBrowser = () => Boolean(window.webkit?.messageHandlers?.performAction);

  function keepGestureInApp(starting) {
    if (isIosBrowser()) {
      // Cancel at the start and first move, not on every animation frame.
      // Source: Telegram-iOS/BrowserUI/BrowserWebContent.swift, cancellingTouch.
      if (starting || firstMove) postEvent('cancellingTouch', {});
      if (!starting) firstMove = false;
      return;
    }
    // Ordinary Android Telegram browser: false keeps the host swipe container
    // from taking over.
    postEvent('allowScroll', [false, false]);
  }

  const passiveCapture = { passive: true, capture: true };
  document.addEventListener('touchstart', event => {
    firstMove = true;
    if (isFlutterTouch(event)) keepGestureInApp(true);
  }, passiveCapture);
  document.addEventListener('touchmove', event => {
    if (isFlutterTouch(event)) keepGestureInApp(false);
  }, passiveCapture);

  // Window bubbling runs after Telegram's document observers, which can
  // otherwise overwrite allowScroll because the Flutter canvas did not move.
  for (const name of ['touchstart', 'touchmove']) {
    window.addEventListener(name, event => {
      if (!isIosBrowser() && isFlutterTouch(event)) {
        postEvent('allowScroll', [false, false]);
      }
    }, { passive: true });
  }
})();
