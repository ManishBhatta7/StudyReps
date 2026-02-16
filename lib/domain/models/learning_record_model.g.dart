// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LearningRecordImpl _$$LearningRecordImplFromJson(Map<String, dynamic> json) =>
    _$LearningRecordImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      videoId: json['videoId'] as String,
      dwellTimeMs: (json['dwellTimeMs'] as num?)?.toInt() ?? 0,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      isCorrect: json['isCorrect'] as bool? ?? false,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      interval: (json['interval'] as num?)?.toInt() ?? 0,
      repetition: (json['repetition'] as num?)?.toInt() ?? 0,
      nextReviewAt: json['nextReviewAt'] == null
          ? null
          : DateTime.parse(json['nextReviewAt'] as String),
      lastReviewedAt: json['lastReviewedAt'] == null
          ? null
          : DateTime.parse(json['lastReviewedAt'] as String),
      masteryScore: (json['masteryScore'] as num?)?.toDouble() ?? 0.0,
      isMastered: json['isMastered'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      syncedAt: json['syncedAt'] == null
          ? null
          : DateTime.parse(json['syncedAt'] as String),
    );

Map<String, dynamic> _$$LearningRecordImplToJson(
        _$LearningRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'videoId': instance.videoId,
      'dwellTimeMs': instance.dwellTimeMs,
      'attempts': instance.attempts,
      'isCorrect': instance.isCorrect,
      'correctCount': instance.correctCount,
      'easeFactor': instance.easeFactor,
      'interval': instance.interval,
      'repetition': instance.repetition,
      'nextReviewAt': instance.nextReviewAt?.toIso8601String(),
      'lastReviewedAt': instance.lastReviewedAt?.toIso8601String(),
      'masteryScore': instance.masteryScore,
      'isMastered': instance.isMastered,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'syncedAt': instance.syncedAt?.toIso8601String(),
    };
