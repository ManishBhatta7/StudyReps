import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/study_reps_theme.dart';
import 'main_navigation_shell.dart';
import 'login_screen.dart';

// Onboarding state providers
final onboardingNameProvider = StateProvider<String>((ref) => '');
final onboardingSubjectsProvider = StateProvider<List<String>>((ref) => []);
final onboardingGoalProvider = StateProvider<int>((ref) => 10);

/// Student Onboarding Screen - Interactive & Concise
/// 
/// 3 quick steps: Name → Subjects → Daily Goal → Done!
class StudentOnboardingScreen extends ConsumerStatefulWidget {
  const StudentOnboardingScreen({super.key});

  @override
  ConsumerState<StudentOnboardingScreen> createState() => _StudentOnboardingScreenState();
}

class _StudentOnboardingScreenState extends ConsumerState<StudentOnboardingScreen> {
  late PageController _pageController;
  int _currentStep = 0;
  final _nameController = TextEditingController();
  VideoPlayerController? _videoController;

  final List<String> _allSubjects = [
    '📐 Mathematics',
    '🔬 Physics', 
    '🧪 Chemistry',
    '🧬 Biology',
    '📚 Literature',
    '🌍 Geography',
    '📜 History',
    '💻 Computer Science',
    '🎨 Art',
    '🎵 Music',
    '🗣️ Languages',
    '💰 Economics',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
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
    _nameController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    // 1. Mark onboarding as complete in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);

    // 2. Try to save preferences to Supabase if user is logged in
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final name = ref.read(onboardingNameProvider);
        final subjects = ref.read(onboardingSubjectsProvider);
        final goal = ref.read(onboardingGoalProvider);
        
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'full_name': name.isNotEmpty ? name : null,
          'preferred_subjects': subjects,
          'daily_goal': goal,
          'has_onboarded': true,
        });
        debugPrint('\u2705 Onboarding preferences saved to Supabase');
      }
    } catch (e) {
      debugPrint('\u26a0\ufe0f Could not save onboarding prefs to Supabase: $e');
      // Non-blocking — prefs are saved locally anyway
    }

    // 3. Navigate to login
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _skipOnboarding() async {
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
          if (_videoController != null && _videoController!.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),
          
          // Dark overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  StudyRepsTheme.bgPrimary.withOpacity(0.8),
                  StudyRepsTheme.bgPrimary.withOpacity(0.95),
                ],
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Progress indicator
                _buildProgressBar(),
                
                // Steps
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentStep = i),
                    children: [
                      _buildNameStep(),
                      _buildSubjectsStep(),
                      _buildGoalStep(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back button
          if (_currentStep > 0)
            IconButton(
              onPressed: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              ),
              icon: const Icon(Icons.arrow_back_ios_rounded, color: StudyRepsTheme.textSecondary),
            )
          else
            const SizedBox(width: 48),
          
          // Progress dots
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentStep == i ? 32 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _currentStep >= i 
                      ? StudyRepsTheme.primaryIndigo 
                      : StudyRepsTheme.bgTertiary,
                  borderRadius: BorderRadius.circular(5),
                ),
              )),
            ),
          ),
          
          // Skip
          TextButton(
            onPressed: _skipOnboarding,
            child: const Text('Skip', style: TextStyle(color: StudyRepsTheme.textMuted)),
          ),
        ],
      ),
    );
  }

  // STEP 1: Name
  Widget _buildNameStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          // Emoji
          const Text('👋', style: TextStyle(fontSize: 64))
              .animate().scale(delay: 200.ms),
          
          const SizedBox(height: 24),
          
          // Title
          const Text(
            "What's your name?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: StudyRepsTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms),
          
          const SizedBox(height: 12),
          
          const Text(
            "Let's personalize your experience",
            style: TextStyle(
              fontSize: 16,
              color: StudyRepsTheme.textSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 40),
          
          // Name input
          Container(
            decoration: BoxDecoration(
              color: StudyRepsTheme.bgSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: StudyRepsTheme.primaryIndigo.withOpacity(0.5)),
            ),
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: StudyRepsTheme.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Enter your name',
                hintStyle: TextStyle(color: StudyRepsTheme.textMuted, fontSize: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              ),
              onChanged: (v) => ref.read(onboardingNameProvider.notifier).state = v,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 48),
          
          // Continue button
          _buildContinueButton(
            enabled: _nameController.text.isNotEmpty,
            label: 'Continue',
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  // STEP 2: Subjects
  Widget _buildSubjectsStep() {
    final selectedSubjects = ref.watch(onboardingSubjectsProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Title
          const Text(
            'What do you want to learn?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: StudyRepsTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(),
          
          const SizedBox(height: 8),
          
          const Text(
            'Pick at least 3 subjects',
            style: TextStyle(
              fontSize: 15,
              color: StudyRepsTheme.textSecondary,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Subjects grid
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _allSubjects.map((subject) {
              final isSelected = selectedSubjects.contains(subject);
              return GestureDetector(
                onTap: () {
                  final current = ref.read(onboardingSubjectsProvider);
                  if (isSelected) {
                    ref.read(onboardingSubjectsProvider.notifier).state = 
                        current.where((s) => s != subject).toList();
                  } else {
                    ref.read(onboardingSubjectsProvider.notifier).state = 
                        [...current, subject];
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? StudyRepsTheme.primaryIndigo 
                        : StudyRepsTheme.bgSecondary,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected 
                          ? StudyRepsTheme.primaryIndigo 
                          : StudyRepsTheme.borderSubtle,
                      width: 2,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: StudyRepsTheme.primaryIndigo.withOpacity(0.3),
                        blurRadius: 12,
                      ),
                    ] : null,
                  ),
                  child: Text(
                    subject,
                    style: TextStyle(
                      color: isSelected ? Colors.white : StudyRepsTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 40),
          
          // Continue
          _buildContinueButton(
            enabled: selectedSubjects.length >= 3,
            label: 'Continue',
          ),
          
          if (selectedSubjects.length < 3) ...[
            const SizedBox(height: 12),
            Text(
              'Select ${3 - selectedSubjects.length} more',
              style: const TextStyle(color: StudyRepsTheme.textMuted, fontSize: 13),
            ),
          ],
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // STEP 3: Daily Goal
  Widget _buildGoalStep() {
    final dailyGoal = ref.watch(onboardingGoalProvider);
    final name = ref.watch(onboardingNameProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Fire emoji
          const Text('🔥', style: TextStyle(fontSize: 64))
              .animate().scale(delay: 100.ms),
          
          const SizedBox(height: 24),
          
          Text(
            name.isNotEmpty ? 'Nice, $name!' : 'Almost done!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: StudyRepsTheme.textPrimary,
            ),
          ).animate().fadeIn(),
          
          const SizedBox(height: 8),
          
          const Text(
            'Set your daily rep goal',
            style: TextStyle(
              fontSize: 16,
              color: StudyRepsTheme.textSecondary,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Goal display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  StudyRepsTheme.primaryIndigo.withOpacity(0.2),
                  StudyRepsTheme.bgSecondary,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: StudyRepsTheme.primaryIndigo.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.fitness_center_rounded, 
                        color: StudyRepsTheme.primaryIndigo, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      '$dailyGoal',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        color: StudyRepsTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'reps per day',
                  style: TextStyle(
                    fontSize: 18,
                    color: StudyRepsTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
          
          const SizedBox(height: 32),
          
          // Goal slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: StudyRepsTheme.primaryIndigo,
              inactiveTrackColor: StudyRepsTheme.bgTertiary,
              thumbColor: StudyRepsTheme.primaryIndigo,
              overlayColor: StudyRepsTheme.primaryIndigo.withOpacity(0.2),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: dailyGoal.toDouble(),
              min: 5,
              max: 30,
              divisions: 5,
              onChanged: (v) => ref.read(onboardingGoalProvider.notifier).state = v.round(),
            ),
          ),
          
          // Goal labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGoalLabel('Casual', '5', dailyGoal <= 10),
              _buildGoalLabel('Regular', '15', dailyGoal > 10 && dailyGoal <= 20),
              _buildGoalLabel('Intense', '30', dailyGoal > 20),
            ],
          ),
          
          const SizedBox(height: 48),
          
          // Start button
          _buildContinueButton(
            enabled: true,
            label: "Let's Go! 🚀",
            isPrimary: true,
          ).animate().fadeIn(delay: 400.ms),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGoalLabel(String label, String value, bool isActive) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isActive ? StudyRepsTheme.primaryIndigo : StudyRepsTheme.textMuted,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton({
    required bool enabled,
    required String label,
    bool isPrimary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? _nextStep : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled 
              ? StudyRepsTheme.primaryIndigo 
              : StudyRepsTheme.bgTertiary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: enabled ? 8 : 0,
          shadowColor: StudyRepsTheme.primaryIndigo.withOpacity(0.4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: enabled ? Colors.white : StudyRepsTheme.textMuted,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}
