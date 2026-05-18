import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'settings_screen.dart';
import '../../presentation/providers/stats_provider.dart';
import '../../domain/models/video_model.dart';
import '../providers/video_feed_provider.dart';
import '../../presentation/providers/xp_provider.dart';
import '../../presentation/providers/auth_provider.dart';
import 'squads_screen.dart';
import 'teacher_dashboard_screen.dart';
import '../../core/theme/study_reps_theme.dart';

/// Profile Stats Screen — BoldVoice-inspired premium design
///
/// Warm cream background with dark cards, orange accents,
/// circular progress rings, and clean modern typography
class ProfileStatsScreen extends ConsumerWidget {
  const ProfileStatsScreen({super.key});

  // No longer needed, using StudyRepsTheme


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardStatsAsync = ref.watch(dashboardStatsProvider);
    final tsrHealthAsync = ref.watch(tsrHealthProvider);
    final xpAsync = ref.watch(xpProvider);
    final user = ref.watch(currentDomainUserProvider);

    return Scaffold(
      backgroundColor: StudyRepsTheme.warmCream,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ─── Top Bar ───
              _buildTopBar(context),

              // ─── Profile Header ───
              xpAsync.when(
                data: (xp) => _buildProfileHeader(xp.currentLevel, xp.totalXp, xp.xpForNextLevel, user),
                loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator(color: StudyRepsTheme.warmOrange))),
                error: (_, __) => _buildProfileHeader(1, 0, 100, user),
              ),

              const SizedBox(height: 28),

              // ─── Proficiency Card (Dark) ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: tsrHealthAsync.when(
                  data: (health) => _buildProficiencyCard(health),
                  loading: () => _buildLoadingCard(),
                  error: (_, __) => _buildProficiencyCardFallback(),
                ),
              ),

              const SizedBox(height: 24),

              // ─── Stats Row ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: dashboardStatsAsync.when(
                  data: (stats) => _buildStatsRow(stats),
                  loading: () => _buildStatsRowLoading(),
                  error: (_, __) => _buildStatsRow(DashboardStats(totalReps: 0, accuracy: '0%', subjectBreakdown: {})),
                ),
              ),

              const SizedBox(height: 24),

              // ─── Study Priorities ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStudyPrioritiesSection(),
              ),

              const SizedBox(height: 24),

              // ─── Squads Hub Card ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSquadsCard(context),
              ),

              const SizedBox(height: 24),

              // ─── Teacher & Parent Dashboard ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTeacherModeCard(context),
              ),

              const SizedBox(height: 24),

              // ─── My Reps Section ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildMyRepsSection(ref),
              ),

              const SizedBox(height: 24),

              // ─── Recent Activity ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildRecentActivity(),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════
  // TOP BAR
  // ════════════════════════════════════
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Profile',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: StudyRepsTheme.warmTextDark,
              letterSpacing: -0.5,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.settings_outlined, color: StudyRepsTheme.warmTextMedium, size: 22),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ════════════════════════════════════
  // PROFILE HEADER — Avatar + Name + Level
  // ════════════════════════════════════
  Widget _buildProfileHeader(int level, int xp, int nextLevelXp, user) {
    final displayName = user?.fullName ?? user?.name ?? 'Student';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    final progress = nextLevelXp > 0 ? (xp / nextLevelXp).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Avatar with level ring
          Stack(
            alignment: Alignment.center,
            children: [
              // Progress ring
              SizedBox(
                width: 96,
                height: 96,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3.5,
                  backgroundColor: StudyRepsTheme.warmBorder,
                  valueColor: const AlwaysStoppedAnimation(StudyRepsTheme.warmOrange),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: StudyRepsTheme.warmDarkCard,
                  boxShadow: [
                    BoxShadow(
                      color: StudyRepsTheme.warmOrange.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: StudyRepsTheme.warmDarkCard,
                  backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                  child: user?.avatarUrl == null
                      ? Text(
                          initial,
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: StudyRepsTheme.warmTextOnDark,
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Name
          Text(
            displayName,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: StudyRepsTheme.warmTextDark,
            ),
          ),

          if (user?.email != null) ...[
            const SizedBox(height: 4),
            Text(
              user!.email!,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: StudyRepsTheme.warmTextLight,
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: StudyRepsTheme.warmOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded, color: StudyRepsTheme.warmOrange, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Level $level',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: StudyRepsTheme.warmOrangeDark,
                  ),
                ),
                Container(
                  width: 1,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: StudyRepsTheme.warmOrange.withOpacity(0.3),
                ),
                Text(
                  '$xp / $nextLevelXp XP',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: StudyRepsTheme.warmTextMedium,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Curriculum / Grade Badge
          if (user?.preferences?.board != null || user?.preferences?.grade != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: StudyRepsTheme.warmGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school_rounded, color: StudyRepsTheme.warmGreen, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    [user?.preferences?.board, user?.preferences?.grade]
                        .where((e) => e != null && e.isNotEmpty)
                        .join(' • '),
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: StudyRepsTheme.warmGreen,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }

  // ════════════════════════════════════
  // PROFICIENCY CARD — Dark card with circular progress
  // (Inspired by BoldVoice's 86% proficiency screen)
  // ════════════════════════════════════
  Widget _buildProficiencyCard(TSRHealthStats health) {
    Color ringColor = StudyRepsTheme.warmGreen;
    if (health.score < 50) {
      ringColor = StudyRepsTheme.warmOrange;
    } else if (health.score < 80) {
      ringColor = StudyRepsTheme.warmOrange.withOpacity(0.8);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StudyRepsTheme.warmDarkCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Study Health',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: StudyRepsTheme.warmTextMutedOnDark,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ringColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  health.status.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: ringColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Circular progress
          _CircularScoreIndicator(
            score: health.score,
            ringColor: ringColor,
          ),

          const SizedBox(height: 20),

          // Feedback text
          Text(
            health.advice.isNotEmpty
                ? health.advice
                : 'Keep up the great work! Your study consistency is paying off.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              height: 1.5,
              color: StudyRepsTheme.warmTextMutedOnDark,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.05);
  }

  Widget _buildProficiencyCardFallback() {
    return _buildProficiencyCard(
      TSRHealthStats(score: 72, status: 'Good', advice: 'Practice daily to maintain your streak and improve retention.'),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: StudyRepsTheme.warmDarkCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: StudyRepsTheme.warmOrange, strokeWidth: 2.5),
      ),
    );
  }

  // ════════════════════════════════════
  // STATS ROW — Two stat cards side by side
  // ════════════════════════════════════
  Widget _buildStatsRow(DashboardStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Total Reps',
            value: '${stats.totalReps}',
            icon: Icons.fitness_center_rounded,
            iconColor: StudyRepsTheme.warmOrange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Accuracy',
            value: stats.accuracy,
            icon: Icons.check_circle_outline_rounded,
            iconColor: StudyRepsTheme.warmGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRowLoading() {
    return Row(
      children: [
        Expanded(child: _buildStatCardSkeleton()),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCardSkeleton()),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
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
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: StudyRepsTheme.warmTextLight,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: StudyRepsTheme.warmTextDark,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildStatCardSkeleton() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(color: StudyRepsTheme.warmOrange, strokeWidth: 2),
        ),
      ),
    );
  }

  // ════════════════════════════════════
  // STUDY PRIORITIES — BoldVoice style tags
  // ════════════════════════════════════
  Widget _buildStudyPrioritiesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: StudyRepsTheme.warmOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: StudyRepsTheme.warmOrange, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                'Study Priorities',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: StudyRepsTheme.warmTextDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            'Tap on a subject to focus on it more.',
            style: GoogleFonts.outfit(fontSize: 13, color: StudyRepsTheme.warmTextLight),
          ),

          const SizedBox(height: 16),

          // Subject chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSubjectChip('Physics', Icons.bolt_rounded, true),
              _buildSubjectChip('Chemistry', Icons.science_rounded, false),
              _buildSubjectChip('Biology', Icons.biotech_rounded, false),
              _buildSubjectChip('History', Icons.history_edu_rounded, true),
              _buildSubjectChip('Math', Icons.calculate_rounded, false),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.05);
  }

  Widget _buildSubjectChip(String label, IconData icon, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? StudyRepsTheme.warmOrange.withOpacity(0.12) : StudyRepsTheme.warmChipBg,
        borderRadius: BorderRadius.circular(12),
        border: active
            ? Border.all(color: StudyRepsTheme.warmOrange.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: active ? StudyRepsTheme.warmOrange : StudyRepsTheme.warmTextMedium),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              color: active ? StudyRepsTheme.warmOrangeDark : StudyRepsTheme.warmTextMedium,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════
  // SQUADS CARD — Premium gradient
  // ════════════════════════════════════
  Widget _buildSquadsCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SquadsScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [StudyRepsTheme.warmDarkCard, Color(0xFF2A2A2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: StudyRepsTheme.warmOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.groups_rounded, color: StudyRepsTheme.warmOrange, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Study Squads',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: StudyRepsTheme.warmTextOnDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Join forces and conquer goals together!',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: StudyRepsTheme.warmTextMutedOnDark,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chevron_right_rounded, color: StudyRepsTheme.warmTextMutedOnDark, size: 20),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 350.ms, duration: 400.ms).slideY(begin: 0.05);
  }

  // ════════════════════════════════════
  // TEACHER & PARENT MODE CARD
  // ════════════════════════════════════
  Widget _buildTeacherModeCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: StudyRepsTheme.primaryPurple.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: StudyRepsTheme.primaryPurple.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: StudyRepsTheme.primaryPurple.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.school_rounded, color: StudyRepsTheme.primaryPurple, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Teacher & Parent Dashboard',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: StudyRepsTheme.warmTextDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Monitor student progress and analytics',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: StudyRepsTheme.warmTextLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: StudyRepsTheme.warmBorder,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chevron_right_rounded, color: StudyRepsTheme.warmTextMedium, size: 20),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.05);
  }

  // ════════════════════════════════════
  // MY REPS SECTION — Grouped by subject
  // ════════════════════════════════════
  Widget _buildMyRepsSection(WidgetRef ref) {
    final userVideos = ref.watch(userCreatedVideosProvider);
    if (userVideos.isEmpty) return const SizedBox.shrink();

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
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: StudyRepsTheme.warmGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.library_books_rounded, color: StudyRepsTheme.warmGreen, size: 16),
            ),
            const SizedBox(width: 10),
            Text(
              'My Reps',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: StudyRepsTheme.warmTextDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: grouped.entries.map((entry) {
                final subject = entry.key;
                final reps = entry.value;

                return Theme(
                  data: ThemeData(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: StudyRepsTheme.warmChipBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getSubjectIcon(subject),
                        color: StudyRepsTheme.warmOrange,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      subject,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: StudyRepsTheme.warmTextDark,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: StudyRepsTheme.warmChipBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${reps.length}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: StudyRepsTheme.warmTextMedium,
                        ),
                      ),
                    ),
                    children: reps.map((rep) => _buildRepTile(rep)).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildRepTile(VideoModel rep) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StudyRepsTheme.warmCream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline_rounded, color: StudyRepsTheme.warmTextLight, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rep.question.prompt,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: StudyRepsTheme.warmTextDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: StudyRepsTheme.warmGreen, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rep.question.correctAnswer,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: StudyRepsTheme.warmTextMedium,
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
      case 'biology':
        return Icons.biotech_rounded;
      case 'physics':
        return Icons.bolt_rounded;
      case 'chemistry':
        return Icons.science_rounded;
      case 'history':
        return Icons.history_edu_rounded;
      case 'math':
      case 'mathematics':
        return Icons.calculate_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  // ════════════════════════════════════
  // RECENT ACTIVITY — Clean timeline
  // ════════════════════════════════════
  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: StudyRepsTheme.warmOrange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.history_rounded, color: StudyRepsTheme.warmOrange, size: 16),
            ),
            const SizedBox(width: 10),
            Text(
              'Recent Activity',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: StudyRepsTheme.warmTextDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildActivityItem('Mastered "Newton\'s Second Law"', '2m ago', Icons.emoji_events_rounded, Colors.amber),
        _buildActivityItem('Completed Physics Quiz', '1h ago', Icons.quiz_rounded, StudyRepsTheme.warmOrange),
        _buildActivityItem('Started 7 Day Streak', '1d ago', Icons.local_fire_department_rounded, StudyRepsTheme.warmOrange),
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms);
  }

  Widget _buildActivityItem(String text, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: StudyRepsTheme.warmTextDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: StudyRepsTheme.warmTextLight,
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

// ════════════════════════════════════
// CIRCULAR SCORE INDICATOR — Custom painted ring
// Matches BoldVoice's 86% proficiency ring exactly
// ════════════════════════════════════
class _CircularScoreIndicator extends StatelessWidget {
  final int score;
  final Color ringColor;

  const _CircularScoreIndicator({
    required this.score,
    required this.ringColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: CustomPaint(
        painter: _ScoreRingPainter(
          score: score,
          ringColor: ringColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score%',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Score',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: StudyRepsTheme.warmTextMutedOnDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final int score;
  final Color ringColor;

  _ScoreRingPainter({required this.score, required this.ringColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 8.0;

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * (score / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) =>
      oldDelegate.score != score || oldDelegate.ringColor != ringColor;
}
