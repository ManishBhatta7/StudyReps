import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../domain/models/video_model.dart';

/// Quiz Generator Service
///
/// Uses Gemini AI to auto-generate active recall questions from video
/// transcripts. Generates a mix of question types including open-input
/// (free text) questions — not just multiple choice — to force genuine
/// knowledge retrieval rather than pattern matching.
///
/// This combats the "illusion of competence" caused by passive watching.
class QuizGeneratorService {
  /// Generate quiz questions from a video's transcript
  static Future<List<GeneratedQuestion>> generateQuiz({
    required VideoModel video,
    int questionCount = 3,
    QuestionDifficulty targetDifficulty = QuestionDifficulty.mixed,
  }) async {
    final apiKey = AppConstants.geminiApiKey;

    // Fallback if no API key or no transcript
    if (apiKey == 'YOUR_GEMINI_API_KEY' || video.transcript.isEmpty) {
      return _generateFallbackQuestions(video);
    }

    try {
      return await _generateWithGemini(
        video: video,
        questionCount: questionCount,
        targetDifficulty: targetDifficulty,
      );
    } catch (e) {
      debugPrint('❌ QuizGen: Error generating quiz: $e');
      return _generateFallbackQuestions(video);
    }
  }

  /// Generate questions using Gemini API
  static Future<List<GeneratedQuestion>> _generateWithGemini({
    required VideoModel video,
    required int questionCount,
    required QuestionDifficulty targetDifficulty,
  }) async {
    final difficultyStr = targetDifficulty == QuestionDifficulty.mixed
        ? 'a mix of easy, medium, and hard'
        : targetDifficulty.name;

    final prompt = '''
You are an expert educational quiz generator for a learning app called StudyReps.

VIDEO CONTEXT:
- Title: "${video.title}"
- Subject: "${video.subject}"
- Topic: "${video.topicId}"
- Transcript: "${video.transcript}"

Generate exactly $questionCount active recall questions based on this content.

RULES:
1. At least 40% must be "open_input" type (free text, no options) to force genuine recall
2. Include a mix of: open_input, multiple_choice, true_false
3. Difficulty: $difficultyStr
4. Questions should test UNDERSTANDING, not just memorization
5. Include one "application" question that asks the student to apply the concept

RESPOND IN JSON ARRAY FORMAT:
[
  {
    "type": "open_input" | "multiple_choice" | "true_false",
    "prompt": "question text",
    "correct_answer": "the correct answer",
    "options": ["opt1", "opt2", "opt3", "opt4"],  // only for multiple_choice
    "explanation": "why this is correct",
    "difficulty": 1-3,
    "hint": "optional hint"
  }
]

RESPOND WITH ONLY THE JSON ARRAY, NO OTHER TEXT.
''';

    final url = Uri.parse(
      '${AppConstants.geminiBaseUrl}/models/${AppConstants.geminiModel}:generateContent?key=${AppConstants.geminiApiKey}',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 1500,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String rawText = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '[]';

      // Clean up markdown code block wrappers if present
      rawText = rawText.replaceAll('```json', '').replaceAll('```', '').trim();

      final List<dynamic> questionsJson = jsonDecode(rawText);
      return questionsJson.map((q) => GeneratedQuestion.fromJson(q)).toList();
    }

    throw Exception('Gemini API returned ${response.statusCode}');
  }

  /// Fallback questions when API is unavailable
  static List<GeneratedQuestion> _generateFallbackQuestions(VideoModel video) {
    return [
      GeneratedQuestion(
        type: GeneratedQuestionType.openInput,
        prompt: 'In your own words, explain the main concept from "${video.title}".',
        correctAnswer: '', // Open-ended, evaluated by AI
        explanation: 'This tests your ability to recall and articulate the core concept.',
        difficulty: 2,
        hint: 'Think about what was the central idea of the video.',
      ),
      const GeneratedQuestion(
        type: GeneratedQuestionType.openInput,
        prompt: 'Give a real-world example of the concept discussed in this video.',
        correctAnswer: '',
        explanation: 'Applying concepts to real-world scenarios deepens understanding.',
        difficulty: 3,
        hint: 'Think about everyday situations where this concept applies.',
      ),
      const GeneratedQuestion(
        type: GeneratedQuestionType.openInput,
        prompt: 'What would happen if the opposite of what was explained in the video were true?',
        correctAnswer: '',
        explanation: 'Thinking about counter-examples helps solidify understanding.',
        difficulty: 3,
      ),
    ];
  }

  /// Evaluate an open-input answer using Gemini
  static Future<QuizEvaluation> evaluateOpenAnswer({
    required String userAnswer,
    required GeneratedQuestion question,
    required VideoModel video,
  }) async {
    final apiKey = AppConstants.geminiApiKey;
    if (apiKey == 'YOUR_GEMINI_API_KEY') {
      return const QuizEvaluation(
        score: 0.5,
        feedback: 'API not configured. Your answer has been recorded.',
        isAcceptable: true,
      );
    }

    final prompt = '''
You are evaluating a student's answer in an educational app.

QUESTION: "${question.prompt}"
EXPECTED ANSWER/CONCEPT: "${question.correctAnswer}"
STUDENT'S ANSWER: "$userAnswer"
VIDEO TOPIC: "${video.title}" - ${video.subject}

Evaluate the answer and respond in JSON:
{
  "score": 0.0-1.0,
  "is_acceptable": true/false,
  "feedback": "1-2 sentences of specific, constructive feedback"
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
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.3,
          'maxOutputTokens': 200,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String rawText = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '{}';
      rawText = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
      final evalJson = jsonDecode(rawText);
      return QuizEvaluation(
        score: (evalJson['score'] as num?)?.toDouble() ?? 0.5,
        feedback: evalJson['feedback'] ?? 'Answer recorded.',
        isAcceptable: evalJson['is_acceptable'] ?? true,
      );
    }

    return const QuizEvaluation(
      score: 0.5,
      feedback: 'Could not evaluate. Your answer has been saved.',
      isAcceptable: true,
    );
  }
}

// ─── Data Models ───

enum GeneratedQuestionType { openInput, multipleChoice, trueFalse }
enum QuestionDifficulty { easy, medium, hard, mixed }

class GeneratedQuestion {
  final GeneratedQuestionType type;
  final String prompt;
  final String correctAnswer;
  final List<String>? options;
  final String explanation;
  final int difficulty;
  final String? hint;

  const GeneratedQuestion({
    required this.type,
    required this.prompt,
    required this.correctAnswer,
    this.options,
    required this.explanation,
    required this.difficulty,
    this.hint,
  });

  factory GeneratedQuestion.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] ?? 'open_input';
    GeneratedQuestionType type;
    switch (typeStr) {
      case 'multiple_choice':
        type = GeneratedQuestionType.multipleChoice;
        break;
      case 'true_false':
        type = GeneratedQuestionType.trueFalse;
        break;
      default:
        type = GeneratedQuestionType.openInput;
    }

    return GeneratedQuestion(
      type: type,
      prompt: json['prompt'] ?? '',
      correctAnswer: json['correct_answer'] ?? '',
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      explanation: json['explanation'] ?? '',
      difficulty: json['difficulty'] ?? 2,
      hint: json['hint'],
    );
  }
}

class QuizEvaluation {
  final double score;
  final String feedback;
  final bool isAcceptable;

  const QuizEvaluation({
    required this.score,
    required this.feedback,
    required this.isAcceptable,
  });
}
