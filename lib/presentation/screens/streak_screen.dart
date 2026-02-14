import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/study_reps_theme.dart';

/// Streak Screen
/// 
/// Displays streak progress, calendar, daily goals, and achievements
class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: StudyRepsTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('StudyReps Streak'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Streak Hero
            _buildStreakHero(),
            
            const SizedBox(height: 32),
            
            // Calendar
            _buildCalendar(),
            
            const SizedBox(height: 32),
            
            // Daily Progress
            _buildDailyProgress(),
            
            const SizedBox(height: 32),
            
            // Achievements
            _buildAchievements(),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakHero() {
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
          child: const Center(
            child: Text(
              '🔥',
              style: TextStyle(fontSize: 60),
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.5.seconds),
        
        const SizedBox(height: 16),
        
        // Streak Count
        const Text(
          '15 Day Streak!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: StudyRepsTheme.textPrimary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Keep the flame burning! You\'re doing great.',
          style: TextStyle(
            color: StudyRepsTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildCalendar() {
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
              Icon(Icons.chevron_left_rounded, color: StudyRepsTheme.textMuted),
              const Text(
                'OCTOBER',
                style: TextStyle(
                  color: StudyRepsTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: StudyRepsTheme.textMuted),
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
            itemCount: 30,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isCompleted = day <= 15; // First 15 days completed
              final isToday = day == 15;
              
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isToday 
                      ? StudyRepsTheme.primaryIndigo 
                      : isCompleted 
                          ? StudyRepsTheme.primaryIndigo.withOpacity(0.2)
                          : Colors.transparent,
                  border: isCompleted && !isToday
                      ? null
                      : Border.all(color: StudyRepsTheme.borderSubtle),
                ),
                child: Center(
                  child: isCompleted && !isToday
                      ? Icon(
                          Icons.check_rounded,
                          color: StudyRepsTheme.primaryIndigo,
                          size: 16,
                        )
                      : Text(
                          '$day',
                          style: TextStyle(
                            color: isToday 
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
          Text(
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

  Widget _buildDailyProgress() {
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
                    value: 0.8,
                    strokeWidth: 10,
                    backgroundColor: StudyRepsTheme.bgTertiary,
                    valueColor: AlwaysStoppedAnimation(StudyRepsTheme.primaryIndigo),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: '8',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: StudyRepsTheme.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: '/10',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: StudyRepsTheme.primaryIndigo,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
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
            'Almost there! 2 more reps to hit your daily goal.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: StudyRepsTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildAchievements() {
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
                  Icon(Icons.lock_outline_rounded, size: 14, color: StudyRepsTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'Locked',
                    style: TextStyle(
                      color: StudyRepsTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBadge('First Rep', '🥉', true, '1/1'),
              _buildBadge('Week Warrior', '🛡️', true, '7/7'),
              _buildBadge('Century Club', '🏆', false, '15/100'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Keep it up! 5 more days for \'Streak Master\' badge',
            style: TextStyle(
              color: StudyRepsTheme.textMuted,
              fontSize: 12,
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
          style: TextStyle(
            color: unlocked ? StudyRepsTheme.textPrimary : StudyRepsTheme.textMuted,
            fontSize: 12,
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
