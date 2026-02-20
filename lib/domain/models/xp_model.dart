import 'package:freezed_annotation/freezed_annotation.dart';

part 'xp_model.freezed.dart';
part 'xp_model.g.dart';

@freezed
class XpModel with _$XpModel {
  const factory XpModel({
    @Default(0) int totalXp,
    @Default(1) int currentLevel,
    @Default(0) int xpForNextLevel,
    @Default(0) int recentXpGain, // For UI animations when XP is gained
  }) = _XpModel;

  factory XpModel.fromJson(Map<String, dynamic> json) => _$XpModelFromJson(json);
}
