// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_rep_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserRepModelImpl _$$UserRepModelImplFromJson(Map<String, dynamic> json) =>
    _$UserRepModelImpl(
      id: json['id'] as String,
      oderId: json['oderId'] as String,
      videoId: json['videoId'] as String,
      isCorrect: json['isCorrect'] as bool,
      userAnswer: json['userAnswer'] as String,
      attemptDate: DateTime.parse(json['attemptDate'] as String),
      attemptCount: (json['attemptCount'] as num?)?.toInt() ?? 1,
      aiFeedback: json['aiFeedback'] as String?,
    );

Map<String, dynamic> _$$UserRepModelImplToJson(_$UserRepModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'oderId': instance.oderId,
      'videoId': instance.videoId,
      'isCorrect': instance.isCorrect,
      'userAnswer': instance.userAnswer,
      'attemptDate': instance.attemptDate.toIso8601String(),
      'attemptCount': instance.attemptCount,
      'aiFeedback': instance.aiFeedback,
    };

_$UserStatsModelImpl _$$UserStatsModelImplFromJson(Map<String, dynamic> json) =>
    _$UserStatsModelImpl(
      userId: json['userId'] as String,
      totalReps: (json['totalReps'] as num?)?.toInt() ?? 0,
      correctReps: (json['correctReps'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      lastRepDate: json['lastRepDate'] == null
          ? null
          : DateTime.parse(json['lastRepDate'] as String),
    );

Map<String, dynamic> _$$UserStatsModelImplToJson(
        _$UserStatsModelImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'totalReps': instance.totalReps,
      'correctReps': instance.correctReps,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'totalXp': instance.totalXp,
      'lastRepDate': instance.lastRepDate?.toIso8601String(),
    };
