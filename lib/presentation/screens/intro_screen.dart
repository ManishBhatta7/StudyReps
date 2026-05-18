import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/study_reps_theme.dart';
import 'main_navigation_shell.dart';
import 'student_onboarding_screen.dart';

/// Intro Screen - App introduction with video background
/// 
/// Showcases the app's key features with beautiful animations
class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  VideoPlayerController? _videoController;

  final List<IntroSlide> _slides = [
    IntroSlide(
      icon: Icons.play_circle_outline_rounded,
      title: 'Learn by Watching',
      subtitle: 'Swipe through bite-sized educational videos from expert creators',
      gradient: [StudyRepsTheme.primaryIndigo, StudyRepsTheme.accentCyan],
    ),
    IntroSlide(
      icon: Icons.lock_outline_rounded,
      title: 'The Lock',
      subtitle: 'Videos pause with a question. Answer correctly to unlock and continue',
      gradient: [StudyRepsTheme.primaryIndigo, Colors.purple],
    ),
    IntroSlide(
      icon: Icons.fitness_center_rounded,
      title: 'Get Your Reps In',
      subtitle: 'Build knowledge through repetition. Track your streaks and level up',
      gradient: [Colors.orange, StudyRepsTheme.errorPink],
    ),
    IntroSlide(
      icon: Icons.psychology_rounded,
      title: 'AI-Powered Feedback',
      subtitle: 'Get personalized coaching and explanations when you need help',
      gradient: [StudyRepsTheme.successGreen, StudyRepsTheme.accentCyan],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    // Using a sample loop video for background
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse('https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4'),
    );
    
    await _videoController!.initialize();
    _videoController!.setLooping(true);
    _videoController!.setVolume(0);
    _videoController!.play();
    
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const StudentOnboardingScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _skipIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainNavigationShell(initialIndex: 1), // 1 is Discover tab
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudyRepsTheme.bgPrimary,
      body: Stack(
        children: [
          // Video Background
          _buildVideoBackground(),
          
          // Gradient Overlay
          _buildGradientOverlay(),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Skip Button
                _buildSkipButton(),
                
                // Page Content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) => _buildSlide(_slides[index], index),
                  ),
                ),
                
                // Bottom Section
                _buildBottomSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoBackground() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Container(color: StudyRepsTheme.bgPrimary);
    }
    
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoController!.value.size.width,
          height: _videoController!.value.size.height,
          child: VideoPlayer(_videoController!),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            StudyRepsTheme.bgPrimary.withOpacity(0.7),
            StudyRepsTheme.bgPrimary.withOpacity(0.85),
            StudyRepsTheme.bgPrimary.withOpacity(0.95),
            StudyRepsTheme.bgPrimary,
          ],
          stops: const [0.0, 0.3, 0.6, 0.8],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextButton(
          onPressed: _skipIntro,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Skip',
                style: TextStyle(
                  color: StudyRepsTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: StudyRepsTheme.textSecondary,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildSlide(IntroSlide slide, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: slide.gradient),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: slide.gradient.first.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              slide.icon,
              color: Colors.white,
              size: 56,
            ),
          )
              .animate(delay: 200.ms)
              .scale(begin: const Offset(0.8, 0.8))
              .fadeIn(),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            slide.title,
            style: const TextStyle(
              color: StudyRepsTheme.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
          
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            slide.subtitle,
            style: const TextStyle(
              color: StudyRepsTheme.textSecondary,
              fontSize: 17,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _slides.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 32 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? StudyRepsTheme.primaryIndigo
                      : StudyRepsTheme.textMuted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Next/Get Started Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: StudyRepsTheme.primaryIndigo,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: StudyRepsTheme.primaryIndigo.withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _currentPage == _slides.length - 1
                        ? Icons.rocket_launch_rounded
                        : Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }
}

class IntroSlide {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  IntroSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}
