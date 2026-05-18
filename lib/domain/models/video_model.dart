import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_model.freezed.dart';
part 'video_model.g.dart';

/// Content Type for feed items
enum ContentType {
  @JsonValue('video')
  video,
  @JsonValue('flashcard')
  flashcard,
}

/// Feed Item Model for StudyReps
/// 
/// Represents either a TikTok-style educational video or an interactive flashcard.
/// For videos: pauses at [lockTimestamp] and requires answering [question] to continue.
/// For flashcards: shows [flashcardFrontText] first, then the question gate.
@freezed
class VideoModel with _$VideoModel {
  const factory VideoModel({
    required String id,
    @Default('') String videoUrl,              // Empty for flashcards
    @Default(0) int lockTimestamp,              // Seconds into video where lock occurs (0 for flashcards)
    required QuestionModel question,
    @Default('StudyReps') String creatorName,
    @Default('https://api.dicebear.com/7.x/avataaars/svg?seed=StudyReps') String creatorAvatar,
    required String title,
    required String subject,
    @Default('') String thumbnailUrl,
    @Default(0) int likesCount,
    @Default(0) int repsCompleted,
    @Default(false) bool isLiked,
    @Default(false) bool isSaved,
    @Default(Duration.zero) Duration duration,
    @Default(0) int startSeconds,
    int? endSeconds,

    // ── Content Type ──
    @Default(ContentType.video) ContentType contentType,

    // ── Flashcard-Specific Fields ──
    @Default('') String flashcardFrontText,     // The "teach" side — concept explanation
    @Default('') String flashcardBackText,      // Optional back text (revealed after answer)
    @Default('') String flashcardImageUrl,      // Optional diagram/illustration URL
    @Default('') String flashcardEmoji,         // Visual emoji for the card header

    // ── Adaptive Feed & Spaced Repetition Fields ──
    @Default('') String transcript,
    @Default([]) List<String> tags,
    @Default([]) List<String> prerequisiteIds,
    @Default(1) int difficultyLevel,
    @Default('') String topicId,
    @Default('') String conceptCluster,
    @Default('en') String language,
    @Default([]) List<String> boards,
    @Default([]) List<String> grades,
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
