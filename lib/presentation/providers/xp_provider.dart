import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/xp_model.dart';
import '../../data/services/xp_service.dart';
import 'auth_provider.dart';

class XpNotifier extends AsyncNotifier<XpModel> {
  @override
  Future<XpModel> build() async {
    final authState = ref.watch(authStateStreamProvider).value;
    if (authState == null) return const XpModel(totalXp: 0, currentLevel: 1, xpForNextLevel: 100);

    return await XpService.getXpRecord(authState.id);
  }

  Future<void> addXp({int xp = XpService.xpPerRep, bool isStreakBonus = false}) async {
    final authState = ref.read(authStateStreamProvider).value;
    if (authState == null) return;

    // Use current state to optimistically add but better to update via DB then set
    try {
      final newRecord = await XpService.addXp(authState.id, xp: xp, isStreakBonus: isStreakBonus);
      state = AsyncValue.data(newRecord);
    } catch (e, st) {
      // ignore
      print("Failed to add XP: $e");
    }
  }
}

final xpProvider = AsyncNotifierProvider<XpNotifier, XpModel>(
  () => XpNotifier(),
);
