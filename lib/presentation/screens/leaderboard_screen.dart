import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../domain/models/leaderboard_model.dart';
import '../providers/leaderboard_provider.dart';

/// Leaderboard Screen — BoldVoice warm cream design
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String _selectedTab = 'Weekly';
  String _selectedSubject = 'Science';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudyRepsTheme.warmCream,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Header
            Text(
              'StudyReps',
              style: GoogleFonts.outfit(
                color: StudyRepsTheme.warmTextMedium,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Leaderboard',
              style: GoogleFonts.outfit(
                color: StudyRepsTheme.warmTextDark,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 20),

            // Tab Selector
            _buildTabSelector(),

            const SizedBox(height: 24),

            // Dynamic Content
            Expanded(child: _buildDynamicContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicContent() {
    final leaderAsync = ref.watch(leaderboardProvider(_selectedTab));

    return leaderAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: StudyRepsTheme.warmOrange)),
      error: (e, _) => Center(child: Text('Error loading leaderboard: $e')),
      data: (state) {
        return Column(
          children: [
            _buildPodium(state.podium),
            const SizedBox(height: 20),
            _buildSubjectFilter(),
            const SizedBox(height: 12),
            if (state.currentUser != null)
              _buildYourPosition(state.currentUser!),
            const SizedBox(height: 8),
            Expanded(child: _buildRankingsList(state.list)),
          ],
        );
      },
    );
  }

  Widget _buildTabSelector() {
    final tabs = ['Daily', 'Weekly', 'All Time'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: StudyRepsTheme.warmChipBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = tab == _selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? StudyRepsTheme.warmOrange : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    tab,
                    style: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : StudyRepsTheme.warmTextMedium,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn();
  }

  Widget _buildPodium(List<LeaderboardEntry> podiumData) {
    if (podiumData.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (podiumData.isNotEmpty)
          _buildPodiumUser(podiumData[0], 65, const Color(0xFFC0C0C0)),
        const SizedBox(width: 16),
        if (podiumData.length > 1)
          _buildPodiumUser(podiumData[1], 85, StudyRepsTheme.warmOrange),
        const SizedBox(width: 16),
        if (podiumData.length > 2)
          _buildPodiumUser(podiumData[2], 50, const Color(0xFFCD7F32)),
      ],
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.15);
  }

  Widget _buildPodiumUser(LeaderboardEntry user, double height, Color color) {
    final isFirst = user.rank == 1;

    return Column(
      children: [
        if (isFirst)
          const Text('👑', style: TextStyle(fontSize: 24))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds),

        const SizedBox(height: 6),

        Container(
          width: isFirst ? 70 : 56,
          height: isFirst ? 70 : 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
            color: StudyRepsTheme.warmCard,
          ),
          child: Center(
            child: user.avatar != null && user.avatar!.isNotEmpty
              ? Text(user.avatar!, style: TextStyle(fontSize: isFirst ? 30 : 24))
              : Icon(Icons.person_rounded, size: isFirst ? 30 : 24, color: StudyRepsTheme.warmTextLight),
          ),
        ),

        const SizedBox(height: 8),

        SizedBox(
          width: 80,
          child: Text(
            user.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: StudyRepsTheme.warmTextDark,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        Text(
          '${_formatNumber(user.xp)} XP',
          style: GoogleFonts.outfit(
            color: StudyRepsTheme.warmOrange,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                StudyRepsTheme.warmOrange.withOpacity(0.3),
                StudyRepsTheme.warmOrange.withOpacity(0.08),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: StudyRepsTheme.warmOrange.withOpacity(0.25)),
          ),
          child: Center(
            child: Text(
              '${user.rank}',
              style: GoogleFonts.outfit(
                color: StudyRepsTheme.warmOrange,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectFilter() {
    final subjects = ['Math', 'Science', 'History', 'Language', 'Coding'];

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final isSelected = subject == _selectedSubject;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedSubject = subject),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? StudyRepsTheme.warmOrange.withOpacity(0.12) : StudyRepsTheme.warmCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? StudyRepsTheme.warmOrange : StudyRepsTheme.warmBorder,
                  ),
                ),
                child: Text(
                  subject,
                  style: GoogleFonts.outfit(
                    color: isSelected ? StudyRepsTheme.warmOrange : StudyRepsTheme.warmTextMedium,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildYourPosition(LeaderboardEntry user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StudyRepsTheme.warmOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StudyRepsTheme.warmOrange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: StudyRepsTheme.warmOrange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You: #${user.rank} - ${_formatNumber(user.xp)} XP',
              style: GoogleFonts.outfit(
                color: StudyRepsTheme.warmTextDark,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '${_formatNumber(user.xp)} XP',
            style: GoogleFonts.outfit(
              color: StudyRepsTheme.warmOrange,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            user.trend == 'up' ? Icons.arrow_upward_rounded :
            user.trend == 'down' ? Icons.arrow_downward_rounded : Icons.remove_rounded,
            color: user.trend == 'up' ? StudyRepsTheme.warmGreen :
                   user.trend == 'down' ? const Color(0xFFE57373) : StudyRepsTheme.warmTextLight,
            size: 18,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.05);
  }

  Widget _buildRankingsList(List<LeaderboardEntry> leaderboardData) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: leaderboardData.length,
      itemBuilder: (context, index) {
        final user = leaderboardData[index];
        return _buildRankingItem(user, index);
      },
    );
  }

  Widget _buildRankingItem(LeaderboardEntry user, int listIndex) {
    IconData trendIcon;
    Color trendColor;

    switch (user.trend) {
      case 'up':
        trendIcon = Icons.arrow_upward_rounded;
        trendColor = StudyRepsTheme.warmGreen;
        break;
      case 'down':
        trendIcon = Icons.arrow_downward_rounded;
        trendColor = const Color(0xFFE57373);
        break;
      default:
        trendIcon = Icons.remove_rounded;
        trendColor = StudyRepsTheme.warmTextLight;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StudyRepsTheme.warmCard,
        borderRadius: BorderRadius.circular(14),
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
          SizedBox(
            width: 32,
            child: Text(
              '#${user.rank}',
              style: GoogleFonts.outfit(
                color: StudyRepsTheme.warmTextMedium,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: StudyRepsTheme.warmChipBg,
            ),
            child: Center(
              child: user.avatar != null && user.avatar!.isNotEmpty
                ? Text(user.avatar!, style: const TextStyle(fontSize: 20))
                : const Icon(Icons.person_rounded, color: StudyRepsTheme.warmTextLight, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.name,
              style: GoogleFonts.outfit(
                color: StudyRepsTheme.warmTextDark,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '${_formatNumber(user.xp)} XP',
            style: GoogleFonts.outfit(
              color: StudyRepsTheme.warmOrange,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Icon(trendIcon, color: trendColor, size: 16),
        ],
      ),
    ).animate().fadeIn(delay: (400 + listIndex * 50).ms);
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K'.replaceAll('.0K', 'K');
    }
    return number.toString();
  }
}
