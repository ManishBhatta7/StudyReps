import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../domain/models/achievement_model.dart';
import '../providers/achievement_provider.dart';
import '../providers/streak_provider.dart';

/// Streak Screen
/// 
/// Displays streak progress, calendar, daily goals, and achievements
class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);
    final achAsync = ref.watch(achievementProvider);

    return Scaffold(
      backgroundColor: StudyRepsTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('StudyReps Streak'),
        centerTitle: true,
      ),
      body: streakAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (streakData) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Streak Hero
                _buildStreakHero(streakData.currentStreak),
                
                const SizedBox(height: 32),
                
                // Calendar
                _buildCalendar(streakData.completedDays),
                
                const SizedBox(height: 32),
                
                // Daily Progress
                _buildDailyProgress(streakData.todayReps),
                
                const SizedBox(height: 32),
                
                // Achievements
                achAsync.when(
                  data: (achievements) => _buildAchievements(achievements),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => const SizedBox(),
                ),
                
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreakHero(int currentStreak) {
    return Column(
      children: [
        // Fire Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.orange.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
          child: Center(
            child: Text(
              currentStreak > 0 ? '🔥' : '🧊',
              style: const TextStyle(fontSize: 60),
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.5.seconds),
        
        const SizedBox(height: 16),
        
        // Streak Count
        Text(
          '$currentStreak Day Streak!',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: StudyRepsTheme.textPrimary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          currentStreak > 0 
            ? 'Keep the flame burning! You\'re doing great.'
            : 'Get started with a rep to ignite your flame!',
          style: const TextStyle(
            color: StudyRepsTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildCalendar(List<DateTime> completedDays) {
    final now = DateTime.now();
    // A simplified map of days in current month to completion status
    final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final Set<int> completedDaysThisMonth = completedDays
        .where((d) => d.year == now.year && d.month == now.month)
        .map((d) => d.day)
        .toSet();

    const monthNames = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgSecondary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StudyRepsTheme.borderSubtle),
      ),
      child: Column(
        children: [
          // Month Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.chevron_left_rounded, color: StudyRepsTheme.textMuted),
              Text(
                monthNames[now.month - 1],
                style: const TextStyle(
                  color: StudyRepsTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: StudyRepsTheme.textMuted),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isCompleted = completedDaysThisMonth.contains(day);
              final isToday = day == now.day;
              
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isToday && isCompleted
                      ? StudyRepsTheme.primaryIndigo 
                      : isCompleted
                          ? StudyRepsTheme.primaryIndigo.withOpacity(0.2)
                          : isToday
                              ? StudyRepsTheme.borderSubtle
                              : Colors.transparent,
                  border: isCompleted && !isToday
                      ? null
                      : Border.all(color: StudyRepsTheme.borderSubtle),
                ),
                child: Center(
                  child: isCompleted && !isToday
                      ? const Icon(
                          Icons.check_rounded,
                          color: StudyRepsTheme.primaryIndigo,
                          size: 16,
                        )
                      : Text(
                          '$day',
                          style: TextStyle(
                            color: isToday && isCompleted
                                ? Colors.white 
                                : StudyRepsTheme.textMuted,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          // Today label
          const Text(
            'TODAY',
            style: TextStyle(
              color: StudyRepsTheme.textMuted,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1);
  }

  Widget _buildDailyProgress(int todayReps) {
    const int dailyGoal = 10;
    final double progress = todayReps / dailyGoal;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgSecondary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StudyRepsTheme.borderSubtle),
      ),
      child: Column(
        children: [
          const Text(
            'Daily Progress',
            style: TextStyle(
              color: StudyRepsTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Progress Ring
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress > 1.0 ? 1.0 : progress,
                    strokeWidth: 10,
                    backgroundColor: StudyRepsTheme.bgTertiary,
                    valueColor: const AlwaysStoppedAnimation(StudyRepsTheme.primaryIndigo),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$todayReps',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: StudyRepsTheme.textPrimary,
                            ),
                          ),
                          const TextSpan(
                            text: '/$dailyGoal',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: StudyRepsTheme.primaryIndigo,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Reps',
                      style: TextStyle(
                        color: StudyRepsTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            todayReps >= dailyGoal 
              ? 'Goal achieved! You are on fire! 🔥'
              : 'Almost there! ${dailyGoal - todayReps} more reps to hit your daily goal.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: StudyRepsTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildAchievements(List<AchievementModel> achievements) {
    final lockedCount = achievements.where((a) => !a.isUnlocked).length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgSecondary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StudyRepsTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Achievement Badges',
                style: TextStyle(
                  color: StudyRepsTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 14, color: StudyRepsTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'Unlocked ${achievements.length - lockedCount}/${achievements.length}',
                    style: const TextStyle(
                      color: StudyRepsTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Wrap(
            spacing: 16,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: achievements.map((ach) {
              return SizedBox(
                width: 80,
                child: _buildBadge(
                  ach.title, 
                  ach.icon, 
                  ach.isUnlocked, 
                  ach.isUnlocked ? 'Unlocked' : '${(ach.progress * 100).toInt()}%'
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          if (lockedCount > 0)
            Center(
              child: Text(
                'Keep it up! $lockedCount more badges to unlock',
                style: const TextStyle(
                  color: StudyRepsTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1);
  }

  Widget _buildBadge(String title, String emoji, bool unlocked, String progress) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: unlocked 
                ? StudyRepsTheme.primaryIndigo.withOpacity(0.2)
                : StudyRepsTheme.bgTertiary,
            border: Border.all(
              color: unlocked 
                  ? StudyRepsTheme.primaryIndigo.withOpacity(0.5)
                  : StudyRepsTheme.borderSubtle,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: 28,
                color: unlocked ? null : Colors.grey.withOpacity(0.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: unlocked ? StudyRepsTheme.textPrimary : StudyRepsTheme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          unlocked ? 'Unlocked' : progress,
          style: TextStyle(
            color: unlocked ? StudyRepsTheme.successGreen : StudyRepsTheme.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
