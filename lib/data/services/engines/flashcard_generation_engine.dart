import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../domain/models/video_model.dart';
import 'review_queue_service.dart';

/// FlashcardGenerationEngine
///
/// Generates structured concept-level flashcards using a fixed
/// pedagogical template. All output is PENDING review — not live until approved.
///
/// Card architecture (6 cards, fixed taxonomy):
///   C1: Definition (What IS it, precisely?)
///   C2: Core Principle / Formula (The governing rule, stated completely)
///   C3: Mechanism (HOW does it work — cause → effect chain)
///   C4: Application (WHERE / WHEN to use it — a concrete scenario)
///   C5: Contrast (What is it NOT — distinguish from the closest imposter concept)
///   C6: Failure Mode (What breaks when this concept is violated or misapplied?)
class FlashcardGenerationEngine {
  /// Generate flashcards for [video] and push them into the review queue.
  static Future<List<ReviewItem>> generateAndQueue(VideoModel video) async {
    debugPrint('🃏 FlashcardEngine: generating for "${video.title}"');
    final cards = await _callGemini(video);
    final items = cards
        .map((c) => ReviewItem.flashcard(videoId: video.id, videoTitle: video.title, content: c))
        .toList();
    await ReviewQueueService.addAll(items);
    debugPrint('✅ FlashcardEngine: queued ${items.length} cards for review');
    return items;
  }

  static Future<List<GeneratedFlashcard>> _callGemini(VideoModel video) async {
    final k = AppConstants.geminiApiKey;
    if (k.isEmpty || k == 'YOUR_GEMINI_API_KEY') {
      return _expertFallback(video);
    }

    final transcript = video.transcript.isNotEmpty
        ? video.transcript.substring(0, video.transcript.length.clamp(0, 2000))
        : '(no transcript — use title and subject to infer likely content)';

    // ── THE PROMPT ──────────────────────────────────────────────────────────
    // Each card has a FIXED slot in a pedagogical sequence.
    // The back must be a TEACHING explanation, not an answer stub.
    // The student must be able to reconstruct understanding from the back alone.
    final prompt = '''
You are a master teacher preparing spaced-repetition flashcards for a student studying ${video.subject} at secondary/higher-secondary level.
These cards go through a human review process, so produce your best work — not a quick draft.

═══ TOPIC ═══
"${video.title}" — ${video.subject}

TRANSCRIPT:
"$transcript"

═══ YOUR TASK ═══
Generate EXACTLY 6 flashcards. Each card has a FIXED role — do not change the slot order:

SLOT 1 — DEFINITION
Front: "Define [concept] precisely in one sentence."
Back: The actual definition — use subject-specific terminology, state what the concept IS (not what it does). 
      Include the unit/dimension if applicable (e.g., "measured in Newtons").

SLOT 2 — CORE PRINCIPLE / FORMULA
Front: "State the governing formula or rule for [concept] completely."
Back: The formula/rule written out, PLUS what each variable/term means.
      If there is no formula, state the governing law/principle in one precise sentence.

SLOT 3 — MECHANISM
Front: "Explain HOW [concept] works — trace the cause-to-effect chain."
Back: 2–3 sentences that trace what happens in sequence: input → process → output.
      Do NOT just restate the definition. Explain the WHY behind the mechanism.

SLOT 4 — APPLICATION
Front: "Describe a specific scenario in ${video.subject} where [concept] determines the outcome. What happens and why?"
Back: A concrete, named scenario (not "everyday life"). Identify the role of the concept explicitly.
     The outcome must be derivable from the principle, not just asserted.

SLOT 5 — CONTRAST
Front: "How is [concept] different from [the most commonly confused related concept]? Where do students go wrong?"
Back: Name the impostor concept. State one thing they share (which causes confusion), then state the key difference.
     End with a memory anchor or rule of thumb.

SLOT 6 — FAILURE MODE
Front: "What goes wrong in a real ${video.subject} problem if [concept] is misunderstood or ignored?"
Back: Describe a specific type of error or incorrect result. Explain which step in reasoning fails and why.
     This should feel like a "warning" — not a positive statement about the concept.

═══ QUALITY RULES ═══
- Every back must be SELF-CONTAINED — a student who has never seen the video should understand it
- NEVER use "This concept is important because..." or "This builds the foundation for..."
- Use PRECISE values, names, or formulas from the transcript wherever available
- Difficulty: Slots 1–2 = easy, Slots 3–4 = medium, Slots 5–6 = hard

═══ OUTPUT FORMAT ═══
Return ONLY a valid JSON array. No markdown. No preamble.
[
  {
    "slot": 1,
    "label": "Definition|Principle|Mechanism|Application|Contrast|Failure Mode",
    "front": "The question on the front of the card",
    "back": "Complete teaching explanation (2-4 sentences)",
    "memory_hook": "A mnemonic, rhyme, or memorable anchor phrase for this card",
    "difficulty": "easy|medium|hard"
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
            'temperature': 0.55,
            'maxOutputTokens': 2500,
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
        return list.map((j) => GeneratedFlashcard.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint('⚠️ FlashcardEngine API error: $e');
    }
    return _expertFallback(video);
  }

  static List<GeneratedFlashcard> _expertFallback(VideoModel video) {
    return [
      GeneratedFlashcard(
        slot: 1, label: 'Definition',
        front: 'Define "${video.title}" precisely. What IS it — in subject-specific terms?',
        back: 'A precise definition names the concept, states its category, and distinguishes it from related terms using ${video.subject} vocabulary. Vague paraphrasing ("it\'s about...") does not count.',
        memoryHook: 'If you can\'t say it in one sentence using the right words, you\'ve memorised the idea but not the concept.',
        difficulty: 'easy',
      ),
      GeneratedFlashcard(
        slot: 2, label: 'Principle',
        front: 'State the governing rule or formula for "${video.title}" completely, including what each term means.',
        back: 'Every concept in ${video.subject} has a governing principle. Write it out in full — formula, law, or rule — then annotate each variable or term. Missing any part means incomplete recall.',
        memoryHook: 'The formula is the skeleton. The variable definitions are the muscles. You need both.',
        difficulty: 'easy',
      ),
      GeneratedFlashcard(
        slot: 3, label: 'Mechanism',
        front: 'Trace the cause-to-effect chain of "${video.title}". What triggers it, what happens during it, what results from it?',
        back: 'A mechanism explanation has three parts: (1) what initiates the process, (2) what happens step-by-step, (3) what the final state or output is. Restating the definition does not answer this question.',
        memoryHook: 'Input → Process → Output. If you can\'t fill all three, you know the word but not the concept.',
        difficulty: 'medium',
      ),
      GeneratedFlashcard(
        slot: 4, label: 'Application',
        front: 'Name a specific scenario in ${video.subject} where "${video.title}" determines the outcome. What is the outcome and why?',
        back: 'Application requires a named, concrete situation — not "in everyday life." The concept must be the determining factor, and the outcome must follow from the principle, not from intuition.',
        memoryHook: 'If your example could work for ANY concept, it\'s too vague. Make it specific to this one.',
        difficulty: 'medium',
      ),
      GeneratedFlashcard(
        slot: 5, label: 'Contrast',
        front: 'What concept is most often confused with "${video.title}"? What do they share, and where is the critical difference?',
        back: 'Contrast questions reveal whether you truly understand the boundary of a concept. The impostor concept shares surface features but differs in mechanism, condition, or scope. Knowing the boundary is the mark of deep understanding.',
        memoryHook: 'If you can\'t name what it\'s NOT, you probably can\'t reliably identify when to use it.',
        difficulty: 'hard',
      ),
      GeneratedFlashcard(
        slot: 6, label: 'Failure Mode',
        front: 'What specific error does a student make in a ${video.subject} problem when they misunderstand "${video.title}"?',
        back: 'Failure modes expose the exact point in reasoning where misunderstanding strikes. Knowing the failure mode — which step produces the wrong result and why — is stronger evidence of mastery than being able to define the concept.',
        memoryHook: 'Knowing how something breaks tells you exactly how it works.',
        difficulty: 'hard',
      ),
    ];
  }
}

// ─── Data Models ─────────────────────────────────────────────────────────────

class GeneratedFlashcard {
  final int slot;
  final String label;
  final String front;
  final String back;
  final String memoryHook;
  final String difficulty;

  const GeneratedFlashcard({
    required this.slot,
    required this.label,
    required this.front,
    required this.back,
    required this.memoryHook,
    required this.difficulty,
  });

  factory GeneratedFlashcard.fromJson(Map<String, dynamic> j) {
    return GeneratedFlashcard(
      slot: (j['slot'] as num?)?.toInt() ?? 1,
      label: j['label'] ?? 'Card',
      front: j['front'] ?? '',
      back: j['back'] ?? '',
      memoryHook: j['memory_hook'] ?? '',
      difficulty: j['difficulty'] ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() => {
    'slot': slot,
    'label': label,
    'front': front,
    'back': back,
    'memory_hook': memoryHook,
    'difficulty': difficulty,
  };
}
