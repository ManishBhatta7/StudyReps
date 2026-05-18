import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/study_reps_theme.dart';
import '../providers/auth_provider.dart';
import 'main_navigation_shell.dart';

/// Login Screen — BoldVoice warm cream design with video background
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
          content: Text(message, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          backgroundColor: isError ? const Color(0xFFE57373) : StudyRepsTheme.warmGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  void _skipLogin() {
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
    final isLoading = ref.watch(isAuthLoadingProvider);

    return Scaffold(
      backgroundColor: StudyRepsTheme.warmCream,
      body: Stack(
        children: [
          // Video Background
          _buildVideoBackground(),
          
          // Gradient Overlay — warm cream
          _buildGradientOverlay(),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 48),
                  _buildFormCard(isLoading),
                  const SizedBox(height: 24),
                  _buildSocialLogin(),
                  const SizedBox(height: 32),
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
      return Container(color: StudyRepsTheme.warmCream);
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
            StudyRepsTheme.warmCream.withOpacity(0.5),
            StudyRepsTheme.warmCream.withOpacity(0.8),
            StudyRepsTheme.warmCream.withOpacity(0.95),
            StudyRepsTheme.warmCream,
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
                gradient: const LinearGradient(
                  colors: [StudyRepsTheme.warmOrange, StudyRepsTheme.warmOrangeDark],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: StudyRepsTheme.warmOrange.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Text(
              'StudyReps',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: StudyRepsTheme.warmTextDark,
                letterSpacing: -1,
              ),
            ),
          ],
        ).animate().fadeIn().slideX(begin: -0.1),
        
        const SizedBox(height: 24),
        
        Text(
          _isSignUp ? 'Create Account' : 'Welcome back,',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: StudyRepsTheme.warmTextDark,
            letterSpacing: -1,
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
        
        const SizedBox(height: 8),
        
        Text(
          _isSignUp 
              ? 'Join thousands of learners getting their reps in'
              : 'Ready to get your reps in?',
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: StudyRepsTheme.warmTextMedium,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildFormCard(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StudyRepsTheme.warmCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isSignUp) ...[
            _buildTextField(
              label: 'Full Name',
              icon: Icons.person_outline_rounded,
              controller: _nameController,
            ),
            const SizedBox(height: 16),
          ],
          
          _buildTextField(
            label: 'Email',
            icon: Icons.email_outlined,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          
          const SizedBox(height: 16),
          
          _buildTextField(
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            controller: _passwordController,
            isPassword: true,
          ),
          
          if (!_isSignUp) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.outfit(
                    color: StudyRepsTheme.warmOrange,
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
                backgroundColor: StudyRepsTheme.warmOrange,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
                shadowColor: StudyRepsTheme.warmOrange.withOpacity(0.4),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _isSignUp ? 'Create Account' : 'Log In',
                      style: GoogleFonts.outfit(
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
                style: GoogleFonts.outfit(color: StudyRepsTheme.warmTextMedium),
              ),
              TextButton(
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(
                  _isSignUp ? 'Log In' : 'Sign Up',
                  style: GoogleFonts.outfit(
                    color: StudyRepsTheme.warmOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
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
          style: GoogleFonts.outfit(
            color: StudyRepsTheme.warmTextMedium,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: StudyRepsTheme.warmBorder.withOpacity(0.8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !_isPasswordVisible,
            keyboardType: keyboardType,
            style: GoogleFonts.outfit(
              color: StudyRepsTheme.warmTextDark, // Ensure high contrast
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: false, // Override theme's dark fill
              prefixIcon: Icon(icon, color: StudyRepsTheme.warmTextMedium, size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: StudyRepsTheme.warmTextMedium,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintText: 'Enter your $label',
              hintStyle: GoogleFonts.outfit(
                color: StudyRepsTheme.warmTextLight.withOpacity(0.7),
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: StudyRepsTheme.warmBorder)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or continue with',
                style: GoogleFonts.outfit(
                  color: StudyRepsTheme.warmTextLight,
                  fontSize: 13,
                ),
              ),
            ),
            const Expanded(child: Divider(color: StudyRepsTheme.warmBorder)),
          ],
        ),
        
        const SizedBox(height: 20),
        
        _buildGoogleButton(),
        
        const SizedBox(height: 12),
        
        _buildSocialButton('Apple', Icons.apple_rounded, onPressed: () {
          _showSnackBar('Apple Sign-In coming soon!', isError: false);
        }),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: _isGoogleLoading
                ? StudyRepsTheme.warmBorder
                : const Color(0xFF4285F4).withOpacity(0.5),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: StudyRepsTheme.warmCard,
        ),
        child: _isGoogleLoading
            ? const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(color: Color(0xFF4285F4), strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24, height: 24,
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
                  Text(
                    'Continue with Google',
                    style: GoogleFonts.outfit(
                      color: StudyRepsTheme.warmTextDark,
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
          side: const BorderSide(color: StudyRepsTheme.warmBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: StudyRepsTheme.warmCard,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: StudyRepsTheme.warmTextDark, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: StudyRepsTheme.warmTextDark,
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
              style: GoogleFonts.outfit(
                color: StudyRepsTheme.warmTextLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_forward_rounded,
              color: StudyRepsTheme.warmTextLight,
              size: 18,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}
