import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

/// Plays MP3 audio bytes in the browser using an HTML5 Audio element.
class WebAudioPlayer {
  static web.HTMLAudioElement? _audio;
  static bool _playing = false;

  static bool get isPlaying => _playing;

  /// Play raw MP3 bytes
  static Future<void> playBytes(Uint8List bytes, {void Function()? onComplete}) async {
    // Stop any current playback
    await stop();

    // Create a Blob URL from the bytes
    final jsArray = bytes.toJS;
    final blob = web.Blob([jsArray].toJS, web.BlobPropertyBag(type: 'audio/mpeg'));
    final url = web.URL.createObjectURL(blob);

    _audio = web.HTMLAudioElement()..src = url;
    _playing = true;

    _audio!.onended = ((web.Event e) {
      _playing = false;
      web.URL.revokeObjectURL(url);
      onComplete?.call();
    }).toJS;

    _audio!.onerror = ((web.Event e) {
      _playing = false;
      web.URL.revokeObjectURL(url);
      onComplete?.call();
    }).toJS;

    await _audio!.play().toDart;
  }

  /// Stop playback
  static Future<void> stop() async {
    if (_audio != null) {
      _audio!.pause();
      _audio!.currentTime = 0;
      _audio = null;
    }
    _playing = false;
  }
}
