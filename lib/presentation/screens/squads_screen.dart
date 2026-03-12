import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/study_reps_theme.dart';
import '../providers/squad_provider.dart';

class SquadsScreen extends ConsumerStatefulWidget {
  const SquadsScreen({super.key});

  @override
  ConsumerState<SquadsScreen> createState() => _SquadsScreenState();
}

class _SquadsScreenState extends ConsumerState<SquadsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudyRepsTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Study Squads'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: StudyRepsTheme.accentCyan,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'My Squads'),
            Tab(text: 'Explore'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMySquadsTab(context, ref),
          _buildExploreSquadsTab(context, ref),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: StudyRepsTheme.primaryPurple,
        icon: const Icon(Icons.add_moderator),
        label: const Text('Create Squad'),
        onPressed: () => _showCreateSquadDialog(context, ref),
      ),
    );
  }

  Widget _buildMySquadsTab(BuildContext context, WidgetRef ref) {
    final mySquadsAsync = ref.watch(mySquadsProvider);

    return mySquadsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      data: (squads) {
        if (squads.isEmpty) {
          return const Center(child: Text("You aren't in any squads yet.\nJoin one from Explore!", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: squads.length,
          itemBuilder: (context, index) {
             final squad = squads[index];
             return _buildSquadCard(squad, isMember: true);
          },
        );
      },
    );
  }

  Widget _buildExploreSquadsTab(BuildContext context, WidgetRef ref) {
    final allSquadsAsync = ref.watch(allSquadsProvider);
    final mySquadsAsync = ref.watch(mySquadsProvider);
    
    // Quick helper to check membership
    final mySquadIds = mySquadsAsync.valueOrNull?.map((s) => s.id).toSet() ?? {};

    return allSquadsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      data: (squads) {
        if (squads.isEmpty) {
          return const Center(child: Text('No squads exist yet. Be the first to create one!', style: TextStyle(color: Colors.white70)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: squads.length,
          itemBuilder: (context, index) {
             final squad = squads[index];
             final isMember = mySquadIds.contains(squad.id);
             return _buildSquadCard(squad, isMember: isMember, onJoin: isMember ? null : () {
                ref.read(squadControllerProvider).joinSquad(squad.id);
             });
          },
        );
      },
    );
  }

  Widget _buildSquadCard(squad, {bool isMember = false, VoidCallback? onJoin}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StudyRepsTheme.primaryIndigo.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: StudyRepsTheme.primaryIndigo.withOpacity(0.5),
            radius: 24,
            child: const Icon(Icons.group, color: StudyRepsTheme.accentCyan),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(squad.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                if (squad.description != null) ...[
                  const SizedBox(height: 4),
                  Text(squad.description, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                     const Icon(Icons.star, size: 14, color: Colors.amber),
                     const SizedBox(width: 4),
                     Text('Goal: ${squad.weeklyGoal} Reps/wk', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ]
                )
              ],
            ),
          ),
          if (onJoin != null)
             ElevatedButton(
               style: ElevatedButton.styleFrom(
                 backgroundColor: StudyRepsTheme.accentCyan,
                 foregroundColor: Colors.black,
               ),
               onPressed: onJoin, 
               child: const Text('Join'),
             )
          else if (isMember)
             const Chip(label: Text('Member', style: TextStyle(fontSize: 11)), backgroundColor: StudyRepsTheme.primaryIndigo)
        ],
      )
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  void _showCreateSquadDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StudyRepsTheme.bgSecondary,
        title: const Text('Create Study Squad', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             TextField(
               controller: nameCtrl,
               style: const TextStyle(color: Colors.white),
               decoration: const InputDecoration(labelText: 'Squad Name', labelStyle: TextStyle(color: Colors.white54)),
             ),
             const SizedBox(height: 12),
             TextField(
               controller: descCtrl,
               style: const TextStyle(color: Colors.white),
               decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Colors.white54)),
             ),
          ]
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () async {
               if (nameCtrl.text.trim().isEmpty) return;
               Navigator.pop(ctx);
               try {
                  await ref.read(squadControllerProvider).createSquad(nameCtrl.text.trim(), descCtrl.text.trim());
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Squad Created!')));
               } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
               }
            }, 
            child: const Text('Submit')
          )
        ],
      )
    );
  }
}
