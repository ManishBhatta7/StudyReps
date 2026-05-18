import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: StudyRepsTheme.warmCream,
      appBar: AppBar(
        backgroundColor: StudyRepsTheme.warmCream,
        elevation: 0,
        title: Text(
          'Study Squads',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: StudyRepsTheme.warmTextDark,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: StudyRepsTheme.warmTextDark),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: StudyRepsTheme.warmOrange,
          indicatorWeight: 3,
          labelColor: StudyRepsTheme.warmOrange,
          unselectedLabelColor: StudyRepsTheme.warmTextLight,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 14),
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
        backgroundColor: StudyRepsTheme.warmOrange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('Create Squad', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        onPressed: () => _showCreateSquadDialog(context, ref),
      ),
    );
  }

  Widget _buildMySquadsTab(BuildContext context, WidgetRef ref) {
    final mySquadsAsync = ref.watch(mySquadsProvider);

    return mySquadsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: StudyRepsTheme.warmOrange)),
      error: (err, st) => Center(child: Text('Error: $err', style: GoogleFonts.outfit(color: Colors.red))),
      data: (squads) {
        if (squads.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.group_rounded, size: 64, color: StudyRepsTheme.warmTextLight.withOpacity(0.4)),
                const SizedBox(height: 16),
                Text(
                  "You aren't in any squads yet.\nJoin one from Explore!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: StudyRepsTheme.warmTextLight, fontSize: 15),
                ),
              ],
            ),
          );
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

    final mySquadIds = mySquadsAsync.valueOrNull?.map((s) => s.id).toSet() ?? {};

    return allSquadsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: StudyRepsTheme.warmOrange)),
      error: (err, st) => Center(child: Text('Error: $err', style: GoogleFonts.outfit(color: Colors.red))),
      data: (squads) {
        if (squads.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.explore_rounded, size: 64, color: StudyRepsTheme.warmTextLight.withOpacity(0.4)),
                const SizedBox(height: 16),
                Text(
                  'No squads exist yet.\nBe the first to create one!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: StudyRepsTheme.warmTextLight, fontSize: 15),
                ),
              ],
            ),
          );
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
        color: StudyRepsTheme.warmCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: StudyRepsTheme.warmOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.group_rounded, color: StudyRepsTheme.warmOrange, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  squad.name,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: StudyRepsTheme.warmTextDark,
                  ),
                ),
                if (squad.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    squad.description,
                    style: GoogleFonts.outfit(color: StudyRepsTheme.warmTextMedium, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                     const Icon(Icons.flag_rounded, size: 14, color: StudyRepsTheme.warmOrange),
                     const SizedBox(width: 4),
                     Text(
                       'Goal: ${squad.weeklyGoal} Reps/wk',
                       style: GoogleFonts.outfit(color: StudyRepsTheme.warmTextLight, fontSize: 12),
                     ),
                  ],
                ),
              ],
            ),
          ),
          if (onJoin != null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: StudyRepsTheme.warmOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 0,
              ),
              onPressed: onJoin,
              child: Text('Join', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
            )
          else if (isMember)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: StudyRepsTheme.warmGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Member',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: StudyRepsTheme.warmGreen,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05);
  }

  void _showCreateSquadDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StudyRepsTheme.warmCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Create Study Squad',
          style: GoogleFonts.outfit(
            color: StudyRepsTheme.warmTextDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             TextField(
               controller: nameCtrl,
               style: GoogleFonts.outfit(color: StudyRepsTheme.warmTextDark),
               decoration: InputDecoration(
                 labelText: 'Squad Name',
                 labelStyle: GoogleFonts.outfit(color: StudyRepsTheme.warmTextLight),
                 enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: StudyRepsTheme.warmBorder)),
                 focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: StudyRepsTheme.warmOrange)),
               ),
             ),
             const SizedBox(height: 12),
             TextField(
               controller: descCtrl,
               style: GoogleFonts.outfit(color: StudyRepsTheme.warmTextDark),
               decoration: InputDecoration(
                 labelText: 'Description',
                 labelStyle: GoogleFonts.outfit(color: StudyRepsTheme.warmTextLight),
                 enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: StudyRepsTheme.warmBorder)),
                 focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: StudyRepsTheme.warmOrange)),
               ),
             ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.outfit(color: StudyRepsTheme.warmTextLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: StudyRepsTheme.warmOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
               if (nameCtrl.text.trim().isEmpty) return;
               Navigator.pop(ctx);
               try {
                  await ref.read(squadControllerProvider).createSquad(nameCtrl.text.trim(), descCtrl.text.trim());
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Squad Created! 🎉', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                      backgroundColor: StudyRepsTheme.warmGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
               } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
               }
            },
            child: Text('Submit', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
