import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../domain/models/learning_record_model.dart';

/// Spaced Repetition Service
///
/// Implements the SM-2 (SuperMemo 2) algorithm to schedule review intervals.
/// Videos that the user answers correctly get pushed further into the future;
/// videos answered incorrectly get scheduled sooner.
///
/// The algorithm adjusts the "ease factor" based on the quality of recall:
///   - Quality 5 (perfect): EF increases, long interval
///   - Quality 3 (correct with difficulty): EF stays, moderate interval
///   - Quality 0-2 (incorrect): Reset to beginning, EF decreases
///
/// Local storage uses Hive; syncs to Supabase when online.
class SpacedRepetitionService {
  static const String boxName = 'learning_records';

  /// Store a record after user interacts with a video
  static Future<LearningRecord> recordInteraction({
    required String userId,
    required String videoId,
    required bool isCorrect,
    required int dwellTimeMs,
    int quality = 3, // 0-5 SM-2 quality rating
  }) async {
    final box = await Hive.openBox(boxName);
    final key = '${userId}_$videoId';

    // Load existing record or create new
    final existingJson = box.get(key);
    LearningRecord record;

    if (existingJson != null) {
      record = LearningRecord.fromJson(Map<String, dynamic>.from(existingJson));
    } else {
      record = LearningRecord.create(userId: userId, videoId: videoId);
    }

    // Update interaction metrics
    record = record.copyWith(
      attempts: record.attempts + 1,
      isCorrect: isCorrect,
      correctCount: isCorrect ? record.correctCount + 1 : record.correctCount,
      dwellTimeMs: record.dwellTimeMs + dwellTimeMs,
      lastReviewedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Apply SM-2 algorithm
    record = _applySM2(record, quality);

    // Calculate mastery score
    record = _calculateMastery(record);

    // Persist to Hive
    await box.put(key, record.toJson());

    debugPrint('📊 SR: videoId=$videoId correct=$isCorrect '
        'ef=${record.easeFactor.toStringAsFixed(2)} '
        'interval=${record.interval}d '
        'nextReview=${record.nextReviewAt?.toIso8601String() ?? "none"}');

    return record;
  }

  /// Get all videos due for review right now
  static Future<List<String>> getVideosForReview(String userId) async {
    final box = await Hive.openBox(boxName);
    final now = DateTime.now();
    final dueVideoIds = <String>[];

    for (final key in box.keys) {
      if (key.toString().startsWith('${userId}_')) {
        final data = box.get(key);
        if (data != null) {
          final record = LearningRecord.fromJson(Map<String, dynamic>.from(data));

          // Include if review date has passed and not yet mastered
          if (!record.isMastered &&
              record.nextReviewAt != null &&
              record.nextReviewAt!.isBefore(now)) {
            dueVideoIds.add(record.videoId);
          }
        }
      }
    }

    debugPrint('📅 SR: ${dueVideoIds.length} videos due for review');
    return dueVideoIds;
  }

  /// Get the learning record for a specific video
  static Future<LearningRecord?> getRecord(String userId, String videoId) async {
    final box = await Hive.openBox(boxName);
    final key = '${userId}_$videoId';
    final data = box.get(key);

    if (data != null) {
      return LearningRecord.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  /// Get all learning records for a user
  static Future<List<LearningRecord>> getAllRecords(String userId) async {
    final box = await Hive.openBox(boxName);
    final records = <LearningRecord>[];

    for (final key in box.keys) {
      if (key.toString().startsWith('${userId}_')) {
        final data = box.get(key);
        if (data != null) {
          records.add(LearningRecord.fromJson(Map<String, dynamic>.from(data)));
        }
      }
    }

    return records;
  }

  /// Get video IDs that the user has struggled with (low mastery + multiple attempts)
  static Future<List<String>> getStruggledVideoIds(String userId) async {
    final records = await getAllRecords(userId);
    return records
        .where((r) => r.masteryScore < 0.4 && r.attempts >= 2)
        .map((r) => r.videoId)
        .toList();
  }

  /// Get video IDs that the user has mastered
  static Future<Set<String>> getMasteredVideoIds(String userId) async {
    final records = await getAllRecords(userId);
    return records
        .where((r) => r.isMastered)
        .map((r) => r.videoId)
        .toSet();
  }

  // ─── SM-2 Algorithm Implementation ───

  /// Apply the SM-2 spaced repetition algorithm
  static LearningRecord _applySM2(LearningRecord record, int quality) {
    // Clamp quality to 0-5
    quality = quality.clamp(0, 5);

    double ef = record.easeFactor;
    int interval = record.interval;
    int repetition = record.repetition;

    if (quality >= 3) {
      // Correct answer → increase interval
      if (repetition == 0) {
        interval = 1; // First correct: review tomorrow
      } else if (repetition == 1) {
        interval = 6; // Second correct: review in 6 days
      } else {
        interval = (interval * ef).round(); // Subsequent: multiply by ease factor
      }
      repetition++;

      // Update ease factor: EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
      ef = ef + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
      ef = max(1.3, ef); // EF never drops below 1.3
    } else {
      // Incorrect answer → reset to beginning
      repetition = 0;
      interval = 1; // Review tomorrow
      // EF stays the same on failure (SM-2 spec)
    }

    final nextReview = DateTime.now().add(Duration(days: interval));

    return record.copyWith(
      easeFactor: ef,
      interval: interval,
      repetition: repetition,
      nextReviewAt: nextReview,
    );
  }

  /// Calculate composite mastery score (0.0 - 1.0)
  static LearningRecord _calculateMastery(LearningRecord record) {
    if (record.attempts == 0) {
      return record.copyWith(masteryScore: 0.0, isMastered: false);
    }

    // Weighted factors:
    // 40% - Accuracy rate
    // 30% - Ease factor relative to max (normalized from 1.3-3.0 to 0-1)
    // 20% - Number of successful repetitions (capped at 5)
    // 10% - Recency bonus (answered correctly recently)

    final accuracy = record.correctCount / record.attempts;
    final efNormalized = ((record.easeFactor - 1.3) / 1.7).clamp(0.0, 1.0);
    final repScore = (record.repetition / 5.0).clamp(0.0, 1.0);

    double recencyBonus = 0.0;
    if (record.lastReviewedAt != null && record.isCorrect) {
      final daysSinceReview = DateTime.now().difference(record.lastReviewedAt!).inDays;
      recencyBonus = daysSinceReview <= 7 ? 1.0 : (14 - daysSinceReview).clamp(0, 7) / 7.0;
    }

    final mastery = (accuracy * 0.4) + (efNormalized * 0.3) + (repScore * 0.2) + (recencyBonus * 0.1);
    final clampedMastery = mastery.clamp(0.0, 1.0);

    return record.copyWith(
      masteryScore: clampedMastery,
      isMastered: clampedMastery >= 0.8 && record.repetition >= 3,
    );
  }

  /// Clear all records (for testing)
  static Future<void> clearAll() async {
    final box = await Hive.openBox(boxName);
    await box.clear();
  }
}
