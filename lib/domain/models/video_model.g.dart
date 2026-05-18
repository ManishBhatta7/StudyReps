// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoModelImpl _$$VideoModelImplFromJson(Map<String, dynamic> json) =>
    _$VideoModelImpl(
      id: json['id'] as String,
      videoUrl: json['videoUrl'] as String? ?? '',
      lockTimestamp: (json['lockTimestamp'] as num?)?.toInt() ?? 0,
      question:
          QuestionModel.fromJson(json['question'] as Map<String, dynamic>),
      creatorName: json['creatorName'] as String? ?? 'StudyReps',
      creatorAvatar: json['creatorAvatar'] as String? ??
          'https://api.dicebear.com/7.x/avataaars/svg?seed=StudyReps',
      title: json['title'] as String,
      subject: json['subject'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      repsCompleted: (json['repsCompleted'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
      duration: json['duration'] == null
          ? Duration.zero
          : Duration(microseconds: (json['duration'] as num).toInt()),
      startSeconds: (json['startSeconds'] as num?)?.toInt() ?? 0,
      endSeconds: (json['endSeconds'] as num?)?.toInt(),
      contentType:
          $enumDecodeNullable(_$ContentTypeEnumMap, json['contentType']) ??
              ContentType.video,
      flashcardFrontText: json['flashcardFrontText'] as String? ?? '',
      flashcardBackText: json['flashcardBackText'] as String? ?? '',
      flashcardImageUrl: json['flashcardImageUrl'] as String? ?? '',
      flashcardEmoji: json['flashcardEmoji'] as String? ?? '',
      transcript: json['transcript'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      prerequisiteIds: (json['prerequisiteIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      difficultyLevel: (json['difficultyLevel'] as num?)?.toInt() ?? 1,
      topicId: json['topicId'] as String? ?? '',
      conceptCluster: json['conceptCluster'] as String? ?? '',
      language: json['language'] as String? ?? 'en',
      boards: (json['boards'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      grades: (json['grades'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$VideoModelImplToJson(_$VideoModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'videoUrl': instance.videoUrl,
      'lockTimestamp': instance.lockTimestamp,
      'question': instance.question,
      'creatorName': instance.creatorName,
      'creatorAvatar': instance.creatorAvatar,
      'title': instance.title,
      'subject': instance.subject,
      'thumbnailUrl': instance.thumbnailUrl,
      'likesCount': instance.likesCount,
      'repsCompleted': instance.repsCompleted,
      'isLiked': instance.isLiked,
      'isSaved': instance.isSaved,
      'duration': instance.duration.inMicroseconds,
      'startSeconds': instance.startSeconds,
      'endSeconds': instance.endSeconds,
      'contentType': _$ContentTypeEnumMap[instance.contentType]!,
      'flashcardFrontText': instance.flashcardFrontText,
      'flashcardBackText': instance.flashcardBackText,
      'flashcardImageUrl': instance.flashcardImageUrl,
      'flashcardEmoji': instance.flashcardEmoji,
      'transcript': instance.transcript,
      'tags': instance.tags,
      'prerequisiteIds': instance.prerequisiteIds,
      'difficultyLevel': instance.difficultyLevel,
      'topicId': instance.topicId,
      'conceptCluster': instance.conceptCluster,
      'language': instance.language,
      'boards': instance.boards,
      'grades': instance.grades,
    };

const _$ContentTypeEnumMap = {
  ContentType.video: 'video',
  ContentType.flashcard: 'flashcard',
};

_$QuestionModelImpl _$$QuestionModelImplFromJson(Map<String, dynamic> json) =>
    _$QuestionModelImpl(
      id: json['id'] as String? ?? '',
      prompt: json['prompt'] as String,
      correctAnswer: json['correctAnswer'] as String,
      type: $enumDecode(_$QuestionTypeEnumMap, json['type']),
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      hint: json['hint'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
    );

Map<String, dynamic> _$$QuestionModelImplToJson(_$QuestionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'prompt': instance.prompt,
      'correctAnswer': instance.correctAnswer,
      'type': _$QuestionTypeEnumMap[instance.type]!,
      'options': instance.options,
      'hint': instance.hint,
      'explanation': instance.explanation,
    };

const _$QuestionTypeEnumMap = {
  QuestionType.text: 'text',
  QuestionType.multipleChoice: 'multiple_choice',
  QuestionType.dragDrop: 'drag_drop',
  QuestionType.equation: 'equation',
  QuestionType.shortAnswer: 'short_answer',
  QuestionType.trueFalse: 'true_false',
  QuestionType.numerical: 'numerical',
  QuestionType.fillBlank: 'fill_blank',
  QuestionType.openInput: 'open_input',
};
