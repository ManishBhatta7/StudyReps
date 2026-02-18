import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/video_model.dart';

/// AI Rep Generator Service
///
/// Uses Gemini to analyze uploaded PDFs and images,
/// then generates study reps (question-based learning cards)
/// with titles, subjects, questions, options, and explanations.
class RepGeneratorService {
  /// Placeholder video URLs for generated reps (no user video)
  static const _placeholderVideos = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  ];

  /// Generate a study rep from an uploaded file (PDF or image)
  static Future<VideoModel?> generateFromFile({
    required Uint8List fileBytes,
    required String mimeType,
    String? fileName,
    String? userHint,
  }) async {
    final apiKey = AppConstants.geminiApiKey;
    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY') {
      throw Exception('Gemini API key not configured');
    }

    final base64Data = base64Encode(fileBytes);
    final hint = userHint?.isNotEmpty == true
        ? '\nUser note: "$userHint"'
        : '';

    final prompt = '''
You are a study content generator for "StudyReps" — an educational app.

A student uploaded a file${fileName != null ? ' ("$fileName")' : ''} for study.$hint

═══ YOUR TASK ═══
Analyze the document/image and generate ONE high-quality study question based on the most important concept.

═══ RESPONSE FORMAT ═══
Return ONLY valid JSON (no markdown, no code fences). Exactly this structure:
{
  "title": "Short descriptive title of the concept (max 60 chars)",
  "subject": "Subject area (e.g. Mathematics, Physics, Biology, Chemistry, History, Computer Science, etc.)",
  "topic": "Specific topic within the subject",
  "question": "A clear, challenging multiple-choice question testing understanding",
  "correctAnswer": "The correct answer text",
  "wrongOption1": "A plausible but wrong answer",
  "wrongOption2": "Another plausible but wrong answer",
  "wrongOption3": "A third plausible but wrong answer",
  "hint": "A brief hint to guide the student (1 sentence)",
  "explanation": "Clear 2-3 sentence explanation of why the correct answer is right"
}

═══ GUIDELINES ═══
1. The question should test UNDERSTANDING, not just recall
2. Wrong options should be plausible (common misconceptions)
3. The explanation should teach the concept
4. Keep language clear and student-friendly
5. Focus on the most important concept in the uploaded content
''';

    final url = Uri.parse(
      '${AppConstants.geminiBaseUrl}/models/${AppConstants.geminiModel}:generateContent?key=$apiKey',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'inline_data': {
                    'mime_type': mimeType,
                    'data': base64Data,
                  }
                },
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 800,
            'topP': 0.95,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_ONLY_HIGH',
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_ONLY_HIGH',
            },
          ],
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Gemini API error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final candidate = data['candidates']?[0];
      final text = candidate?['content']?['parts']?[0]?['text'];

      if (text == null) {
        throw Exception('Empty response from Gemini');
      }

      debugPrint('✅ Raw AI Response (single): ${text.substring(0, text.length > 100 ? 100 : text.length)}...');
      return _parseRepFromJson(text.toString().trim());
    } catch (e) {
      debugPrint('❌ RepGenerator error: $e');
      rethrow;
    }
  }

  /// Generate multiple reps from a single document
  static Future<List<VideoModel>> generateMultipleFromFile({
    required Uint8List fileBytes,
    required String mimeType,
    String? fileName,
    int count = 3,
  }) async {
    final apiKey = AppConstants.geminiApiKey;
    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY') {
      throw Exception('Gemini API key not configured');
    }

    // Check file size (limit to ~10MB for safety with base64 overhead)
    if (fileBytes.lengthInBytes > 10 * 1024 * 1024) {
      throw Exception('File is too large (max 10MB). Please try a smaller file.');
    }

    final base64Data = base64Encode(fileBytes);
    debugPrint('📄 Analyzing file: $fileName (${(fileBytes.length / 1024).toStringAsFixed(1)} KB)');

    final prompt = '''
You are an expert educational content creator for "StudyReps".

A student has uploaded a study document${fileName != null ? ' named "$fileName"' : ''}.
Your task is to READ this document thoroughly and extract the core concepts to create high-quality study reps (questions).

═══ TASK ═══
1. Analyze the attached document content deepy.
2. Identify $count distinct, key concepts or facts.
3. For EACH concept, create a challenging multiple-choice question.

═══ RESPONSE FORMAT ═══
Return ONLY a strictly valid JSON array. Do not include markdown formatting (like ```json ... ```) or any other text.
Structure:
[
  {
    "title": "Concept Title (max 50 chars)",
    "subject": "Subject (e.g. Physics, History)",
    "topic": "Specific Topic",
    "question": "The question text?",
    "correctAnswer": "The correct answer",
    "wrongOption1": "Wrong answer 1",
    "wrongOption2": "Wrong answer 2",
    "wrongOption3": "Wrong answer 3",
    "hint": "A helpful hint",
    "explanation": "Why the answer is correct (reference the document)"
  }
]

═══ CRITICAL RULES ═══
- The questions MUST be based on the provided document content.
- If the document is an image of text, read the text.
- If the document is a diagram, interpret it.
- Ensure valid JSON syntax.
''';

    final url = Uri.parse(
      '${AppConstants.geminiBaseUrl}/models/${AppConstants.geminiModel}:generateContent?key=$apiKey',
    );

    try {
      debugPrint('🌐 Sending request to Gemini (${AppConstants.geminiModel})...');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'inline_data': {
                    'mime_type': mimeType,
                    'data': base64Data,
                  }
                },
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.5,
            'maxOutputTokens': 8192, // Increased to max to prevent JSON truncation
            'topP': 0.95,
          },
        }),
      );

      debugPrint('📡 Gemini Response Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('❌ API Error Body: ${response.body}');
        throw Exception('Gemini API Error (${response.statusCode}): ${response.body}');
      }

      final data = jsonDecode(response.body);
      
      // Check for safety blocking or other finish reasons
      final candidate = data['candidates']?[0];
      final finishReason = candidate?['finishReason'];
      if (finishReason != 'STOP') {
        debugPrint('⚠️ Finish Reason: $finishReason');
        if (finishReason == 'SAFETY') {
          throw Exception('Content blocked for safety reasons.');
        } else if (finishReason == 'RECITATION') {
          throw Exception('Content blocked (recitation).');
        }
      }

      final text = candidate?['content']?['parts']?[0]?['text'];

      if (text == null) {
        throw Exception('No content generated by AI.');
      }

      debugPrint('✅ Raw AI Response (first 200 chars): ${text.substring(0, text.length > 200 ? 200 : text.length)}');

      final reps = _parseMultipleRepsFromJson(text.toString().trim());
      if (reps.isEmpty) {
        throw Exception('Failed to parse AI response into study reps.');
      }
      return reps;

    } catch (e) {
      debugPrint('❌ RepGenerator multi error: $e');
      rethrow;
    }
  }

  /// Parse a single rep from Gemini JSON response
  static VideoModel? _parseRepFromJson(String rawText) {
    try {
      // Strip markdown code fences if present (more robust regex)
      var cleaned = rawText.trim();
      final codeBlockRegex = RegExp(r'^```[a-z]*\s*([\s\S]*?)\s*```$', caseSensitive: false);
      final match = codeBlockRegex.firstMatch(cleaned);
      if (match != null) {
        cleaned = match.group(1) ?? cleaned;
      }

      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      return _jsonToVideoModel(json);
    } catch (e) {
      debugPrint('❌ Parse error: $e\nRaw: $rawText');
      return null;
    }
  }

  /// Parse multiple reps from Gemini JSON array response
  static List<VideoModel> _parseMultipleRepsFromJson(String rawText) {
    try {
      var cleaned = rawText.trim();
      
      // 1. Strip markdown code fences
      final codeBlockRegex = RegExp(r'^```[a-z]*\s*([\s\S]*?)\s*```$', caseSensitive: false);
      final match = codeBlockRegex.firstMatch(cleaned);
      if (match != null) {
        cleaned = match.group(1) ?? cleaned;
      }
      cleaned = cleaned.trim();

      // 2. Try parsing directly
      final list = jsonDecode(cleaned) as List<dynamic>;
      return list
          .map((json) => _jsonToVideoModel(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Parse multi error: $e. Attempting repair...');
      
      // 3. Attempt to repair truncated JSON
      // If the array wasn't closed, find the last closing brace '}' and close the array provided it's part of an object.
      try {
        var repaired = rawText.trim();
        // Remove markdown first
        final codeBlockRegex = RegExp(r'^```[a-z]*\s*([\s\S]*?)\s*```$', caseSensitive: false);
        final match = codeBlockRegex.firstMatch(repaired);
        if (match != null) {
          repaired = match.group(1) ?? repaired;
        }
        repaired = repaired.trim();

        // Find the last occurrence of "}," which indicates the end of a complete object in a list
        final lastObjectEnd = repaired.lastIndexOf('},');
        if (lastObjectEnd != -1) {
          // Keep everything up to the closing brace '}'
          repaired = repaired.substring(0, lastObjectEnd + 1);
          // Close the array
          repaired += ']';
          debugPrint('🔧 Repaired JSON: ${repaired.substring(0, 50)}...${repaired.substring(repaired.length - 20)}');
          
          final list = jsonDecode(repaired) as List<dynamic>;
          return list
              .map((json) => _jsonToVideoModel(json as Map<String, dynamic>))
              .toList();
        }
      } catch (repairError) {
        debugPrint('❌ Repair failed: $repairError');
      }

      // 4. Fallback: Try parsing as single object if it's not a list
      final single = _parseRepFromJson(rawText);
      return single != null ? [single] : [];
    }
  }

  /// Convert parsed JSON to VideoModel
  static VideoModel _jsonToVideoModel(Map<String, dynamic> json) {
    final uuid = const Uuid();
    final id = uuid.v4();

    final correctAnswer = json['correctAnswer'] ?? 'Answer';
    final options = [
      correctAnswer,
      json['wrongOption1'] ?? 'Option B',
      json['wrongOption2'] ?? 'Option C',
      json['wrongOption3'] ?? 'Option D',
    ]..shuffle(); // Randomize option order

    final correctIndex = options.indexOf(correctAnswer);

    // Pick a placeholder video
    final videoIndex = id.hashCode.abs() % _placeholderVideos.length;

    return VideoModel(
      id: 'ai_$id',
      title: json['title'] ?? 'AI Generated Rep',
      subject: json['subject'] ?? 'General',
      creatorName: 'AI Generator',
      videoUrl: _placeholderVideos[videoIndex],
      lockTimestamp: 3, // Lock early since it's AI-generated
      topicId: json['topic'] ?? '',
      conceptCluster: json['subject'] ?? '',
      question: QuestionModel(
        id: 'q_$id',
        prompt: json['question'] ?? 'Question',
        correctAnswer: correctAnswer.toString(),
        type: QuestionType.multipleChoice,
        options: options.map((o) => o.toString()).toList(),
        hint: json['hint'] ?? '',
        explanation: json['explanation'] ?? '',
      ),
    );
  }
}
