import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/comment_model.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Stream of comments for a specific video
final videoCommentsProvider = StreamProvider.family<List<CommentModel>, String>((ref, videoId) {
  final supabase = ref.watch(supabaseClientProvider);
  
  // Notice we use the view `educational_comments` (created in migration)
  return supabase
      .from('educational_comments')
      .stream(primaryKey: ['id'])
      .eq('video_id', videoId)
      .order('created_at', ascending: false)
      .map((data) {
        return data.map((json) {
          // You might need a join or a database view to get username/avatar automatically,
          // but for now we'll map the raw JSON data.
          return CommentModel(
            id: json['id'] as int,
            videoId: json['video_id'] as String,
            userId: json['user_id'] as String,
            body: json['body'] as String,
            likesCount: json['likes_count'] as int? ?? 0,
            createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
            // Fallback for demo purposes until profile join is implemented
            username: 'User_${(json['user_id'] as String).substring(0, 5)}',
            isAI: false,
          );
        }).toList();
      });
});

final commentControllerProvider = Provider((ref) => CommentController(ref));

class CommentController {
  final Ref _ref;
  CommentController(this._ref);

  Future<void> addComment(String videoId, String text) async {
    final supabase = _ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Must be logged in to comment');

    await supabase.from('educational_comments').insert({
      'video_id': videoId,
      'user_id': user.id,
      'body': text,
    });
  }

  Future<void> deleteComment(int commentId) async {
     final supabase = _ref.read(supabaseClientProvider);
     final user = supabase.auth.currentUser;
     if (user == null) return;

     await supabase.from('educational_comments')
        .delete()
        .eq('id', commentId)
        .eq('user_id', user.id);
  }
}
