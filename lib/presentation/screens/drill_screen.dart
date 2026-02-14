import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
    // Initial Greeting
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

    // 1. Add User Message
    final userMsg = ChatMessage(
      id: DateTime.now().toString(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      currentTopic: state.currentTopic ?? text, // Naive topic detection for first msg
    );

    // 2. Prepare Context for AI
    // We prepend the System Prompt to the conversation history for the AI
    final prompt = "$kDrillSystemPrompt\n\nUser: $text";

    try {
      final repository = ref.read(geminiRepositoryProvider);
      
      // Placeholder for bot
      final botMsgId = "bot_${DateTime.now().millisecondsSinceEpoch}";
      final botMsg = ChatMessage(
        id: botMsgId,
        content: "",
        isUser: false,
        isStreaming: true,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(messages: [...state.messages, botMsg]);

      final stream = repository.sendChatMessage(
        message: prompt,
        contextIds: [], 
        // In a real app we'd maintain history context here or via the repository
      );

      String accumulated = "";
      await for (final chunk in stream) {
        accumulated += chunk;
        state = state.copyWith(
          messages: state.messages.map((m) => 
            m.id == botMsgId ? m.copyWith(content: accumulated) : m
          ).toList(),
        );
      }
      
      // Parse Rep Count from response if possible
      int newRep = state.currentRep;
      if (accumulated.contains("Rep")) {
         // Naive parsing logic could go here
         // e.g. Regex to find "Rep (\d+)/10"
         final regex = RegExp(r"Rep\s+(\d+)/");
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
      // Handle error display
    }
  }
}

// --- Screen ---
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
      backgroundColor: StudyRepsTheme.bgPrimary,
      appBar: AppBar(
        title: Column(
          children: [
            const Text("AdaptiveEd Coach"),
            Text(
              "Rep ${state.currentRep}/${state.totalReps} • ${state.currentTopic ?? 'Select Topic'}",
              style: StudyRepsTheme.darkTheme.textTheme.labelMedium,
            ),
          ],
        ),
        backgroundColor: StudyRepsTheme.bgSecondary,
        elevation: 0,
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
            decoration: const BoxDecoration(
              color: StudyRepsTheme.bgSecondary,
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Answer or ask...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric( horizontal: 20, vertical: 14),
                    ),
                    onSubmitted: (_) => _handleSubmitted(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: _handleSubmitted,
                  backgroundColor: StudyRepsTheme.primaryPurple,
                  mini: true,
                  child: state.isLoading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send, size: 18),
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
          color: isUser ? StudyRepsTheme.primaryPurple.withOpacity(0.2) : StudyRepsTheme.bgSecondary,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? Radius.zero : null,
            bottomLeft: !isUser ? Radius.zero : null,
          ),
          border: Border.all(
            color: isUser ? StudyRepsTheme.primaryPurple.withOpacity(0.5) : Colors.white10,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const Text("COACH", style: TextStyle(color: StudyRepsTheme.primaryPurple, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
            ],
            MarkdownBody(
              data: message.content,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                strong: const TextStyle(color: StudyRepsTheme.successGreen, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
