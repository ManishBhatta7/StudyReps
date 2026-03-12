import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Captures the current frame of the visible <video> element on the page.
/// Used specifically for Flutter Web because the video_player plugin renders
/// via an HTML <video> element that sits OUTSIDE Flutter's Canvas layer,
/// making it invisible to RepaintBoundary / Screenshot captures.
///
/// This works by:
/// 1. Finding the <video> DOM element directly
/// 2. Drawing its current frame onto a temporary <canvas>
/// 3. Exporting the canvas pixels as JPEG bytes
///
/// IMPORTANT: This only works when the video is loaded from the SAME ORIGIN
/// (e.g., local assets served by the Flutter dev server). Cross-origin videos
/// will cause a SecurityError ("tainted canvas").
Future<Uint8List?> captureVideoFrame() async {
  try {
    // Small delay to ensure the video has fully paused and the current frame is stable
    await Future.delayed(const Duration(milliseconds: 150));

    final videoElements = web.document.getElementsByTagName('video');
    if (videoElements.length == 0) {
      debugPrint('📷 No <video> elements found in DOM');
      return null;
    }

    // Find the first video element that has actual content
    web.HTMLVideoElement? targetVideo;
    for (var i = 0; i < videoElements.length; i++) {
      final el = videoElements.item(i)! as web.HTMLVideoElement;
      if (el.videoWidth > 0 && el.videoHeight > 0) {
        targetVideo = el;
        break;
      }
    }

    if (targetVideo == null) {
      debugPrint('📷 No video element with valid dimensions found');
      return null;
    }

    debugPrint('📷 Found video: ${targetVideo.videoWidth}x${targetVideo.videoHeight}');

    final canvas = web.document.createElement('canvas') as web.HTMLCanvasElement;
    canvas.width = targetVideo.videoWidth;
    canvas.height = targetVideo.videoHeight;
    final ctx = canvas.getContext('2d')! as web.CanvasRenderingContext2D;
    ctx.drawImage(targetVideo, 0, 0);

    final dataUrl = canvas.toDataURL('image/jpeg', 0.85.toJS);

    // Validate the output
    if (dataUrl == 'data:,' || !dataUrl.contains(',') || dataUrl.length < 100) {
      debugPrint('📷 Canvas toDataUrl returned empty/invalid data');
      return null;
    }

    final base64String = dataUrl.split(',').last;
    final bytes = base64Decode(base64String);
    debugPrint('📷 Successfully captured video frame: ${bytes.length} bytes');
    return bytes;
  } catch (e) {
    debugPrint('📷 Failed to capture video frame: $e');
    return null;
  }
}
