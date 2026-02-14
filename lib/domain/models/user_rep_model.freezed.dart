// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_rep_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserRepModel _$UserRepModelFromJson(Map<String, dynamic> json) {
  return _UserRepModel.fromJson(json);
}

/// @nodoc
mixin _$UserRepModel {
  String get id => throw _privateConstructorUsedError;
  String get oderId => throw _privateConstructorUsedError;
  String get videoId => throw _privateConstructorUsedError;
  bool get isCorrect => throw _privateConstructorUsedError;
  String get userAnswer => throw _privateConstructorUsedError;
  DateTime get attemptDate => throw _privateConstructorUsedError;
  int get attemptCount => throw _privateConstructorUsedError;
  String? get aiFeedback => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserRepModelCopyWith<UserRepModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserRepModelCopyWith<$Res> {
  factory $UserRepModelCopyWith(
          UserRepModel value, $Res Function(UserRepModel) then) =
      _$UserRepModelCopyWithImpl<$Res, UserRepModel>;
  @useResult
  $Res call(
      {String id,
      String oderId,
      String videoId,
      bool isCorrect,
      String userAnswer,
      DateTime attemptDate,
      int attemptCount,
      String? aiFeedback});
}

/// @nodoc
class _$UserRepModelCopyWithImpl<$Res, $Val extends UserRepModel>
    implements $UserRepModelCopyWith<$Res> {
  _$UserRepModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? oderId = null,
    Object? videoId = null,
    Object? isCorrect = null,
    Object? userAnswer = null,
    Object? attemptDate = null,
    Object? attemptCount = null,
    Object? aiFeedback = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      oderId: null == oderId
          ? _value.oderId
          : oderId // ignore: cast_nullable_to_non_nullable
              as String,
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      userAnswer: null == userAnswer
          ? _value.userAnswer
          : userAnswer // ignore: cast_nullable_to_non_nullable
              as String,
      attemptDate: null == attemptDate
          ? _value.attemptDate
          : attemptDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      attemptCount: null == attemptCount
          ? _value.attemptCount
          : attemptCount // ignore: cast_nullable_to_non_nullable
              as int,
      aiFeedback: freezed == aiFeedback
          ? _value.aiFeedback
          : aiFeedback // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserRepModelImplCopyWith<$Res>
    implements $UserRepModelCopyWith<$Res> {
  factory _$$UserRepModelImplCopyWith(
          _$UserRepModelImpl value, $Res Function(_$UserRepModelImpl) then) =
      __$$UserRepModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String oderId,
      String videoId,
      bool isCorrect,
      String userAnswer,
      DateTime attemptDate,
      int attemptCount,
      String? aiFeedback});
}

/// @nodoc
class __$$UserRepModelImplCopyWithImpl<$Res>
    extends _$UserRepModelCopyWithImpl<$Res, _$UserRepModelImpl>
    implements _$$UserRepModelImplCopyWith<$Res> {
  __$$UserRepModelImplCopyWithImpl(
      _$UserRepModelImpl _value, $Res Function(_$UserRepModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? oderId = null,
    Object? videoId = null,
    Object? isCorrect = null,
    Object? userAnswer = null,
    Object? attemptDate = null,
    Object? attemptCount = null,
    Object? aiFeedback = freezed,
  }) {
    return _then(_$UserRepModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      oderId: null == oderId
          ? _value.oderId
          : oderId // ignore: cast_nullable_to_non_nullable
              as String,
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      userAnswer: null == userAnswer
          ? _value.userAnswer
          : userAnswer // ignore: cast_nullable_to_non_nullable
              as String,
      attemptDate: null == attemptDate
          ? _value.attemptDate
          : attemptDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      attemptCount: null == attemptCount
          ? _value.attemptCount
          : attemptCount // ignore: cast_nullable_to_non_nullable
              as int,
      aiFeedback: freezed == aiFeedback
          ? _value.aiFeedback
          : aiFeedback // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserRepModelImpl implements _UserRepModel {
  const _$UserRepModelImpl(
      {required this.id,
      required this.oderId,
      required this.videoId,
      required this.isCorrect,
      required this.userAnswer,
      required this.attemptDate,
      this.attemptCount = 1,
      this.aiFeedback});

  factory _$UserRepModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserRepModelImplFromJson(json);

  @override
  final String id;
  @override
  final String oderId;
  @override
  final String videoId;
  @override
  final bool isCorrect;
  @override
  final String userAnswer;
  @override
  final DateTime attemptDate;
  @override
  @JsonKey()
  final int attemptCount;
  @override
  final String? aiFeedback;

  @override
  String toString() {
    return 'UserRepModel(id: $id, oderId: $oderId, videoId: $videoId, isCorrect: $isCorrect, userAnswer: $userAnswer, attemptDate: $attemptDate, attemptCount: $attemptCount, aiFeedback: $aiFeedback)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserRepModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.oderId, oderId) || other.oderId == oderId) &&
            (identical(other.videoId, videoId) || other.videoId == videoId) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.userAnswer, userAnswer) ||
                other.userAnswer == userAnswer) &&
            (identical(other.attemptDate, attemptDate) ||
                other.attemptDate == attemptDate) &&
            (identical(other.attemptCount, attemptCount) ||
                other.attemptCount == attemptCount) &&
            (identical(other.aiFeedback, aiFeedback) ||
                other.aiFeedback == aiFeedback));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, oderId, videoId, isCorrect,
      userAnswer, attemptDate, attemptCount, aiFeedback);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserRepModelImplCopyWith<_$UserRepModelImpl> get copyWith =>
      __$$UserRepModelImplCopyWithImpl<_$UserRepModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserRepModelImplToJson(
      this,
    );
  }
}

abstract class _UserRepModel implements UserRepModel {
  const factory _UserRepModel(
      {required final String id,
      required final String oderId,
      required final String videoId,
      required final bool isCorrect,
      required final String userAnswer,
      required final DateTime attemptDate,
      final int attemptCount,
      final String? aiFeedback}) = _$UserRepModelImpl;

  factory _UserRepModel.fromJson(Map<String, dynamic> json) =
      _$UserRepModelImpl.fromJson;

  @override
  String get id;
  @override
  String get oderId;
  @override
  String get videoId;
  @override
  bool get isCorrect;
  @override
  String get userAnswer;
  @override
  DateTime get attemptDate;
  @override
  int get attemptCount;
  @override
  String? get aiFeedback;
  @override
  @JsonKey(ignore: true)
  _$$UserRepModelImplCopyWith<_$UserRepModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserStatsModel _$UserStatsModelFromJson(Map<String, dynamic> json) {
  return _UserStatsModel.fromJson(json);
}

/// @nodoc
mixin _$UserStatsModel {
  String get userId => throw _privateConstructorUsedError;
  int get totalReps => throw _privateConstructorUsedError;
  int get correctReps => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  int get totalXp => throw _privateConstructorUsedError;
  DateTime? get lastRepDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserStatsModelCopyWith<UserStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStatsModelCopyWith<$Res> {
  factory $UserStatsModelCopyWith(
          UserStatsModel value, $Res Function(UserStatsModel) then) =
      _$UserStatsModelCopyWithImpl<$Res, UserStatsModel>;
  @useResult
  $Res call(
      {String userId,
      int totalReps,
      int correctReps,
      int currentStreak,
      int longestStreak,
      int totalXp,
      DateTime? lastRepDate});
}

/// @nodoc
class _$UserStatsModelCopyWithImpl<$Res, $Val extends UserStatsModel>
    implements $UserStatsModelCopyWith<$Res> {
  _$UserStatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? totalReps = null,
    Object? correctReps = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? totalXp = null,
    Object? lastRepDate = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      totalReps: null == totalReps
          ? _value.totalReps
          : totalReps // ignore: cast_nullable_to_non_nullable
              as int,
      correctReps: null == correctReps
          ? _value.correctReps
          : correctReps // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalXp: null == totalXp
          ? _value.totalXp
          : totalXp // ignore: cast_nullable_to_non_nullable
              as int,
      lastRepDate: freezed == lastRepDate
          ? _value.lastRepDate
          : lastRepDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserStatsModelImplCopyWith<$Res>
    implements $UserStatsModelCopyWith<$Res> {
  factory _$$UserStatsModelImplCopyWith(_$UserStatsModelImpl value,
          $Res Function(_$UserStatsModelImpl) then) =
      __$$UserStatsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      int totalReps,
      int correctReps,
      int currentStreak,
      int longestStreak,
      int totalXp,
      DateTime? lastRepDate});
}

/// @nodoc
class __$$UserStatsModelImplCopyWithImpl<$Res>
    extends _$UserStatsModelCopyWithImpl<$Res, _$UserStatsModelImpl>
    implements _$$UserStatsModelImplCopyWith<$Res> {
  __$$UserStatsModelImplCopyWithImpl(
      _$UserStatsModelImpl _value, $Res Function(_$UserStatsModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? totalReps = null,
    Object? correctReps = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? totalXp = null,
    Object? lastRepDate = freezed,
  }) {
    return _then(_$UserStatsModelImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      totalReps: null == totalReps
          ? _value.totalReps
          : totalReps // ignore: cast_nullable_to_non_nullable
              as int,
      correctReps: null == correctReps
          ? _value.correctReps
          : correctReps // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalXp: null == totalXp
          ? _value.totalXp
          : totalXp // ignore: cast_nullable_to_non_nullable
              as int,
      lastRepDate: freezed == lastRepDate
          ? _value.lastRepDate
          : lastRepDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserStatsModelImpl implements _UserStatsModel {
  const _$UserStatsModelImpl(
      {required this.userId,
      this.totalReps = 0,
      this.correctReps = 0,
      this.currentStreak = 0,
      this.longestStreak = 0,
      this.totalXp = 0,
      this.lastRepDate});

  factory _$UserStatsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserStatsModelImplFromJson(json);

  @override
  final String userId;
  @override
  @JsonKey()
  final int totalReps;
  @override
  @JsonKey()
  final int correctReps;
  @override
  @JsonKey()
  final int currentStreak;
  @override
  @JsonKey()
  final int longestStreak;
  @override
  @JsonKey()
  final int totalXp;
  @override
  final DateTime? lastRepDate;

  @override
  String toString() {
    return 'UserStatsModel(userId: $userId, totalReps: $totalReps, correctReps: $correctReps, currentStreak: $currentStreak, longestStreak: $longestStreak, totalXp: $totalXp, lastRepDate: $lastRepDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserStatsModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.totalReps, totalReps) ||
                other.totalReps == totalReps) &&
            (identical(other.correctReps, correctReps) ||
                other.correctReps == correctReps) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.totalXp, totalXp) || other.totalXp == totalXp) &&
            (identical(other.lastRepDate, lastRepDate) ||
                other.lastRepDate == lastRepDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, userId, totalReps, correctReps,
      currentStreak, longestStreak, totalXp, lastRepDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserStatsModelImplCopyWith<_$UserStatsModelImpl> get copyWith =>
      __$$UserStatsModelImplCopyWithImpl<_$UserStatsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserStatsModelImplToJson(
      this,
    );
  }
}

abstract class _UserStatsModel implements UserStatsModel {
  const factory _UserStatsModel(
      {required final String userId,
      final int totalReps,
      final int correctReps,
      final int currentStreak,
      final int longestStreak,
      final int totalXp,
      final DateTime? lastRepDate}) = _$UserStatsModelImpl;

  factory _UserStatsModel.fromJson(Map<String, dynamic> json) =
      _$UserStatsModelImpl.fromJson;

  @override
  String get userId;
  @override
  int get totalReps;
  @override
  int get correctReps;
  @override
  int get currentStreak;
  @override
  int get longestStreak;
  @override
  int get totalXp;
  @override
  DateTime? get lastRepDate;
  @override
  @JsonKey(ignore: true)
  _$$UserStatsModelImplCopyWith<_$UserStatsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
