import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_model.freezed.dart';
part 'video_model.g.dart';

/// Video Model for StudyReps
/// 
/// Represents a TikTok-style educational video with "The Lock" feature.
/// Videos pause at [lockTimestamp] and require answering [question] to continue.
@freezed
class VideoModel with _$VideoModel {
  const factory VideoModel({
    required String id,
    required String videoUrl,
    required int lockTimestamp, // Seconds into video where lock occurs
    required QuestionModel question,
    @Default('StudyReps') String creatorName,
    @Default('https://api.dicebear.com/7.x/avataaars/svg?seed=StudyReps') String creatorAvatar,
    required String title,
    required String subject,
    @Default('') String thumbnailUrl, // Added for UI
    @Default(0) int likesCount,
    @Default(0) int repsCompleted,
    @Default(false) bool isLiked,
    @Default(Duration.zero) Duration duration, // Added missing duration

    // ── Adaptive Feed & Spaced Repetition Fields ──
    @Default('') String transcript,              // Full text for tutorbot context & quiz gen
    @Default([]) List<String> tags,              // Searchable tags for discovery
    @Default([]) List<String> prerequisiteIds,   // Video IDs that should be mastered first
    @Default(1) int difficultyLevel,             // 1-5 scale
    @Default('') String topicId,                 // Maps to TopicSchema.id
    @Default('') String conceptCluster,          // Groups related concepts (e.g. "newton_laws")
    @Default('en') String language,              // ISO 639-1 language code
  }) = _VideoModel;

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);
}

/// Question Model for "The Rep" interaction
@freezed
class QuestionModel with _$QuestionModel {
  const factory QuestionModel({
    @Default('') String id, // Made ID optional/default for easier data entry
    required String prompt,
    required String correctAnswer,
    required QuestionType type,
    @Default([]) List<String> options, // For multiple choice
    @Default('') String hint,
    @Default('') String explanation, // Added for post-answer learning
  }) = _QuestionModel;

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);
}

/// Types of questions for The Rep
enum QuestionType {
  @JsonValue('text')
  text,
  @JsonValue('multiple_choice')
  multipleChoice,
  @JsonValue('drag_drop')
  dragDrop,
  @JsonValue('equation')
  equation,
  @JsonValue('short_answer')
  shortAnswer,
  @JsonValue('true_false')
  trueFalse,
  @JsonValue('numerical')
  numerical,
  @JsonValue('fill_blank')
  fillBlank,
  @JsonValue('open_input')
  openInput,
}
