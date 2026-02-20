// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeaderboardEntryImpl _$$LeaderboardEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$LeaderboardEntryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      xp: (json['xp'] as num).toInt(),
      rank: (json['rank'] as num).toInt(),
      trend: json['trend'] as String? ?? 'same',
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$$LeaderboardEntryImplToJson(
        _$LeaderboardEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'xp': instance.xp,
      'rank': instance.rank,
      'trend': instance.trend,
      'avatar': instance.avatar,
    };
