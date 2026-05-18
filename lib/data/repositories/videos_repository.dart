import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/video_model.dart';
import '../content/force_chapter_videos.dart'; // For offline fallback data source

/// Repository for fetching video content and managing interactions via Supabase
class VideosRepository {
  final SupabaseClient _supabase;

  VideosRepository(this._supabase);

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // Local fallback storage for session persistence
  final Set<String> _localSavedVideoIds = {};
  final Set<String> _localLikedVideoIds = {};
  bool _localLoaded = false;

  Future<void> _ensureLocalLoaded() async {
    if (_localLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    _localSavedVideoIds.addAll(prefs.getStringList('local_saved_videos') ?? []);
    _localLikedVideoIds.addAll(prefs.getStringList('local_liked_videos') ?? []);
    _localLoaded = true;
  }

  Future<void> _persistLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('local_saved_videos', _localSavedVideoIds.toList());
    await prefs.setStringList('local_liked_videos', _localLikedVideoIds.toList());
  }

  // ─────────────────────────────────────────────
  // FETCH
  // ─────────────────────────────────────────────

  /// Fetch videos with pagination, including like/save status for current user
  Future<List<VideoModel>> fetchVideos({int limit = 10, int offset = 0}) async {
    await _ensureLocalLoaded();
    try {
      final userId = _currentUserId;

      final response = await _supabase
          .from('educational_content')
          .select('*, educational_likes(user_id), educational_saves(user_id)')
          .range(offset, offset + limit - 1)
          .order('created_at', ascending: false);

      return (response as List<dynamic>).map((json) {
        final likes = json['educational_likes'] as List<dynamic>? ?? [];
        final saves = json['educational_saves'] as List<dynamic>? ?? [];
        final isLiked = (userId != null && likes.any((l) => l['user_id'] == userId)) || _localLikedVideoIds.contains(json['id']);
        final isSaved = (userId != null && saves.any((s) => s['user_id'] == userId)) || _localSavedVideoIds.contains(json['id']);

        final Map<String, dynamic> videoData = Map.from(json);
        videoData.remove('educational_likes');
        videoData.remove('educational_saves');
        videoData['isLiked'] = isLiked;
        videoData['isSaved'] = isSaved;
        videoData['likesCount'] = likes.length;
        return VideoModel.fromJson(videoData);
      }).toList();
    } catch (e) {
      debugPrint('⚠️ Error fetching videos: $e');
      return [];
    }
  }

  /// Fetch a single video by ID
  Future<VideoModel?> fetchVideoById(String id) async {
    try {
      final response = await _supabase
          .from('educational_content')
          .select()
          .eq('id', id)
          .single();

      return VideoModel.fromJson(response);
    } catch (e) {
      debugPrint('⚠️ Error fetching video $id: $e');
      return null;
    }
  }

  /// Search videos by title or subject
  Future<List<VideoModel>> searchVideos(String query, {int limit = 20}) async {
    try {
      final response = await _supabase
          .from('educational_content')
          .select()
          .or('title.ilike.%$query%,subject.ilike.%$query%,tags.cs.{$query}')
          .limit(limit)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => VideoModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error searching videos: $e');
      return [];
    }
  }

  /// Fetch videos by subject category
  Future<List<VideoModel>> fetchBySubject(String subject, {int limit = 20}) async {
    try {
      final response = await _supabase
          .from('educational_content')
          .select()
          .ilike('subject', '%$subject%')
          .limit(limit)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => VideoModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error fetching by subject: $e');
      return [];
    }
  }

  /// Fetch saved/bookmarked videos for current user
  Future<List<VideoModel>> fetchSavedVideos() async {
    await _ensureLocalLoaded();
    try {
      final userId = _currentUserId;
      final savedVideos = <VideoModel>[];

      if (userId != null) {
        final response = await _supabase
            .from('educational_saves')
            .select('video_id, educational_content(*)')
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        savedVideos.addAll((response as List<dynamic>)
            .where((r) => r['educational_content'] != null)
            .map((r) {
          final videoData = Map<String, dynamic>.from(r['educational_content']);
          videoData['isSaved'] = true;
          return VideoModel.fromJson(videoData);
        }));
      }

      // Merge with local saved state (for session persistence if DB lags or fails)
      final fetchedIds = savedVideos.map((v) => v.id).toSet();
      final mockVideos = ForceChapterVideos.getVideos();
      
      for (final localId in _localSavedVideoIds) {
        if (!fetchedIds.contains(localId)) {
          try {
            // Try to find in mock data
            final video = mockVideos.firstWhere(
              (v) => v.id == localId,
              orElse: () => throw Exception('Video not found in mock'),
            );
            savedVideos.add(video.copyWith(isSaved: true));
            fetchedIds.add(localId);
          } catch (_) {
            // Ignore if not found in mock either
          }
        }
      }
      
      return savedVideos;

    } catch (e) {
      debugPrint('⚠️ Error fetching saved videos: $e');
      
      // Full Fallback: Return locally saved videos from Mock Data
      if (_localSavedVideoIds.isNotEmpty) {
        final mockVideos = ForceChapterVideos.getVideos();
        return mockVideos
            .where((v) => _localSavedVideoIds.contains(v.id))
            .map((v) => v.copyWith(isSaved: true))
            .toList();
      }
      
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // INTERACTIONS
  // ─────────────────────────────────────────────

  /// Toggle Like status — fallback to local if DB fails
  Future<bool> toggleLike(String videoId, String userId) async {
    await _ensureLocalLoaded();
    try {
      final existing = await _supabase
          .from('educational_likes')
          .select()
          .eq('video_id', videoId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('educational_likes')
            .delete()
            .eq('video_id', videoId)
            .eq('user_id', userId);
        _localLikedVideoIds.remove(videoId);
        _persistLocal();
        return false;
      } else {
        await _supabase
            .from('educational_likes')
            .insert({'video_id': videoId, 'user_id': userId});
        _localLikedVideoIds.add(videoId);
        _persistLocal();
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ Error toggling like (using fallback): $e');
      // Fallback: Toggle local state
      if (_localLikedVideoIds.contains(videoId)) {
        _localLikedVideoIds.remove(videoId);
        _persistLocal();
        return false;
      } else {
        _localLikedVideoIds.add(videoId);
        _persistLocal();
        return true;
      }
    }
  }

  /// Toggle Save/Bookmark — fallback to local if DB fails
  Future<bool> toggleSave(String videoId, String userId) async {
    await _ensureLocalLoaded();
    try {
      final existing = await _supabase
          .from('educational_saves')
          .select()
          .eq('video_id', videoId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('educational_saves')
            .delete()
            .eq('video_id', videoId)
            .eq('user_id', userId);
        _localSavedVideoIds.remove(videoId);
        _persistLocal();
        return false;
      } else {
        await _supabase
            .from('educational_saves')
            .insert({'video_id': videoId, 'user_id': userId});
        _localSavedVideoIds.add(videoId);
        _persistLocal();
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ Error toggling save (using fallback): $e');
      // Fallback: Toggle local state
      if (_localSavedVideoIds.contains(videoId)) {
        _localSavedVideoIds.remove(videoId);
        _persistLocal();
        return false;
      } else {
        _localSavedVideoIds.add(videoId);
        _persistLocal();
        return true;
      }
    }
  }

  /// Log a video view
  Future<void> logView(String videoId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      await _supabase.from('educational_views').insert({
        'video_id': videoId,
        'user_id': userId, // Can be null if anonymous
        'viewed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Fail silently for analytics
      debugPrint('⚠️ Error logging view: $e');
    }
  }

  /// Log a video share
  Future<void> logShare(String videoId, {String? platform}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      await _supabase.from('educational_shares').insert({
        'video_id': videoId,
        'user_id': userId, // Can be null if anonymous
        'shared_at': DateTime.now().toIso8601String(),
        'platform': platform,
      });
    } catch (e) {
      debugPrint('⚠️ Error logging share: $e');
    }
  }
}

