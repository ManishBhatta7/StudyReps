import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:typed_data';

/// Web implementation of screen capture using getDisplayMedia API.
/// Prompts the user to share a screen/tab/window, captures a single frame,
/// and returns it as image bytes for Gemini Vision analysis.

bool get isScreenCaptureSupported => true;

Future<Uint8List?> captureScreen() async {
  try {
    // Request screen share via getDisplayMedia
    final mediaDevices = html.window.navigator.mediaDevices;
    if (mediaDevices == null) return null;

    final stream = await js_util.promiseToFuture<html.MediaStream>(
      js_util.callMethod(mediaDevices, 'getDisplayMedia', [
        js_util.jsify({'video': true})
      ]),
    );

    // Create a video element to receive the stream
    final video = html.VideoElement()
      ..srcObject = stream
      ..autoplay = true
      ..muted = true;

    // Append to DOM temporarily (needed for rendering)
    video.style
      ..position = 'fixed'
      ..top = '-9999px'
      ..left = '-9999px';
    html.document.body?.append(video);

    // Wait for video to load
    await video.onLoadedData.first;
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
    final canvas = html.CanvasElement(width: width, height: height);
    canvas.context2D.drawImageScaled(video, 0, 0, width.toDouble(), height.toDouble());

    // Cleanup: stop all tracks and remove video
    _cleanupStream(stream, video);

    // Convert canvas to JPEG bytes
    final dataUrl = canvas.toDataUrl('image/jpeg', 0.85);
    final base64Data = dataUrl.split(',')[1];
    return base64Decode(base64Data);
  } catch (e) {
    // User cancelled or browser denied permission
    return null;
  }
}

void _cleanupStream(html.MediaStream stream, html.VideoElement video) {
  try {
    for (final track in stream.getTracks()) {
      track.stop();
    }
    video.srcObject = null;
    video.remove();
  } catch (_) {}
}
