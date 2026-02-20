import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/streak_model.dart';
import '../../data/services/streak_service.dart';
import 'auth_provider.dart';

class StreakNotifier extends AsyncNotifier<StreakModel> {
  @override
  Future<StreakModel> build() async {
    final authState = ref.watch(authStateStreamProvider).value;
    if (authState == null) return const StreakModel();

    return await StreakService.getStreakRecord(authState.id);
  }

  Future<void> logRep() async {
    final authState = ref.read(authStateStreamProvider).value;
    if (authState == null) return;

    state = const AsyncValue.loading();
    try {
      final newRecord = await StreakService.recordRep(authState.id);
      state = AsyncValue.data(newRecord);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final streakProvider = AsyncNotifierProvider<StreakNotifier, StreakModel>(
  () => StreakNotifier(),
);
