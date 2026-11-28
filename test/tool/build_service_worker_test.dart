import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/build_service_worker.dart';

void main() {
  group('shouldPrecache', () {
    test('keeps the app, its data and images', () {
      for (final p in [
        'index.html',
        'main.dart.js',
        'flutter_bootstrap.js',
        'manifest.json',
        'assets/driving_rules_data/sign.json',
        'assets/driving_rules_data/sign/15.png',
        'assets/assets/fonts/NotoSansKhmer-Variable.ttf',
        'icons/apple-touch-icon.png',
      ]) {
        expect(shouldPrecache(p), isTrue, reason: p);
      }
    });

    test('leaves out engine builds, debug files and old workers', () {
      for (final p in [
        'canvaskit/canvaskit.wasm',
        'canvaskit/chromium/canvaskit.js',
        'main.dart.js.map',
        'canvaskit/skwasm.js.symbols',
        'flutter_service_worker.js',
        'sw.js',
        'assets/NOTICES',
      ]) {
        expect(shouldPrecache(p), isFalse, reason: p);
      }
    });
  });

  group('contentVersion', () {
    test('matches the FNV-1a 64-bit reference values', () {
      expect(contentVersion([]), 'cbf29ce484222325');
      expect(contentVersion(utf8.encode('a')), 'af63dc4c8601ec8c');
      expect(contentVersion(utf8.encode('foobar')), '85944171f73967e8');
    });

    test('changes when any byte changes', () {
      expect(
        contentVersion(utf8.encode('index.html v1')),
        isNot(contentVersion(utf8.encode('index.html v2'))),
      );
    });
  });

  group('stampWorker', () {
    const source =
        "const VERSION = '__SW_VERSION__';\nconst PRECACHE = /* __SW_PRECACHE__ */ [];";

    test('fills the version and the file list, with the app shell first', () {
      final out = stampWorker(source, version: 'abc', paths: ['a.js', 'b.png']);
      expect(out, contains("const VERSION = 'abc';"));
      expect(out, contains('const PRECACHE = ["./","a.js","b.png"];'));
    });

    test('refuses to stamp twice', () {
      final once = stampWorker(source, version: 'abc', paths: const []);
      expect(
        () => stampWorker(once, version: 'def', paths: const []),
        throwsStateError,
      );
    });
  });
}
