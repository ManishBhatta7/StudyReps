// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StreakModelImpl _$$StreakModelImplFromJson(Map<String, dynamic> json) =>
    _$StreakModelImpl(
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      maxStreak: (json['maxStreak'] as num?)?.toInt() ?? 0,
      todayReps: (json['todayReps'] as num?)?.toInt() ?? 0,
      lastRepDate: json['lastRepDate'] == null
          ? null
          : DateTime.parse(json['lastRepDate'] as String),
      completedDays: (json['completedDays'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$StreakModelImplToJson(_$StreakModelImpl instance) =>
    <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'maxStreak': instance.maxStreak,
      'todayReps': instance.todayReps,
      'lastRepDate': instance.lastRepDate?.toIso8601String(),
      'completedDays':
          instance.completedDays.map((e) => e.toIso8601String()).toList(),
    };
