import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

/// GeminiCoachService - AI-powered coaching for StudyReps
///
/// Uses Google Gemini API to provide instant, specific feedback on answers.
/// The "Bold Coach" gives 1-sentence feedback, no fluff.
class GeminiCoachService {
  static const String _baseUrl = AppConstants.geminiBaseUrl;
  static const String _model = AppConstants.geminiModel;
  
  /// Validate an answer and get coaching feedback
  /// 
  /// [userAnswer] - The student's answer
  /// [correctAnswer] - The correct answer
  /// [questionPrompt] - The original question for context
  /// 
  /// Returns coaching feedback or "CORRECT" if answer is right
  static Future<CoachingResult> validateAnswer({
    required String userAnswer,
    required String correctAnswer,
    required String questionPrompt,
  }) async {
    // Quick local check first
    final isCorrect = _isAnswerCorrect(userAnswer, correctAnswer);
    
    if (isCorrect) {
      return const CoachingResult(
        isCorrect: true,
        feedback: 'CORRECT',
        encouragement: '💪 Great rep!',
      );
    }

    // Get AI coaching feedback for incorrect answers
    try {
      final feedback = await _getGeminiFeedback(
        userAnswer: userAnswer,
        correctAnswer: correctAnswer,
        questionPrompt: questionPrompt,
      );
      
      return CoachingResult(
        isCorrect: false,
        feedback: feedback,
        encouragement: 'Keep pushing! 🔥',
      );
    } catch (e) {
      // Fallback to simple feedback if API fails
      return CoachingResult(
        isCorrect: false,
        feedback: 'The correct answer is "$correctAnswer". Try again!',
        encouragement: 'You got this! 💪',
      );
    }
  }

  /// Simple local answer comparison
  static bool _isAnswerCorrect(String userAnswer, String correctAnswer) {
    final normalizedUser = userAnswer.trim().toLowerCase();
    final normalizedCorrect = correctAnswer.trim().toLowerCase();
    
    // Exact match
    if (normalizedUser == normalizedCorrect) return true;
    
    // Number comparison (handle "56" vs "56.0")
    final userNum = double.tryParse(normalizedUser);
    final correctNum = double.tryParse(normalizedCorrect);
    if (userNum != null && correctNum != null && userNum == correctNum) {
      return true;
    }
    
    return false;
  }

  /// Get coaching feedback from Gemini API
  static Future<String> _getGeminiFeedback({
    required String userAnswer,
    required String correctAnswer,
    required String questionPrompt,
  }) async {
    final apiKey = AppConstants.geminiApiKey;
    
    // Skip API call if no key configured
    if (apiKey == 'YOUR_GEMINI_API_KEY') {
      return 'The correct answer is "$correctAnswer". Compare with your answer and try again.';
    }
    
    final prompt = '''
You are a strict but encouraging logic coach in a learning app. 
The student was asked: "$questionPrompt"
Their answer: "$userAnswer"
The correct answer is: "$correctAnswer"

Give EXACTLY 1 sentence of specific, actionable feedback. No fluff.
Be direct but kind. Focus on WHY they might have gotten it wrong.
''';

    final url = Uri.parse(
      '$_baseUrl/models/$_model:generateContent?key=$apiKey'
    );

    // Build the request body with optional thinking config
    final requestBody = <String, dynamic>{
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 150,
      },
    };

    // Enable thinking mode for deeper reasoning on answers
    if (AppConstants.enableThinking) {
      (requestBody['generationConfig'] as Map<String, dynamic>)['thinkingConfig'] = {
        'thinkingBudget': AppConstants.thinkingBudget,
      };
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final candidates = data['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        // With thinking enabled, the model may return multiple parts.
        // The actual text response is in the last non-thinking part.
        final parts = candidates[0]['content']?['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          // Find the actual text response (skip any "thought" parts)
          for (final part in parts.reversed) {
            if (part['text'] != null && part['thought'] != true) {
              return part['text'].toString().trim();
            }
          }
          // Fallback: just use the last part's text
          return parts.last['text']?.toString().trim() ?? 
              'The correct answer is "$correctAnswer".';
        }
      }
      return 'The correct answer is "$correctAnswer".';
    }

    throw GeminiException(
      'API returned ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }

  /// Test API connection
  static Future<bool> testConnection() async {
    try {
      final result = await validateAnswer(
        userAnswer: 'test',
        correctAnswer: 'test',
        questionPrompt: 'Connection test',
      );
      return result.isCorrect;
    } catch (e) {
      return false;
    }
  }
}

/// Result from coaching validation
class CoachingResult {
  final bool isCorrect;
  final String feedback;
  final String encouragement;

  const CoachingResult({
    required this.isCorrect,
    required this.feedback,
    this.encouragement = '',
  });
}

/// Custom exception for Gemini-related errors
class GeminiException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  GeminiException(this.message, {this.statusCode, this.details});

  @override
  String toString() {
    if (statusCode != null) {
      return 'GeminiException [$statusCode]: $message';
    }
    return 'GeminiException: $message';
  }
}
