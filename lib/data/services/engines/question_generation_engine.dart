import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../domain/models/video_model.dart';
import 'review_queue_service.dart';

/// QuestionGenerationEngine
///
/// Generates exam-quality questions across Bloom's taxonomy levels.
/// All output goes into [ReviewQueueService] as PENDING — never served
/// directly to students until manually approved.
class QuestionGenerationEngine {
  /// Generate a full set of questions for a video and queue them for review.
  /// Returns the list of generated [ReviewItem]s so the caller can navigate
  /// directly to the review screen.
  static Future<List<ReviewItem>> generateAndQueue(VideoModel video) async {
    debugPrint('🧠 QuestionEngine: generating for "${video.title}"');
    final questions = await _callGemini(video);
    final items = questions
        .map((q) => ReviewItem.question(videoId: video.id, videoTitle: video.title, content: q))
        .toList();
    await ReviewQueueService.addAll(items);
    debugPrint('✅ QuestionEngine: queued ${items.length} questions for review');
    return items;
  }

  static Future<List<GeneratedQuestion>> _callGemini(VideoModel video) async {
    final k = AppConstants.geminiApiKey;
    if (k.isEmpty || k == 'YOUR_GEMINI_API_KEY') {
      return _expertFallback(video);
    }

    final transcript = video.transcript.isNotEmpty
        ? video.transcript.substring(0, video.transcript.length.clamp(0, 2000))
        : '(no transcript — use title and subject to infer likely content)';

    // ── THE PROMPT ──────────────────────────────────────────────────────────
    // Structured around Bloom's Taxonomy:
    //   L1 Remember → L2 Understand → L3 Apply → L4 Analyze → L5 Evaluate
    // Each level demands a qualitatively different cognitive operation.
    // Banned: surface-recall, "what is the main idea", definition restatements.
    final prompt = '''
You are a senior curriculum designer and exam setter for competitive exams (JEE, NEET, IGCSE, CBSE board level).
Your job: create EXAM-GRADE questions that genuinely test whether a student understands the concept, not whether they watched the video.

═══ VIDEO CONTEXT ═══
Title: "${video.title}"
Subject: ${video.subject}
Transcript: "$transcript"

═══ YOUR TASK ═══
Generate EXACTLY 8 questions covering all 5 levels of Bloom's Taxonomy.
Produce one question per level plus extras at Apply/Analyze since those are hardest to self-generate.

MANDATORY STRUCTURE — one question per level, in this order:
1. [REMEMBER]   A precise definition or statement retrieval (NOT "what is the main idea")
2. [UNDERSTAND] Ask them to explain the mechanism/process in their own words
3. [UNDERSTAND] Ask them to distinguish this concept from a closely related, commonly confused concept
4. [APPLY]      Give a specific numerical scenario or real-world situation — ask them to predict the outcome
5. [APPLY]      Ask them to identify where this concept applies (or fails) in a described scenario
6. [ANALYZE]    Ask them to break down why a common mistake or misconception is wrong, citing the principle
7. [ANALYZE]    Ask them to compare two approaches/methods and explain which is better and why
8. [EVALUATE]   Ask them to judge a flawed argument or solution and explain the error using the principle

═══ STRICT QUALITY RULES ═══
- Every question must be answerable ONLY by someone who genuinely understood this specific video's content
- NEVER ask "What is the main idea?", "Why is this important?", or "Give an example of X"
- Use SPECIFIC values, names, formulas, or scenarios from the transcript where possible
- The correct_answer must be a complete, 2–4 sentence explanation — not a one-word label
- The distractor_rationale must explain WHY a student who half-understood would pick each wrong option
- For open_input questions, correct_answer should be a model answer a teacher would accept

═══ OUTPUT FORMAT ═══
Return ONLY a valid JSON array. No markdown. No preamble.
[
  {
    "bloom_level": "REMEMBER|UNDERSTAND|APPLY|ANALYZE|EVALUATE",
    "type": "multiple_choice|open_input",
    "prompt": "The full question text",
    "correct_answer": "Complete model answer (2-4 sentences)",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correct_option_index": 0,
    "explanation": "Why this answer is correct — citing the principle from the video",
    "distractor_rationale": "Why wrong options seem plausible (1 sentence each, semicolon-separated)",
    "hint": "A Socratic nudge — not the answer, but a pointer to the right reasoning",
    "difficulty": 1|2|3
  }
]
''';
    // ────────────────────────────────────────────────────────────────────────

    try {
      final url = Uri.parse(
        '${AppConstants.geminiBaseUrl}/models/${AppConstants.geminiModel}:generateContent?key=$k',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}],
          'generationConfig': {
            'temperature': 0.5,   // Lower = more accurate/factual
            'maxOutputTokens': 3000,
            'responseMimeType': 'application/json',
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String raw = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '[]';
        raw = raw.replaceAll('```json', '').replaceAll('```', '').trim();
        if (raw.contains('[')) {
          raw = raw.substring(raw.indexOf('['), raw.lastIndexOf(']') + 1);
        }
        final List<dynamic> list = jsonDecode(raw);
        return list.map((j) => GeneratedQuestion.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint('⚠️ QuestionEngine API error: $e');
    }
    return _expertFallback(video);
  }

  /// Expert-authored fallback questions that are still pedagogically sound.
  static List<GeneratedQuestion> _expertFallback(VideoModel video) {
    return [
      GeneratedQuestion(
        bloomLevel: 'REMEMBER',
        type: 'open_input',
        prompt: 'State the precise definition of the core concept from "${video.title}". Use subject-specific vocabulary from ${video.subject}.',
        correctAnswer: 'A complete answer names the concept precisely, states what it is (not what it does), and uses at least one domain-specific term from ${video.subject}.',
        explanation: 'Precise definitions are the foundation — vague paraphrasing usually indicates shallow encoding.',
        hint: 'Focus on what the concept IS, not what it DOES or why it matters.',
        difficulty: 1,
      ),
      GeneratedQuestion(
        bloomLevel: 'UNDERSTAND',
        type: 'open_input',
        prompt: 'Without restating the definition: explain WHY the mechanism in "${video.title}" works the way it does. What underlying principle drives it?',
        correctAnswer: 'A correct answer identifies the causal chain or governing principle — not just the outcome. It should explain what would change if conditions were altered.',
        explanation: 'Understanding requires explaining causation, not just correlation or definition.',
        hint: 'Ask yourself: what would break if you changed one variable in this process?',
        difficulty: 2,
      ),
      GeneratedQuestion(
        bloomLevel: 'APPLY',
        type: 'open_input',
        prompt: 'Describe a specific real-world scenario in ${video.subject} where "${video.title}" directly determines an observable outcome. What is the outcome, and why?',
        correctAnswer: 'The answer must name a concrete scenario (not "everyday life"), identify the specific role of the concept, and correctly predict the outcome using the principle.',
        explanation: 'Application questions reveal whether knowledge can transfer from the example in the video to novel contexts.',
        hint: 'Think of a scenario where ignoring this concept would lead to a measurably wrong result.',
        difficulty: 2,
      ),
      GeneratedQuestion(
        bloomLevel: 'ANALYZE',
        type: 'open_input',
        prompt: 'A common misconception about "${video.title}" is that [students often confuse it with a related concept]. Identify that misconception and explain, using the principle from ${video.subject}, exactly why it is wrong.',
        correctAnswer: 'A strong answer names the specific misconception, explains why it feels intuitive, then dismantles it using the correct principle with at least one concrete counter-example.',
        explanation: 'Identifying why wrong answers are wrong is a stronger signal of mastery than just knowing the right answer.',
        hint: 'What would someone who half-paid-attention to this video get wrong?',
        difficulty: 3,
      ),
    ];
  }
}

// ─── Data Models ─────────────────────────────────────────────────────────────

class GeneratedQuestion {
  final String bloomLevel;
  final String type;
  final String prompt;
  final String correctAnswer;
  final List<String>? options;
  final int? correctOptionIndex;
  final String explanation;
  final String? distractorRationale;
  final String? hint;
  final int difficulty;

  const GeneratedQuestion({
    required this.bloomLevel,
    required this.type,
    required this.prompt,
    required this.correctAnswer,
    this.options,
    this.correctOptionIndex,
    required this.explanation,
    this.distractorRationale,
    this.hint,
    required this.difficulty,
  });

  factory GeneratedQuestion.fromJson(Map<String, dynamic> j) {
    return GeneratedQuestion(
      bloomLevel: j['bloom_level'] ?? 'UNDERSTAND',
      type: j['type'] ?? 'open_input',
      prompt: j['prompt'] ?? '',
      correctAnswer: j['correct_answer'] ?? '',
      options: j['options'] != null ? List<String>.from(j['options']) : null,
      correctOptionIndex: j['correct_option_index'],
      explanation: j['explanation'] ?? '',
      distractorRationale: j['distractor_rationale'],
      hint: j['hint'],
      difficulty: (j['difficulty'] as num?)?.toInt() ?? 2,
    );
  }

  Map<String, dynamic> toJson() => {
    'bloom_level': bloomLevel,
    'type': type,
    'prompt': prompt,
    'correct_answer': correctAnswer,
    'options': options,
    'correct_option_index': correctOptionIndex,
    'explanation': explanation,
    'distractor_rationale': distractorRationale,
    'hint': hint,
    'difficulty': difficulty,
  };
}
