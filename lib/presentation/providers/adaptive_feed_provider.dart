import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/video_model.dart';
import '../../domain/models/learning_record_model.dart';
import '../../data/services/spaced_repetition_service.dart';
import 'video_feed_provider.dart';

/// Adaptive Feed Provider
///
/// Replaces the static mock video list with an intelligent feed that:
/// 1. Mixes new content with spaced-repetition review items
/// 2. Detects user struggles → injects prerequisite videos
/// 3. Respects difficulty progression (easy → hard)
/// 4. Enforces fairness constraints (subject diversity, creator diversity)
///
/// Architecture: "GPS for Learning" — if the user struggles, the feed
/// adjusts to show prerequisite content rather than just more of the same.

// ── Current user ID (placeholder until auth is wired) ──
final currentUserIdProvider = StateProvider<String>((ref) => 'local_user');

// ── Feed configuration ──
final feedConfigProvider = Provider<FeedConfig>((ref) => const FeedConfig());

// ── The main adaptive feed ──
final adaptiveFeedProvider = FutureProvider<List<VideoModel>>((ref) async {
  final allVideos = ref.watch(mockVideosProvider);
  final userId = ref.watch(currentUserIdProvider);
  final config = ref.watch(feedConfigProvider);

  if (allVideos.isEmpty) return [];

  return AdaptiveFeedEngine.buildFeed(
    allVideos: allVideos,
    userId: userId,
    config: config,
  );
});

// ── Feed state: tracks which videos are review items ──
final reviewVideoIdsProvider = FutureProvider<Set<String>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final reviewIds = await SpacedRepetitionService.getVideosForReview(userId);
  return reviewIds.toSet();
});

// ── Video mastery map ──
final videoMasteryProvider = FutureProvider<Map<String, double>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final records = await SpacedRepetitionService.getAllRecords(userId);
  return {for (final r in records) r.videoId: r.masteryScore};
});

/// Feed configuration parameters
class FeedConfig {
  final double reviewInjectionRate;     // % of feed that should be review items
  final int maxConsecutiveSameSubject;  // Fairness: max same-subject in a row
  final int maxConsecutiveSameCreator;  // Fairness: max same-creator in a row
  final bool enablePrerequisiteInjection;
  final bool enableDifficultyProgression;

  const FeedConfig({
    this.reviewInjectionRate = 0.25,       // 25% review items
    this.maxConsecutiveSameSubject = 3,
    this.maxConsecutiveSameCreator = 2,
    this.enablePrerequisiteInjection = true,
    this.enableDifficultyProgression = true,
  });
}

/// The adaptive feed engine that builds personalized video sequences
class AdaptiveFeedEngine {
  /// Build a personalized feed for a user
  static Future<List<VideoModel>> buildFeed({
    required List<VideoModel> allVideos,
    required String userId,
    required FeedConfig config,
  }) async {
    if (allVideos.isEmpty) return [];

    // 1. Gather user learning data
    final reviewVideoIds = await SpacedRepetitionService.getVideosForReview(userId);
    final struggledVideoIds = await SpacedRepetitionService.getStruggledVideoIds(userId);
    final masteredVideoIds = await SpacedRepetitionService.getMasteredVideoIds(userId);
    final allRecords = await SpacedRepetitionService.getAllRecords(userId);
    final recordMap = {for (final r in allRecords) r.videoId: r};

    debugPrint('🧠 AdaptiveFeed: ${reviewVideoIds.length} reviews, '
        '${struggledVideoIds.length} struggled, '
        '${masteredVideoIds.length} mastered, '
        '${allVideos.length} total videos');

    // 2. Categorize videos
    final reviewVideos = <VideoModel>[];
    final prerequisiteVideos = <VideoModel>[];
    final newVideos = <VideoModel>[];
    final masteredVideos = <VideoModel>[];

    for (final video in allVideos) {
      if (reviewVideoIds.contains(video.id)) {
        reviewVideos.add(video);
      } else if (masteredVideoIds.contains(video.id)) {
        masteredVideos.add(video);
      } else if (!recordMap.containsKey(video.id)) {
        newVideos.add(video);
      }
    }

    // 3. Find prerequisites for struggled videos
    if (config.enablePrerequisiteInjection) {
      for (final struggledId in struggledVideoIds) {
        final struggledVideo = allVideos.where((v) => v.id == struggledId).firstOrNull;
        if (struggledVideo != null) {
          for (final prereqId in struggledVideo.prerequisiteIds) {
            final prereq = allVideos.where((v) => v.id == prereqId).firstOrNull;
            if (prereq != null && !masteredVideoIds.contains(prereqId)) {
              prerequisiteVideos.add(prereq);
            }
          }
        }
      }
    }

    // 4. Sort new videos by difficulty if enabled
    if (config.enableDifficultyProgression) {
      newVideos.sort((a, b) => a.difficultyLevel.compareTo(b.difficultyLevel));
    }

    // 5. Interleave: review items injected at configured rate
    final feed = <VideoModel>[];
    int newIndex = 0;
    int reviewIndex = 0;
    int prereqIndex = 0;
    int videosSinceReview = 0;
    final reviewInterval = config.reviewInjectionRate > 0
        ? (1 / config.reviewInjectionRate).round()
        : 999;

    // Prioritize prerequisites first
    while (prereqIndex < prerequisiteVideos.length) {
      feed.add(prerequisiteVideos[prereqIndex++]);
    }

    // Then interleave new content with reviews
    while (newIndex < newVideos.length || reviewIndex < reviewVideos.length) {
      // Inject review item at configured intervals
      if (reviewIndex < reviewVideos.length &&
          videosSinceReview >= reviewInterval) {
        feed.add(reviewVideos[reviewIndex++]);
        videosSinceReview = 0;
      } else if (newIndex < newVideos.length) {
        feed.add(newVideos[newIndex++]);
        videosSinceReview++;
      } else if (reviewIndex < reviewVideos.length) {
        feed.add(reviewVideos[reviewIndex++]);
      }
    }

    // 6. Apply fairness constraints
    final fairFeed = _applyFairnessConstraints(feed, config);

    debugPrint('🎯 AdaptiveFeed: built ${fairFeed.length} items '
        '(${prerequisiteVideos.length} prereqs, '
        '${reviewVideos.length} reviews, '
        '${newVideos.length} new)');

    // If feed is empty (all mastered), recycle mastered at higher difficulty
    if (fairFeed.isEmpty && masteredVideos.isNotEmpty) {
      return masteredVideos;
    }

    return fairFeed;
  }

  /// Apply fairness constraints to prevent repetitive content
  static List<VideoModel> _applyFairnessConstraints(
    List<VideoModel> feed,
    FeedConfig config,
  ) {
    if (feed.length <= 1) return feed;

    final result = <VideoModel>[feed.first];
    final remaining = feed.sublist(1).toList();

    while (remaining.isNotEmpty) {
      // Find the first video that doesn't violate constraints
      int? bestIndex;

      for (int i = 0; i < remaining.length; i++) {
        if (_passesConstraints(result, remaining[i], config)) {
          bestIndex = i;
          break;
        }
      }

      // If no video passes constraints, just take the first one
      bestIndex ??= 0;
      result.add(remaining.removeAt(bestIndex));
    }

    return result;
  }

  /// Check if adding a video would violate fairness constraints
  static bool _passesConstraints(
    List<VideoModel> currentFeed,
    VideoModel candidate,
    FeedConfig config,
  ) {
    if (currentFeed.isEmpty) return true;

    // Check subject diversity
    int consecutiveSubject = 0;
    for (int i = currentFeed.length - 1; i >= 0; i--) {
      if (currentFeed[i].subject == candidate.subject) {
        consecutiveSubject++;
      } else {
        break;
      }
    }
    if (consecutiveSubject >= config.maxConsecutiveSameSubject) return false;

    // Check creator diversity
    int consecutiveCreator = 0;
    for (int i = currentFeed.length - 1; i >= 0; i--) {
      if (currentFeed[i].creatorName == candidate.creatorName) {
        consecutiveCreator++;
      } else {
        break;
      }
    }
    if (consecutiveCreator >= config.maxConsecutiveSameCreator) return false;

    return true;
  }
}
