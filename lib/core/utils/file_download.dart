import 'dart:typed_data';

import 'file_download_stub.dart'
    if (dart.library.html) 'file_download_web.dart' as platform;

/// Cross-platform utility that triggers file download on Web or delegates
/// gracefully on native targets.
void saveOrDownloadFile(Uint8List bytes, String filename) {
  platform.downloadBytes(bytes, filename);
}
