import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/squad_model.dart';
import 'comments_provider.dart'; // To get supabaseClientProvider

final allSquadsProvider = FutureProvider<List<StudySquad>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final response = await supabase
      .from('study_squads')
      .select('*')
      .order('created_at', ascending: false);
      
  return (response as List).map((json) => StudySquad.fromJson(json)).toList();
});

final mySquadsProvider = FutureProvider<List<StudySquad>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return [];
  
  // Query squads where the user is a member
  final response = await supabase
      .from('squad_members')
      .select('*, study_squads(*)')
      .eq('user_id', user.id);
      
  final squads = (response as List)
      .map((entry) => entry['study_squads'] as Map<String, dynamic>?)
      .whereType<Map<String, dynamic>>()
      .map((json) => StudySquad.fromJson(json))
      .toList();
      
  return squads;
});

final squadControllerProvider = Provider((ref) => SquadController(ref));

class SquadController {
  final Ref _ref;
  SquadController(this._ref);

  Future<void> createSquad(String name, String description) async {
    final supabase = _ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Must be logged in to create a squad');

    // 1. Create the squad
    final squadRes = await supabase.from('study_squads').insert({
      'name': name,
      'description': description,
      'created_by': user.id,
      'weekly_goal': 500, // default
    }).select().single();

    final newSquadId = squadRes['id'] as int;

    // 2. Add creator as admin member
    await supabase.from('squad_members').insert({
      'squad_id': newSquadId,
      'user_id': user.id,
      'role': 'admin',
    });

    // Refresh squads
    _ref.invalidate(allSquadsProvider);
    _ref.invalidate(mySquadsProvider);
  }

  Future<void> joinSquad(int squadId) async {
    final supabase = _ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Must be logged in to join a squad');

    await supabase.from('squad_members').insert({
      'squad_id': squadId,
      'user_id': user.id,
      'role': 'member',
    });

    _ref.invalidate(mySquadsProvider);
  }
}
