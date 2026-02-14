import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/study_reps_theme.dart';
import 'swipe_gated_feed_screen.dart';
import 'discover_screen.dart';
import 'streak_screen.dart';
import 'profile_stats_screen.dart';
import 'leaderboard_screen.dart';

/// Main Navigation Shell
/// 
/// Bottom navigation wrapper for all main screens
class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const SwipeGatedFeedScreen(),
    const DiscoverScreen(),
    const SizedBox(), // Placeholder for Create button (opens modal)
    const StreakScreen(),
    const ProfileStatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex, // Skip create index
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgSecondary,
        border: Border(
          top: BorderSide(color: StudyRepsTheme.borderSubtle),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.explore_rounded, 'Discover'),
              _buildCreateButton(),
              _buildNavItem(3, Icons.local_fire_department_rounded, 'Streak'),
              _buildNavItem(4, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? StudyRepsTheme.primaryIndigo.withOpacity(0.15) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? StudyRepsTheme.primaryIndigo 
                  : StudyRepsTheme.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? StudyRepsTheme.primaryIndigo 
                    : StudyRepsTheme.textMuted,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showCreateBottomSheet();
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: StudyRepsTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: StudyRepsTheme.primaryIndigo.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  void _showCreateBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: StudyRepsTheme.bgSecondary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: StudyRepsTheme.borderSubtle),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: StudyRepsTheme.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Create Rep',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: StudyRepsTheme.textPrimary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Share your knowledge with the community',
              style: TextStyle(
                color: StudyRepsTheme.textSecondary,
              ),
            ),
            
            const SizedBox(height: 28),
            
            // Options
            _CreateOption(
              icon: Icons.videocam_rounded,
              title: 'Record Video',
              subtitle: 'Create a new educational video',
              color: StudyRepsTheme.primaryIndigo,
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to video recording
              },
            ),
            
            const SizedBox(height: 12),
            
            _CreateOption(
              icon: Icons.upload_rounded,
              title: 'Upload Video',
              subtitle: 'Add a video from your gallery',
              color: StudyRepsTheme.accentCyan,
              onTap: () {
                Navigator.pop(context);
                // TODO: Open gallery picker
              },
            ),
            
            const SizedBox(height: 12),
            
            _CreateOption(
              icon: Icons.quiz_rounded,
              title: 'Create Question',
              subtitle: 'Add a question to existing content',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to question creator
              },
            ),
            
            const SizedBox(height: 12),
            
            _CreateOption(
              icon: Icons.leaderboard_rounded,
              title: 'View Leaderboard',
              subtitle: 'See how you rank against others',
              color: StudyRepsTheme.successGreen,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                );
              },
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CreateOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _CreateOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: StudyRepsTheme.bgTertiary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: StudyRepsTheme.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: StudyRepsTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: StudyRepsTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: StudyRepsTheme.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
