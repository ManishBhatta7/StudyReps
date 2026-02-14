import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../domain/models/video_model.dart';

/// Video Tutorbot Sheet
///
/// A bottom-sheet "AI Tutorbot" scoped to a single video.
/// Users can ask clarification questions, request examples, or get
/// deeper explanations — turning passive video consumption into
/// active Socratic dialogue.
///
/// Uses the video transcript as context for Gemini responses.
class VideoTutorbotSheet extends StatefulWidget {
  final VideoModel video;

  const VideoTutorbotSheet({super.key, required this.video});

  /// Show the tutorbot as a draggable bottom sheet
  static void show(BuildContext context, VideoModel video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => _TutorbotContent(
          video: video,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  State<VideoTutorbotSheet> createState() => _VideoTutorbotSheetState();
}

class _VideoTutorbotSheetState extends State<VideoTutorbotSheet> {
  @override
  Widget build(BuildContext context) {
    return _TutorbotContent(video: widget.video);
  }
}

class _TutorbotContent extends StatefulWidget {
  final VideoModel video;
  final ScrollController? scrollController;

  const _TutorbotContent({required this.video, this.scrollController});

  @override
  State<_TutorbotContent> createState() => _TutorbotContentState();
}

class _TutorbotContentState extends State<_TutorbotContent> {
  final _inputController = TextEditingController();
  final _messages = <_ChatBubble>[];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(_ChatBubble(
      text: "👋 Hi! I'm your study buddy for **\"${widget.video.title}\"**.\n\n"
          "Ask me anything about this video — want examples, clarification, "
          "or a deeper dive into a specific concept?",
      isBot: true,
    ));
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _inputController.clear();

    setState(() {
      _messages.add(_ChatBubble(text: text, isBot: false));
      _isLoading = true;
    });

    try {
      final response = await _getGeminiResponse(text);
      setState(() {
        _messages.add(_ChatBubble(text: response, isBot: true));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatBubble(
          text: "Sorry, I couldn't process that. Try again!",
          isBot: true,
        ));
        _isLoading = false;
      });
    }
  }

  Future<String> _getGeminiResponse(String userQuestion) async {
    final apiKey = AppConstants.geminiApiKey;
    if (apiKey == 'YOUR_GEMINI_API_KEY') {
      return "API key not configured. Set your Gemini API key in AppConstants.";
    }

    // Build context-rich prompt using the video transcript
    final contextPrompt = '''
You are an expert, Socratic tutor embedded in a short-form educational video app called StudyReps.

VIDEO CONTEXT:
- Title: "${widget.video.title}"
- Subject: "${widget.video.subject}"
- Transcript: "${widget.video.transcript.isNotEmpty ? widget.video.transcript : 'No transcript available'}"
- Topic: "${widget.video.topicId}"

CONVERSATION HISTORY:
${_messages.where((m) => !m.isBot || _messages.indexOf(m) > 0).map((m) => '${m.isBot ? "Tutor" : "Student"}: ${m.text}').join('\n')}

STUDENT'S NEW QUESTION: "$userQuestion"

INSTRUCTIONS:
- Answer in 2-3 concise sentences maximum
- Use analogies and real-world examples
- If the student seems confused, break it down further
- If the student seems to understand, challenge them with a follow-up question (Socratic method)
- Use emoji sparingly for engagement
- Reference the video content when relevant
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
              {'text': contextPrompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.8,
          'maxOutputTokens': 300,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      return text?.toString().trim() ?? "I couldn't understand that. Can you rephrase?";
    }

    throw Exception('Gemini API error: ${response.statusCode}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgPrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: StudyRepsTheme.primaryPurple.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [StudyRepsTheme.primaryPurple, StudyRepsTheme.accentCyan],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tutorbot',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.video.title,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Quick action chips
                _buildQuickAction('Explain', Icons.lightbulb_outline),
                const SizedBox(width: 8),
                _buildQuickAction('Example', Icons.emoji_objects_outlined),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.1)),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: StudyRepsTheme.bgPrimary,
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ask about this video...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(_inputController.text),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [StudyRepsTheme.primaryPurple, StudyRepsTheme.accentCyan],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon) {
    return GestureDetector(
      onTap: () => _sendMessage('Can you $label this concept?'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: StudyRepsTheme.accentCyan, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatBubble msg) {
    return Align(
      alignment: msg.isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: msg.isBot
              ? Colors.white.withOpacity(0.08)
              : StudyRepsTheme.primaryPurple.withOpacity(0.3),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isBot ? 4 : 16),
            bottomRight: Radius.circular(msg.isBot ? 16 : 4),
          ),
          border: msg.isBot
              ? Border.all(color: Colors.white.withOpacity(0.1))
              : null,
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            _buildDot(150),
            _buildDot(300),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delayMs),
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: StudyRepsTheme.accentCyan.withOpacity(0.4 + value * 0.6),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

/// Simple chat bubble data
class _ChatBubble {
  final String text;
  final bool isBot;

  const _ChatBubble({required this.text, required this.isBot});
}
