import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/learning_record_model.dart';
import 'spaced_repetition_service.dart';
import 'streak_service.dart';
import 'xp_service.dart';
import 'achievement_service.dart';

// Provider for easy access
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(Supabase.instance.client);
});

class SyncService {
  final SupabaseClient _supabase;
  bool _isSyncing = false;
  Timer? _timer;

  SyncService(this._supabase);

  /// Initializes the background sync worker.
  /// Call this when the app starts.
  void initWorker() {
    // Check every 2 minutes
    _timer = Timer.periodic(const Duration(minutes: 2), (_) {
      syncPendingReps();
      syncGamification();
    });
    
    // Also trigger immediately
    syncPendingReps();
    syncGamification();
  }

  void dispose() {
    _timer?.cancel();
  }

  /// Pushes unsynced local records to Supabase
  Future<void> syncPendingReps() async {
    if (_isSyncing) return;
    
    // Check auth
    final session = _supabase.auth.currentSession;
    if (session == null) return;

    _isSyncing = true;
    
    try {
      final box = await Hive.openBox(SpacedRepetitionService.boxName);
      
      final pendingReps = <LearningRecord>[];
      final keysToUpdate = <dynamic>[];
      final currentUserId = session.user.id;

      for (final key in box.keys) {
        final map = box.get(key);
        if (map != null) {
          try {
            final record = LearningRecord.fromJson(Map<String, dynamic>.from(map));
            
            // Only sync for current user
            if (record.userId != currentUserId) continue;

            // Sync Logic
            bool needsSync = record.syncedAt == null;
            if (!needsSync && record.updatedAt != null) {
                if (record.syncedAt!.isBefore(record.updatedAt!)) {
                    needsSync = true;
                }
            }
            
            if (needsSync) {
              pendingReps.add(record);
              keysToUpdate.add(key);
            }
          } catch (e) {
            debugPrint('⚠️ SyncService: Error parsing record $key: $e');
          }
        }
      }

      if (pendingReps.isEmpty) {
        _isSyncing = false;
        return;
      }

      debugPrint('🔄 SyncService: Pushing ${pendingReps.length} reps...');

      // Call Edge Function
      final response = await _supabase.functions.invoke(
        'sync-reps',
        body: {
          'reps': pendingReps.map((r) => r.toJson()).toList(),
        },
      );
      
      // Handle response
      if (response.status == 200 || response.status == 201) {
          // Success! Mark as synced.
          final now = DateTime.now();
          for (int i = 0; i < pendingReps.length; i++) {
            final updatedRecord = pendingReps[i].copyWith(syncedAt: now);
            await box.put(keysToUpdate[i], updatedRecord.toJson());
          }
          debugPrint('✅ SyncService: Complete. ${pendingReps.length} records pushed.');
      } else {
        debugPrint('❌ SyncService: Failed ${response.status} ${response.data}');
      }

    } catch (e) {
      debugPrint('❌ SyncService: Error $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> syncGamification() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return;

    try {
      final userId = session.user.id;
      final streak = await StreakService.getStreakRecord(userId);
      final xp = await XpService.getXpRecord(userId);
      final achievements = await AchievementService.getAchievements(userId);

      final response = await _supabase.functions.invoke(
        'sync-gamification',
        body: {
          'userId': userId,
          'streak': streak.toJson(),
          'xp': xp.toJson(),
          'achievements': achievements.map((a) => a.toJson()).toList(),
        },
      );

      if (response.status == 200 || response.status == 201) {
        debugPrint('✅ SyncService: Gamification sync complete.');
      } else {
        debugPrint('❌ SyncService: Gamification sync failed ${response.status} ${response.data}');
      }
    } catch (e) {
      debugPrint('❌ SyncService: Gamification Exception: $e');
    }
  }
}
