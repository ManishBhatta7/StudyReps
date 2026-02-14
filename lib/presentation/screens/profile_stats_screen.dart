import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/study_reps_theme.dart';
import 'settings_screen.dart';

/// Profile Stats Screen
/// 
/// Shows user profile, statistics, level progress, and recent activity
class ProfileStatsScreen extends ConsumerWidget {
  const ProfileStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: StudyRepsTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: StudyRepsTheme.textSecondary),
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
            _buildProfileHeader(),
            
            const SizedBox(height: 24),
            
            // Level Progress
            _buildLevelProgress(),
            
            const SizedBox(height: 24),
            
            // Stats Grid
            _buildStatsGrid(),
            
            const SizedBox(height: 32),
            
            // Recent Activity
            _buildRecentActivity(),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
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
            child: Icon(
              Icons.person_rounded,
              size: 50,
              color: StudyRepsTheme.textMuted,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Username
        const Text(
          '@StudentPro',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: StudyRepsTheme.textPrimary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Level Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: StudyRepsTheme.primaryIndigo.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: StudyRepsTheme.primaryIndigo.withOpacity(0.5)),
          ),
          child: Text(
            'Level 12',
            style: TextStyle(
              color: StudyRepsTheme.primaryIndigoLight,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildLevelProgress() {
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
              Text(
                'Progress to Level 13',
                style: TextStyle(
                  color: StudyRepsTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                '85%',
                style: TextStyle(
                  color: StudyRepsTheme.primaryIndigoLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.85,
              minHeight: 10,
              backgroundColor: StudyRepsTheme.bgTertiary,
              valueColor: AlwaysStoppedAnimation(StudyRepsTheme.primaryIndigo),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '750 XP to Level 13',
            style: TextStyle(
              color: StudyRepsTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildStatsGrid() {
    final stats = [
      {'label': 'Reps', 'value': '2,847', 'icon': Icons.fitness_center_rounded, 'color': StudyRepsTheme.primaryIndigo},
      {'label': 'Accuracy', 'value': '89%', 'icon': Icons.check_circle_outline_rounded, 'color': StudyRepsTheme.successGreen},
      {'label': 'Day Streak', 'value': '15', 'icon': Icons.local_fire_department_rounded, 'color': Colors.orange},
      {'label': 'XP', 'value': '4,250', 'icon': Icons.star_rounded, 'color': StudyRepsTheme.accentCyan},
    ];

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildStatCard(stats[0], 0),
              const SizedBox(height: 12),
              _buildStatCard(stats[2], 2),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              _buildStatCard(stats[1], 1),
              const SizedBox(height: 12),
              _buildStatCard(stats[3], 3),
            ],
          ),
        ),
      ],
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
                style: TextStyle(
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
          Text(
            stat['label'],
            style: TextStyle(
              color: StudyRepsTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (150 + index * 80).ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildRecentActivity() {
    final activities = [
      {'title': 'Spanish Vocab', 'time': '10m', 'icon': Icons.translate_rounded},
      {'title': 'Math Quiz', 'time': '10m', 'icon': Icons.calculate_rounded},
      {'title': 'Spanish', 'time': '10m', 'icon': Icons.language_rounded},
      {'title': 'Art History', 'time': '10m', 'icon': Icons.palette_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: StudyRepsTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Container(
                width: 100,
                margin: EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: StudyRepsTheme.bgSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: StudyRepsTheme.borderSubtle),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: StudyRepsTheme.primaryIndigo.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        activity['icon'] as IconData,
                        color: StudyRepsTheme.primaryIndigo,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      activity['title'] as String,
                      style: TextStyle(
                        color: StudyRepsTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (400 + index * 80).ms);
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 350.ms);
  }
}
