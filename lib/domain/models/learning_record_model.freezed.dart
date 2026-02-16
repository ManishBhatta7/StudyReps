// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'learning_record_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LearningRecord _$LearningRecordFromJson(Map<String, dynamic> json) {
  return _LearningRecord.fromJson(json);
}

/// @nodoc
mixin _$LearningRecord {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get videoId =>
      throw _privateConstructorUsedError; // ── Interaction Metrics ──
  int get dwellTimeMs =>
      throw _privateConstructorUsedError; // Total time spent on this video
  int get attempts =>
      throw _privateConstructorUsedError; // Number of answer attempts
  bool get isCorrect =>
      throw _privateConstructorUsedError; // Was the latest attempt correct?
  int get correctCount =>
      throw _privateConstructorUsedError; // Total correct answers across reviews
// ── SM-2 Spaced Repetition Parameters ──
  double get easeFactor =>
      throw _privateConstructorUsedError; // Ease factor (≥1.3, starts at 2.5)
  int get interval =>
      throw _privateConstructorUsedError; // Current interval in days
  int get repetition =>
      throw _privateConstructorUsedError; // Number of successful repetitions
  DateTime? get nextReviewAt =>
      throw _privateConstructorUsedError; // When to re-inject into feed
  DateTime? get lastReviewedAt =>
      throw _privateConstructorUsedError; // When the user last saw this
// ── Mastery Tracking ──
  double get masteryScore =>
      throw _privateConstructorUsedError; // 0.0-1.0 composite mastery
  bool get isMastered =>
      throw _privateConstructorUsedError; // True when masteryScore > 0.8
// ── Timestamps ──
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get syncedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LearningRecordCopyWith<LearningRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LearningRecordCopyWith<$Res> {
  factory $LearningRecordCopyWith(
          LearningRecord value, $Res Function(LearningRecord) then) =
      _$LearningRecordCopyWithImpl<$Res, LearningRecord>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String videoId,
      int dwellTimeMs,
      int attempts,
      bool isCorrect,
      int correctCount,
      double easeFactor,
      int interval,
      int repetition,
      DateTime? nextReviewAt,
      DateTime? lastReviewedAt,
      double masteryScore,
      bool isMastered,
      DateTime createdAt,
      DateTime? updatedAt,
      DateTime? syncedAt});
}

/// @nodoc
class _$LearningRecordCopyWithImpl<$Res, $Val extends LearningRecord>
    implements $LearningRecordCopyWith<$Res> {
  _$LearningRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? videoId = null,
    Object? dwellTimeMs = null,
    Object? attempts = null,
    Object? isCorrect = null,
    Object? correctCount = null,
    Object? easeFactor = null,
    Object? interval = null,
    Object? repetition = null,
    Object? nextReviewAt = freezed,
    Object? lastReviewedAt = freezed,
    Object? masteryScore = null,
    Object? isMastered = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? syncedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      dwellTimeMs: null == dwellTimeMs
          ? _value.dwellTimeMs
          : dwellTimeMs // ignore: cast_nullable_to_non_nullable
              as int,
      attempts: null == attempts
          ? _value.attempts
          : attempts // ignore: cast_nullable_to_non_nullable
              as int,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      correctCount: null == correctCount
          ? _value.correctCount
          : correctCount // ignore: cast_nullable_to_non_nullable
              as int,
      easeFactor: null == easeFactor
          ? _value.easeFactor
          : easeFactor // ignore: cast_nullable_to_non_nullable
              as double,
      interval: null == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as int,
      repetition: null == repetition
          ? _value.repetition
          : repetition // ignore: cast_nullable_to_non_nullable
              as int,
      nextReviewAt: freezed == nextReviewAt
          ? _value.nextReviewAt
          : nextReviewAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastReviewedAt: freezed == lastReviewedAt
          ? _value.lastReviewedAt
          : lastReviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      masteryScore: null == masteryScore
          ? _value.masteryScore
          : masteryScore // ignore: cast_nullable_to_non_nullable
              as double,
      isMastered: null == isMastered
          ? _value.isMastered
          : isMastered // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      syncedAt: freezed == syncedAt
          ? _value.syncedAt
          : syncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LearningRecordImplCopyWith<$Res>
    implements $LearningRecordCopyWith<$Res> {
  factory _$$LearningRecordImplCopyWith(_$LearningRecordImpl value,
          $Res Function(_$LearningRecordImpl) then) =
      __$$LearningRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String videoId,
      int dwellTimeMs,
      int attempts,
      bool isCorrect,
      int correctCount,
      double easeFactor,
      int interval,
      int repetition,
      DateTime? nextReviewAt,
      DateTime? lastReviewedAt,
      double masteryScore,
      bool isMastered,
      DateTime createdAt,
      DateTime? updatedAt,
      DateTime? syncedAt});
}

/// @nodoc
class __$$LearningRecordImplCopyWithImpl<$Res>
    extends _$LearningRecordCopyWithImpl<$Res, _$LearningRecordImpl>
    implements _$$LearningRecordImplCopyWith<$Res> {
  __$$LearningRecordImplCopyWithImpl(
      _$LearningRecordImpl _value, $Res Function(_$LearningRecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? videoId = null,
    Object? dwellTimeMs = null,
    Object? attempts = null,
    Object? isCorrect = null,
    Object? correctCount = null,
    Object? easeFactor = null,
    Object? interval = null,
    Object? repetition = null,
    Object? nextReviewAt = freezed,
    Object? lastReviewedAt = freezed,
    Object? masteryScore = null,
    Object? isMastered = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? syncedAt = freezed,
  }) {
    return _then(_$LearningRecordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      dwellTimeMs: null == dwellTimeMs
          ? _value.dwellTimeMs
          : dwellTimeMs // ignore: cast_nullable_to_non_nullable
              as int,
      attempts: null == attempts
          ? _value.attempts
          : attempts // ignore: cast_nullable_to_non_nullable
              as int,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      correctCount: null == correctCount
          ? _value.correctCount
          : correctCount // ignore: cast_nullable_to_non_nullable
              as int,
      easeFactor: null == easeFactor
          ? _value.easeFactor
          : easeFactor // ignore: cast_nullable_to_non_nullable
              as double,
      interval: null == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as int,
      repetition: null == repetition
          ? _value.repetition
          : repetition // ignore: cast_nullable_to_non_nullable
              as int,
      nextReviewAt: freezed == nextReviewAt
          ? _value.nextReviewAt
          : nextReviewAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastReviewedAt: freezed == lastReviewedAt
          ? _value.lastReviewedAt
          : lastReviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      masteryScore: null == masteryScore
          ? _value.masteryScore
          : masteryScore // ignore: cast_nullable_to_non_nullable
              as double,
      isMastered: null == isMastered
          ? _value.isMastered
          : isMastered // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      syncedAt: freezed == syncedAt
          ? _value.syncedAt
          : syncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LearningRecordImpl extends _LearningRecord {
  const _$LearningRecordImpl(
      {required this.id,
      required this.userId,
      required this.videoId,
      this.dwellTimeMs = 0,
      this.attempts = 0,
      this.isCorrect = false,
      this.correctCount = 0,
      this.easeFactor = 2.5,
      this.interval = 0,
      this.repetition = 0,
      this.nextReviewAt,
      this.lastReviewedAt,
      this.masteryScore = 0.0,
      this.isMastered = false,
      required this.createdAt,
      this.updatedAt,
      this.syncedAt})
      : super._();

  factory _$LearningRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$LearningRecordImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String videoId;
// ── Interaction Metrics ──
  @override
  @JsonKey()
  final int dwellTimeMs;
// Total time spent on this video
  @override
  @JsonKey()
  final int attempts;
// Number of answer attempts
  @override
  @JsonKey()
  final bool isCorrect;
// Was the latest attempt correct?
  @override
  @JsonKey()
  final int correctCount;
// Total correct answers across reviews
// ── SM-2 Spaced Repetition Parameters ──
  @override
  @JsonKey()
  final double easeFactor;
// Ease factor (≥1.3, starts at 2.5)
  @override
  @JsonKey()
  final int interval;
// Current interval in days
  @override
  @JsonKey()
  final int repetition;
// Number of successful repetitions
  @override
  final DateTime? nextReviewAt;
// When to re-inject into feed
  @override
  final DateTime? lastReviewedAt;
// When the user last saw this
// ── Mastery Tracking ──
  @override
  @JsonKey()
  final double masteryScore;
// 0.0-1.0 composite mastery
  @override
  @JsonKey()
  final bool isMastered;
// True when masteryScore > 0.8
// ── Timestamps ──
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? syncedAt;

  @override
  String toString() {
    return 'LearningRecord(id: $id, userId: $userId, videoId: $videoId, dwellTimeMs: $dwellTimeMs, attempts: $attempts, isCorrect: $isCorrect, correctCount: $correctCount, easeFactor: $easeFactor, interval: $interval, repetition: $repetition, nextReviewAt: $nextReviewAt, lastReviewedAt: $lastReviewedAt, masteryScore: $masteryScore, isMastered: $isMastered, createdAt: $createdAt, updatedAt: $updatedAt, syncedAt: $syncedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LearningRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.videoId, videoId) || other.videoId == videoId) &&
            (identical(other.dwellTimeMs, dwellTimeMs) ||
                other.dwellTimeMs == dwellTimeMs) &&
            (identical(other.attempts, attempts) ||
                other.attempts == attempts) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.correctCount, correctCount) ||
                other.correctCount == correctCount) &&
            (identical(other.easeFactor, easeFactor) ||
                other.easeFactor == easeFactor) &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            (identical(other.repetition, repetition) ||
                other.repetition == repetition) &&
            (identical(other.nextReviewAt, nextReviewAt) ||
                other.nextReviewAt == nextReviewAt) &&
            (identical(other.lastReviewedAt, lastReviewedAt) ||
                other.lastReviewedAt == lastReviewedAt) &&
            (identical(other.masteryScore, masteryScore) ||
                other.masteryScore == masteryScore) &&
            (identical(other.isMastered, isMastered) ||
                other.isMastered == isMastered) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.syncedAt, syncedAt) ||
                other.syncedAt == syncedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      videoId,
      dwellTimeMs,
      attempts,
      isCorrect,
      correctCount,
      easeFactor,
      interval,
      repetition,
      nextReviewAt,
      lastReviewedAt,
      masteryScore,
      isMastered,
      createdAt,
      updatedAt,
      syncedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LearningRecordImplCopyWith<_$LearningRecordImpl> get copyWith =>
      __$$LearningRecordImplCopyWithImpl<_$LearningRecordImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LearningRecordImplToJson(
      this,
    );
  }
}

abstract class _LearningRecord extends LearningRecord {
  const factory _LearningRecord(
      {required final String id,
      required final String userId,
      required final String videoId,
      final int dwellTimeMs,
      final int attempts,
      final bool isCorrect,
      final int correctCount,
      final double easeFactor,
      final int interval,
      final int repetition,
      final DateTime? nextReviewAt,
      final DateTime? lastReviewedAt,
      final double masteryScore,
      final bool isMastered,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final DateTime? syncedAt}) = _$LearningRecordImpl;
  const _LearningRecord._() : super._();

  factory _LearningRecord.fromJson(Map<String, dynamic> json) =
      _$LearningRecordImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get videoId;
  @override // ── Interaction Metrics ──
  int get dwellTimeMs;
  @override // Total time spent on this video
  int get attempts;
  @override // Number of answer attempts
  bool get isCorrect;
  @override // Was the latest attempt correct?
  int get correctCount;
  @override // Total correct answers across reviews
// ── SM-2 Spaced Repetition Parameters ──
  double get easeFactor;
  @override // Ease factor (≥1.3, starts at 2.5)
  int get interval;
  @override // Current interval in days
  int get repetition;
  @override // Number of successful repetitions
  DateTime? get nextReviewAt;
  @override // When to re-inject into feed
  DateTime? get lastReviewedAt;
  @override // When the user last saw this
// ── Mastery Tracking ──
  double get masteryScore;
  @override // 0.0-1.0 composite mastery
  bool get isMastered;
  @override // True when masteryScore > 0.8
// ── Timestamps ──
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get syncedAt;
  @override
  @JsonKey(ignore: true)
  _$$LearningRecordImplCopyWith<_$LearningRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
