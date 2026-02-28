import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Direct Web Speech Synthesis API access for natural-sounding voices.
/// Bypasses flutter_tts on web to get full control over voice selection.
class WebTtsService {
  static bool get isSupported => true;
  static web.SpeechSynthesis get _synth => web.window.speechSynthesis;
  static web.SpeechSynthesisVoice? _selectedVoice;
  static bool _voicesLoaded = false;

  /// Wait for voices to become available (Chrome loads them async)
  static Future<List<web.SpeechSynthesisVoice>> _waitForVoices() async {
    var voices = _synth.getVoices().toDart;
    if (voices.isNotEmpty) return voices;

    // Chrome loads voices asynchronously. Poll with a timeout.
    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      voices = _synth.getVoices().toDart;
      if (voices.isNotEmpty) break;
    }

    return voices;
  }

  /// Get all available voices
  static Future<List<Map<String, String>>> getAvailableVoices() async {
    final voices = await _waitForVoices();
    _voicesLoaded = true;

    return voices.map((v) {
      return {
        'name': v.name,
        'lang': v.lang,
      };
    }).toList();
  }

  /// Find and cache the best Indian voice
  static Future<void> _ensureVoiceSelected() async {
    if (_selectedVoice != null) return;

    final voices = await _waitForVoices();
    if (voices.isEmpty) return;

    // Log all voices
    for (var v in voices) {
      debugPrint('🔊 Voice: "${v.name}" (${v.lang})');
    }

    // Priority: pick the most natural-sounding Indian voice available.
    final preferenceOrder = [
      'Microsoft Neerja Online (Natural)',
      'Microsoft Prabhat Online (Natural)',
      'Microsoft Swara Online (Natural)',
      'Microsoft Heera',
      'Microsoft Ravi',
      'Microsoft Neerja',
      'Microsoft Hemant',
      'Google हिन्दी',
    ];

    for (final preferred in preferenceOrder) {
      for (var v in voices) {
        if (v.name.contains(preferred)) {
          _selectedVoice = v;
          debugPrint('🔊 ✅ Selected: "${v.name}"');
          return;
        }
      }
    }

    // Fallback: any en-IN or hi voice
    for (var v in voices) {
      final lang = v.lang.toLowerCase();
      if (lang.startsWith('en-in') || lang.startsWith('hi-in') || lang.startsWith('hi')) {
        _selectedVoice = v;
        debugPrint('🔊 ✅ Fallback: "${v.name}" ($lang)');
        return;
      }
    }

    debugPrint('🔊 ⚠️ No Indian voice found — using browser default');
  }

  /// Speak text with the best available voice
  static Future<void> speak(String text, {
    String? voiceName,
    double rate = 0.9,
    double pitch = 1.05,
    void Function()? onComplete,
  }) async {
    _synth.cancel();
    await _ensureVoiceSelected();

    final utterance = web.SpeechSynthesisUtterance(text);

    if (_selectedVoice != null) {
      utterance.voice = _selectedVoice;
      utterance.lang = _selectedVoice!.lang;
    } else {
      utterance.lang = 'en-IN';
    }

    utterance.rate = rate;
    utterance.pitch = pitch;
    utterance.volume = 1.0;

    if (onComplete != null) {
      utterance.onend = ((web.Event e) {
        onComplete();
      }).toJS;
    }
    utterance.onerror = ((web.Event e) {
      debugPrint('🔊 Speech error');
      onComplete?.call();
    }).toJS;

    _synth.speak(utterance);
  }

  /// Stop speaking
  static Future<void> stop() async {
    _synth.cancel();
  }
}
