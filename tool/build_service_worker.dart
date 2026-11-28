// Stamps the offline cache (web/sw.js) in a finished web build.
//
// Run after `flutter build web`:
//
//   dart run tool/build_service_worker.dart build/web
//
// It lists every file the app may need offline, derives a version from their
// contents, and writes both into build/web/sw.js. A new deploy therefore gets a
// new version, which makes browsers install the new worker and refresh the cache.
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final dir = Directory(args.isEmpty ? 'build/web' : args.first);
  final worker = File('${dir.path}/sw.js');
  if (!worker.existsSync()) {
    stderr.writeln('No sw.js in ${dir.path}. Run `flutter build web` first.');
    exitCode = 1;
    return;
  }

  final files = <String, List<int>>{};
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is! File) continue;
    final path = entity.path
        .substring(dir.path.length + 1)
        .replaceAll(Platform.pathSeparator, '/');
    if (shouldPrecache(path)) files[path] = entity.readAsBytesSync();
  }

  final paths = files.keys.toList()..sort();
  final version = contentVersion([
    for (final p in paths) ...[...utf8.encode(p), ...files[p]!],
  ]);
  worker.writeAsStringSync(
    stampWorker(worker.readAsStringSync(), version: version, paths: paths),
  );
  stdout.writeln('sw.js: version $version, ${paths.length} files precached.');
}

/// Whether [path] (relative to the build folder, `/`-separated) is cached when
/// the app is installed.
///
/// Left out: the rendering engine builds (only the one a browser uses is cached,
/// at runtime), debug symbols and source maps, the license text, Flutter's
/// deprecated service worker, and the worker itself.
bool shouldPrecache(String path) {
  if (path.startsWith('canvaskit/')) return false;
  if (path.endsWith('.map') || path.endsWith('.symbols')) return false;
  const skip = {
    'sw.js',
    'flutter_service_worker.js',
    'assets/NOTICES',
    '.last_build_id',
  };
  return !skip.contains(path);
}

/// Short, stable hex version for [bytes] (64-bit FNV-1a).
String contentVersion(List<int> bytes) {
  // Two 32-bit halves keep the arithmetic exact on the web and the VM alike.
  var hi = 0xcbf29ce4, lo = 0x84222325;
  for (final b in bytes) {
    lo ^= b;
    // Multiply the 64-bit value (hi:lo) by the FNV prime 0x100000001b3.
    final loMul = lo * 0x1b3;
    final carry = loMul ~/ 0x100000000;
    hi = (hi * 0x1b3 + lo * 0x100 + carry) & 0xffffffff;
    lo = loMul & 0xffffffff;
  }
  return hi.toRadixString(16).padLeft(8, '0') + lo.toRadixString(16).padLeft(8, '0');
}

/// Fills the VERSION and PRECACHE placeholders of the worker [source].
String stampWorker(
  String source, {
  required String version,
  required List<String> paths,
}) {
  const versionSlot = "'__SW_VERSION__'";
  const listSlot = '/* __SW_PRECACHE__ */ []';
  if (!source.contains(versionSlot) || !source.contains(listSlot)) {
    throw StateError('sw.js has no placeholders (already stamped?)');
  }
  // './' is the app shell (index.html at the app's own path).
  final list = jsonEncode(['./', ...paths]);
  return source
      .replaceFirst(versionSlot, "'$version'")
      .replaceFirst(listSlot, list);
}
