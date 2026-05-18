// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'squad_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudySquadImpl _$$StudySquadImplFromJson(Map<String, dynamic> json) =>
    _$StudySquadImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      weeklyGoal: (json['weekly_goal'] as num?)?.toInt() ?? 500,
      createdBy: json['created_by'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$StudySquadImplToJson(_$StudySquadImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'avatar_url': instance.avatarUrl,
      'weekly_goal': instance.weeklyGoal,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt?.toIso8601String(),
    };

_$SquadMemberImpl _$$SquadMemberImplFromJson(Map<String, dynamic> json) =>
    _$SquadMemberImpl(
      squadId: (json['squad_id'] as num).toInt(),
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'member',
      joinedAt: json['joined_at'] == null
          ? null
          : DateTime.parse(json['joined_at'] as String),
    );

Map<String, dynamic> _$$SquadMemberImplToJson(_$SquadMemberImpl instance) =>
    <String, dynamic>{
      'squad_id': instance.squadId,
      'user_id': instance.userId,
      'role': instance.role,
      'joined_at': instance.joinedAt?.toIso8601String(),
    };
