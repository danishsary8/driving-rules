// The installed app must render with no connection. Flutter web downloads
// fonts for characters the bundled fonts (Kanit, Noto Sans Khmer) don't have,
// such as emoji, so offline those would show as empty boxes. This test keeps
// every UI string and every question to characters the bundled fonts cover.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Characters both bundled fonts were checked to contain (fontTools cmap):
/// printable ASCII, the Khmer block, and this punctuation.
const _extra = '’‘“”–—…·•«»×÷→←';

bool _renderable(int rune) =>
    (rune >= 0x20 && rune <= 0x7e) ||
    rune == 0x0a ||
    rune == 0x0d ||
    rune == 0x09 ||
    (rune >= 0x1780 && rune <= 0x17ff) ||
    _extra.runes.contains(rune);

List<String> _problems(String label, String text) => [
  for (final r in text.runes)
    if (!_renderable(r))
      '$label: U+${r.toRadixString(16).toUpperCase()} "${String.fromCharCode(r)}"',
];

void main() {
  test('UI source uses only characters the bundled fonts can draw', () {
    final problems = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trimLeft();
        if (line.startsWith('//')) continue; // comments never render
        problems.addAll(_problems('${file.path}:${i + 1}', lines[i]));
      }
    }
    expect(problems, isEmpty);
  });

  test('question data uses only characters the bundled fonts can draw', () {
    final problems = <String>[];
    for (final file in Directory('driving_rules_data').listSync()) {
      if (file is! File || !file.path.endsWith('.json')) continue;
      final items = jsonDecode(file.readAsStringSync()) as List<dynamic>;
      for (final item in items.cast<Map<String, dynamic>>()) {
        for (final value in item.values) {
          problems.addAll(_problems('${file.path} #${item['id']}', '$value'));
        }
      }
    }
    expect(problems, isEmpty);
  });
}
