import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/study_reps_theme.dart';
import 'settings_screen.dart';
import '../../presentation/providers/stats_provider.dart';
import '../../domain/models/video_model.dart';
import '../providers/video_feed_provider.dart';
import '../../presentation/providers/xp_provider.dart';
import '../../presentation/providers/auth_provider.dart';
import 'squads_screen.dart';

/// Profile Stats Screen
/// 
/// Shows user profile, statistics, level progress, and recent activity
class ProfileStatsScreen extends ConsumerWidget {
  const ProfileStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardStatsAsync = ref.watch(dashboardStatsProvider);
    final tsrHealthAsync = ref.watch(tsrHealthProvider);
    final xpAsync = ref.watch(xpProvider);
    final user = ref.watch(currentDomainUserProvider);

    return Scaffold(
      backgroundColor: StudyRepsTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: StudyRepsTheme.textSecondary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            
            // Avatar & Name
            xpAsync.when(
              data: (xp) => _buildProfileHeader(xp.currentLevel, xp.totalXp, xp.xpForNextLevel, user),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => _buildProfileHeader(1, 0, 100, user),
            ),
            
            const SizedBox(height: 24),
            
            // TSR Health Score (New)
            tsrHealthAsync.when(
              data: (health) => _buildHealthScore(health),
              loading: () => _buildLoadingCard('Calculating Health Score...'),
              error: (err, _) => _buildErrorCard('Could not load health score'),
            ),

            const SizedBox(height: 24),
            
            // Stats Grid
            dashboardStatsAsync.when(
              data: (stats) => _buildStatsGrid(stats),
              loading: () => _buildStatsLoading(),
              error: (err, _) => _buildErrorCard('Could not load stats'),
            ),

            const SizedBox(height: 24),
            
            // Study Squads Hub Card
            _buildSquadsHubCard(context),
            
            const SizedBox(height: 24),
            
            // My Created Reps (Categorized)
            _buildMyRepsSection(ref),

            const SizedBox(height: 32),
            
            // Recent Activity
            _buildRecentActivity(),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(int level, int xp, int nextLevelXp, user) {
    final displayName = user?.fullName ?? user?.name ?? 'Student';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Column(
      children: [
        // Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: StudyRepsTheme.primaryIndigo,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: StudyRepsTheme.primaryIndigo.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 47,
            backgroundColor: StudyRepsTheme.bgSecondary,
            backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
            child: user?.avatarUrl == null ? Text(
              initial,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: StudyRepsTheme.textMuted,
              ),
            ) : null,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Username
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: StudyRepsTheme.textPrimary,
          ),
        ),
        
        if (user?.email != null) ...[
          const SizedBox(height: 4),
          Text(
            user!.email!,
            style: const TextStyle(
              fontSize: 14,
              color: StudyRepsTheme.textMuted,
            ),
          ),
        ],
        
        const SizedBox(height: 8),
        
        // Level Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: StudyRepsTheme.primaryIndigo.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: StudyRepsTheme.primaryIndigo.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              const SizedBox(width: 6),
              Text(
                'Level $level',
                style: const TextStyle(
                  color: StudyRepsTheme.primaryIndigoLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 1,
                height: 12,
                color: StudyRepsTheme.primaryIndigo.withOpacity(0.4),
              ),
              const SizedBox(width: 12),
              Text(
                '$xp / $nextLevelXp XP',
                style: const TextStyle(
                  color: StudyRepsTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildHealthScore(TSRHealthStats health) {
    Color scoreColor = StudyRepsTheme.successGreen;
    if (health.score < 50) {
      scoreColor = StudyRepsTheme.errorPink;
    } else if (health.score < 80) {
      scoreColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: StudyRepsTheme.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TSR Health Score',
                style: TextStyle(
                  color: StudyRepsTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                   color: scoreColor.withOpacity(0.2),
                   borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  health.status.toUpperCase(),
                  style: TextStyle(
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: health.score / 100,
                  strokeWidth: 10,
                  backgroundColor: StudyRepsTheme.bgTertiary,
                  valueColor: AlwaysStoppedAnimation(scoreColor),
                ),
              ),
              Text(
                '${health.score}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            health.advice,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: StudyRepsTheme.textMuted,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildStatsGrid(DashboardStats stats) {
    final statItems = [
      {'label': 'Total Reps', 'value': '${stats.totalReps}', 'icon': Icons.fitness_center_rounded, 'color': StudyRepsTheme.primaryIndigo},
      {'label': 'Accuracy', 'value': stats.accuracy, 'icon': Icons.check_circle_outline_rounded, 'color': StudyRepsTheme.successGreen},
      // You could add streak here if you were tracking it in the DB
    ];

    return Row(
      children: [
        for (int i = 0; i < statItems.length; i++) ...[
             Expanded(
              child: _buildStatCard(statItems[i], i),
            ),
            if (i < statItems.length - 1) const SizedBox(width: 12),
        ]
      ],
    );
  }
  
  Widget _buildLoadingCard(String message) {
      return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: StudyRepsTheme.bgSecondary.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
              children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(message, style: const TextStyle(color: StudyRepsTheme.textMuted)),
              ],
          ),
      );
  }
  
  Widget _buildStatsLoading() {
      return Row(
          children: [
              Expanded(child: _buildLoadingCard('...')),
              const SizedBox(width: 12),
              Expanded(child: _buildLoadingCard('...')),
          ],
      );
  }
  
  Widget _buildErrorCard(String error) {
      return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: StudyRepsTheme.errorPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: StudyRepsTheme.errorPink.withOpacity(0.5)),
          ),
          child: Text(error, style: const TextStyle(color: StudyRepsTheme.errorPink)),
      );
  }

  Widget _buildStatCard(Map<String, dynamic> stat, int index) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: StudyRepsTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stat['label'],
                style: const TextStyle(
                  color: StudyRepsTheme.textMuted,
                  fontSize: 13,
                ),
              ),
              Icon(
                stat['icon'] as IconData,
                color: stat['color'] as Color,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            stat['value'],
            style: const TextStyle(
              color: StudyRepsTheme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (150 + index * 80).ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildSquadsHubCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SquadsScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              StudyRepsTheme.primaryIndigo.withOpacity(0.8),
              StudyRepsTheme.primaryPurple.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: StudyRepsTheme.primaryPurple.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.groups_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Study Squads',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Join forces and conquer goals together!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white54),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildMyRepsSection(WidgetRef ref) {
    // 1. Get user created videos
    final userVideos = ref.watch(userCreatedVideosProvider);

    if (userVideos.isEmpty) return const SizedBox.shrink();

    // 2. Group by subject
    final grouped = <String, List<VideoModel>>{};
    for (final video in userVideos) {
      final subject = video.subject.isEmpty ? 'General' : video.subject;
      if (!grouped.containsKey(subject)) {
        grouped[subject] = [];
      }
      grouped[subject]!.add(video);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'My Reps',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: grouped.entries.map((entry) {
              final subject = entry.key;
              final reps = entry.value;
              
              return Theme(
                data: Theme.of(ref.context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: StudyRepsTheme.primaryIndigo.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getSubjectIcon(subject),
                      color: StudyRepsTheme.accentCyan,
                      size: 16,
                    ),
                  ),
                  title: Text(
                    subject,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${reps.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  children: reps.map((rep) => _buildRepTile(rep)).toList(),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 350.ms);
  }

  Widget _buildRepTile(VideoModel rep) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline_rounded, 
                  color: StudyRepsTheme.textSecondary, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rep.question.prompt,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, 
                  color: StudyRepsTheme.successGreen, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rep.question.correctAnswer,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7), 
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'biology': return Icons.biotech_rounded;
      case 'physics': return Icons.bolt_rounded;
      case 'chemistry': return Icons.science_rounded;
      case 'history': return Icons.history_edu_rounded;
      case 'math': 
      case 'mathematics': return Icons.calculate_rounded;
      default: return Icons.school_rounded;
    }
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Recent Activity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // Placeholder data
        _buildActivityItem('Mastered "Newton\'s Second Law"', '2m ago', Icons.emoji_events_rounded, Colors.amber),
        _buildActivityItem('Completed Physics Quiz', '1h ago', Icons.quiz_rounded, Colors.purple),
        _buildActivityItem('Started 7 Day Streak', '1d ago', Icons.local_fire_department_rounded, Colors.orange),
      ],
    );
  }
  
  Widget _buildActivityItem(String text, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
