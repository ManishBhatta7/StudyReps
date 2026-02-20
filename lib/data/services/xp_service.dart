import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/xp_model.dart';
import '../../core/constants/app_constants.dart';

class XpService {
  static const String boxName = 'xp_box';
  static const int xpPerRep = 15;
  static const int streakBonusXp = AppConstants.streakBonusXp; // Usually 50

  /// Get current XP record
  static Future<XpModel> getXpRecord(String userId) async {
    final box = await Hive.openBox(boxName);
    final key = '${userId}_xp';
    final existingJson = box.get(key);

    if (existingJson != null) {
      return XpModel.fromJson(Map<String, dynamic>.from(existingJson));
    } else {
      return const XpModel(totalXp: 0, currentLevel: 1, xpForNextLevel: 100);
    }
  }

  /// Award XP to a user (e.g. for completing a rep)
  static Future<XpModel> addXp(String userId, {int xp = xpPerRep, bool isStreakBonus = false}) async {
    final box = await Hive.openBox(boxName);
    final key = '${userId}_xp';
    var record = await getXpRecord(userId);

    int totalAmount = xp + (isStreakBonus ? streakBonusXp : 0);
    int newTotalXp = record.totalXp + totalAmount;
    
    // Formula: Level = floor(sqrt(XP / 100)) + 1
    // (100 XP -> lvl 2, 400 XP -> lvl 3, 900 XP -> lvl 4... etc)
    int newLevel = sqrt(newTotalXp / 100.0).floor() + 1;
    
    // XP For Next level = (newLevel)^2 * 100
    int nextLevelXp = (newLevel * newLevel) * 100;
    
    final newRecord = record.copyWith(
      totalXp: newTotalXp,
      currentLevel: newLevel,
      xpForNextLevel: nextLevelXp,
      recentXpGain: totalAmount, // Useful if the UI wants to show an animation
    );

    await box.put(key, newRecord.toJson());
    return newRecord;
  }
}
