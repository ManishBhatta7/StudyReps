import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../data/providers/repository_providers.dart';
import '../providers/chat_provider.dart';

// --- System Prompt ---
const String kDrillSystemPrompt = '''
Role: You are the AdaptiveEdCoach Study Reps Facilitator.
Goal: Build muscle memory and mastery through active active repetition. Do not lecture; drill.
Priority: Active Recall over passive recognition.

Instructions:
1. Topic Ingestion: If the user says "I want to rep X", specifically handle X.
2. Expert Instantiation: Become an expert in X.
3. The Rep Loop:
   - Ask a question based on Learning Style (Visual/Auditory/Analytical).
   - visual: "Imagine/Look at..."
   - analytical: "Solve..."
   - Wait for input.
4. Grading:
   - Correct: "Good rep. +1." -> Harder next question.
   - Incorrect: Explain briefly -> Easier variation next.
5. Limits: Keep responses short. 

Format:
Rep Counter: (e.g., "Rep 3/10")
The Challenge: ...
''';

// --- State ---
class DrillState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final int currentRep;
  final int totalReps;
  final String? currentTopic;

  const DrillState({
    this.messages = const [],
    this.isLoading = false,
    this.currentRep = 0,
    this.totalReps = 10,
    this.currentTopic,
  });

  DrillState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    int? currentRep,
    int? totalReps,
    String? currentTopic,
  }) {
    return DrillState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      currentRep: currentRep ?? this.currentRep,
      totalReps: totalReps ?? this.totalReps,
      currentTopic: currentTopic ?? this.currentTopic,
    );
  }
}

// --- Provider ---
final drillProvider = StateNotifierProvider.autoDispose<DrillNotifier, DrillState>((ref) {
  return DrillNotifier(ref);
});

class DrillNotifier extends StateNotifier<DrillState> {
  final Ref ref;

  DrillNotifier(this.ref) : super(const DrillState()) {
    state = state.copyWith(messages: [
      ChatMessage(
        id: 'init',
        content: "I am your AdaptiveEdCoach. What topic shall we drill today? (e.g., 'Biochemistry', 'Calculus', 'History')",
        isUser: false,
        timestamp: DateTime.now(),
      )
    ]);
  }

  Future<void> sendResponse(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().toString(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      currentTopic: state.currentTopic ?? text,
    );

    final prompt = '$kDrillSystemPrompt\n\nUser: $text';

    try {
      final repository = ref.read(geminiRepositoryProvider);
      
      final botMsgId = 'bot_${DateTime.now().millisecondsSinceEpoch}';
      final botMsg = ChatMessage(
        id: botMsgId,
        content: '',
        isUser: false,
        isStreaming: true,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(messages: [...state.messages, botMsg]);

      final stream = repository.sendChatMessage(
        message: prompt,
        contextIds: [], 
      );

      String accumulated = '';
      await for (final chunk in stream) {
        accumulated += chunk;
        state = state.copyWith(
          messages: state.messages.map((m) => 
            m.id == botMsgId ? m.copyWith(content: accumulated) : m
          ).toList(),
        );
      }
      
      int newRep = state.currentRep;
      if (accumulated.contains('Rep')) {
         final regex = RegExp(r'Rep\s+(\d+)/');
         final match = regex.firstMatch(accumulated);
         if (match != null) {
           newRep = int.tryParse(match.group(1)!) ?? newRep;
         }
      }

      state = state.copyWith(
        isLoading: false,
        currentRep: newRep,
        messages: state.messages.map((m) => 
            m.id == botMsgId ? m.copyWith(isStreaming: false) : m
          ).toList(),
      );

    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

// --- Screen — BoldVoice warm cream design ---
class DrillScreen extends ConsumerStatefulWidget {
  const DrillScreen({super.key});

  @override
  ConsumerState<DrillScreen> createState() => _DrillScreenState();
}

class _DrillScreenState extends ConsumerState<DrillScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _handleSubmitted() {
    final text = _textController.text;
    if (text.isEmpty) return;
    _textController.clear();
    ref.read(drillProvider.notifier).sendResponse(text);
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(drillProvider);

    return Scaffold(
      backgroundColor: StudyRepsTheme.warmCream,
      appBar: AppBar(
        backgroundColor: StudyRepsTheme.warmCard,
        elevation: 0,
        iconTheme: const IconThemeData(color: StudyRepsTheme.warmTextDark),
        title: Column(
          children: [
            Text(
              'AdaptiveEd Coach',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: StudyRepsTheme.warmTextDark,
                fontSize: 16,
              ),
            ),
            Text(
              "Rep ${state.currentRep}/${state.totalReps} • ${state.currentTopic ?? 'Select Topic'}",
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: StudyRepsTheme.warmTextLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Chat List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                return _DrillBubble(message: state.messages[index]);
              },
            ),
          ),
          
          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: StudyRepsTheme.warmCard,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: GoogleFonts.outfit(color: StudyRepsTheme.warmTextDark),
                    decoration: InputDecoration(
                      hintText: 'Answer or ask...',
                      hintStyle: GoogleFonts.outfit(color: StudyRepsTheme.warmTextLight),
                      filled: true,
                      fillColor: StudyRepsTheme.warmChipBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onSubmitted: (_) => _handleSubmitted(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: _handleSubmitted,
                  backgroundColor: StudyRepsTheme.warmOrange,
                  mini: true,
                  child: state.isLoading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrillBubble extends StatelessWidget {
  final ChatMessage message;
  const _DrillBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          color: isUser ? StudyRepsTheme.warmOrange.withOpacity(0.12) : StudyRepsTheme.warmCard,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? Radius.zero : null,
            bottomLeft: !isUser ? Radius.zero : null,
          ),
          border: Border.all(
            color: isUser ? StudyRepsTheme.warmOrange.withOpacity(0.3) : StudyRepsTheme.warmBorder,
          ),
          boxShadow: [
            if (!isUser)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Text(
                'COACH',
                style: GoogleFonts.outfit(
                  color: StudyRepsTheme.warmOrange,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
            ],
            MarkdownBody(
              data: message.content,
              styleSheet: MarkdownStyleSheet(
                p: GoogleFonts.outfit(
                  color: StudyRepsTheme.warmTextDark,
                  fontSize: 15,
                  height: 1.5,
                ),
                strong: GoogleFonts.outfit(
                  color: StudyRepsTheme.warmGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
