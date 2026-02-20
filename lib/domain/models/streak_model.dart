import 'package:freezed_annotation/freezed_annotation.dart';

part 'streak_model.freezed.dart';
part 'streak_model.g.dart';

@freezed
class StreakModel with _$StreakModel {
  const factory StreakModel({
    @Default(0) int currentStreak,
    @Default(0) int maxStreak,
    @Default(0) int todayReps,
    DateTime? lastRepDate,
    @Default([]) List<DateTime> completedDays,
  }) = _StreakModel;

  factory StreakModel.fromJson(Map<String, dynamic> json) =>
      _$StreakModelFromJson(json);
}
