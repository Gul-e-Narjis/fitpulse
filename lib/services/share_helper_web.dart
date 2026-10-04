import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

// navigator.share with files is mostly available on mobile browsers
bool get canShareFiles {
  try {
    final probe = web.File(
      <web.BlobPart>[Uint8List(1).toJS].toJS,
      'probe.png',
      web.FilePropertyBag(type: 'image/png'),
    );
    return web.window.navigator.canShare(
      web.ShareData(files: <web.File>[probe].toJS),
    );
  } catch (_) {
    return false;
  }
}

void downloadPng(Uint8List bytes, String filename) {
  final blob = web.Blob(
    <web.BlobPart>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'image/png'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}

Future<bool> sharePng(Uint8List bytes, String filename, String text) async {
  try {
    final file = web.File(
      <web.BlobPart>[bytes.toJS].toJS,
      filename,
      web.FilePropertyBag(type: 'image/png'),
    );
    final data = web.ShareData(
      files: <web.File>[file].toJS,
      title: 'FitPulse',
      text: text,
    );
    if (!web.window.navigator.canShare(data)) return false;
    await web.window.navigator.share(data).toDart;
    return true;
  } catch (_) {
    // Cancelled by the user or not supported
    return false;
  }
}
