import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/video_model.dart';

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

  /// Get coaching feedback from Gemini API via Edge Function
  static Future<String> _getGeminiFeedback({
    required String userAnswer,
    required String correctAnswer,
    required String questionPrompt,
  }) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'gemini-coach',
        body: {
          'action': 'validateAnswer',
          'userAnswer': userAnswer,
          'correctAnswer': correctAnswer,
          'questionPrompt': questionPrompt,
          'enableThinking': AppConstants.enableThinking,
          'thinkingBudget': AppConstants.thinkingBudget,
        },
      );

      final data = response.data;
      final candidates = data['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final parts = candidates[0]['content']?['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          for (final part in parts.reversed) {
            if (part['text'] != null && part['thought'] != true) {
              return part['text'].toString().trim();
            }
          }
          return parts.last['text']?.toString().trim() ??
              'The correct answer is "$correctAnswer".';
        }
      }
      return 'The correct answer is "$correctAnswer".';
    } catch (e) {
      throw GeminiException('API returned an error: $e');
    }
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

  /// NEW: Generate a context-aware question based on video metadata/transcript
  static Future<QuestionModel> generateDynamicQuestion(VideoModel video) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'gemini-coach',
        body: {
          'action': 'generateDynamicQuestion',
          'title': video.title,
          'subject': video.subject,
          'creatorName': video.creatorName,
          'tags': video.tags,
          'transcriptSnippet': video.transcript.length > 500 ? video.transcript.substring(0, 500) : video.transcript,
        },
      );

      final data = response.data;
      final candidates = data['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final parts = candidates[0]['content']?['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          final text = parts[0]['text'] as String;
          // Handle optional markdown wrapping in API response
          String cleanJson = text.replaceAll('```json', '').replaceAll('```', '').trim();
          
          if (cleanJson.contains('{') && cleanJson.contains('}')) {
            int firstBrace = cleanJson.indexOf('{');
            int lastBrace = cleanJson.lastIndexOf('}');
            cleanJson = cleanJson.substring(firstBrace, lastBrace + 1);
          }
          
          final json = jsonDecode(cleanJson);
          
          return QuestionModel(
            id: 'ai_gen_${DateTime.now().millisecondsSinceEpoch}',
            prompt: json['prompt'],
            correctAnswer: json['correctAnswer'],
            type: QuestionType.multipleChoice,
            options: List<String>.from(json['options']),
            hint: json['hint'] ?? '',
            explanation: json['explanation'] ?? '',
          );
        }
      }
    } catch (e) {
      print('⚠️ AI Question Generation Error: $e');
    }
    
    return video.question; // Fallback to hardcoded question
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
