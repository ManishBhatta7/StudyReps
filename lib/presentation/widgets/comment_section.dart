import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/study_reps_theme.dart';
import '../providers/comments_provider.dart';
import '../../domain/models/comment_model.dart';

/// Comment Section Widget
///
/// Inline comments on videos with threaded replies, sentiment indicators,
/// and "helpful" voting. Part of the social/collaborative learning layer.
class CommentSection extends ConsumerStatefulWidget {
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
  ConsumerState<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends ConsumerState<CommentSection> {
  @override
  Widget build(BuildContext context) {
    return _CommentSheetContent(videoId: widget.videoId);
  }
}

class _CommentSheetContent extends ConsumerStatefulWidget {
  final String videoId;
  final ScrollController? scrollController;

  const _CommentSheetContent({required this.videoId, this.scrollController});

  @override
  ConsumerState<_CommentSheetContent> createState() => _CommentSheetContentState();
}

class _CommentSheetContentState extends ConsumerState<_CommentSheetContent> {
  final _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _addComment(String text) async {
    if (text.trim().isEmpty) return;
    _inputController.clear();
    
    // Unfocus keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      await ref.read(commentControllerProvider).addComment(widget.videoId, text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding comment: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
    }
  }

  String _formatTimeAgo(DateTime? time) {
    if (time == null) return 'just now';
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(videoCommentsProvider(widget.videoId));

    return Container(
      decoration: BoxDecoration(
        color: StudyRepsTheme.warmCream,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: StudyRepsTheme.warmBorder),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: StudyRepsTheme.warmTextLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                commentsAsync.maybeWhen(
                  data: (comments) => Text(
                    '${comments.length} Comments',
                    style: const TextStyle(
                      color: StudyRepsTheme.warmTextDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  orElse: () => const Text(
                    'Comments',
                    style: TextStyle(
                      color: StudyRepsTheme.warmTextDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sort, size: 16),
                  label: const Text('Top'),
                  style: TextButton.styleFrom(foregroundColor: StudyRepsTheme.warmTextMedium),
                ),
              ],
            ),
          ),
          const Divider(color: StudyRepsTheme.warmBorder),

          // Comments list
          Expanded(
            child: commentsAsync.when(
              data: (comments) {
                if (comments.isEmpty) {
                  return const Center(
                    child: Text('No comments yet. Start the discussion!', style: TextStyle(color: StudyRepsTheme.warmTextMedium)),
                  );
                }
                return ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) => _buildCommentTile(comments[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: StudyRepsTheme.warmOrange)),
              error: (e, st) => Center(child: Text('Failed to load comments\n$e', style: const TextStyle(color: StudyRepsTheme.warmTextMedium), textAlign: TextAlign.center)),
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: StudyRepsTheme.warmBorder),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: StudyRepsTheme.warmOrange,
                    child: Text('Y', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      style: const TextStyle(color: StudyRepsTheme.warmTextDark, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: const TextStyle(color: StudyRepsTheme.warmTextLight),
                        filled: true,
                        fillColor: Colors.white,
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
                    child: const Icon(Icons.send_rounded,
                        color: StudyRepsTheme.warmOrange, size: 22),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(CommentModel comment, {bool isReply = false}) {
    // Generate an avatar letter and determine sentiment mock based on ID purely for visuals
    final initial = (comment.username?.isNotEmpty == true) ? comment.username![0].toUpperCase() : 'U';
    
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
                    ? StudyRepsTheme.warmOrange
                    : StudyRepsTheme.warmOrange.withOpacity(0.5),
                child: Text(
                  comment.isAI ? '🤖' : initial,
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
                          comment.username ?? 'Unknown Student',
                          style: TextStyle(
                            color: comment.isAI
                                ? StudyRepsTheme.warmOrange
                                : StudyRepsTheme.warmTextDark,
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
                              color: StudyRepsTheme.warmOrange.withOpacity(0.2),
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
                        _buildSentimentDot(comment.id % 4), // visual mock for demo
                        const Spacer(),
                        Text(
                          _formatTimeAgo(comment.createdAt),
                          style: const TextStyle(
                            color: StudyRepsTheme.warmTextLight,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Content
                    Text(
                      comment.body,
                      style: const TextStyle(
                        color: StudyRepsTheme.warmTextDark,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Actions
                    Row(
                      children: [
                        _buildAction(Icons.thumb_up_outlined,
                            '${comment.likesCount}'),
                        const SizedBox(width: 16),
                        _buildAction(Icons.reply_rounded, 'Reply'),
                        if (comment.userId == ref.read(supabaseClientProvider).auth.currentUser?.id) ... [
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              ref.read(commentControllerProvider).deleteComment(comment.id);
                            },
                            child: const Icon(Icons.delete_outline, color: StudyRepsTheme.warmTextLight, size: 14),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Placeholder for real replies relation eventually
        ],
      ),
    );
  }

  Widget _buildSentimentDot(int index) {
    Color color;
    switch (index) {
      case 0:
        color = Colors.greenAccent;
        break;
      case 1:
        color = Colors.orangeAccent;
        break;
      case 2:
        color = Colors.redAccent;
        break;
      default:
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
          Icon(icon, size: 14, color: StudyRepsTheme.warmTextMedium),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: StudyRepsTheme.warmTextMedium, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
