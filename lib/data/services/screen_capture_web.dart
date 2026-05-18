import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

/// Web implementation of screen capture using getDisplayMedia API.
/// Prompts the user to share a screen/tab/window, captures a single frame,
/// and returns it as image bytes for Gemini Vision analysis.

bool get isScreenCaptureSupported => true;

Future<Uint8List?> captureScreen() async {
  try {
    // Request screen share via getDisplayMedia
    final mediaDevices = web.window.navigator.mediaDevices;

    final options = web.DisplayMediaStreamOptions(video: true.toJS);
    final stream = await mediaDevices.getDisplayMedia(options).toDart;

    // Create a video element to receive the stream
    final video = web.document.createElement('video') as web.HTMLVideoElement;
    video.srcObject = stream;
    video.autoplay = true;
    video.muted = true;

    // Append to DOM temporarily (needed for rendering)
    video.style.position = 'fixed';
    video.style.top = '-9999px';
    video.style.left = '-9999px';
    web.document.body?.append(video);

    // Wait for video to load
    // Poll until video has valid dimensions or timeout
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (video.videoWidth > 0 && video.videoHeight > 0) break;
    }
    // Small delay to ensure frame is rendered
    await Future.delayed(const Duration(milliseconds: 400));

    // Get actual video dimensions
    final width = video.videoWidth;
    final height = video.videoHeight;

    if (width == 0 || height == 0) {
      _cleanupStream(stream, video);
      return null;
    }

    // Capture frame to canvas
    final canvas = web.document.createElement('canvas') as web.HTMLCanvasElement;
    canvas.width = width;
    canvas.height = height;
    final ctx = canvas.getContext('2d')! as web.CanvasRenderingContext2D;
    ctx.drawImage(video, 0, 0);

    // Cleanup: stop all tracks and remove video
    _cleanupStream(stream, video);

    // Convert canvas to JPEG bytes
    final dataUrl = canvas.toDataURL('image/jpeg', 0.85.toJS);
    final base64Data = dataUrl.split(',')[1];
    return base64Decode(base64Data);
  } catch (e) {
    // User cancelled or browser denied permission
    return null;
  }
}

void _cleanupStream(web.MediaStream stream, web.HTMLVideoElement video) {
  try {
    final tracks = stream.getTracks().toDart;
    for (final track in tracks) {
      track.stop();
    }
    video.srcObject = null;
    video.remove();
  } catch (_) {}
}
