import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/study_reps_theme.dart';
import '../providers/auth_provider.dart';
import 'main_navigation_shell.dart';

/// Login Screen - Beautiful login with video background
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isSignUp = false;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
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
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    if (_isSignUp && _nameController.text.isEmpty) {
      _showSnackBar('Please enter your name');
      return;
    }
    
    final authController = ref.read(authControllerProvider.notifier);
    final success = _isSignUp
        ? await authController.signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            fullName: _nameController.text.trim(),
          )
        : await authController.signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

    if (success && mounted) {
      if (_isSignUp) {
         _showSnackBar('Account created! Please check your email.', isError: false);
         // You could also auto-login some users here if email confirmation is disabled
         // For now, if we assume they need to verify, we don't skip.
      } else {
         _skipLogin();
      }
    } else {
      final error = ref.read(authErrorProvider);
      if (error != null) {
        _showSnackBar(error);
      }
    }
  }

  bool _isGoogleLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    
    try {
      final authController = ref.read(authControllerProvider.notifier);
      final success = await authController.signInWithGoogle();
      
      if (success && mounted) {
        _skipLogin();
      } else if (mounted) {
        final error = ref.read(authErrorProvider);
        if (error != null) {
          _showSnackBar(error);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Google Sign-In failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? StudyRepsTheme.errorPink : StudyRepsTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  void _skipLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainNavigationShell(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isAuthLoadingProvider);

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  
                  // Logo & Title
                  _buildHeader(),
                  
                  const SizedBox(height: 48),
                  
                  // Login Form Card
                  _buildFormCard(isLoading),
                  
                  const SizedBox(height: 24),
                  
                  // Social Login
                  _buildSocialLogin(),
                  
                  const SizedBox(height: 32),
                  
                  // Skip for now
                  _buildSkipButton(),
                ],
              ),
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
            StudyRepsTheme.bgPrimary.withOpacity(0.6),
            StudyRepsTheme.bgPrimary.withOpacity(0.85),
            StudyRepsTheme.bgPrimary.withOpacity(0.95),
            StudyRepsTheme.bgPrimary,
          ],
          stops: const [0.0, 0.3, 0.5, 0.7],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: StudyRepsTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: StudyRepsTheme.primaryIndigo.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'StudyReps',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: StudyRepsTheme.textPrimary,
                letterSpacing: -1,
              ),
            ),
          ],
        ).animate().fadeIn().slideX(begin: -0.1),
        
        const SizedBox(height: 24),
        
        // Welcome text
        Text(
          _isSignUp ? 'Create Account' : 'Welcome back,',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: StudyRepsTheme.textPrimary,
            letterSpacing: -1,
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
        
        const SizedBox(height: 8),
        
        Text(
          _isSignUp 
              ? 'Join thousands of learners getting their reps in'
              : 'Ready to get your reps in?',
          style: TextStyle(
            fontSize: 16,
            color: StudyRepsTheme.textSecondary,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildFormCard(bool isLoading) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: StudyRepsTheme.bgSecondary.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: StudyRepsTheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field (only for sign up)
              if (_isSignUp) ...[
                _buildTextField(
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
              ],
              
              // Email Field
              _buildTextField(
                label: 'Email',
                icon: Icons.email_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 16),
              
              // Password Field
              _buildTextField(
                label: 'Password',
                icon: Icons.lock_outline_rounded,
                controller: _passwordController,
                isPassword: true,
              ),
              
              if (!_isSignUp) ...[
                const SizedBox(height: 12),
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: StudyRepsTheme.primaryIndigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Login/Sign Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StudyRepsTheme.primaryIndigo,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 8,
                    shadowColor: StudyRepsTheme.primaryIndigo.withOpacity(0.4),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isSignUp ? 'Create Account' : 'Log In',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Toggle Sign Up / Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isSignUp ? 'Already have an account?' : "Don't have an account?",
                    style: TextStyle(color: StudyRepsTheme.textSecondary),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(
                      _isSignUp ? 'Log In' : 'Sign Up',
                      style: TextStyle(
                        color: StudyRepsTheme.primaryIndigo,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: StudyRepsTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: StudyRepsTheme.bgTertiary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: StudyRepsTheme.borderSubtle),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !_isPasswordVisible,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: StudyRepsTheme.textPrimary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: StudyRepsTheme.textMuted, size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: StudyRepsTheme.textMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintText: 'Enter your $label',
              hintStyle: TextStyle(color: StudyRepsTheme.textMuted),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: StudyRepsTheme.borderSubtle)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or continue with',
                style: TextStyle(
                  color: StudyRepsTheme.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(child: Divider(color: StudyRepsTheme.borderSubtle)),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Google Sign-In — Primary Social Button
        _buildGoogleButton(),
        
        const SizedBox(height: 12),
        
        // Apple Sign-In — Secondary
        _buildSocialButton('Apple', Icons.apple_rounded, onPressed: () {
          _showSnackBar('Apple Sign-In coming soon!', isError: false);
        }),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  /// Premium Google Sign-In button with official styling
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: _isGoogleLoading
                ? StudyRepsTheme.borderSubtle
                : const Color(0xFF4285F4).withOpacity(0.5),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: StudyRepsTheme.bgSecondary.withOpacity(0.7),
        ),
        child: _isGoogleLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Color(0xFF4285F4),
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google "G" logo colors
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        'G',
                        style: TextStyle(
                          color: Color(0xFF4285F4),
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      color: StudyRepsTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon, {VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed ?? () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: StudyRepsTheme.borderSubtle),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: StudyRepsTheme.bgSecondary.withOpacity(0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: StudyRepsTheme.textPrimary, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: StudyRepsTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Center(
      child: TextButton(
        onPressed: _skipLogin,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Skip for now',
              style: TextStyle(
                color: StudyRepsTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_rounded,
              color: StudyRepsTheme.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}
