import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/video_model.dart';
import '../../data/content/force_chapter_videos.dart';

/// Mock Video Data Provider
/// 
/// Includes Physics Force chapter content from ICSE Class X
/// Videos are designed for "The Lock" feature with varied question types
final mockVideosProvider = Provider<List<VideoModel>>((ref) {
  return [
    // ============ PHYSICS: FORCE CHAPTER (High Quality AI Content) ============
    ...ForceChapterVideos.getVideos(),
    // ==========================================================================
  ];
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
