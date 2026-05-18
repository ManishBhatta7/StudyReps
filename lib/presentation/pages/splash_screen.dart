import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/study_reps_theme.dart';

/// Splash Screen - Shown while checking auth state
///
/// Displays a loading spinner with branding while the app
/// determines if the user is logged in.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudyRepsTheme.warmCream,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: StudyRepsTheme.warmOrange,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: StudyRepsTheme.warmOrange.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_stories,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 32),
            
            // App Name
            Text(
              'StudyReps',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: StudyRepsTheme.warmTextDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Repetition for Retention',
              style: TextStyle(
                fontSize: 14,
                color: StudyRepsTheme.warmTextMedium,
              ),
            ),
            const SizedBox(height: 48),
            
            // Loading Indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: StudyRepsTheme.warmOrange,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 13,
                color: StudyRepsTheme.warmTextLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
