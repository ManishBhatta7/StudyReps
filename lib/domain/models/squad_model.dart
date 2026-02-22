import 'package:freezed_annotation/freezed_annotation.dart';

part 'squad_model.freezed.dart';
part 'squad_model.g.dart';

@freezed
class StudySquad with _$StudySquad {
  const factory StudySquad({
    required int id,
    required String name,
    String? description,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @Default(500) @JsonKey(name: 'weekly_goal') int weeklyGoal,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _StudySquad;

  factory StudySquad.fromJson(Map<String, dynamic> json) =>
      _$StudySquadFromJson(json);
}

@freezed
class SquadMember with _$SquadMember {
  const factory SquadMember({
    @JsonKey(name: 'squad_id') required int squadId,
    @JsonKey(name: 'user_id') required String userId,
    @Default('member') String role,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
  }) = _SquadMember;

  factory SquadMember.fromJson(Map<String, dynamic> json) =>
      _$SquadMemberFromJson(json);
}
