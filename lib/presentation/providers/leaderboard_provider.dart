import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/leaderboard_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  List<LeaderboardEntry> baseList = [];
  
  try {
    // 1. Fetch top users by XP from Supabase (up to 50 users)
    final response = await Supabase.instance.client
        .from('user_xp')
        .select('user_id, total_xp, current_level')
        .order('total_xp', ascending: false)
        .limit(50);
        
    final xpData = response as List<dynamic>;

    // 2. Fetch profiles for these users to get names/avatars
    if (xpData.isNotEmpty) {
      final userIds = xpData.map((e) => e['user_id']).toList();
      final profilesResp = await Supabase.instance.client
          .from('profiles')
          .select('id, full_name, avatar_url')
          .inFilter('id', userIds);
          
      final profiles = profilesResp as List<dynamic>;
      final profileMap = {for (var p in profiles) p['id']: p};

      int rank = 1;
      for (var xpRow in xpData) {
        final profile = profileMap[xpRow['user_id']];
        int totalXp = xpRow['total_xp'] ?? 0;
        
        // Simulating weekly by dividing randomly just for demo logic if no actual timeline data
        if (filter == 'Weekly') {
           totalXp = (totalXp * 0.2).round();
        }

        baseList.add(LeaderboardEntry(
          id: xpRow['user_id'],
          name: profile?['full_name'] ?? 'Anonymous Student',
          avatar: profile?['avatar_url'] ?? '🧠',
          xp: totalXp,
          rank: rank++,
          trend: 'up', // Could implement dynamic trend based on history
        ));
      }
    }
  } catch (e) {
    print("Leaderboard error: $e");
    // Fallback if Supabase fails
  }

  // If Supabase returned nothing, fallback to mock data
  if (baseList.isEmpty) {
    baseList = [
      LeaderboardEntry(id: '2', name: 'Maria Garcia', xp: filter == 'Weekly' ? 10200 : 45000, rank: 2, avatar: '🧠', trend: 'up'),
      LeaderboardEntry(id: '1', name: 'Alex Chen', xp: filter == 'Weekly' ? 12500 : 50000, rank: 1, avatar: '🏆', trend: 'same'),
      LeaderboardEntry(id: '3', name: 'David Lee', xp: filter == 'Weekly' ? 9800 : 41000, rank: 3, avatar: '💡', trend: 'down'),
      LeaderboardEntry(id: '4', name: 'Emily Davis', xp: filter == 'Weekly' ? 9150 : 38000, rank: 4, trend: 'up'),
      LeaderboardEntry(id: '5', name: 'Chris Wilson', xp: filter == 'Weekly' ? 8900 : 35000, rank: 5, trend: 'down'),
    ];
  }

  // Inject current user if not already in the list
  final meId = Supabase.instance.client.auth.currentUser?.id ?? 'local_user';
  if (!baseList.any((e) => e.id == meId)) {
    final myXpState = ref.watch(xpProvider).value;
    int myTotalXp = myXpState?.totalXp ?? 0;
    if (filter == 'Weekly') {
        myTotalXp = myTotalXp > 3000 ? 3000 : myTotalXp;
    }
    
    baseList.add(LeaderboardEntry(
      id: meId, 
      name: 'You', 
      xp: myTotalXp, 
      rank: 0, 
      trend: 'up'
    ));
  }

  // Re-sort by XP
  baseList.sort((a, b) => b.xp.compareTo(a.xp));

  // Re-assign ranks
  for (int i = 0; i < baseList.length; i++) {
    baseList[i] = baseList[i].copyWith(rank: i + 1);
  }

  // Build podium [2nd, 1st, 3rd]
  final podiumElements = baseList.take(3).toList();
  List<LeaderboardEntry> podium = [];
  if (podiumElements.isNotEmpty) {
    if (podiumElements.length > 1) podium.add(podiumElements[1]);
    podium.add(podiumElements[0]);
    if (podiumElements.length > 2) podium.add(podiumElements[2]);
  }

  final listRest = baseList.skip(3).toList();
  final me = baseList.firstWhere((e) => e.id == meId, orElse: () => baseList.first);

  return LeaderboardState(
    podium: podium,
    list: listRest,
    currentUser: me,
  );
});
