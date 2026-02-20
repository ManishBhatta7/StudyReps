import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/leaderboard_model.dart';
import 'xp_provider.dart';

// Because we don't have a real multiplayer backend yet, we'll simulate the leaderboard 
// and merge the local user into it.
class LeaderboardState {
  final List<LeaderboardEntry> podium;
  final List<LeaderboardEntry> list;
  final LeaderboardEntry? currentUser;

  LeaderboardState({
    required this.podium,
    required this.list,
    this.currentUser,
  });
}

final leaderboardProvider = FutureProvider.family<LeaderboardState, String>((ref, filter) async {
  // Wait artificially to simulate network
  await Future.delayed(const Duration(milliseconds: 600));
  
  // Base mock users
  final baseList = [
    LeaderboardEntry(id: '2', name: 'Maria Garcia', xp: filter == 'Weekly' ? 10200 : 45000, rank: 2, avatar: '🧠', trend: 'up'),
    LeaderboardEntry(id: '1', name: 'Alex Chen', xp: filter == 'Weekly' ? 12500 : 50000, rank: 1, avatar: '🏆', trend: 'same'),
    LeaderboardEntry(id: '3', name: 'David Lee', xp: filter == 'Weekly' ? 9800 : 41000, rank: 3, avatar: '💡', trend: 'down'),
    LeaderboardEntry(id: '4', name: 'Emily Davis', xp: filter == 'Weekly' ? 9150 : 38000, rank: 4, trend: 'up'),
    LeaderboardEntry(id: '5', name: 'Chris Wilson', xp: filter == 'Weekly' ? 8900 : 35000, rank: 5, trend: 'down'),
    LeaderboardEntry(id: '6', name: 'Jessica Kim', xp: filter == 'Weekly' ? 8400 : 32000, rank: 6, trend: 'up'),
    LeaderboardEntry(id: '7', name: 'Ryan Patel', xp: filter == 'Weekly' ? 7800 : 28000, rank: 7, trend: 'same'),
    LeaderboardEntry(id: '8', name: 'Dan Georgin', xp: filter == 'Weekly' ? 7700 : 27000, rank: 8, trend: 'up'),
    LeaderboardEntry(id: '10', name: 'Sophie Turner', xp: filter == 'Weekly' ? 6100 : 24000, rank: 9, trend: 'down'),
  ];
  
  // Get our local user XP
  final myXpState = ref.watch(xpProvider).value;
  int myTotalXp = myXpState?.totalXp ?? 0;
  
  if (filter == 'Weekly') {
      myTotalXp = myTotalXp > 3000 ? 3000 : myTotalXp; // fake some weekly limitation 
  }

  // Inject user into the list
  baseList.add(LeaderboardEntry(
    id: 'local_user', 
    name: 'You', 
    xp: myTotalXp, 
    rank: 0, // Calculated later
    trend: 'up'
  ));

  // Sort by XP
  baseList.sort((a, b) => b.xp.compareTo(a.xp));

  // Assign Ranks
  for (int i = 0; i < baseList.length; i++) {
    baseList[i] = baseList[i].copyWith(rank: i + 1);
  }

  // Split into Podium (Top 3) and the rest
  final podiumElements = baseList.take(3).toList();
  // Podium expects [2nd, 1st, 3rd] for display rendering
  List<LeaderboardEntry> podium = [];
  if (podiumElements.isNotEmpty) {
    if (podiumElements.length > 1) podium.add(podiumElements[1]);
    podium.add(podiumElements[0]);
    if (podiumElements.length > 2) podium.add(podiumElements[2]);
  }

  final listRest = baseList.skip(3).toList();
  
  // Get the current user
  final me = baseList.firstWhere((e) => e.id == 'local_user');

  return LeaderboardState(
    podium: podium,
    list: listRest,
    currentUser: me,
  );
});
