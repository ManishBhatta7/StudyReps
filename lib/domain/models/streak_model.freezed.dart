// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StreakModel _$StreakModelFromJson(Map<String, dynamic> json) {
  return _StreakModel.fromJson(json);
}

/// @nodoc
mixin _$StreakModel {
  int get currentStreak => throw _privateConstructorUsedError;
  int get maxStreak => throw _privateConstructorUsedError;
  int get todayReps => throw _privateConstructorUsedError;
  DateTime? get lastRepDate => throw _privateConstructorUsedError;
  List<DateTime> get completedDays => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StreakModelCopyWith<StreakModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreakModelCopyWith<$Res> {
  factory $StreakModelCopyWith(
          StreakModel value, $Res Function(StreakModel) then) =
      _$StreakModelCopyWithImpl<$Res, StreakModel>;
  @useResult
  $Res call(
      {int currentStreak,
      int maxStreak,
      int todayReps,
      DateTime? lastRepDate,
      List<DateTime> completedDays});
}

/// @nodoc
class _$StreakModelCopyWithImpl<$Res, $Val extends StreakModel>
    implements $StreakModelCopyWith<$Res> {
  _$StreakModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? maxStreak = null,
    Object? todayReps = null,
    Object? lastRepDate = freezed,
    Object? completedDays = null,
  }) {
    return _then(_value.copyWith(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      maxStreak: null == maxStreak
          ? _value.maxStreak
          : maxStreak // ignore: cast_nullable_to_non_nullable
              as int,
      todayReps: null == todayReps
          ? _value.todayReps
          : todayReps // ignore: cast_nullable_to_non_nullable
              as int,
      lastRepDate: freezed == lastRepDate
          ? _value.lastRepDate
          : lastRepDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedDays: null == completedDays
          ? _value.completedDays
          : completedDays // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StreakModelImplCopyWith<$Res>
    implements $StreakModelCopyWith<$Res> {
  factory _$$StreakModelImplCopyWith(
          _$StreakModelImpl value, $Res Function(_$StreakModelImpl) then) =
      __$$StreakModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int currentStreak,
      int maxStreak,
      int todayReps,
      DateTime? lastRepDate,
      List<DateTime> completedDays});
}

/// @nodoc
class __$$StreakModelImplCopyWithImpl<$Res>
    extends _$StreakModelCopyWithImpl<$Res, _$StreakModelImpl>
    implements _$$StreakModelImplCopyWith<$Res> {
  __$$StreakModelImplCopyWithImpl(
      _$StreakModelImpl _value, $Res Function(_$StreakModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? maxStreak = null,
    Object? todayReps = null,
    Object? lastRepDate = freezed,
    Object? completedDays = null,
  }) {
    return _then(_$StreakModelImpl(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      maxStreak: null == maxStreak
          ? _value.maxStreak
          : maxStreak // ignore: cast_nullable_to_non_nullable
              as int,
      todayReps: null == todayReps
          ? _value.todayReps
          : todayReps // ignore: cast_nullable_to_non_nullable
              as int,
      lastRepDate: freezed == lastRepDate
          ? _value.lastRepDate
          : lastRepDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedDays: null == completedDays
          ? _value._completedDays
          : completedDays // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StreakModelImpl implements _StreakModel {
  const _$StreakModelImpl(
      {this.currentStreak = 0,
      this.maxStreak = 0,
      this.todayReps = 0,
      this.lastRepDate,
      final List<DateTime> completedDays = const []})
      : _completedDays = completedDays;

  factory _$StreakModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$StreakModelImplFromJson(json);

  @override
  @JsonKey()
  final int currentStreak;
  @override
  @JsonKey()
  final int maxStreak;
  @override
  @JsonKey()
  final int todayReps;
  @override
  final DateTime? lastRepDate;
  final List<DateTime> _completedDays;
  @override
  @JsonKey()
  List<DateTime> get completedDays {
    if (_completedDays is EqualUnmodifiableListView) return _completedDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedDays);
  }

  @override
  String toString() {
    return 'StreakModel(currentStreak: $currentStreak, maxStreak: $maxStreak, todayReps: $todayReps, lastRepDate: $lastRepDate, completedDays: $completedDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreakModelImpl &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.maxStreak, maxStreak) ||
                other.maxStreak == maxStreak) &&
            (identical(other.todayReps, todayReps) ||
                other.todayReps == todayReps) &&
            (identical(other.lastRepDate, lastRepDate) ||
                other.lastRepDate == lastRepDate) &&
            const DeepCollectionEquality()
                .equals(other._completedDays, _completedDays));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentStreak,
      maxStreak,
      todayReps,
      lastRepDate,
      const DeepCollectionEquality().hash(_completedDays));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StreakModelImplCopyWith<_$StreakModelImpl> get copyWith =>
      __$$StreakModelImplCopyWithImpl<_$StreakModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StreakModelImplToJson(
      this,
    );
  }
}

abstract class _StreakModel implements StreakModel {
  const factory _StreakModel(
      {final int currentStreak,
      final int maxStreak,
      final int todayReps,
      final DateTime? lastRepDate,
      final List<DateTime> completedDays}) = _$StreakModelImpl;

  factory _StreakModel.fromJson(Map<String, dynamic> json) =
      _$StreakModelImpl.fromJson;

  @override
  int get currentStreak;
  @override
  int get maxStreak;
  @override
  int get todayReps;
  @override
  DateTime? get lastRepDate;
  @override
  List<DateTime> get completedDays;
  @override
  @JsonKey(ignore: true)
  _$$StreakModelImplCopyWith<_$StreakModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
