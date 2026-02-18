import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/video_model.dart';
import '../../data/content/force_chapter_videos.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/videos_repository.dart';

/// Videos Repository Provider
final videosRepositoryProvider = Provider<VideosRepository>((ref) {
  return VideosRepository(Supabase.instance.client);
});

/// Local state for user-created videos (immediate feedback)
final userCreatedVideosProvider = StateProvider<List<VideoModel>>((ref) => []);

/// All Videos Provider (Supabase + Local + Mock Fallback)
final allVideosProvider = FutureProvider<List<VideoModel>>((ref) async {
  final userVideos = ref.watch(userCreatedVideosProvider);
  List<VideoModel> fetchedVideos = [];

  try {
    final repo = ref.read(videosRepositoryProvider);
    fetchedVideos = await repo.fetchVideos(limit: 50); // Fetch initial batch
  } catch (e) {
    print('⚠️ Failed to fetch videos from Supabase, falling back to mock: $e');
  }
  
  // Fallback to mock data if empty
  if (fetchedVideos.isEmpty) {
    fetchedVideos = ForceChapterVideos.getVideos();
  }

  // Combine user created (newest first) with fetched
  return [...userVideos, ...fetchedVideos];
});

/// Legacy Mock Provider (Deprecated, pointing to new FutureProvider logic via adaptive feed)
/// Kept for compatibility but should be migrated away from. 
/// Using standard Provider here to avoid breaking changes in dependent widgets 
/// that expect synchronous list, but this will return empty initially if purely async.
/// 
/// Ideally, consumers should watch `adaptiveFeedProvider` or `allVideosProvider` directly.
final mockVideosProvider = Provider<List<VideoModel>>((ref) {
   // This is a temporary shim. Real app should use async providers.
   // For now, return mock data immediately to prevent breakage.
   return ForceChapterVideos.getVideos();
});

/// Current Video Index State
final currentVideoIndexProvider = StateProvider<int>((ref) => 0);

/// Current Video Provider
final currentVideoProvider = Provider<VideoModel>((ref) {
  final videos = ref.watch(mockVideosProvider);
  final index = ref.watch(currentVideoIndexProvider);
  return videos[index % videos.length];
});

/// Video Lock State - tracks if each video is unlocked
final videoUnlockStateProvider = StateNotifierProvider<VideoUnlockNotifier, Map<String, bool>>((ref) {
  return VideoUnlockNotifier();
});

class VideoUnlockNotifier extends StateNotifier<Map<String, bool>> {
  VideoUnlockNotifier() : super({});

  bool isUnlocked(String videoId) => state[videoId] ?? false;

  void unlock(String videoId) {
    state = {...state, videoId: true};
  }

  void reset(String videoId) {
    state = {...state, videoId: false};
  }
}

/// Answer Validation State
enum AnswerState { idle, checking, correct, incorrect }

final answerStateProvider = StateProvider<AnswerState>((ref) => AnswerState.idle);

/// AI Feedback from Gemini
final aiFeedbackProvider = StateProvider<String?>((ref) => null);

/// Filter by subject
final selectedSubjectProvider = StateProvider<String?>((ref) => null);

/// Filtered videos based on selected subject
final filteredVideosProvider = Provider<List<VideoModel>>((ref) {
  final videos = ref.watch(mockVideosProvider);
  final selectedSubject = ref.watch(selectedSubjectProvider);
  
  if (selectedSubject == null || selectedSubject.isEmpty) {
    return videos;
  }
  
  return videos.where((v) => v.subject == selectedSubject).toList();
});

/// Saved / Bookmarked videos
/// Fetches persistent saves from Supabase/Local storage
final savedVideosProvider = FutureProvider<List<VideoModel>>((ref) async {
  try {
    final repo = ref.read(videosRepositoryProvider);
    return await repo.fetchSavedVideos();
  } catch (_) {
    return [];
  }
});
