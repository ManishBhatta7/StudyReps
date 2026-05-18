// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'squad_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StudySquad _$StudySquadFromJson(Map<String, dynamic> json) {
  return _StudySquad.fromJson(json);
}

/// @nodoc
mixin _$StudySquad {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'weekly_goal')
  int get weeklyGoal => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String get createdBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StudySquadCopyWith<StudySquad> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudySquadCopyWith<$Res> {
  factory $StudySquadCopyWith(
          StudySquad value, $Res Function(StudySquad) then) =
      _$StudySquadCopyWithImpl<$Res, StudySquad>;
  @useResult
  $Res call(
      {int id,
      String name,
      String? description,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      @JsonKey(name: 'weekly_goal') int weeklyGoal,
      @JsonKey(name: 'created_by') String createdBy,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class _$StudySquadCopyWithImpl<$Res, $Val extends StudySquad>
    implements $StudySquadCopyWith<$Res> {
  _$StudySquadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? avatarUrl = freezed,
    Object? weeklyGoal = null,
    Object? createdBy = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      weeklyGoal: null == weeklyGoal
          ? _value.weeklyGoal
          : weeklyGoal // ignore: cast_nullable_to_non_nullable
              as int,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StudySquadImplCopyWith<$Res>
    implements $StudySquadCopyWith<$Res> {
  factory _$$StudySquadImplCopyWith(
          _$StudySquadImpl value, $Res Function(_$StudySquadImpl) then) =
      __$$StudySquadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String? description,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      @JsonKey(name: 'weekly_goal') int weeklyGoal,
      @JsonKey(name: 'created_by') String createdBy,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class __$$StudySquadImplCopyWithImpl<$Res>
    extends _$StudySquadCopyWithImpl<$Res, _$StudySquadImpl>
    implements _$$StudySquadImplCopyWith<$Res> {
  __$$StudySquadImplCopyWithImpl(
      _$StudySquadImpl _value, $Res Function(_$StudySquadImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? avatarUrl = freezed,
    Object? weeklyGoal = null,
    Object? createdBy = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$StudySquadImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      weeklyGoal: null == weeklyGoal
          ? _value.weeklyGoal
          : weeklyGoal // ignore: cast_nullable_to_non_nullable
              as int,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudySquadImpl implements _StudySquad {
  const _$StudySquadImpl(
      {required this.id,
      required this.name,
      this.description,
      @JsonKey(name: 'avatar_url') this.avatarUrl,
      @JsonKey(name: 'weekly_goal') this.weeklyGoal = 500,
      @JsonKey(name: 'created_by') required this.createdBy,
      @JsonKey(name: 'created_at') this.createdAt});

  factory _$StudySquadImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudySquadImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @override
  @JsonKey(name: 'weekly_goal')
  final int weeklyGoal;
  @override
  @JsonKey(name: 'created_by')
  final String createdBy;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'StudySquad(id: $id, name: $name, description: $description, avatarUrl: $avatarUrl, weeklyGoal: $weeklyGoal, createdBy: $createdBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudySquadImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.weeklyGoal, weeklyGoal) ||
                other.weeklyGoal == weeklyGoal) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description, avatarUrl,
      weeklyGoal, createdBy, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StudySquadImplCopyWith<_$StudySquadImpl> get copyWith =>
      __$$StudySquadImplCopyWithImpl<_$StudySquadImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudySquadImplToJson(
      this,
    );
  }
}

abstract class _StudySquad implements StudySquad {
  const factory _StudySquad(
          {required final int id,
          required final String name,
          final String? description,
          @JsonKey(name: 'avatar_url') final String? avatarUrl,
          @JsonKey(name: 'weekly_goal') final int weeklyGoal,
          @JsonKey(name: 'created_by') required final String createdBy,
          @JsonKey(name: 'created_at') final DateTime? createdAt}) =
      _$StudySquadImpl;

  factory _StudySquad.fromJson(Map<String, dynamic> json) =
      _$StudySquadImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;
  @override
  @JsonKey(name: 'weekly_goal')
  int get weeklyGoal;
  @override
  @JsonKey(name: 'created_by')
  String get createdBy;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$StudySquadImplCopyWith<_$StudySquadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SquadMember _$SquadMemberFromJson(Map<String, dynamic> json) {
  return _SquadMember.fromJson(json);
}

/// @nodoc
mixin _$SquadMember {
  @JsonKey(name: 'squad_id')
  int get squadId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'joined_at')
  DateTime? get joinedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SquadMemberCopyWith<SquadMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SquadMemberCopyWith<$Res> {
  factory $SquadMemberCopyWith(
          SquadMember value, $Res Function(SquadMember) then) =
      _$SquadMemberCopyWithImpl<$Res, SquadMember>;
  @useResult
  $Res call(
      {@JsonKey(name: 'squad_id') int squadId,
      @JsonKey(name: 'user_id') String userId,
      String role,
      @JsonKey(name: 'joined_at') DateTime? joinedAt});
}

/// @nodoc
class _$SquadMemberCopyWithImpl<$Res, $Val extends SquadMember>
    implements $SquadMemberCopyWith<$Res> {
  _$SquadMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? squadId = null,
    Object? userId = null,
    Object? role = null,
    Object? joinedAt = freezed,
  }) {
    return _then(_value.copyWith(
      squadId: null == squadId
          ? _value.squadId
          : squadId // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: freezed == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SquadMemberImplCopyWith<$Res>
    implements $SquadMemberCopyWith<$Res> {
  factory _$$SquadMemberImplCopyWith(
          _$SquadMemberImpl value, $Res Function(_$SquadMemberImpl) then) =
      __$$SquadMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'squad_id') int squadId,
      @JsonKey(name: 'user_id') String userId,
      String role,
      @JsonKey(name: 'joined_at') DateTime? joinedAt});
}

/// @nodoc
class __$$SquadMemberImplCopyWithImpl<$Res>
    extends _$SquadMemberCopyWithImpl<$Res, _$SquadMemberImpl>
    implements _$$SquadMemberImplCopyWith<$Res> {
  __$$SquadMemberImplCopyWithImpl(
      _$SquadMemberImpl _value, $Res Function(_$SquadMemberImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? squadId = null,
    Object? userId = null,
    Object? role = null,
    Object? joinedAt = freezed,
  }) {
    return _then(_$SquadMemberImpl(
      squadId: null == squadId
          ? _value.squadId
          : squadId // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: freezed == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SquadMemberImpl implements _SquadMember {
  const _$SquadMemberImpl(
      {@JsonKey(name: 'squad_id') required this.squadId,
      @JsonKey(name: 'user_id') required this.userId,
      this.role = 'member',
      @JsonKey(name: 'joined_at') this.joinedAt});

  factory _$SquadMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$SquadMemberImplFromJson(json);

  @override
  @JsonKey(name: 'squad_id')
  final int squadId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey()
  final String role;
  @override
  @JsonKey(name: 'joined_at')
  final DateTime? joinedAt;

  @override
  String toString() {
    return 'SquadMember(squadId: $squadId, userId: $userId, role: $role, joinedAt: $joinedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SquadMemberImpl &&
            (identical(other.squadId, squadId) || other.squadId == squadId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, squadId, userId, role, joinedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SquadMemberImplCopyWith<_$SquadMemberImpl> get copyWith =>
      __$$SquadMemberImplCopyWithImpl<_$SquadMemberImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SquadMemberImplToJson(
      this,
    );
  }
}

abstract class _SquadMember implements SquadMember {
  const factory _SquadMember(
          {@JsonKey(name: 'squad_id') required final int squadId,
          @JsonKey(name: 'user_id') required final String userId,
          final String role,
          @JsonKey(name: 'joined_at') final DateTime? joinedAt}) =
      _$SquadMemberImpl;

  factory _SquadMember.fromJson(Map<String, dynamic> json) =
      _$SquadMemberImpl.fromJson;

  @override
  @JsonKey(name: 'squad_id')
  int get squadId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get role;
  @override
  @JsonKey(name: 'joined_at')
  DateTime? get joinedAt;
  @override
  @JsonKey(ignore: true)
  _$$SquadMemberImplCopyWith<_$SquadMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
