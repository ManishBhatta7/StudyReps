/// Screen capture service — conditional export.
/// Imports the web implementation on web, and the stub on mobile.
export 'screen_capture_stub.dart'
    if (dart.library.js_interop) 'screen_capture_web.dart';
