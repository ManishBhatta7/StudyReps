import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/study_reps_theme.dart';
import 'presentation/screens/intro_screen.dart';
import 'presentation/screens/main_navigation_shell.dart';
import 'presentation/screens/swipe_gated_feed_screen.dart';


/// StudyReps - "TikTok for Logic"
/// 
/// A mobile-first educational platform where vertical videos pause ("The Lock")
/// and require users to answer logic questions ("The Rep") to resume.
/// 
/// Architecture: Clean Architecture with Riverpod
/// Backend: Supabase (Auth, Database, Storage)
/// AI: Google Gemini API for coaching feedback
import 'dart:async';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Set preferred orientations for video feed
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize Hive for local storage
    await Hive.initFlutter();

    // Initialize Supabase
    debugPrint('🚀 Initializing StudyReps...');
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
      
      // Log initial auth state
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        debugPrint('✅ Supabase initialized with active session');
        debugPrint('   User: ${session.user.email}');
      } else {
        debugPrint('✅ Supabase initialized (no active session)');
      }
    } catch (e) {
      debugPrint('⚠️ Supabase initialization failed: $e');
      debugPrint('   App will run in offline mode');
    }

    debugPrint('💪 StudyReps ready - Time to get those reps in!');

    runApp(
      const ProviderScope(
        child: StudyRepsApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('💥 FATAL ERROR STARTUP: $error');
    debugPrint(stack.toString());
  });
}

/// Root application widget for StudyReps
class StudyRepsApp extends ConsumerWidget {
  const StudyRepsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: StudyRepsTheme.darkTheme,
      themeMode: ThemeMode.dark,
      // Start with swipe gated feed for dev
      home: const SwipeGatedFeedScreen(),
    );
  }
}

