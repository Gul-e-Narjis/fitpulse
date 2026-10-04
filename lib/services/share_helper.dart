// PNG download / Web Share helpers. The real implementation only exists on
// the web; other platforms (and tests) get a no-op stub.
export 'share_helper_stub.dart'
    if (dart.library.js_interop) 'share_helper_web.dart';
