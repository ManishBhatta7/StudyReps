import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement_model.freezed.dart';
part 'achievement_model.g.dart';

@freezed
class AchievementModel with _$AchievementModel {
  const factory AchievementModel({
    required String id,
    required String title,
    required String description,
    required String icon,
    @JsonKey(name: 'unlocked_at') DateTime? unlockedAt,
    @Default(false) bool isUnlocked,
    @Default(0.0) double progress, // 0.0 to 1.0
  }) = _AchievementModel;

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      _$AchievementModelFromJson(json);
}
