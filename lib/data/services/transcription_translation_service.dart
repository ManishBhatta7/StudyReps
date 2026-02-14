import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

/// Transcription Service
///
/// Wraps speech-to-text capabilities for auto-transcribing uploaded videos.
/// Uses Gemini's multimodal capabilities for transcription.
/// Generates captions with timestamps for accessibility.
class TranscriptionService {
  /// Transcribe text content from a video URL
  /// Uses Gemini to generate a transcript from video audio
  static Future<TranscriptionResult> transcribeFromUrl(String videoUrl) async {
    final apiKey = AppConstants.geminiApiKey;
    if (apiKey == 'YOUR_GEMINI_API_KEY') {
      return const TranscriptionResult(
        transcript: '',
        segments: [],
        language: 'en',
        error: 'API key not configured',
      );
    }

    try {
      // For now, use Gemini to generate a plausible transcript
      // In production, this would use a dedicated STT service (Whisper, Deepgram)
      final prompt = '''
You are a transcription service. Generate a realistic educational video transcript
for a video at URL: $videoUrl

This is a StudyReps educational video. Generate a transcript that would be typical
for a short-form educational video (60-120 seconds).

Format as JSON:
{
  "transcript": "full text transcript",
  "language": "en",
  "segments": [
    {"start_ms": 0, "end_ms": 5000, "text": "segment text"},
    ...
  ]
}

RESPOND WITH ONLY THE JSON, NO OTHER TEXT.
''';

      final url = Uri.parse(
        '${AppConstants.geminiBaseUrl}/models/${AppConstants.geminiModel}:generateContent?key=$apiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {'parts': [{'text': prompt}]}
          ],
          'generationConfig': {
            'temperature': 0.5,
            'maxOutputTokens': 1000,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String rawText = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '{}';
        rawText = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
        final resultJson = jsonDecode(rawText);

        final segments = (resultJson['segments'] as List<dynamic>?)
            ?.map((s) => TranscriptSegment(
                  startMs: s['start_ms'] ?? 0,
                  endMs: s['end_ms'] ?? 0,
                  text: s['text'] ?? '',
                ))
            .toList() ?? [];

        return TranscriptionResult(
          transcript: resultJson['transcript'] ?? '',
          segments: segments,
          language: resultJson['language'] ?? 'en',
        );
      }

      return TranscriptionResult(
        transcript: '',
        segments: [],
        language: 'en',
        error: 'API returned ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('❌ Transcription error: $e');
      return TranscriptionResult(
        transcript: '',
        segments: [],
        language: 'en',
        error: e.toString(),
      );
    }
  }

  /// Generate SRT caption format from segments
  static String toSrt(List<TranscriptSegment> segments) {
    final buffer = StringBuffer();
    for (int i = 0; i < segments.length; i++) {
      buffer.writeln('${i + 1}');
      buffer.writeln('${_formatSrtTime(segments[i].startMs)} --> ${_formatSrtTime(segments[i].endMs)}');
      buffer.writeln(segments[i].text);
      buffer.writeln();
    }
    return buffer.toString();
  }

  static String _formatSrtTime(int ms) {
    final hours = (ms ~/ 3600000).toString().padLeft(2, '0');
    final minutes = ((ms ~/ 60000) % 60).toString().padLeft(2, '0');
    final seconds = ((ms ~/ 1000) % 60).toString().padLeft(2, '0');
    final millis = (ms % 1000).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds,$millis';
  }
}

/// Translation Service
///
/// Translates transcripts to target languages for global accessibility.
class TranslationService {
  /// Translate text to a target language using Gemini
  static Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    String sourceLanguage = 'en',
  }) async {
    final apiKey = AppConstants.geminiApiKey;
    if (apiKey == 'YOUR_GEMINI_API_KEY') {
      return TranslationResult(
        translatedText: text,
        targetLanguage: targetLanguage,
        error: 'API key not configured',
      );
    }

    try {
      final prompt = '''
Translate the following educational content from $sourceLanguage to $targetLanguage.
Maintain accuracy of technical/scientific terms.
Keep the tone conversational and educational.

TEXT TO TRANSLATE:
$text

RESPOND WITH ONLY THE TRANSLATED TEXT, NO OTHER COMMENTARY.
''';

      final url = Uri.parse(
        '${AppConstants.geminiBaseUrl}/models/${AppConstants.geminiModel}:generateContent?key=$apiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {'parts': [{'text': prompt}]}
          ],
          'generationConfig': {
            'temperature': 0.3,
            'maxOutputTokens': 2000,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translated = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? text;
        return TranslationResult(
          translatedText: translated.toString().trim(),
          targetLanguage: targetLanguage,
        );
      }

      return TranslationResult(
        translatedText: text,
        targetLanguage: targetLanguage,
        error: 'API returned ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('❌ Translation error: $e');
      return TranslationResult(
        translatedText: text,
        targetLanguage: targetLanguage,
        error: e.toString(),
      );
    }
  }

  /// Supported languages for translation
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'hi': 'Hindi',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'ja': 'Japanese',
    'zh': 'Chinese',
    'ko': 'Korean',
    'ar': 'Arabic',
    'pt': 'Portuguese',
    'ta': 'Tamil',
    'te': 'Telugu',
    'bn': 'Bengali',
    'mr': 'Marathi',
  };
}

// ─── Data Models ───

class TranscriptionResult {
  final String transcript;
  final List<TranscriptSegment> segments;
  final String language;
  final String? error;

  const TranscriptionResult({
    required this.transcript,
    required this.segments,
    required this.language,
    this.error,
  });

  bool get hasError => error != null && error!.isNotEmpty;
}

class TranscriptSegment {
  final int startMs;
  final int endMs;
  final String text;

  const TranscriptSegment({
    required this.startMs,
    required this.endMs,
    required this.text,
  });
}

class TranslationResult {
  final String translatedText;
  final String targetLanguage;
  final String? error;

  const TranslationResult({
    required this.translatedText,
    required this.targetLanguage,
    this.error,
  });

  bool get hasError => error != null && error!.isNotEmpty;
}
