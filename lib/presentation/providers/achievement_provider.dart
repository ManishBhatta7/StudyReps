import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/achievement_model.dart';
import '../../data/services/achievement_service.dart';
import 'auth_provider.dart';
import 'streak_provider.dart';
import 'xp_provider.dart';

class AchievementNotifier extends AsyncNotifier<List<AchievementModel>> {
  @override
  Future<List<AchievementModel>> build() async {
    final authState = ref.watch(authStateStreamProvider).value;
    
    // Watch dependencies to automatically re-evaluate achievements
    ref.watch(streakProvider);
    ref.watch(xpProvider);

    if (authState == null) return [];

    return await AchievementService.getAchievements(authState.id);
  }
}

final achievementProvider = AsyncNotifierProvider<AchievementNotifier, List<AchievementModel>>(
  () => AchievementNotifier(),
);
