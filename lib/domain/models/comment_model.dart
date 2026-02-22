import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

@freezed
class CommentModel with _$CommentModel {
  const factory CommentModel({
    required int id,
    required String videoId,
    required String userId,
    required String body,
    @Default(0) int likesCount,
    DateTime? createdAt,
    // Transient fields joined from other tables
    String? username,
    String? avatarUrl,
    @Default(false) bool isAI,
  }) = _CommentModel;

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);
}
