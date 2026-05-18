import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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
final onboardingBoardProvider = StateProvider<String?>((ref) => null);
final onboardingGradeProvider = StateProvider<String?>((ref) => null);

/// Student Onboarding Screen — BoldVoice warm cream design
///
/// 4 quick steps: Name → Curriculum → Subjects → Daily Goal → Done!
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
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final name = ref.read(onboardingNameProvider);
        final subjects = ref.read(onboardingSubjectsProvider);
        final goal = ref.read(onboardingGoalProvider);
        final board = ref.read(onboardingBoardProvider);
        final grade = ref.read(onboardingGradeProvider);
        
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'full_name': name.isNotEmpty ? name : null,
          'preferred_subjects': subjects,
          'daily_goal': goal,
          'board': board,
          'grade': grade,
          'has_onboarded': true,
        });
        debugPrint('\u2705 Onboarding preferences saved to Supabase');
      }
    } catch (e) {
      debugPrint('\u26a0\ufe0f Could not save onboarding prefs to Supabase: $e');
    }

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
        pageBuilder: (_, __, ___) => const MainNavigationShell(initialIndex: 1),
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
      backgroundColor: StudyRepsTheme.warmCream,
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
          
          // Warm cream overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  StudyRepsTheme.warmCream.withOpacity(0.8),
                  StudyRepsTheme.warmCream.withOpacity(0.95),
                ],
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                _buildProgressBar(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentStep = i),
                    children: [
                      _buildNameStep(),
                      _buildCurriculumStep(),
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
          if (_currentStep > 0)
            IconButton(
              onPressed: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              ),
              icon: const Icon(Icons.arrow_back_ios_rounded, color: StudyRepsTheme.warmTextMedium),
            )
          else
            const SizedBox(width: 48),
          
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentStep == i ? 32 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _currentStep >= i 
                      ? StudyRepsTheme.warmOrange 
                      : StudyRepsTheme.warmBorder,
                  borderRadius: BorderRadius.circular(5),
                ),
              )),
            ),
          ),
          
          TextButton(
            onPressed: _skipOnboarding,
            child: Text(
              'Skip',
              style: GoogleFonts.outfit(color: StudyRepsTheme.warmTextLight),
            ),
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
          
          const Text('👋', style: TextStyle(fontSize: 64))
              .animate().scale(delay: 200.ms),
          
          const SizedBox(height: 24),
          
          Text(
            "What's your name?",
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: StudyRepsTheme.warmTextDark,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms),
          
          const SizedBox(height: 12),
          
          Text(
            "Let's personalize your experience",
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: StudyRepsTheme.warmTextMedium,
            ),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 40),
          
          Container(
            decoration: BoxDecoration(
              color: StudyRepsTheme.warmCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: StudyRepsTheme.warmOrange.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: StudyRepsTheme.warmTextDark,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: GoogleFonts.outfit(
                  color: StudyRepsTheme.warmTextLight,
                  fontSize: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              ),
              onChanged: (v) => ref.read(onboardingNameProvider.notifier).state = v,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 48),
          
          _buildContinueButton(
            enabled: _nameController.text.isNotEmpty,
            label: 'Continue',
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  // STEP 2: Curriculum
  Widget _buildCurriculumStep() {
    final selectedBoard = ref.watch(onboardingBoardProvider);
    final selectedGrade = ref.watch(onboardingGradeProvider);

    final boards = ['CBSE', 'ICSE', 'IGCSE'];
    final grades = ['Grade 7', 'Grade 8', 'Grade 9'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Your Curriculum',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: StudyRepsTheme.warmTextDark,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            'So we can align your content',
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: StudyRepsTheme.warmTextMedium,
            ),
          ),
          const SizedBox(height: 32),
          
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select Board',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: StudyRepsTheme.warmTextDark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.start,
            children: boards.map((board) {
              final isSelected = selectedBoard == board;
              return GestureDetector(
                onTap: () => ref.read(onboardingBoardProvider.notifier).state = board,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? StudyRepsTheme.warmOrange : StudyRepsTheme.warmCard,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? StudyRepsTheme.warmOrange : StudyRepsTheme.warmBorder,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    board,
                    style: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : StudyRepsTheme.warmTextDark,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select Grade',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: StudyRepsTheme.warmTextDark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.start,
            children: grades.map((grade) {
              final isSelected = selectedGrade == grade;
              return GestureDetector(
                onTap: () => ref.read(onboardingGradeProvider.notifier).state = grade,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? StudyRepsTheme.warmOrange : StudyRepsTheme.warmCard,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? StudyRepsTheme.warmOrange : StudyRepsTheme.warmBorder,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    grade,
                    style: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : StudyRepsTheme.warmTextDark,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 40),
          _buildContinueButton(
            enabled: selectedBoard != null && selectedGrade != null,
            label: 'Continue',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // STEP 3: Subjects
  Widget _buildSubjectsStep() {
    final selectedSubjects = ref.watch(onboardingSubjectsProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          Text(
            'What do you want to learn?',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: StudyRepsTheme.warmTextDark,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(),
          
          const SizedBox(height: 8),
          
          Text(
            'Pick at least 3 subjects',
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: StudyRepsTheme.warmTextMedium,
            ),
          ),
          
          const SizedBox(height: 32),
          
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
                        ? StudyRepsTheme.warmOrange 
                        : StudyRepsTheme.warmCard,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected 
                          ? StudyRepsTheme.warmOrange 
                          : StudyRepsTheme.warmBorder,
                      width: 2,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: StudyRepsTheme.warmOrange.withOpacity(0.3),
                        blurRadius: 12,
                      ),
                    ] : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    subject,
                    style: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : StudyRepsTheme.warmTextDark,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 40),
          
          _buildContinueButton(
            enabled: selectedSubjects.length >= 3,
            label: 'Continue',
          ),
          
          if (selectedSubjects.length < 3) ...[
            const SizedBox(height: 12),
            Text(
              'Select ${3 - selectedSubjects.length} more',
              style: GoogleFonts.outfit(
                color: StudyRepsTheme.warmTextLight,
                fontSize: 13,
              ),
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
          
          const Text('🔥', style: TextStyle(fontSize: 64))
              .animate().scale(delay: 100.ms),
          
          const SizedBox(height: 24),
          
          Text(
            name.isNotEmpty ? 'Nice, $name!' : 'Almost done!',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: StudyRepsTheme.warmTextDark,
            ),
          ).animate().fadeIn(),
          
          const SizedBox(height: 8),
          
          Text(
            'Set your daily rep goal',
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: StudyRepsTheme.warmTextMedium,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Goal display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  StudyRepsTheme.warmOrange.withOpacity(0.12),
                  StudyRepsTheme.warmCard,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: StudyRepsTheme.warmOrange.withOpacity(0.3)),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.fitness_center_rounded, 
                        color: StudyRepsTheme.warmOrange, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      '$dailyGoal',
                      style: GoogleFonts.outfit(
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        color: StudyRepsTheme.warmTextDark,
                      ),
                    ),
                  ],
                ),
                Text(
                  'reps per day',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    color: StudyRepsTheme.warmTextMedium,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
          
          const SizedBox(height: 32),
          
          // Goal slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: StudyRepsTheme.warmOrange,
              inactiveTrackColor: StudyRepsTheme.warmBorder,
              thumbColor: StudyRepsTheme.warmOrange,
              overlayColor: StudyRepsTheme.warmOrange.withOpacity(0.2),
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
          style: GoogleFonts.outfit(
            color: isActive ? StudyRepsTheme.warmOrange : StudyRepsTheme.warmTextLight,
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
              ? StudyRepsTheme.warmOrange 
              : StudyRepsTheme.warmBorder,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: enabled ? 4 : 0,
          shadowColor: StudyRepsTheme.warmOrange.withOpacity(0.4),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: enabled ? Colors.white : StudyRepsTheme.warmTextLight,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}
