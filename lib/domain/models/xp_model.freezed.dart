// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'xp_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

XpModel _$XpModelFromJson(Map<String, dynamic> json) {
  return _XpModel.fromJson(json);
}

/// @nodoc
mixin _$XpModel {
  int get totalXp => throw _privateConstructorUsedError;
  int get currentLevel => throw _privateConstructorUsedError;
  int get xpForNextLevel => throw _privateConstructorUsedError;
  int get recentXpGain => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $XpModelCopyWith<XpModel> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $XpModelCopyWith<$Res> {
  factory $XpModelCopyWith(XpModel value, $Res Function(XpModel) then) =
      _$XpModelCopyWithImpl<$Res, XpModel>;
  @useResult
  $Res call(
      {int totalXp, int currentLevel, int xpForNextLevel, int recentXpGain});
}

/// @nodoc
class _$XpModelCopyWithImpl<$Res, $Val extends XpModel>
    implements $XpModelCopyWith<$Res> {
  _$XpModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalXp = null,
    Object? currentLevel = null,
    Object? xpForNextLevel = null,
    Object? recentXpGain = null,
  }) {
    return _then(_value.copyWith(
      totalXp: null == totalXp
          ? _value.totalXp
          : totalXp // ignore: cast_nullable_to_non_nullable
              as int,
      currentLevel: null == currentLevel
          ? _value.currentLevel
          : currentLevel // ignore: cast_nullable_to_non_nullable
              as int,
      xpForNextLevel: null == xpForNextLevel
          ? _value.xpForNextLevel
          : xpForNextLevel // ignore: cast_nullable_to_non_nullable
              as int,
      recentXpGain: null == recentXpGain
          ? _value.recentXpGain
          : recentXpGain // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$XpModelImplCopyWith<$Res> implements $XpModelCopyWith<$Res> {
  factory _$$XpModelImplCopyWith(
          _$XpModelImpl value, $Res Function(_$XpModelImpl) then) =
      __$$XpModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalXp, int currentLevel, int xpForNextLevel, int recentXpGain});
}

/// @nodoc
class __$$XpModelImplCopyWithImpl<$Res>
    extends _$XpModelCopyWithImpl<$Res, _$XpModelImpl>
    implements _$$XpModelImplCopyWith<$Res> {
  __$$XpModelImplCopyWithImpl(
      _$XpModelImpl _value, $Res Function(_$XpModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalXp = null,
    Object? currentLevel = null,
    Object? xpForNextLevel = null,
    Object? recentXpGain = null,
  }) {
    return _then(_$XpModelImpl(
      totalXp: null == totalXp
          ? _value.totalXp
          : totalXp // ignore: cast_nullable_to_non_nullable
              as int,
      currentLevel: null == currentLevel
          ? _value.currentLevel
          : currentLevel // ignore: cast_nullable_to_non_nullable
              as int,
      xpForNextLevel: null == xpForNextLevel
          ? _value.xpForNextLevel
          : xpForNextLevel // ignore: cast_nullable_to_non_nullable
              as int,
      recentXpGain: null == recentXpGain
          ? _value.recentXpGain
          : recentXpGain // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$XpModelImpl implements _XpModel {
  const _$XpModelImpl(
      {this.totalXp = 0,
      this.currentLevel = 1,
      this.xpForNextLevel = 0,
      this.recentXpGain = 0});

  factory _$XpModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$XpModelImplFromJson(json);

  @override
  @JsonKey()
  final int totalXp;
  @override
  @JsonKey()
  final int currentLevel;
  @override
  @JsonKey()
  final int xpForNextLevel;
  @override
  @JsonKey()
  final int recentXpGain;

  @override
  String toString() {
    return 'XpModel(totalXp: $totalXp, currentLevel: $currentLevel, xpForNextLevel: $xpForNextLevel, recentXpGain: $recentXpGain)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$XpModelImpl &&
            (identical(other.totalXp, totalXp) || other.totalXp == totalXp) &&
            (identical(other.currentLevel, currentLevel) ||
                other.currentLevel == currentLevel) &&
            (identical(other.xpForNextLevel, xpForNextLevel) ||
                other.xpForNextLevel == xpForNextLevel) &&
            (identical(other.recentXpGain, recentXpGain) ||
                other.recentXpGain == recentXpGain));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, totalXp, currentLevel, xpForNextLevel, recentXpGain);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$XpModelImplCopyWith<_$XpModelImpl> get copyWith =>
      __$$XpModelImplCopyWithImpl<_$XpModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$XpModelImplToJson(
      this,
    );
  }
}

abstract class _XpModel implements XpModel {
  const factory _XpModel(
      {final int totalXp,
      final int currentLevel,
      final int xpForNextLevel,
      final int recentXpGain}) = _$XpModelImpl;

  factory _XpModel.fromJson(Map<String, dynamic> json) = _$XpModelImpl.fromJson;

  @override
  int get totalXp;
  @override
  int get currentLevel;
  @override
  int get xpForNextLevel;
  @override
  int get recentXpGain;
  @override
  @JsonKey(ignore: true)
  _$$XpModelImplCopyWith<_$XpModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
