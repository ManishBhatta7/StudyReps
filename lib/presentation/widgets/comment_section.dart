import 'package:flutter/material.dart';
import '../../core/theme/study_reps_theme.dart';

/// Comment Section Widget
///
/// Inline comments on videos with threaded replies, sentiment indicators,
/// and "helpful" voting. Part of the social/collaborative learning layer.
class CommentSection extends StatefulWidget {
  final String videoId;
  final VoidCallback? onClose;

  const CommentSection({super.key, required this.videoId, this.onClose});

  static void show(BuildContext context, String videoId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        builder: (context, scrollController) => _CommentSheetContent(
          videoId: videoId,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  @override
  Widget build(BuildContext context) {
    return _CommentSheetContent(videoId: widget.videoId);
  }
}

class _CommentSheetContent extends StatefulWidget {
  final String videoId;
  final ScrollController? scrollController;

  const _CommentSheetContent({required this.videoId, this.scrollController});

  @override
  State<_CommentSheetContent> createState() => _CommentSheetContentState();
}

class _CommentSheetContentState extends State<_CommentSheetContent> {
  final _inputController = TextEditingController();
  final List<_Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadMockComments();
  }

  void _loadMockComments() {
    _comments.addAll([
      _Comment(
        username: 'physicsNerd42',
        content: 'This finally made F=ma click for me! The car example was perfect 🚗',
        sentiment: _Sentiment.positive,
        helpfulCount: 12,
        timeAgo: '2h ago',
        replies: [
          _Comment(
            username: 'studybuddy',
            content: 'Same! I kept confusing force and momentum before this.',
            sentiment: _Sentiment.positive,
            helpfulCount: 3,
            timeAgo: '1h ago',
          ),
        ],
      ),
      _Comment(
        username: 'confused_student',
        content: 'Wait, so what happens when two forces are equal? Does the object just stop?',
        sentiment: _Sentiment.confused,
        helpfulCount: 5,
        timeAgo: '4h ago',
        replies: [
          _Comment(
            username: 'StudyReps_AI',
            content: '💡 Great question! When two forces are equal and opposite, the net force is zero — '
                "the object doesn't stop, it maintains its current state (Newton's 1st Law). "
                'If moving, it keeps moving at the same speed!',
            sentiment: _Sentiment.positive,
            helpfulCount: 18,
            timeAgo: '4h ago',
            isAI: true,
          ),
        ],
      ),
      _Comment(
        username: 'mathLover',
        content: 'Could someone explain the derivation from momentum? F = Δp/Δt',
        sentiment: _Sentiment.neutral,
        helpfulCount: 8,
        timeAgo: '6h ago',
      ),
    ]);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _addComment(String text) {
    if (text.trim().isEmpty) return;
    _inputController.clear();
    setState(() {
      _comments.insert(
        0,
        _Comment(
          username: 'you',
          content: text,
          sentiment: _Sentiment.neutral,
          helpfulCount: 0,
          timeAgo: 'just now',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgPrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                Text(
                  '${_comments.length} Comments',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sort, size: 16),
                  label: const Text('Top'),
                  style: TextButton.styleFrom(foregroundColor: Colors.white54),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.1)),

          // Comments list
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _comments.length,
              itemBuilder: (context, index) =>
                  _buildCommentTile(_comments[index]),
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: StudyRepsTheme.primaryPurple,
                    child: const Text('Y', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: _addComment,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _addComment(_inputController.text),
                    child: Icon(Icons.send_rounded,
                        color: StudyRepsTheme.primaryPurple, size: 22),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(_Comment comment, {bool isReply = false}) {
    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? 40 : 0,
        top: 12,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: isReply ? 14 : 16,
                backgroundColor: comment.isAI
                    ? StudyRepsTheme.accentCyan
                    : StudyRepsTheme.primaryPurple.withOpacity(0.5),
                child: Text(
                  comment.isAI ? '🤖' : comment.username[0].toUpperCase(),
                  style: TextStyle(fontSize: isReply ? 10 : 12),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username + sentiment + time
                    Row(
                      children: [
                        Text(
                          comment.username,
                          style: TextStyle(
                            color: comment.isAI
                                ? StudyRepsTheme.accentCyan
                                : Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (comment.isAI) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: StudyRepsTheme.accentCyan.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'AI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 6),
                        _buildSentimentDot(comment.sentiment),
                        const Spacer(),
                        Text(
                          comment.timeAgo,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Content
                    Text(
                      comment.content,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Actions
                    Row(
                      children: [
                        _buildAction(Icons.thumb_up_outlined,
                            '${comment.helpfulCount}'),
                        const SizedBox(width: 16),
                        _buildAction(Icons.reply_rounded, 'Reply'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Replies
          if (comment.replies != null)
            ...comment.replies!
                .map((reply) => _buildCommentTile(reply, isReply: true)),
        ],
      ),
    );
  }

  Widget _buildSentimentDot(_Sentiment sentiment) {
    Color color;
    switch (sentiment) {
      case _Sentiment.positive:
        color = Colors.greenAccent;
        break;
      case _Sentiment.confused:
        color = Colors.orangeAccent;
        break;
      case _Sentiment.negative:
        color = Colors.redAccent;
        break;
      case _Sentiment.neutral:
        color = Colors.grey;
        break;
    }
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildAction(IconData icon, String label) {
    return GestureDetector(
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white38),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─── Data Models ───

enum _Sentiment { positive, negative, confused, neutral }

class _Comment {
  final String username;
  final String content;
  final _Sentiment sentiment;
  final int helpfulCount;
  final String timeAgo;
  final bool isAI;
  final List<_Comment>? replies;

  const _Comment({
    required this.username,
    required this.content,
    required this.sentiment,
    required this.helpfulCount,
    required this.timeAgo,
    this.isAI = false,
    this.replies,
  });
}
