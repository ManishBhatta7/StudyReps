import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../domain/models/achievement_model.dart';
import '../providers/achievement_provider.dart';
import '../providers/streak_provider.dart';

/// Streak Screen — BoldVoice warm cream design
///
/// Warm cream background, white cards, orange accents
class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);
    final achAsync = ref.watch(achievementProvider);

    return Scaffold(
      backgroundColor: StudyRepsTheme.warmCream,
      body: SafeArea(
        child: streakAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: StudyRepsTheme.warmOrange)),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (streakData) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Title
                  Row(
                    children: [
                      Text(
                        'Streak',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: StudyRepsTheme.warmTextDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 24),

                  // Streak Hero
                  _buildStreakHero(streakData.currentStreak),

                  const SizedBox(height: 28),

                  // Calendar
                  _buildCalendar(streakData.completedDays),

                  const SizedBox(height: 24),

                  // Daily Progress
                  _buildDailyProgress(streakData.todayReps),

                  const SizedBox(height: 24),

                  // Achievements
                  achAsync.when(
                    data: (achievements) => _buildAchievements(achievements),
                    loading: () => const CircularProgressIndicator(color: StudyRepsTheme.warmOrange),
                    error: (e, _) => const SizedBox(),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStreakHero(int currentStreak) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: StudyRepsTheme.warmDarkCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Fire Icon
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  StudyRepsTheme.warmOrange.withOpacity(0.25),
                  Colors.transparent,
                ],
              ),
            ),
            child: Center(
              child: Text(
                currentStreak > 0 ? '🔥' : '🧊',
                style: const TextStyle(fontSize: 52),
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.5.seconds),

          const SizedBox(height: 12),

          // Streak Count
          Text(
            '$currentStreak Day Streak!',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: StudyRepsTheme.warmTextOnDark,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            currentStreak > 0
              ? 'Keep the flame burning! You\'re doing great.'
              : 'Get started with a rep to ignite your flame!',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: StudyRepsTheme.warmTextMutedOnDark,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildCalendar(List<DateTime> completedDays) {
    final now = DateTime.now();
    final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final Set<int> completedDaysThisMonth = completedDays
        .where((d) => d.year == now.year && d.month == now.month)
        .map((d) => d.day)
        .toSet();

    const monthNames = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StudyRepsTheme.warmCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.chevron_left_rounded, color: StudyRepsTheme.warmTextLight),
              Text(
                monthNames[now.month - 1],
                style: GoogleFonts.outfit(
                  color: StudyRepsTheme.warmTextDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: StudyRepsTheme.warmTextLight),
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
                      ? StudyRepsTheme.warmOrange
                      : isCompleted
                          ? StudyRepsTheme.warmOrange.withOpacity(0.15)
                          : isToday
                              ? StudyRepsTheme.warmChipBg
                              : Colors.transparent,
                  border: isCompleted && !isToday
                      ? null
                      : Border.all(color: StudyRepsTheme.warmBorder),
                ),
                child: Center(
                  child: isCompleted && !isToday
                      ? const Icon(
                          Icons.check_rounded,
                          color: StudyRepsTheme.warmOrange,
                          size: 16,
                        )
                      : Text(
                          '$day',
                          style: GoogleFonts.outfit(
                            color: isToday && isCompleted
                                ? Colors.white
                                : StudyRepsTheme.warmTextMedium,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          Text(
            'TODAY',
            style: GoogleFonts.outfit(
              color: StudyRepsTheme.warmTextLight,
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05);
  }

  Widget _buildDailyProgress(int todayReps) {
    const int dailyGoal = 10;
    final double progress = todayReps / dailyGoal;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StudyRepsTheme.warmCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Daily Progress',
            style: GoogleFonts.outfit(
              color: StudyRepsTheme.warmTextDark,
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
                    backgroundColor: StudyRepsTheme.warmBorder,
                    valueColor: const AlwaysStoppedAnimation(StudyRepsTheme.warmOrange),
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
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: StudyRepsTheme.warmTextDark,
                            ),
                          ),
                          TextSpan(
                            text: '/$dailyGoal',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: StudyRepsTheme.warmOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Reps',
                      style: GoogleFonts.outfit(
                        color: StudyRepsTheme.warmTextLight,
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
            style: GoogleFonts.outfit(
              color: StudyRepsTheme.warmTextMedium,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05);
  }

  Widget _buildAchievements(List<AchievementModel> achievements) {
    final lockedCount = achievements.where((a) => !a.isUnlocked).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StudyRepsTheme.warmCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievement Badges',
                style: GoogleFonts.outfit(
                  color: StudyRepsTheme.warmTextDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 14, color: StudyRepsTheme.warmTextLight),
                  const SizedBox(width: 4),
                  Text(
                    'Unlocked ${achievements.length - lockedCount}/${achievements.length}',
                    style: GoogleFonts.outfit(
                      color: StudyRepsTheme.warmTextLight,
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
                style: GoogleFonts.outfit(
                  color: StudyRepsTheme.warmTextLight,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.05);
  }

  Widget _buildBadge(String title, String emoji, bool unlocked, String progress) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: unlocked
                ? StudyRepsTheme.warmOrange.withOpacity(0.12)
                : StudyRepsTheme.warmChipBg,
            border: Border.all(
              color: unlocked
                  ? StudyRepsTheme.warmOrange.withOpacity(0.4)
                  : StudyRepsTheme.warmBorder,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: 26,
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
          style: GoogleFonts.outfit(
            color: unlocked ? StudyRepsTheme.warmTextDark : StudyRepsTheme.warmTextLight,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          unlocked ? 'Unlocked' : progress,
          style: GoogleFonts.outfit(
            color: unlocked ? StudyRepsTheme.warmGreen : StudyRepsTheme.warmTextLight,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
