import 'dart:typed_data';

/// Screen capture stub for mobile platforms.
/// On mobile, screen capture is not supported — use camera instead.

bool get isScreenCaptureSupported => false;

Future<Uint8List?> captureScreen() async => null;
