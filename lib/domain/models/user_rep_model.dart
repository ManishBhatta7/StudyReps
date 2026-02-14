import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_rep_model.freezed.dart';
part 'user_rep_model.g.dart';

/// User Rep Model
/// 
/// Tracks user's attempts at "The Rep" (answering questions)
/// Used for progress tracking and Supabase sync
@freezed
class UserRepModel with _$UserRepModel {
  const factory UserRepModel({
    required String id,
    required String oderId,
    required String videoId,
    required bool isCorrect,
    required String userAnswer,
    required DateTime attemptDate,
    @Default(1) int attemptCount,
    String? aiFeedback,
  }) = _UserRepModel;

  factory UserRepModel.fromJson(Map<String, dynamic> json) =>
      _$UserRepModelFromJson(json);
}

/// User Stats for gamification
@freezed
class UserStatsModel with _$UserStatsModel {
  const factory UserStatsModel({
    required String userId,
    @Default(0) int totalReps,
    @Default(0) int correctReps,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0) int totalXp,
    DateTime? lastRepDate,
  }) = _UserStatsModel;

  factory UserStatsModel.fromJson(Map<String, dynamic> json) =>
      _$UserStatsModelFromJson(json);
}
