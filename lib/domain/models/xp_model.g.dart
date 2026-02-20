// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$XpModelImpl _$$XpModelImplFromJson(Map<String, dynamic> json) =>
    _$XpModelImpl(
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      currentLevel: (json['currentLevel'] as num?)?.toInt() ?? 1,
      xpForNextLevel: (json['xpForNextLevel'] as num?)?.toInt() ?? 0,
      recentXpGain: (json['recentXpGain'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$XpModelImplToJson(_$XpModelImpl instance) =>
    <String, dynamic>{
      'totalXp': instance.totalXp,
      'currentLevel': instance.currentLevel,
      'xpForNextLevel': instance.xpForNextLevel,
      'recentXpGain': instance.recentXpGain,
    };
