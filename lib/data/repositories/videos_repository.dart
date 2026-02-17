import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/video_model.dart';

/// Repository for fetching video content and managing interactions via Supabase
class VideosRepository {
  final SupabaseClient _supabase;

  VideosRepository(this._supabase);

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // ─────────────────────────────────────────────
  // FETCH
  // ─────────────────────────────────────────────

  /// Fetch videos with pagination, including like/save status for current user
  Future<List<VideoModel>> fetchVideos({int limit = 10, int offset = 0}) async {
    try {
      final userId = _currentUserId;

      final response = await _supabase
          .from('videos')
          .select('*, video_likes(user_id), video_saves(user_id)')
          .range(offset, offset + limit - 1)
          .order('created_at', ascending: false);

      return (response as List<dynamic>).map((json) {
        final likes = json['video_likes'] as List<dynamic>? ?? [];
        final saves = json['video_saves'] as List<dynamic>? ?? [];
        final isLiked = userId != null && likes.any((l) => l['user_id'] == userId);
        final isSaved = userId != null && saves.any((s) => s['user_id'] == userId);

        final Map<String, dynamic> videoData = Map.from(json);
        videoData.remove('video_likes');
        videoData.remove('video_saves');
        videoData['isLiked'] = isLiked;
        videoData['isSaved'] = isSaved;
        videoData['likesCount'] = likes.length;

        return VideoModel.fromJson(videoData);
      }).toList();
    } catch (e) {
      print('⚠️ Error fetching videos: $e');
      return [];
    }
  }

  /// Fetch a single video by ID
  Future<VideoModel?> fetchVideoById(String id) async {
    try {
      final response = await _supabase
          .from('videos')
          .select()
          .eq('id', id)
          .single();

      return VideoModel.fromJson(response);
    } catch (e) {
      print('⚠️ Error fetching video $id: $e');
      return null;
    }
  }

  /// Search videos by title or subject
  Future<List<VideoModel>> searchVideos(String query, {int limit = 20}) async {
    try {
      final response = await _supabase
          .from('videos')
          .select()
          .or('title.ilike.%$query%,subject.ilike.%$query%,tags.cs.{$query}')
          .limit(limit)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => VideoModel.fromJson(json))
          .toList();
    } catch (e) {
      print('⚠️ Error searching videos: $e');
      return [];
    }
  }

  /// Fetch videos by subject category
  Future<List<VideoModel>> fetchBySubject(String subject, {int limit = 20}) async {
    try {
      final response = await _supabase
          .from('videos')
          .select()
          .ilike('subject', '%$subject%')
          .limit(limit)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => VideoModel.fromJson(json))
          .toList();
    } catch (e) {
      print('⚠️ Error fetching by subject: $e');
      return [];
    }
  }

  /// Fetch saved/bookmarked videos for current user
  Future<List<VideoModel>> fetchSavedVideos() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return [];

      final response = await _supabase
          .from('video_saves')
          .select('video_id, videos(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .where((r) => r['videos'] != null)
          .map((r) {
        final videoData = Map<String, dynamic>.from(r['videos']);
        videoData['isSaved'] = true;
        return VideoModel.fromJson(videoData);
      }).toList();
    } catch (e) {
      print('⚠️ Error fetching saved videos: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // INTERACTIONS
  // ─────────────────────────────────────────────

  /// Toggle Like status — returns true if now liked, false if unliked
  Future<bool> toggleLike(String videoId, String userId) async {
    try {
      final existing = await _supabase
          .from('video_likes')
          .select()
          .eq('video_id', videoId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('video_likes')
            .delete()
            .eq('video_id', videoId)
            .eq('user_id', userId);
        return false;
      } else {
        await _supabase
            .from('video_likes')
            .insert({'video_id': videoId, 'user_id': userId});
        return true;
      }
    } catch (e) {
      print('⚠️ Error toggling like: $e');
      rethrow;
    }
  }

  /// Toggle Save/Bookmark — returns true if now saved, false if unsaved
  Future<bool> toggleSave(String videoId, String userId) async {
    try {
      final existing = await _supabase
          .from('video_saves')
          .select()
          .eq('video_id', videoId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('video_saves')
            .delete()
            .eq('video_id', videoId)
            .eq('user_id', userId);
        return false;
      } else {
        await _supabase
            .from('video_saves')
            .insert({'video_id': videoId, 'user_id': userId});
        return true;
      }
    } catch (e) {
      print('⚠️ Error toggling save: $e');
      rethrow;
    }
  }
}
