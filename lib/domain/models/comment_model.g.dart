// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentModelImpl _$$CommentModelImplFromJson(Map<String, dynamic> json) =>
    _$CommentModelImpl(
      id: (json['id'] as num).toInt(),
      videoId: json['videoId'] as String,
      userId: json['userId'] as String,
      body: json['body'] as String,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isAI: json['isAI'] as bool? ?? false,
    );

Map<String, dynamic> _$$CommentModelImplToJson(_$CommentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'videoId': instance.videoId,
      'userId': instance.userId,
      'body': instance.body,
      'likesCount': instance.likesCount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'isAI': instance.isAI,
    };
