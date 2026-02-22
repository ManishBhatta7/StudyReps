import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/streak_model.dart';
import '../../core/constants/app_constants.dart';
import 'package:clock/clock.dart'; // helpful if we want to mock time later, else just DateTime.now()
import 'package:supabase_flutter/supabase_flutter.dart';

class StreakService {
  static const String boxName = 'streak_box';
  static const int dailyGoal = 10; // e.g. 10 reps per day

  static Future<StreakModel> getStreakRecord(String userId) async {
    final box = await Hive.openBox(boxName);
    final key = '${userId}_streak';
    final existingJson = box.get(key);

    if (existingJson != null) {
      final model = StreakModel.fromJson(Map<String, dynamic>.from(existingJson));
      return _checkAndResetDaily(model);
    } else {
      // Try to fetch from Supabase
      try {
         final response = await Supabase.instance.client
           .from('user_streaks')
           .select('*')
           .eq('user_id', userId)
           .maybeSingle();

         if (response != null) {
             final completedDaysRaw = response['completed_days'] as List<dynamic>? ?? [];
             final record = StreakModel(
                currentStreak: response['current_streak'] ?? 0,
                maxStreak: response['max_streak'] ?? 0,
                todayReps: response['today_reps'] ?? 0,
                lastRepDate: response['last_rep_date'] != null ? DateTime.parse(response['last_rep_date']) : null,
                completedDays: completedDaysRaw.map((e) => DateTime.parse(e.toString())).toList(),
             );
             await box.put(key, record.toJson());
             return _checkAndResetDaily(record);
         }
      } catch (e) {
         // ignore
      }

      return const StreakModel();
    }
  }

  static Future<StreakModel> recordRep(String userId) async {
    final box = await Hive.openBox(boxName);
    final key = '${userId}_streak';
    var record = await getStreakRecord(userId);

    // Increase today's reps
    int newTodayReps = record.todayReps + 1;
    bool justCompletedGoal = newTodayReps == dailyGoal;

    int newCurrentStreak = record.currentStreak;
    int newMaxStreak = record.maxStreak;
    List<DateTime> newCompletedDays = List.from(record.completedDays);

    final now = DateTime.now();

    if (justCompletedGoal) {
      // We hit the daily goal!
      // Check if it was already hit today (shouldn't be, if we handle reset correctly, but just in case)
      bool alreadyCompletedToday = newCompletedDays.isNotEmpty && 
        _isSameDay(newCompletedDays.last, now);
      
      if (!alreadyCompletedToday) {
        newCurrentStreak++;
        if (newCurrentStreak > newMaxStreak) newMaxStreak = newCurrentStreak;
        newCompletedDays.add(now);
      }
    }

    final newRecord = record.copyWith(
      todayReps: newTodayReps,
      currentStreak: newCurrentStreak,
      maxStreak: newMaxStreak,
      completedDays: newCompletedDays,
      lastRepDate: now,
    );

    await box.put(key, newRecord.toJson());

    // Sync to Supabase
    try {
        await Supabase.instance.client.from('user_streaks').upsert({
            'user_id': userId,
            'current_streak': newCurrentStreak,
            'max_streak': newMaxStreak,
            'today_reps': newTodayReps,
            'last_rep_date': now.toIso8601String(),
            'completed_days': newCompletedDays.map((e) => e.toIso8601String()).toList(),
            'synced_at': now.toIso8601String(),
        });
    } catch(e) {
        // Fail silently for offline
    }

    return newRecord;
  }

  // Purely private function to reset 'todayReps' if it's a new day
  // and reset 'currentStreak' if it's been more than 1 day since last completion
  static StreakModel _checkAndResetDaily(StreakModel record) {
    if (record.lastRepDate == null) return record;

    final now = DateTime.now();
    bool isNewDay = !_isSameDay(record.lastRepDate!, now);

    if (isNewDay) {
      // It's a new day, so reset today's reps
      int newTodayReps = 0;
      int newCurrentStreak = record.currentStreak;

      // Did they complete yesterday's goal? (Was 'now - 1 day' in completedDays?)
      if (record.completedDays.isNotEmpty) {
        DateTime lastCompleted = record.completedDays.last;
        // If yesterday was NOT completed, the streak is broken!
        if (!_isYesterday(lastCompleted, now) && !_isSameDay(lastCompleted, now)) {
            newCurrentStreak = 0;
        }
      } else {
         newCurrentStreak = 0; // Never completed a day
      }

      return record.copyWith(
        todayReps: newTodayReps,
        currentStreak: newCurrentStreak,
      );
    }

    return record; // Still same day
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool _isYesterday(DateTime last, DateTime today) {
    // compare only dates
    DateTime d1 = DateTime(last.year, last.month, last.day);
    DateTime d2 = DateTime(today.year, today.month, today.day);
    return d2.difference(d1).inDays == 1;
  }
}
