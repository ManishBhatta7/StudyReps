import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/study_reps_theme.dart';
import '../providers/chat_provider.dart';

class NotebookChatView extends ConsumerStatefulWidget {
  const NotebookChatView({super.key});

  @override
  ConsumerState<NotebookChatView> createState() => _NotebookChatViewState();
}

class _NotebookChatViewState extends ConsumerState<NotebookChatView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Mock active sources
  final List<String> _activeSources = [
    'Math Assignment.pdf',
    'Report Card (Oct)',
    'Biology Notes'
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmitted() {
    final text = _textController.text;
    if (text.isEmpty) return;
    
    _textController.clear();
    ref.read(chatProvider.notifier).sendMessage(text);

    // Scroll to bottom
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
    final chatState = ref.watch(chatProvider);
    final messages = chatState.messages;

    return Column(
      children: [
        // 1. Context Bubbles Header
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: StudyRepsTheme.warmCream,
            border: Border(bottom: BorderSide(color: StudyRepsTheme.warmBorder)),
          ),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _activeSources.length + 1,
            separatorBuilder: (ctx, i) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              if (i == 0) {
                 return Chip(
                  avatar: const Icon(Icons.add, size: 16, color: StudyRepsTheme.warmOrange),
                  label: const Text('Add Source'),
                  backgroundColor: StudyRepsTheme.warmOrange.withOpacity(0.1),
                  side: BorderSide.none,
                  labelStyle: const TextStyle(
                    color: StudyRepsTheme.warmOrangeDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }
              final source = _activeSources[i - 1];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: StudyRepsTheme.warmBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 14, color: StudyRepsTheme.warmTextMedium),
                    const SizedBox(width: 6),
                    Text(
                      source,
                      style: const TextStyle(fontSize: 12, color: StudyRepsTheme.warmTextDark),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.close, size: 12, color: StudyRepsTheme.warmTextLight),
                  ],
                ),
              );
            },
          ),
        ),

        // 2. Chat Area
        Expanded(
          child: messages.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(24),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _ChatBubble(message: msg);
                  },
                ),
        ),

        // 3. Input Area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: StudyRepsTheme.warmCream,
            border: Border(top: BorderSide(color: StudyRepsTheme.warmBorder)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  style: StudyRepsTheme.warmBodyStyle,
                  decoration: InputDecoration(
                    hintText: 'Ask a question about your sources...',
                    hintStyle: const TextStyle(color: StudyRepsTheme.warmTextLight),
                    filled: true,
                    fillColor: StudyRepsTheme.warmWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: StudyRepsTheme.warmBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: StudyRepsTheme.warmBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: StudyRepsTheme.warmOrange),
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
                foregroundColor: Colors.white,
                elevation: 0,
                mini: true,
                child: chatState.isLoading
                  ? const SizedBox(
                      width: 16, 
                      height: 16, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Icon(Icons.arrow_upward, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: StudyRepsTheme.warmOrange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, size: 48, color: StudyRepsTheme.warmOrange),
          ),
          const SizedBox(height: 24),
          Text(
            'Study Assistant',
            style: StudyRepsTheme.warmHeadingStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'Ask questions, summarize documents, or get study tips.',
            textAlign: TextAlign.center,
            style: StudyRepsTheme.warmBodyStyle.copyWith(color: StudyRepsTheme.warmTextMedium),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isUser) ...[
                   const Icon(Icons.auto_awesome, size: 16, color: StudyRepsTheme.warmOrange),
                   const SizedBox(width: 8),
                   Text('Assistant', style: StudyRepsTheme.warmLabelStyle.copyWith(color: StudyRepsTheme.warmTextDark)),
                ],
                if (isUser)
                   Text('You', style: StudyRepsTheme.warmLabelStyle.copyWith(color: StudyRepsTheme.warmTextMedium)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? StudyRepsTheme.warmWhite : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isUser ? Border.all(color: StudyRepsTheme.warmBorder) : null,
              ),
              child: isUser 
                ? Text(message.content, style: StudyRepsTheme.warmBodyStyle.copyWith(color: StudyRepsTheme.warmTextDark, height: 1.5))
                : MarkdownBody(
                    data: message.content + (message.isStreaming ? ' ▋' : ''), // Blinking cursor effect
                    styleSheet: MarkdownStyleSheet(
                      p: StudyRepsTheme.warmBodyStyle.copyWith(color: StudyRepsTheme.warmTextDark, height: 1.6, fontSize: 16),
                      h1: StudyRepsTheme.warmHeadingStyle.copyWith(color: StudyRepsTheme.warmTextDark, fontWeight: FontWeight.bold, fontSize: 24),
                      h2: StudyRepsTheme.warmHeadingStyle.copyWith(color: StudyRepsTheme.warmTextDark, fontWeight: FontWeight.bold, fontSize: 20),
                      code: const TextStyle(backgroundColor: StudyRepsTheme.warmCream, fontFamily: 'monospace'),
                      codeblockDecoration: BoxDecoration(
                        color: StudyRepsTheme.warmCream,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
