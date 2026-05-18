import 'dart:typed_data';

/// Stub for non-web platforms
class WebAudioPlayer {
  static Future<void> playBytes(Uint8List bytes, {void Function()? onComplete}) async {}
  static Future<void> stop() async {}
  static bool get isPlaying => false;
}
