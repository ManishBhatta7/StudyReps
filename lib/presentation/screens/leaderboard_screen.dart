import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../domain/models/leaderboard_model.dart';
import '../providers/leaderboard_provider.dart';

/// Leaderboard Screen
/// 
/// Shows competitive rankings with podium, filters, and your position
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
      backgroundColor: StudyRepsTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Header
            const Text(
              'StudyReps',
              style: TextStyle(
                color: StudyRepsTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              'Leaderboard',
              style: TextStyle(
                color: StudyRepsTheme.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Tab Selector
            _buildTabSelector(),
            
            const SizedBox(height: 24),
            
            // Dynamic Content
            Expanded(
              child: _buildDynamicContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicContent() {
    final leaderAsync = ref.watch(leaderboardProvider(_selectedTab));

    return leaderAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error loading leaderboard: $e")),
      data: (state) {
        return Column(
          children: [
            // Podium
            _buildPodium(state.podium),
            
            const SizedBox(height: 20),
            
            // Subject Filter
            _buildSubjectFilter(),
            
            const SizedBox(height: 12),
            
            // Your Position
            if (state.currentUser != null) 
              _buildYourPosition(state.currentUser!),
            
            const SizedBox(height: 8),
            
            // Rankings List
            Expanded(
              child: _buildRankingsList(state.list),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabSelector() {
    final tabs = ['Daily', 'Weekly', 'All Time'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: tabs.map((tab) {
        final isSelected = tab == _selectedTab;
        return GestureDetector(
          onTap: () => setState(() => _selectedTab = tab),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Text(
                  tab,
                  style: TextStyle(
                    color: isSelected 
                        ? StudyRepsTheme.primaryIndigo 
                        : StudyRepsTheme.textMuted,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 40 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: StudyRepsTheme.primaryIndigo,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn();
  }

  Widget _buildPodium(List<LeaderboardEntry> podiumData) {
    if (podiumData.isEmpty) return const SizedBox.shrink();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd Place
        if (podiumData.length > 0)
          _buildPodiumUser(podiumData[0], 65, Colors.grey.shade400),
        
        const SizedBox(width: 16),
        
        // 1st Place
        if (podiumData.length > 1)
          _buildPodiumUser(podiumData[1], 85, Colors.amber),
        
        const SizedBox(width: 16),
        
        // 3rd Place
        if (podiumData.length > 2)
          _buildPodiumUser(podiumData[2], 50, Colors.brown.shade300),
      ],
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.15);
  }

  Widget _buildPodiumUser(LeaderboardEntry user, double height, Color color) {
    final isFirst = user.rank == 1;
    
    return Column(
      children: [
        // Crown for 1st place
        if (isFirst)
          const Text('👑', style: TextStyle(fontSize: 24))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds),
        
        const SizedBox(height: 6),
        
        // Avatar
        Container(
          width: isFirst ? 70 : 56,
          height: isFirst ? 70 : 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
            color: StudyRepsTheme.bgSecondary,
          ),
          child: Center(
            child: user.avatar != null && user.avatar!.isNotEmpty
              ? Text(user.avatar!, style: TextStyle(fontSize: isFirst ? 30 : 24))
              : Icon(
                  Icons.person_rounded,
                  size: isFirst ? 30 : 24,
                  color: StudyRepsTheme.textMuted,
                ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Name
        SizedBox(
          width: 80,
          child: Text(
            user.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: StudyRepsTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // XP
        Text(
          '${_formatNumber(user.xp)} XP',
          style: TextStyle(
            color: StudyRepsTheme.primaryIndigo,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        
        const SizedBox(height: 10),
        
        // Podium block
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                StudyRepsTheme.primaryIndigo.withOpacity(0.4),
                StudyRepsTheme.primaryIndigo.withOpacity(0.1),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: StudyRepsTheme.primaryIndigo.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              '${user.rank}',
              style: TextStyle(
                color: StudyRepsTheme.primaryIndigo,
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
                  color: isSelected 
                      ? StudyRepsTheme.bgTertiary 
                      : StudyRepsTheme.bgSecondary,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected 
                        ? StudyRepsTheme.textSecondary 
                        : StudyRepsTheme.borderSubtle,
                  ),
                ),
                child: Text(
                  subject,
                  style: TextStyle(
                    color: isSelected 
                        ? StudyRepsTheme.textPrimary 
                        : StudyRepsTheme.textMuted,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
        color: StudyRepsTheme.primaryIndigo.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StudyRepsTheme.primaryIndigo.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // Rank Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: StudyRepsTheme.primaryIndigo,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Info
          Expanded(
            child: Text(
              'You: #${user.rank} - ${_formatNumber(user.xp)} XP',
              style: const TextStyle(
                color: StudyRepsTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          
          // XP
          Text(
            '${_formatNumber(user.xp)} XP',
            style: TextStyle(
              color: StudyRepsTheme.primaryIndigoLight,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Trend
          Icon(
            user.trend == 'up' ? Icons.arrow_upward_rounded : 
            user.trend == 'down' ? Icons.arrow_downward_rounded : Icons.remove_rounded,
            color: user.trend == 'up' ? StudyRepsTheme.successGreen : 
                   user.trend == 'down' ? StudyRepsTheme.errorPink : StudyRepsTheme.textMuted,
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
        trendColor = StudyRepsTheme.successGreen;
        break;
      case 'down':
        trendIcon = Icons.arrow_downward_rounded;
        trendColor = StudyRepsTheme.errorPink;
        break;
      default:
        trendIcon = Icons.remove_rounded;
        trendColor = StudyRepsTheme.textMuted;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StudyRepsTheme.borderSubtle),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 32,
            child: Text(
              '#${user.rank}',
              style: const TextStyle(
                color: StudyRepsTheme.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: StudyRepsTheme.bgTertiary,
            ),
            child: Center(
              child: user.avatar != null && user.avatar!.isNotEmpty
                ? Text(user.avatar!, style: const TextStyle(fontSize: 20))
                : Icon(
                    Icons.person_rounded,
                    color: StudyRepsTheme.textMuted,
                    size: 20,
                  ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Name
          Expanded(
            child: Text(
              user.name,
              style: const TextStyle(
                color: StudyRepsTheme.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          
          // XP
          Text(
            '${_formatNumber(user.xp)} XP',
            style: TextStyle(
              color: StudyRepsTheme.primaryIndigoLight,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Trend
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
