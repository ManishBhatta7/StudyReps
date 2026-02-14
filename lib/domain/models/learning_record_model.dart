import 'package:freezed_annotation/freezed_annotation.dart';

part 'learning_record_model.freezed.dart';
part 'learning_record_model.g.dart';

/// Learning Record Model
///
/// Tracks a user's interaction with each video for the adaptive algorithm
/// and spaced repetition engine. Each record captures dwell time, attempts,
/// correctness, and SM-2 scheduling parameters.
@freezed
class LearningRecord with _$LearningRecord {
  const LearningRecord._();

  const factory LearningRecord({
    required String id,
    required String userId,
    required String videoId,

    // ── Interaction Metrics ──
    @Default(0) int dwellTimeMs,          // Total time spent on this video
    @Default(0) int attempts,             // Number of answer attempts
    @Default(false) bool isCorrect,       // Was the latest attempt correct?
    @Default(0) int correctCount,         // Total correct answers across reviews

    // ── SM-2 Spaced Repetition Parameters ──
    @Default(2.5) double easeFactor,      // Ease factor (≥1.3, starts at 2.5)
    @Default(0) int interval,             // Current interval in days
    @Default(0) int repetition,           // Number of successful repetitions
    DateTime? nextReviewAt,               // When to re-inject into feed
    DateTime? lastReviewedAt,             // When the user last saw this

    // ── Mastery Tracking ──
    @Default(0.0) double masteryScore,    // 0.0-1.0 composite mastery
    @Default(false) bool isMastered,      // True when masteryScore > 0.8

    // ── Timestamps ──
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _LearningRecord;

  factory LearningRecord.fromJson(Map<String, dynamic> json) =>
      _$LearningRecordFromJson(json);

  /// Create a fresh record for a new user-video pair
  factory LearningRecord.create({
    required String userId,
    required String videoId,
  }) {
    return LearningRecord(
      id: '${userId}_$videoId',
      userId: userId,
      videoId: videoId,
      createdAt: DateTime.now(),
    );
  }
}
