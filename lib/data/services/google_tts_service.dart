import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

/// Google Cloud Text-to-Speech Service
///
/// Drop-in replacement for ElevenLabs with a much more generous free tier:
/// - 1M characters/month FREE for WaveNet/Neural2 voices
/// - 4M characters/month FREE for Standard voices
/// - Excellent Hindi & English-IN voices
///
/// API Docs: https://cloud.google.com/text-to-speech/docs/reference/rest
class GoogleTtsService {
  static const String _baseUrl =
      'https://texttospeech.googleapis.com/v1/text:synthesize';

  /// Whether the service is properly configured with an API key
  static bool get isConfigured {
    final key = AppConstants.googleTtsApiKey;
    return key.isNotEmpty;
  }

  /// Convert text to speech audio bytes using Google Cloud TTS API.
  ///
  /// Returns MP3 audio bytes on success, null on failure.
  /// Uses WaveNet voices for natural-sounding speech (1M chars/month free).
  static Future<Uint8List?> textToSpeech(
    String text, {
    String? languageCode,
    String? voiceName,
    double speakingRate = 1.0,
    double pitch = 0.0,
  }) async {
    final apiKey = AppConstants.googleTtsApiKey;

    if (apiKey.isEmpty) {
      debugPrint('🔊 Google TTS: API key not configured!');
      return null;
    }

    // Truncate text to avoid exceeding limits (5000 bytes per request)
    final trimmedText = text.length > 4500 ? text.substring(0, 4500) : text;

    final lang = languageCode ?? AppConstants.googleTtsLanguageCode;
    final voice = voiceName ?? AppConstants.googleTtsVoiceName;

    final url = Uri.parse('$_baseUrl?key=$apiKey');

    debugPrint('🔊 Google TTS: Synthesizing ${trimmedText.length} chars');
    debugPrint('🔊 Google TTS: Voice = $voice ($lang)');

    try {
      final body = jsonEncode({
        'input': {'text': trimmedText},
        'voice': {
          'languageCode': lang,
          'name': voice,
        },
        'audioConfig': {
          'audioEncoding': 'MP3',
          'speakingRate': speakingRate,
          'pitch': pitch,
          'effectsProfileId': ['small-bluetooth-speaker-class-device'],
        },
      });

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: body,
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('🔊 Google TTS: Response status = ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final audioBase64 = json['audioContent'] as String?;

        if (audioBase64 != null && audioBase64.isNotEmpty) {
          final bytes = base64Decode(audioBase64);
          debugPrint('🔊 Google TTS: ✅ Got ${bytes.length} bytes of audio!');
          return bytes;
        } else {
          debugPrint('🔊 Google TTS: ❌ No audioContent in response');
          return null;
        }
      } else {
        debugPrint('🔊 Google TTS: ❌ Error ${response.statusCode}');
        debugPrint(
            '🔊 Google TTS: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
        return null;
      }
    } catch (e) {
      debugPrint('🔊 Google TTS: ❌ Exception: $e');
      return null;
    }
  }

  /// List available voices (useful for debugging / voice picker)
  static Future<List<Map<String, dynamic>>> listVoices({
    String? languageCode,
  }) async {
    final apiKey = AppConstants.googleTtsApiKey;
    if (apiKey.isEmpty) return [];

    try {
      final langFilter =
          languageCode != null ? '&languageCode=$languageCode' : '';
      final url = Uri.parse(
          'https://texttospeech.googleapis.com/v1/voices?key=$apiKey$langFilter');

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final voices = json['voices'] as List<dynamic>? ?? [];
        return voices.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('🔊 Google TTS: listVoices error: $e');
    }
    return [];
  }
}
