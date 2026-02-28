import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/app_constants.dart';

/// ElevenLabs TTS Service — uses the Ruhaan voice for natural Hindi/Hinglish speech.
class ElevenLabsTtsService {
  static bool get isConfigured {
    final key = AppConstants.elevenLabsApiKey;
    debugPrint('🔊 ElevenLabs key check: "${key.isNotEmpty ? '${key.substring(0, 5)}...(${key.length} chars)' : 'EMPTY'}"');
    return key.isNotEmpty;
  }
  
  /// Convert text to speech audio bytes using ElevenLabs API
  static Future<Uint8List?> textToSpeech(String text) async {
    final apiKey = AppConstants.elevenLabsApiKey;
    debugPrint('🔊 ElevenLabs API key: "${apiKey.isNotEmpty ? '${apiKey.substring(0, 8)}...' : 'EMPTY'}"');
    
    if (apiKey.isEmpty) {
      debugPrint('🔊 ElevenLabs: API key not configured!');
      return null;
    }

    final voiceId = AppConstants.elevenLabsVoiceId;
    final url = Uri.parse(
      '${AppConstants.elevenLabsBaseUrl}/text-to-speech/$voiceId',
    );

    debugPrint('🔊 ElevenLabs: Calling $url');
    debugPrint('🔊 ElevenLabs: Voice ID = $voiceId');
    debugPrint('🔊 ElevenLabs: Text length = ${text.length} chars');

    try {
      final body = jsonEncode({
        'text': text,
        'model_id': 'eleven_multilingual_v2',
        'voice_settings': {
          'stability': 0.5,
          'similarity_boost': 0.75,
          'style': 0.4,
          'use_speaker_boost': true,
        },
      });
      
      debugPrint('🔊 ElevenLabs: Sending request...');
      
      final response = await http.post(
        url,
        headers: {
          'xi-api-key': apiKey,
          'Content-Type': 'application/json',
          'Accept': 'audio/mpeg',
        },
        body: body,
      ).timeout(const Duration(seconds: 20));

      debugPrint('🔊 ElevenLabs: Response status = ${response.statusCode}');
      debugPrint('🔊 ElevenLabs: Response content-type = ${response.headers['content-type']}');

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        debugPrint('🔊 ElevenLabs: ✅ Got ${bytes.length} bytes of audio!');
        return bytes;
      } else {
        debugPrint('🔊 ElevenLabs: ❌ Error ${response.statusCode}');
        debugPrint('🔊 ElevenLabs: Response body = ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
        return null;
      }
    } catch (e) {
      debugPrint('🔊 ElevenLabs: ❌ Exception: $e');
      return null;
    }
  }
}
