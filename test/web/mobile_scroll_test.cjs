const { test } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { resolve } = require('node:path');
const { runInNewContext } = require('node:vm');

const script = readFileSync(resolve(__dirname, '../../web/mobile-scroll.js'), 'utf8');

function harness({ ios = false, outside = false, broken = false } = {}) {
  const events = [];
  const listeners = {};
  const bubbles = {};
  const window = outside ? {} : {
    TelegramWebviewProxy: { postEvent(name, data) {
      if (broken) throw new Error('Host is closing');
      events.push([name, JSON.parse(data)]);
    } },
    ...(ios ? { webkit: { messageHandlers: { performAction: {} } } } : {}),
  };
  window.addEventListener = (name, fn, options) => {
    assert.equal(options.passive, true);
    bubbles[name] = fn;
  };
  runInNewContext(script, {
    window,
    document: { addEventListener(name, fn, options) {
      assert.equal(options.passive, true);
      assert.equal(options.capture, true);
      listeners[name] = fn;
    } },
  });
  function touch(name, flutter = true, hostObserver = () => {}) {
    const event = { composedPath: () => [{ tagName: flutter ? 'FLUTTER-VIEW' : 'INPUT' }],
      preventDefault() { assert.fail('Touch events must reach Flutter'); },
      stopPropagation() { assert.fail('Touch events must reach Flutter'); } };
    listeners[name](event);
    hostObserver();
    bubbles[name](event);
  }
  return { events, touch };
}

test('iOS cancels host dismissal at touch start and first movement only', () => {
  const h = harness({ ios: true });
  h.touch('touchstart');
  for (let i = 0; i < 20; i++) h.touch('touchmove');
  assert.deepEqual(h.events, [['cancellingTouch', {}], ['cancellingTouch', {}]]);
  h.touch('touchstart');
  h.touch('touchmove');
  assert.equal(h.events.length, 4);
});

test('Android keeps both axes in Flutter after host touch observers', () => {
  const h = harness();
  h.touch('touchstart', true, () => h.events.push(['allowScroll', [true, true]]));
  assert.deepEqual(h.events.at(-1), ['allowScroll', [false, false]]);
  h.touch('touchmove');
  assert.deepEqual(h.events.at(-1), ['allowScroll', [false, false]]);
});

test('native controls outside the Flutter view keep their gestures', () => {
  const h = harness({ ios: true });
  h.touch('touchstart', false);
  h.touch('touchmove', false);
  assert.deepEqual(h.events, []);
});

test('ordinary Safari and Chrome need no Telegram SDK or bridge', () => {
  const h = harness({ outside: true });
  h.touch('touchstart');
  h.touch('touchmove');
  assert.deepEqual(h.events, []);
});

test('closing host bridges cannot break app input', () => {
  const h = harness({ broken: true });
  h.touch('touchstart');
  h.touch('touchmove');
  assert.deepEqual(h.events, []);
});
