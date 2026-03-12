import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../data/services/chat_persistence_service.dart';
import '../../domain/models/video_model.dart';

/// Chat state for a single tutorbot conversation
class TutorbotState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final String videoId;

  const TutorbotState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.videoId = '',
  });

  TutorbotState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    String? videoId,
    bool clearError = false,
  }) {
    return TutorbotState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      videoId: videoId ?? this.videoId,
    );
  }
}

/// Tutorbot Controller — manages AI chat with persistent memory
class TutorbotController extends StateNotifier<TutorbotState> {
  final VideoModel video;

  TutorbotController(this.video) : super(const TutorbotState()) {
    _initializeChat();
  }

  /// Load previous conversation from Hive + add welcome message if new
  void _initializeChat() {
    final videoId = video.id;
    state = state.copyWith(videoId: videoId);

    // Load persisted messages
    final savedMessages = ChatPersistenceService.getMessagesForVideo(videoId);

    if (savedMessages.isEmpty) {
      // First time — add welcome message
      final welcome = ChatMessage(
        id: 'welcome_$videoId',
        text: '👋 Hey! Main hoon tumhara study buddy for **"${video.title}"**.\n\n'
            'Mujhse kuch bhi poocho is video ke baare mein — examples chahiye, '
            "koi concept samajhna hai, ya deeper dive karna hai? Let's go! 🚀",
        isBot: true,
        timestamp: DateTime.now(),
        videoId: videoId,
      );

      state = state.copyWith(messages: [welcome]);
      ChatPersistenceService.saveMessage(videoId, welcome);
    } else {
      state = state.copyWith(messages: savedMessages);
    }
  }

  /// Send a user message and get an AI response
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMsg = ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      isBot: false,
      timestamp: DateTime.now(),
      videoId: video.id,
    );

    final updatedMessages = [...state.messages, userMsg];
    state = state.copyWith(messages: updatedMessages, isLoading: true, clearError: true);
    await ChatPersistenceService.saveMessage(video.id, userMsg);

    try {
      final response = await _getGeminiResponse(text.trim());

      final botMsg = ChatMessage(
        id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
        text: response,
        isBot: true,
        timestamp: DateTime.now(),
        videoId: video.id,
      );

      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
      );
      await ChatPersistenceService.saveMessage(video.id, botMsg);
    } catch (e, stack) {
      debugPrint('❌ Tutorbot error: $e');
      debugPrint('Stack: $stack');
      
      // Show actual error detail to help debug
      final errorText = e.toString().contains('API')
          ? e.toString().replaceAll('Exception: ', '')
          : "Sorry, I couldn't process that. Error: ${e.toString().replaceAll('Exception: ', '')}";

      final errorMsg = ChatMessage(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        text: '$errorText\n\nPlease try again! 🔄',
        isBot: true,
        timestamp: DateTime.now(),
        videoId: video.id,
      );

      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isLoading: false,
        error: e.toString(),
      );
      await ChatPersistenceService.saveMessage(video.id, errorMsg);
    }
  }

  /// Clear conversation and start fresh
  Future<void> clearConversation() async {
    await ChatPersistenceService.clearVideoChat(video.id);
    state = const TutorbotState();
    _initializeChat();
  }

  /// Send an image message for Gemini Vision analysis
  Future<void> sendImageMessage({
    required Uint8List imageBytes,
    required String mimeType,
    String? userPrompt,
  }) async {
    final base64Full = base64Encode(imageBytes);

    // Create user message with image thumbnail for display
    // Store a smaller portion for chat history to save storage
    final thumbnailBase64 = base64Full.length > 50000
        ? base64Full.substring(0, 50000) // ~37KB thumbnail
        : base64Full;

    final displayText = userPrompt?.isNotEmpty == true
        ? '📸 $userPrompt'
        : '📸 Analyze this image';

    final userMsg = ChatMessage(
      id: 'img_${DateTime.now().millisecondsSinceEpoch}',
      text: displayText,
      isBot: false,
      timestamp: DateTime.now(),
      videoId: video.id,
      imageBase64: thumbnailBase64,
      imageMimeType: mimeType,
    );

    final updatedMessages = [...state.messages, userMsg];
    state = state.copyWith(messages: updatedMessages, isLoading: true, clearError: true);
    await ChatPersistenceService.saveMessage(video.id, userMsg);

    try {
      final response = await _getGeminiVisionResponse(
        base64Image: base64Full,
        mimeType: mimeType,
        userPrompt: userPrompt ?? 'Analyze this image and help me understand it.',
      );

      final botMsg = ChatMessage(
        id: 'vbot_${DateTime.now().millisecondsSinceEpoch}',
        text: response,
        isBot: true,
        timestamp: DateTime.now(),
        videoId: video.id,
      );

      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
      );
      await ChatPersistenceService.saveMessage(video.id, botMsg);
    } catch (e) {
      debugPrint('❌ Vision error: $e');
      final errorMsg = ChatMessage(
        id: 'verr_${DateTime.now().millisecondsSinceEpoch}',
        text: "Sorry, I couldn't analyze that image. Please try again with a clearer photo! 📷",
        isBot: true,
        timestamp: DateTime.now(),
        videoId: video.id,
      );

      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isLoading: false,
        error: e.toString(),
      );
      await ChatPersistenceService.saveMessage(video.id, errorMsg);
    }
  }

  /// Call Gemini Vision API with image + text
  Future<String> _getGeminiVisionResponse({
    required String base64Image,
    required String mimeType,
    required String userPrompt,
  }) async {
    final apiKey = AppConstants.geminiApiKey;
    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY') {
      return '⚠️ API key not configured. Please set your Gemini API key in the .env file.';
    }

    // Build context from conversation history
    final recentMessages = ChatPersistenceService.getContextWindow(video.id);
    final conversationHistory = recentMessages
        .where((m) => m.id != 'welcome_${video.id}')
        .take(10) // Fewer for vision to save token budget
        .map((m) => '${m.isBot ? "Tutor" : "Student"}: ${m.text}')
        .join('\n');

    final visionPrompt = '''
You are an expert female tutor with vision capabilities in "StudyReps" — an educational video app for Indian students.

═══ VIDEO CONTEXT ═══
- Title: "${video.title}"
- Subject: "${video.subject}"
- Topic: "${video.topicId.isNotEmpty ? video.topicId.replaceAll('_', ' ') : 'general'}"
- Current Focus Question: "${video.question.prompt}"

═══ RECENT CONVERSATION ═══
$conversationHistory

═══ TASK ═══
The student has shared an image. Their message: "$userPrompt"

═══ LANGUAGE INSTRUCTIONS ═══
You MUST respond in **Hinglish** — a natural mix of Hindi and English using ONLY Roman/Latin script.
NEVER use Devanagari/Hindi script. ALL Hindi words must be written in English letters.
**CRITICAL**: You are a **FEMALE** tutor. You MUST use **female pronouns** in Hindi/Hinglish when referring to yourself (e.g. use "main bataati hoon", "main dekhti hoon"). NEVER use male pronouns like "dekhta hoon" or "bataata hoon".
Example: "Mujhe lagta hai yeh diagram theek hai, ab main tumhe next step samjhaati hoon."

═══ TEACHING INSTRUCTIONS ═══
1. Analyze the image carefully — it could be a math problem, diagram, textbook page, handwritten notes, or question paper
2. If it's a problem/equation: solve it step-by-step in Hinglish, explaining the reasoning
3. If it's a diagram: explain what it shows and how it relates to the concept
4. If it's handwritten notes: help organize and clarify them
5. If it's a question paper: help the student understand and solve the questions
6. Connect your analysis to the video topic ("${video.title}") and the "Current Focus Question" when relevant
7. Use **bold** for key terms and format formulas clearly
8. Keep the response concise (4-6 sentences) but thorough.
9. Be encouraging, like a supportive senior sister — the student is making an effort by sharing their work!
10. If the student implies they want you to just read the text (like a screen reader), accurately transcribe or read the text from the image without unnecessary explanations.
11. Never output raw technical variable names or IDs in your text (e.g., instead of "gravity_basics", say "Gravity Basics"); always use human-readable formats.
''';

    final url = Uri.parse(
      '${AppConstants.geminiBaseUrl}/models/${AppConstants.geminiModel}:generateContent?key=$apiKey',
    );

    final requestBody = <String, dynamic>{
      'contents': [
        {
          'parts': [
            {'text': visionPrompt},
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              }
            },
          ]
        }
      ],
      'generationConfig': <String, dynamic>{
        'temperature': 0.7,
        'maxOutputTokens': 600,
        'topP': 0.95,
        'topK': 40,
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
    };

    // Enable thinking mode for deeper analysis
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
      final text = _extractTextFromResponse(data);
      return text ??
          "I could see the image but couldn't fully analyze it. Can you tell me what you'd like help with? 🤔";
    }

    if (response.statusCode == 429) {
      return '⏳ Too many requests! Please wait a moment and try again.';
    }

    throw Exception('Gemini Vision API error: ${response.statusCode}');
  }

  /// Build a context-rich prompt with conversation memory
  Future<String> _getGeminiResponse(String userQuestion) async {
    final apiKey = AppConstants.geminiApiKey;
    debugPrint('🔑 Gemini API key length: ${apiKey.length}, starts with: ${apiKey.substring(0, 10)}...');
    
    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY') {
      return '⚠️ API key not configured. Please set your Gemini API key in the .env file.\n\n'
          'Add `GEMINI_API_KEY=your_key_here` to your .env file.';
    }

    // Build conversation history from context window (last N messages)
    final recentMessages = ChatPersistenceService.getContextWindow(video.id);
    final conversationHistory = recentMessages
        .where((m) => m.id != 'welcome_${video.id}') // skip welcome msg
        .map((m) => '${m.isBot ? "Tutor" : "Student"}: ${m.text}')
        .join('\n');

    // Get global learner struggles for deeper personalization
    final struggles = ChatPersistenceService.getStruggleTopics();
    final struggleContext = struggles.isNotEmpty
        ? 'The student has previously struggled with: ${struggles.keys.take(5).join(', ')}'
        : 'This is a new student — be encouraging and build confidence.';

    // Get learner profile if available
    final learningStyle = ChatPersistenceService.getLearnerProfile('learning_style') ?? 'unknown';
    final gradeLevel = ChatPersistenceService.getLearnerProfile('grade_level') ?? 'unknown';

    final contextPrompt = '''
You are an expert, Socratic female tutor embedded in "StudyReps" — a short-form educational video app for Indian students.

═══ VIDEO CONTEXT ═══
- Title: "${video.title}"
- Subject: "${video.subject}"
- Topic: "${video.topicId.isNotEmpty ? video.topicId.replaceAll('_', ' ') : 'general'}"
- Concept Cluster: "${video.conceptCluster.isNotEmpty ? video.conceptCluster.replaceAll('_', ' ') : 'general'}"
- Current Focus Question: "${video.question.prompt}"
- Core Concept / Explanation: "${video.question.explanation}"
- Transcript: "${video.transcript.isNotEmpty ? video.transcript : 'No transcript available — use the Title, Subject, and Focus Question to infer the exact context.'}"

═══ LEARNER PROFILE ═══
- Learning Style: $learningStyle
- Grade Level: $gradeLevel
- $struggleContext

═══ CONVERSATION HISTORY (last ${recentMessages.length} messages) ═══
$conversationHistory

═══ NEW QUESTION ═══
Student: "$userQuestion"

═══ LANGUAGE & TONE INSTRUCTIONS ═══
You MUST respond in **Hinglish** — a natural mix of Hindi and English using ONLY Roman/Latin script (NEVER use Devanagari/Hindi script like हिन्दी).
**CRITICAL**: You are a **FEMALE** tutor. You MUST use **female pronouns** in Hindi/Hinglish when referring to yourself (e.g. use "main bataati hoon", "main samjhaati hoon", "main karti hoon"). NEVER use male pronouns (like "batata hoon" or "karta hoon").

Examples of Hinglish:
- "Yeh bahut important concept hai, let me explain karti hoon."
- "Isme basically kya hota hai ki force mass times acceleration hota hai."
- "Socho agar tum ek ball throw karte ho toh uska trajectory parabolic hoga, main tumhe next step samjhaati hoon."
- "Isko samajhne ke liye pehle hum basic formula dekhte hain."

═══ TEACHING INSTRUCTIONS ═══
1. Provide your ENTIRE response as ONE single, continuous paragraph message. Do NOT use bullet points, line breaks, or multiple chunks.
2. Directly answer the question by clearly explaining the core syllabus concept. Do NOT include generic fluff, greetings, or irrelevant conversational filler.
3. Keep it strictly relevant to the syllabus and the topic at hand.
4. Use clear analogies and real-world examples relevant to an Indian ICSE/CBSE student.
5. If referencing formulas, clearly dictate them in words (since this will be read out loud). Do not use complex mathematical formatting.
6. Formulate your answer carefully around the specific "Current Focus Question" of the video to help them specifically pass the gate.
7. Keep responses conversational, encouraging, and educational — like a friendly, supportive senior sister.
8. NEVER use Devanagari script. ALL Hindi words must be strictly in Roman letters.
9. Never output raw technical variable names or IDs in your text.
''';

    final url = Uri.parse(
      '${AppConstants.geminiBaseUrl}/models/${AppConstants.geminiModel}:generateContent?key=$apiKey',
    );

    debugPrint('🌐 Calling Gemini API: $url');
    debugPrint('📝 Question: $userQuestion');

    try {
      final requestBody = <String, dynamic>{
        'contents': [
          {
            'parts': [
              {'text': contextPrompt}
            ]
          }
        ],
        'generationConfig': <String, dynamic>{
          'temperature': 0.8,
          'maxOutputTokens': 4000,
          'topP': 0.95,
          'topK': 40,
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
      };

      // Enable thinking mode for deeper Socratic reasoning
      if (AppConstants.enableThinking) {
        (requestBody['generationConfig'] as Map<String, dynamic>)['thinkingConfig'] = {
          'thinkingBudget': AppConstants.thinkingBudget,
        };
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📦 Response body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resultText = _extractTextFromResponse(data) ??
            "I understood your question but couldn't generate a clear response. Can you rephrase? 🤔";

        // Check if the student might be struggling (simple heuristic)
        final lowerQuestion = userQuestion.toLowerCase();
        if (lowerQuestion.contains("don't understand") ||
            lowerQuestion.contains('confused') ||
            lowerQuestion.contains('what does') ||
            lowerQuestion.contains('help') ||
            lowerQuestion.contains('explain again')) {
          ChatPersistenceService.recordStruggleTopic(
            video.topicId.isNotEmpty ? video.topicId : video.subject,
            video.id,
          );
        }

        return resultText;
      }

      if (response.statusCode == 429) {
        return "⏳ I'm getting a lot of questions right now! Please wait a moment and try again.";
      }

      if (response.statusCode == 403) {
        return '⚠️ API key may be invalid or expired. Please verify your Gemini API key in the .env file.';
      }

      if (response.statusCode == 400) {
        debugPrint('❌ Bad request body: ${response.body}');
        return '⚠️ Request error. The question might be too long. Try a shorter question!';
      }

      // For any other error, return a helpful message instead of throwing
      debugPrint('❌ Gemini API error ${response.statusCode}: ${response.body}');
      return '⚠️ API returned status ${response.statusCode}. Please check your internet connection and try again.';
    } on TimeoutException {
      return '⏳ Request timed out. Please check your internet connection and try again.';
    } catch (e) {
      debugPrint('❌ Network error: $e');
      return "Whoops, looks like I lost connection! Make sure your internet is working and let's try that again. 🔌";
    }
  }

  /// Extract the actual text response from Gemini API response.
  /// With thinking mode enabled, the model returns multiple parts:
  /// - Parts with 'thought: true' contain internal reasoning (hidden from user)
  /// - Parts with regular 'text' contain the actual response
  /// This method finds and returns only the actual response text.
  static String? _extractTextFromResponse(Map<String, dynamic> data) {
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return null;

    final parts = candidates[0]['content']?['parts'] as List?;
    if (parts == null || parts.isEmpty) return null;

    // Walk parts in reverse to find the last non-thinking text
    for (final part in parts.reversed) {
      if (part['text'] != null && part['thought'] != true) {
        return part['text'].toString().trim();
      }
    }

    // Fallback: return the last part's text regardless
    return parts.last['text']?.toString().trim();
  }
}

/// Provider for tutorbot controller — scoped per video
/// Use `.family` so each video gets its own controller
final tutorbotControllerProvider = StateNotifierProvider.family<
    TutorbotController, TutorbotState, VideoModel>(
  (ref, video) => TutorbotController(video),
);
