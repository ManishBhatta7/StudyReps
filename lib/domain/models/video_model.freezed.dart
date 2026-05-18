// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VideoModel _$VideoModelFromJson(Map<String, dynamic> json) {
  return _VideoModel.fromJson(json);
}

/// @nodoc
mixin _$VideoModel {
  String get id => throw _privateConstructorUsedError;
  String get videoUrl =>
      throw _privateConstructorUsedError; // Empty for flashcards
  int get lockTimestamp =>
      throw _privateConstructorUsedError; // Seconds into video where lock occurs (0 for flashcards)
  QuestionModel get question => throw _privateConstructorUsedError;
  String get creatorName => throw _privateConstructorUsedError;
  String get creatorAvatar => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String get thumbnailUrl => throw _privateConstructorUsedError;
  int get likesCount => throw _privateConstructorUsedError;
  int get repsCompleted => throw _privateConstructorUsedError;
  bool get isLiked => throw _privateConstructorUsedError;
  bool get isSaved => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;
  int get startSeconds => throw _privateConstructorUsedError;
  int? get endSeconds =>
      throw _privateConstructorUsedError; // ── Content Type ──
  ContentType get contentType =>
      throw _privateConstructorUsedError; // ── Flashcard-Specific Fields ──
  String get flashcardFrontText =>
      throw _privateConstructorUsedError; // The "teach" side — concept explanation
  String get flashcardBackText =>
      throw _privateConstructorUsedError; // Optional back text (revealed after answer)
  String get flashcardImageUrl =>
      throw _privateConstructorUsedError; // Optional diagram/illustration URL
  String get flashcardEmoji =>
      throw _privateConstructorUsedError; // Visual emoji for the card header
// ── Adaptive Feed & Spaced Repetition Fields ──
  String get transcript => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  List<String> get prerequisiteIds => throw _privateConstructorUsedError;
  int get difficultyLevel => throw _privateConstructorUsedError;
  String get topicId => throw _privateConstructorUsedError;
  String get conceptCluster => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  List<String> get boards => throw _privateConstructorUsedError;
  List<String> get grades => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VideoModelCopyWith<VideoModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoModelCopyWith<$Res> {
  factory $VideoModelCopyWith(
          VideoModel value, $Res Function(VideoModel) then) =
      _$VideoModelCopyWithImpl<$Res, VideoModel>;
  @useResult
  $Res call(
      {String id,
      String videoUrl,
      int lockTimestamp,
      QuestionModel question,
      String creatorName,
      String creatorAvatar,
      String title,
      String subject,
      String thumbnailUrl,
      int likesCount,
      int repsCompleted,
      bool isLiked,
      bool isSaved,
      Duration duration,
      int startSeconds,
      int? endSeconds,
      ContentType contentType,
      String flashcardFrontText,
      String flashcardBackText,
      String flashcardImageUrl,
      String flashcardEmoji,
      String transcript,
      List<String> tags,
      List<String> prerequisiteIds,
      int difficultyLevel,
      String topicId,
      String conceptCluster,
      String language,
      List<String> boards,
      List<String> grades});

  $QuestionModelCopyWith<$Res> get question;
}

/// @nodoc
class _$VideoModelCopyWithImpl<$Res, $Val extends VideoModel>
    implements $VideoModelCopyWith<$Res> {
  _$VideoModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? videoUrl = null,
    Object? lockTimestamp = null,
    Object? question = null,
    Object? creatorName = null,
    Object? creatorAvatar = null,
    Object? title = null,
    Object? subject = null,
    Object? thumbnailUrl = null,
    Object? likesCount = null,
    Object? repsCompleted = null,
    Object? isLiked = null,
    Object? isSaved = null,
    Object? duration = null,
    Object? startSeconds = null,
    Object? endSeconds = freezed,
    Object? contentType = null,
    Object? flashcardFrontText = null,
    Object? flashcardBackText = null,
    Object? flashcardImageUrl = null,
    Object? flashcardEmoji = null,
    Object? transcript = null,
    Object? tags = null,
    Object? prerequisiteIds = null,
    Object? difficultyLevel = null,
    Object? topicId = null,
    Object? conceptCluster = null,
    Object? language = null,
    Object? boards = null,
    Object? grades = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      videoUrl: null == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      lockTimestamp: null == lockTimestamp
          ? _value.lockTimestamp
          : lockTimestamp // ignore: cast_nullable_to_non_nullable
              as int,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as QuestionModel,
      creatorName: null == creatorName
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String,
      creatorAvatar: null == creatorAvatar
          ? _value.creatorAvatar
          : creatorAvatar // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: null == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
      likesCount: null == likesCount
          ? _value.likesCount
          : likesCount // ignore: cast_nullable_to_non_nullable
              as int,
      repsCompleted: null == repsCompleted
          ? _value.repsCompleted
          : repsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaved: null == isSaved
          ? _value.isSaved
          : isSaved // ignore: cast_nullable_to_non_nullable
              as bool,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      startSeconds: null == startSeconds
          ? _value.startSeconds
          : startSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      endSeconds: freezed == endSeconds
          ? _value.endSeconds
          : endSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as ContentType,
      flashcardFrontText: null == flashcardFrontText
          ? _value.flashcardFrontText
          : flashcardFrontText // ignore: cast_nullable_to_non_nullable
              as String,
      flashcardBackText: null == flashcardBackText
          ? _value.flashcardBackText
          : flashcardBackText // ignore: cast_nullable_to_non_nullable
              as String,
      flashcardImageUrl: null == flashcardImageUrl
          ? _value.flashcardImageUrl
          : flashcardImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      flashcardEmoji: null == flashcardEmoji
          ? _value.flashcardEmoji
          : flashcardEmoji // ignore: cast_nullable_to_non_nullable
              as String,
      transcript: null == transcript
          ? _value.transcript
          : transcript // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      prerequisiteIds: null == prerequisiteIds
          ? _value.prerequisiteIds
          : prerequisiteIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      difficultyLevel: null == difficultyLevel
          ? _value.difficultyLevel
          : difficultyLevel // ignore: cast_nullable_to_non_nullable
              as int,
      topicId: null == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as String,
      conceptCluster: null == conceptCluster
          ? _value.conceptCluster
          : conceptCluster // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      boards: null == boards
          ? _value.boards
          : boards // ignore: cast_nullable_to_non_nullable
              as List<String>,
      grades: null == grades
          ? _value.grades
          : grades // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $QuestionModelCopyWith<$Res> get question {
    return $QuestionModelCopyWith<$Res>(_value.question, (value) {
      return _then(_value.copyWith(question: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VideoModelImplCopyWith<$Res>
    implements $VideoModelCopyWith<$Res> {
  factory _$$VideoModelImplCopyWith(
          _$VideoModelImpl value, $Res Function(_$VideoModelImpl) then) =
      __$$VideoModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String videoUrl,
      int lockTimestamp,
      QuestionModel question,
      String creatorName,
      String creatorAvatar,
      String title,
      String subject,
      String thumbnailUrl,
      int likesCount,
      int repsCompleted,
      bool isLiked,
      bool isSaved,
      Duration duration,
      int startSeconds,
      int? endSeconds,
      ContentType contentType,
      String flashcardFrontText,
      String flashcardBackText,
      String flashcardImageUrl,
      String flashcardEmoji,
      String transcript,
      List<String> tags,
      List<String> prerequisiteIds,
      int difficultyLevel,
      String topicId,
      String conceptCluster,
      String language,
      List<String> boards,
      List<String> grades});

  @override
  $QuestionModelCopyWith<$Res> get question;
}

/// @nodoc
class __$$VideoModelImplCopyWithImpl<$Res>
    extends _$VideoModelCopyWithImpl<$Res, _$VideoModelImpl>
    implements _$$VideoModelImplCopyWith<$Res> {
  __$$VideoModelImplCopyWithImpl(
      _$VideoModelImpl _value, $Res Function(_$VideoModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? videoUrl = null,
    Object? lockTimestamp = null,
    Object? question = null,
    Object? creatorName = null,
    Object? creatorAvatar = null,
    Object? title = null,
    Object? subject = null,
    Object? thumbnailUrl = null,
    Object? likesCount = null,
    Object? repsCompleted = null,
    Object? isLiked = null,
    Object? isSaved = null,
    Object? duration = null,
    Object? startSeconds = null,
    Object? endSeconds = freezed,
    Object? contentType = null,
    Object? flashcardFrontText = null,
    Object? flashcardBackText = null,
    Object? flashcardImageUrl = null,
    Object? flashcardEmoji = null,
    Object? transcript = null,
    Object? tags = null,
    Object? prerequisiteIds = null,
    Object? difficultyLevel = null,
    Object? topicId = null,
    Object? conceptCluster = null,
    Object? language = null,
    Object? boards = null,
    Object? grades = null,
  }) {
    return _then(_$VideoModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      videoUrl: null == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      lockTimestamp: null == lockTimestamp
          ? _value.lockTimestamp
          : lockTimestamp // ignore: cast_nullable_to_non_nullable
              as int,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as QuestionModel,
      creatorName: null == creatorName
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String,
      creatorAvatar: null == creatorAvatar
          ? _value.creatorAvatar
          : creatorAvatar // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: null == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
      likesCount: null == likesCount
          ? _value.likesCount
          : likesCount // ignore: cast_nullable_to_non_nullable
              as int,
      repsCompleted: null == repsCompleted
          ? _value.repsCompleted
          : repsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaved: null == isSaved
          ? _value.isSaved
          : isSaved // ignore: cast_nullable_to_non_nullable
              as bool,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      startSeconds: null == startSeconds
          ? _value.startSeconds
          : startSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      endSeconds: freezed == endSeconds
          ? _value.endSeconds
          : endSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as ContentType,
      flashcardFrontText: null == flashcardFrontText
          ? _value.flashcardFrontText
          : flashcardFrontText // ignore: cast_nullable_to_non_nullable
              as String,
      flashcardBackText: null == flashcardBackText
          ? _value.flashcardBackText
          : flashcardBackText // ignore: cast_nullable_to_non_nullable
              as String,
      flashcardImageUrl: null == flashcardImageUrl
          ? _value.flashcardImageUrl
          : flashcardImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      flashcardEmoji: null == flashcardEmoji
          ? _value.flashcardEmoji
          : flashcardEmoji // ignore: cast_nullable_to_non_nullable
              as String,
      transcript: null == transcript
          ? _value.transcript
          : transcript // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      prerequisiteIds: null == prerequisiteIds
          ? _value._prerequisiteIds
          : prerequisiteIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      difficultyLevel: null == difficultyLevel
          ? _value.difficultyLevel
          : difficultyLevel // ignore: cast_nullable_to_non_nullable
              as int,
      topicId: null == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as String,
      conceptCluster: null == conceptCluster
          ? _value.conceptCluster
          : conceptCluster // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      boards: null == boards
          ? _value._boards
          : boards // ignore: cast_nullable_to_non_nullable
              as List<String>,
      grades: null == grades
          ? _value._grades
          : grades // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoModelImpl implements _VideoModel {
  const _$VideoModelImpl(
      {required this.id,
      this.videoUrl = '',
      this.lockTimestamp = 0,
      required this.question,
      this.creatorName = 'StudyReps',
      this.creatorAvatar =
          'https://api.dicebear.com/7.x/avataaars/svg?seed=StudyReps',
      required this.title,
      required this.subject,
      this.thumbnailUrl = '',
      this.likesCount = 0,
      this.repsCompleted = 0,
      this.isLiked = false,
      this.isSaved = false,
      this.duration = Duration.zero,
      this.startSeconds = 0,
      this.endSeconds,
      this.contentType = ContentType.video,
      this.flashcardFrontText = '',
      this.flashcardBackText = '',
      this.flashcardImageUrl = '',
      this.flashcardEmoji = '',
      this.transcript = '',
      final List<String> tags = const [],
      final List<String> prerequisiteIds = const [],
      this.difficultyLevel = 1,
      this.topicId = '',
      this.conceptCluster = '',
      this.language = 'en',
      final List<String> boards = const [],
      final List<String> grades = const []})
      : _tags = tags,
        _prerequisiteIds = prerequisiteIds,
        _boards = boards,
        _grades = grades;

  factory _$VideoModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String videoUrl;
// Empty for flashcards
  @override
  @JsonKey()
  final int lockTimestamp;
// Seconds into video where lock occurs (0 for flashcards)
  @override
  final QuestionModel question;
  @override
  @JsonKey()
  final String creatorName;
  @override
  @JsonKey()
  final String creatorAvatar;
  @override
  final String title;
  @override
  final String subject;
  @override
  @JsonKey()
  final String thumbnailUrl;
  @override
  @JsonKey()
  final int likesCount;
  @override
  @JsonKey()
  final int repsCompleted;
  @override
  @JsonKey()
  final bool isLiked;
  @override
  @JsonKey()
  final bool isSaved;
  @override
  @JsonKey()
  final Duration duration;
  @override
  @JsonKey()
  final int startSeconds;
  @override
  final int? endSeconds;
// ── Content Type ──
  @override
  @JsonKey()
  final ContentType contentType;
// ── Flashcard-Specific Fields ──
  @override
  @JsonKey()
  final String flashcardFrontText;
// The "teach" side — concept explanation
  @override
  @JsonKey()
  final String flashcardBackText;
// Optional back text (revealed after answer)
  @override
  @JsonKey()
  final String flashcardImageUrl;
// Optional diagram/illustration URL
  @override
  @JsonKey()
  final String flashcardEmoji;
// Visual emoji for the card header
// ── Adaptive Feed & Spaced Repetition Fields ──
  @override
  @JsonKey()
  final String transcript;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<String> _prerequisiteIds;
  @override
  @JsonKey()
  List<String> get prerequisiteIds {
    if (_prerequisiteIds is EqualUnmodifiableListView) return _prerequisiteIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_prerequisiteIds);
  }

  @override
  @JsonKey()
  final int difficultyLevel;
  @override
  @JsonKey()
  final String topicId;
  @override
  @JsonKey()
  final String conceptCluster;
  @override
  @JsonKey()
  final String language;
  final List<String> _boards;
  @override
  @JsonKey()
  List<String> get boards {
    if (_boards is EqualUnmodifiableListView) return _boards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_boards);
  }

  final List<String> _grades;
  @override
  @JsonKey()
  List<String> get grades {
    if (_grades is EqualUnmodifiableListView) return _grades;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_grades);
  }

  @override
  String toString() {
    return 'VideoModel(id: $id, videoUrl: $videoUrl, lockTimestamp: $lockTimestamp, question: $question, creatorName: $creatorName, creatorAvatar: $creatorAvatar, title: $title, subject: $subject, thumbnailUrl: $thumbnailUrl, likesCount: $likesCount, repsCompleted: $repsCompleted, isLiked: $isLiked, isSaved: $isSaved, duration: $duration, startSeconds: $startSeconds, endSeconds: $endSeconds, contentType: $contentType, flashcardFrontText: $flashcardFrontText, flashcardBackText: $flashcardBackText, flashcardImageUrl: $flashcardImageUrl, flashcardEmoji: $flashcardEmoji, transcript: $transcript, tags: $tags, prerequisiteIds: $prerequisiteIds, difficultyLevel: $difficultyLevel, topicId: $topicId, conceptCluster: $conceptCluster, language: $language, boards: $boards, grades: $grades)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.lockTimestamp, lockTimestamp) ||
                other.lockTimestamp == lockTimestamp) &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.creatorName, creatorName) ||
                other.creatorName == creatorName) &&
            (identical(other.creatorAvatar, creatorAvatar) ||
                other.creatorAvatar == creatorAvatar) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.likesCount, likesCount) ||
                other.likesCount == likesCount) &&
            (identical(other.repsCompleted, repsCompleted) ||
                other.repsCompleted == repsCompleted) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.isSaved, isSaved) || other.isSaved == isSaved) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.startSeconds, startSeconds) ||
                other.startSeconds == startSeconds) &&
            (identical(other.endSeconds, endSeconds) ||
                other.endSeconds == endSeconds) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.flashcardFrontText, flashcardFrontText) ||
                other.flashcardFrontText == flashcardFrontText) &&
            (identical(other.flashcardBackText, flashcardBackText) ||
                other.flashcardBackText == flashcardBackText) &&
            (identical(other.flashcardImageUrl, flashcardImageUrl) ||
                other.flashcardImageUrl == flashcardImageUrl) &&
            (identical(other.flashcardEmoji, flashcardEmoji) ||
                other.flashcardEmoji == flashcardEmoji) &&
            (identical(other.transcript, transcript) ||
                other.transcript == transcript) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._prerequisiteIds, _prerequisiteIds) &&
            (identical(other.difficultyLevel, difficultyLevel) ||
                other.difficultyLevel == difficultyLevel) &&
            (identical(other.topicId, topicId) || other.topicId == topicId) &&
            (identical(other.conceptCluster, conceptCluster) ||
                other.conceptCluster == conceptCluster) &&
            (identical(other.language, language) ||
                other.language == language) &&
            const DeepCollectionEquality().equals(other._boards, _boards) &&
            const DeepCollectionEquality().equals(other._grades, _grades));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        videoUrl,
        lockTimestamp,
        question,
        creatorName,
        creatorAvatar,
        title,
        subject,
        thumbnailUrl,
        likesCount,
        repsCompleted,
        isLiked,
        isSaved,
        duration,
        startSeconds,
        endSeconds,
        contentType,
        flashcardFrontText,
        flashcardBackText,
        flashcardImageUrl,
        flashcardEmoji,
        transcript,
        const DeepCollectionEquality().hash(_tags),
        const DeepCollectionEquality().hash(_prerequisiteIds),
        difficultyLevel,
        topicId,
        conceptCluster,
        language,
        const DeepCollectionEquality().hash(_boards),
        const DeepCollectionEquality().hash(_grades)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoModelImplCopyWith<_$VideoModelImpl> get copyWith =>
      __$$VideoModelImplCopyWithImpl<_$VideoModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoModelImplToJson(
      this,
    );
  }
}

abstract class _VideoModel implements VideoModel {
  const factory _VideoModel(
      {required final String id,
      final String videoUrl,
      final int lockTimestamp,
      required final QuestionModel question,
      final String creatorName,
      final String creatorAvatar,
      required final String title,
      required final String subject,
      final String thumbnailUrl,
      final int likesCount,
      final int repsCompleted,
      final bool isLiked,
      final bool isSaved,
      final Duration duration,
      final int startSeconds,
      final int? endSeconds,
      final ContentType contentType,
      final String flashcardFrontText,
      final String flashcardBackText,
      final String flashcardImageUrl,
      final String flashcardEmoji,
      final String transcript,
      final List<String> tags,
      final List<String> prerequisiteIds,
      final int difficultyLevel,
      final String topicId,
      final String conceptCluster,
      final String language,
      final List<String> boards,
      final List<String> grades}) = _$VideoModelImpl;

  factory _VideoModel.fromJson(Map<String, dynamic> json) =
      _$VideoModelImpl.fromJson;

  @override
  String get id;
  @override
  String get videoUrl;
  @override // Empty for flashcards
  int get lockTimestamp;
  @override // Seconds into video where lock occurs (0 for flashcards)
  QuestionModel get question;
  @override
  String get creatorName;
  @override
  String get creatorAvatar;
  @override
  String get title;
  @override
  String get subject;
  @override
  String get thumbnailUrl;
  @override
  int get likesCount;
  @override
  int get repsCompleted;
  @override
  bool get isLiked;
  @override
  bool get isSaved;
  @override
  Duration get duration;
  @override
  int get startSeconds;
  @override
  int? get endSeconds;
  @override // ── Content Type ──
  ContentType get contentType;
  @override // ── Flashcard-Specific Fields ──
  String get flashcardFrontText;
  @override // The "teach" side — concept explanation
  String get flashcardBackText;
  @override // Optional back text (revealed after answer)
  String get flashcardImageUrl;
  @override // Optional diagram/illustration URL
  String get flashcardEmoji;
  @override // Visual emoji for the card header
// ── Adaptive Feed & Spaced Repetition Fields ──
  String get transcript;
  @override
  List<String> get tags;
  @override
  List<String> get prerequisiteIds;
  @override
  int get difficultyLevel;
  @override
  String get topicId;
  @override
  String get conceptCluster;
  @override
  String get language;
  @override
  List<String> get boards;
  @override
  List<String> get grades;
  @override
  @JsonKey(ignore: true)
  _$$VideoModelImplCopyWith<_$VideoModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) {
  return _QuestionModel.fromJson(json);
}

/// @nodoc
mixin _$QuestionModel {
  String get id =>
      throw _privateConstructorUsedError; // Made ID optional/default for easier data entry
  String get prompt => throw _privateConstructorUsedError;
  String get correctAnswer => throw _privateConstructorUsedError;
  QuestionType get type => throw _privateConstructorUsedError;
  List<String> get options =>
      throw _privateConstructorUsedError; // For multiple choice
  String get hint => throw _privateConstructorUsedError;
  String get explanation => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuestionModelCopyWith<QuestionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionModelCopyWith<$Res> {
  factory $QuestionModelCopyWith(
          QuestionModel value, $Res Function(QuestionModel) then) =
      _$QuestionModelCopyWithImpl<$Res, QuestionModel>;
  @useResult
  $Res call(
      {String id,
      String prompt,
      String correctAnswer,
      QuestionType type,
      List<String> options,
      String hint,
      String explanation});
}

/// @nodoc
class _$QuestionModelCopyWithImpl<$Res, $Val extends QuestionModel>
    implements $QuestionModelCopyWith<$Res> {
  _$QuestionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? prompt = null,
    Object? correctAnswer = null,
    Object? type = null,
    Object? options = null,
    Object? hint = null,
    Object? explanation = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      prompt: null == prompt
          ? _value.prompt
          : prompt // ignore: cast_nullable_to_non_nullable
              as String,
      correctAnswer: null == correctAnswer
          ? _value.correctAnswer
          : correctAnswer // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as QuestionType,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hint: null == hint
          ? _value.hint
          : hint // ignore: cast_nullable_to_non_nullable
              as String,
      explanation: null == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuestionModelImplCopyWith<$Res>
    implements $QuestionModelCopyWith<$Res> {
  factory _$$QuestionModelImplCopyWith(
          _$QuestionModelImpl value, $Res Function(_$QuestionModelImpl) then) =
      __$$QuestionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String prompt,
      String correctAnswer,
      QuestionType type,
      List<String> options,
      String hint,
      String explanation});
}

/// @nodoc
class __$$QuestionModelImplCopyWithImpl<$Res>
    extends _$QuestionModelCopyWithImpl<$Res, _$QuestionModelImpl>
    implements _$$QuestionModelImplCopyWith<$Res> {
  __$$QuestionModelImplCopyWithImpl(
      _$QuestionModelImpl _value, $Res Function(_$QuestionModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? prompt = null,
    Object? correctAnswer = null,
    Object? type = null,
    Object? options = null,
    Object? hint = null,
    Object? explanation = null,
  }) {
    return _then(_$QuestionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      prompt: null == prompt
          ? _value.prompt
          : prompt // ignore: cast_nullable_to_non_nullable
              as String,
      correctAnswer: null == correctAnswer
          ? _value.correctAnswer
          : correctAnswer // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as QuestionType,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hint: null == hint
          ? _value.hint
          : hint // ignore: cast_nullable_to_non_nullable
              as String,
      explanation: null == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuestionModelImpl implements _QuestionModel {
  const _$QuestionModelImpl(
      {this.id = '',
      required this.prompt,
      required this.correctAnswer,
      required this.type,
      final List<String> options = const [],
      this.hint = '',
      this.explanation = ''})
      : _options = options;

  factory _$QuestionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestionModelImplFromJson(json);

  @override
  @JsonKey()
  final String id;
// Made ID optional/default for easier data entry
  @override
  final String prompt;
  @override
  final String correctAnswer;
  @override
  final QuestionType type;
  final List<String> _options;
  @override
  @JsonKey()
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

// For multiple choice
  @override
  @JsonKey()
  final String hint;
  @override
  @JsonKey()
  final String explanation;

  @override
  String toString() {
    return 'QuestionModel(id: $id, prompt: $prompt, correctAnswer: $correctAnswer, type: $type, options: $options, hint: $hint, explanation: $explanation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.prompt, prompt) || other.prompt == prompt) &&
            (identical(other.correctAnswer, correctAnswer) ||
                other.correctAnswer == correctAnswer) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.hint, hint) || other.hint == hint) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, prompt, correctAnswer, type,
      const DeepCollectionEquality().hash(_options), hint, explanation);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionModelImplCopyWith<_$QuestionModelImpl> get copyWith =>
      __$$QuestionModelImplCopyWithImpl<_$QuestionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionModelImplToJson(
      this,
    );
  }
}

abstract class _QuestionModel implements QuestionModel {
  const factory _QuestionModel(
      {final String id,
      required final String prompt,
      required final String correctAnswer,
      required final QuestionType type,
      final List<String> options,
      final String hint,
      final String explanation}) = _$QuestionModelImpl;

  factory _QuestionModel.fromJson(Map<String, dynamic> json) =
      _$QuestionModelImpl.fromJson;

  @override
  String get id;
  @override // Made ID optional/default for easier data entry
  String get prompt;
  @override
  String get correctAnswer;
  @override
  QuestionType get type;
  @override
  List<String> get options;
  @override // For multiple choice
  String get hint;
  @override
  String get explanation;
  @override
  @JsonKey(ignore: true)
  _$$QuestionModelImplCopyWith<_$QuestionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
