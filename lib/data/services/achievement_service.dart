import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/achievement_model.dart';
import 'streak_service.dart';
import 'xp_service.dart';

class AchievementService {
  static const String boxName = 'achievements_box';

  static Future<List<AchievementModel>> getAchievements(String userId) async {
    final box = await Hive.openBox(boxName);
    final key = '${userId}_achievements';
    
    // Unlocked IDs
    final unlockedIds = List<String>.from(box.get(key) ?? []);

    // Get current progress
    final streakRecord = await StreakService.getStreakRecord(userId);
    final xpRecord = await XpService.getXpRecord(userId);

    // Approximate total reps via XP because StreakModel doesn't individually aggregate all-time reps
    final totalRepsEst = xpRecord.totalXp ~/ XpService.xpPerRep;
    final maxStreak = streakRecord.maxStreak;
    final level = xpRecord.currentLevel;

    // Define all achievements with their thresholds
    final List<AchievementModel> allAchievements = [
      _buildAchievement('first_rep', 'First Rep', 'Complete your first study rep.', '🎉', totalRepsEst, 1, unlockedIds),
      _buildAchievement('rep_10', 'Getting Warm', 'Complete 10 reps.', '🔥', totalRepsEst, 10, unlockedIds),
      _buildAchievement('rep_50', 'Rep Machine', 'Complete 50 reps.', '🤖', totalRepsEst, 50, unlockedIds),
      _buildAchievement('streak_3', '3 Day Streak', 'Maintain a rep streak for 3 days.', '📅', maxStreak, 3, unlockedIds),
      _buildAchievement('streak_7', 'Weekly Warrior', 'Maintain a rep streak for 7 days.', '🏆', maxStreak, 7, unlockedIds),
      _buildAchievement('level_2', 'Level Up', 'Reach Level 2.', '⭐', level, 2, unlockedIds),
      _buildAchievement('level_5', 'Rising Star', 'Reach Level 5.', '🌟', level, 5, unlockedIds),
      _buildAchievement('level_10', 'Master Scholar', 'Reach Level 10.', '👑', level, 10, unlockedIds),
    ];

    // Check for newly unlocked
    List<String> newUnlocked = [];
    for (var ach in allAchievements) {
      if (ach.isUnlocked && !unlockedIds.contains(ach.id)) {
        newUnlocked.add(ach.id);
      }
    }

    if (newUnlocked.isNotEmpty) {
      unlockedIds.addAll(newUnlocked);
      await box.put(key, unlockedIds);
    }

    return allAchievements;
  }

  static AchievementModel _buildAchievement(
    String id, String title, String desc, String icon, int currentValue, int requiredValue, List<String> unlockedIds
  ) {
    bool previouslyUnlocked = unlockedIds.contains(id);
    bool newlyUnlocked = currentValue >= requiredValue;
    bool isUnlocked = previouslyUnlocked || newlyUnlocked;
    
    double progress = isUnlocked ? 1.0 : (currentValue / requiredValue).clamp(0.0, 1.0);
    
    return AchievementModel(
      id: id,
      title: title,
      description: desc,
      icon: icon,
      isUnlocked: isUnlocked,
      progress: progress,
      // Record exact time won't be saved permanently in this simplified hive logic, but handles fresh unlocks dynamically when checking
      unlockedAt: isUnlocked && !previouslyUnlocked ? DateTime.now() : null, 
    );
  }
}
