import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../domain/models/video_model.dart';

/// "Explain This" — Interactive Storyboard Explainer
///
/// Instead of a generic chat, the AI generates a structured,
/// swipable 3–5 card storyboard that breaks down the concept
/// with analogies, visuals, and key takeaways.
class ExplainStoryboardSheet extends StatelessWidget {
  final VideoModel video;

  const ExplainStoryboardSheet({super.key, required this.video});

  static void show(BuildContext context, VideoModel video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => _StoryboardContent(
          video: video,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _StoryboardContent(video: video);
}

class _StoryboardContent extends StatefulWidget {
  final VideoModel video;
  const _StoryboardContent({required this.video});
  @override
  State<_StoryboardContent> createState() => _StoryboardContentState();
}

class _StoryboardContentState extends State<_StoryboardContent> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = true;
  List<_ExplainCard> _cards = [];

  @override
  void initState() {
    super.initState();
    _generateExplanation();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _generateExplanation() async {
    try {
      final cards = await _fetchExplanationCards();
      if (mounted) setState(() { _cards = cards; _isLoading = false; });
    } catch (e) {
      // Fallback: generate simple cards from transcript
      if (mounted) {
        setState(() {
          _cards = _buildFallbackCards();
          _isLoading = false;
        });
      }
    }
  }

  Future<List<_ExplainCard>> _fetchExplanationCards() async {
    final apiKey = AppConstants.geminiApiKey;
    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY') {
      return _buildFallbackCards();
    }

    final prompt = '''
You are a world-class educator creating a visual storyboard explanation.
Topic: "${widget.video.title}"
Subject: "${widget.video.subject}"
Transcript: "${widget.video.transcript}"

Create EXACTLY 4 explanation cards as a JSON array. Each card has:
{
  "emoji": "a single relevant emoji",
  "title": "short card title (3-5 words)",
  "body": "clear 2-3 sentence explanation of this concept step",
  "analogy": "a real-world analogy in 1 sentence (start with 'Think of it like...')",
  "keyTakeaway": "1 bold sentence the student must remember"
}

Rules:
- Card 1: Introduce the concept simply
- Card 2: Explain the core mechanism/process
- Card 3: Show a concrete example or application
- Card 4: Summarize + connect to bigger picture
- Use simple language a 16-year-old would understand
- Return ONLY the JSON array, no markdown wrapping
''';

    final url = Uri.parse(
      '${AppConstants.geminiBaseUrl}/models/${AppConstants.geminiModel}:generateContent?key=$apiKey'
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [{'parts': [{'text': prompt}]}],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 800,
          'responseMimeType': 'application/json',
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final parts = data['candidates']?[0]?['content']?['parts'] as List?;
      if (parts != null && parts.isNotEmpty) {
        String text = parts[0]['text'] as String;
        text = text.replaceAll('```json', '').replaceAll('```', '').trim();
        
        // Extract JSON array
        if (text.contains('[')) {
          text = text.substring(text.indexOf('['), text.lastIndexOf(']') + 1);
        }
        
        final List<dynamic> jsonCards = jsonDecode(text);
        return jsonCards.map((c) => _ExplainCard(
          emoji: c['emoji'] ?? '📚',
          title: c['title'] ?? '',
          body: c['body'] ?? '',
          analogy: c['analogy'] ?? '',
          keyTakeaway: c['keyTakeaway'] ?? '',
        )).toList();
      }
    }
    return _buildFallbackCards();
  }

  List<_ExplainCard> _buildFallbackCards() {
    final t = widget.video.transcript;
    final sentences = t.split('. ');
    return [
      _ExplainCard(
        emoji: '🎯',
        title: 'The Big Idea',
        body: '${sentences.take(2).join('. ')}.',
        analogy: 'Think of it like building blocks — each piece supports the next.',
        keyTakeaway: '${widget.video.title} is a foundational concept in ${widget.video.subject}.',
      ),
      _ExplainCard(
        emoji: '⚙️',
        title: 'How It Works',
        body: sentences.length > 2 ? '${sentences.skip(2).take(2).join('. ')}.' : 'The mechanism relies on core principles taught in this video.',
        analogy: 'Think of it like a recipe — each step must happen in order.',
        keyTakeaway: 'Understanding the process is key to applying this concept.',
      ),
      _ExplainCard(
        emoji: '💡',
        title: 'Real-World Example',
        body: 'This concept appears everywhere in ${widget.video.subject}. Watch for it in your daily studies and problem sets.',
        analogy: 'Think of it like learning to ride a bike — theory becomes intuition with practice.',
        keyTakeaway: 'Practice applying this concept to solidify your understanding.',
      ),
      _ExplainCard(
        emoji: '🚀',
        title: 'The Takeaway',
        body: 'Mastering ${widget.video.title} unlocks deeper topics in ${widget.video.subject}. It\'s worth revisiting this concept.',
        analogy: 'Think of it like a key — it opens doors to more advanced ideas.',
        keyTakeaway: 'Review this after 24 hours for optimal retention!',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Concept Breakdown',
                        style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.video.title,
                        style: GoogleFonts.outfit(
                          fontSize: 13, color: Colors.white.withOpacity(0.5),
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.5)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _buildCardsPager(),
          ),

          // Page indicator + nav
          if (!_isLoading && _cards.isNotEmpty)
            _buildBottomNav(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 48, height: 48,
            child: CircularProgressIndicator(
              color: Color(0xFF6366F1),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Building your explanation...',
            style: GoogleFonts.outfit(
              fontSize: 16, color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1500.ms, color: const Color(0xFF6366F1).withOpacity(0.1));
  }

  Widget _buildCardsPager() {
    return PageView.builder(
      controller: _pageController,
      itemCount: _cards.length,
      onPageChanged: (i) => setState(() => _currentPage = i),
      itemBuilder: (context, index) {
        final card = _cards[index];
        return _buildExplainCardUI(card, index);
      },
    );
  }

  Widget _buildExplainCardUI(_ExplainCard card, int index) {
    final colors = [
      const [Color(0xFF6366F1), Color(0xFF818CF8)], // Indigo
      const [Color(0xFF10B981), Color(0xFF34D399)], // Emerald
      const [Color(0xFFFF7043), Color(0xFFFF8A65)], // Orange
      const [Color(0xFF38BDF8), Color(0xFF7DD3FC)], // Sky
    ];
    final gradientColors = colors[index % colors.length];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Step indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: gradientColors[0].withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Step ${index + 1} of ${_cards.length}',
              style: GoogleFonts.outfit(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: gradientColors[0],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Main card
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: gradientColors[0].withOpacity(0.2)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Emoji + Title
                    Row(
                      children: [
                        Text(card.emoji, style: const TextStyle(fontSize: 36)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            card.title,
                            style: GoogleFonts.outfit(
                              fontSize: 22, fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Body
                    Text(
                      card.body,
                      style: GoogleFonts.outfit(
                        fontSize: 16, color: Colors.white.withOpacity(0.85),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Analogy box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: gradientColors[0].withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: gradientColors[0].withOpacity(0.15)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_rounded, color: gradientColors[0], size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              card.analogy,
                              style: GoogleFonts.outfit(
                                fontSize: 14, color: gradientColors[1],
                                fontStyle: FontStyle.italic, height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Key takeaway
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [gradientColors[0].withOpacity(0.15), gradientColors[1].withOpacity(0.08)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Text('🔑', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              card.keyTakeaway,
                              style: GoogleFonts.outfit(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Prev button
          if (_currentPage > 0)
            GestureDetector(
              onTap: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 300), curve: Curves.easeOut,
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
            )
          else
            const SizedBox(width: 40),

          const SizedBox(width: 16),

          // Dots
          Row(
            children: List.generate(_cards.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? const Color(0xFF6366F1)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          const SizedBox(width: 16),

          // Next / Done button
          GestureDetector(
            onTap: () {
              if (_currentPage < _cards.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300), curve: Curves.easeOut,
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _currentPage == _cards.length - 1
                    ? StudyRepsTheme.warmOrange
                    : Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _currentPage == _cards.length - 1 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                color: Colors.white, size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplainCard {
  final String emoji;
  final String title;
  final String body;
  final String analogy;
  final String keyTakeaway;

  _ExplainCard({
    required this.emoji,
    required this.title,
    required this.body,
    required this.analogy,
    required this.keyTakeaway,
  });
}
