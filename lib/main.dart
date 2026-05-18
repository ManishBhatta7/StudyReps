import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/study_reps_theme.dart';
import 'data/services/chat_persistence_service.dart';
import 'data/services/engines/review_queue_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/intro_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/main_navigation_shell.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(
      const ProviderScope(
        child: AppRoot(),
      ),
    );
  }, (error, stack) {
    debugPrint('💥 FATAL ERROR STARTUP: $error');
    debugPrint(stack.toString());
  });
}

/// Root widget that handles initialization and routing
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _isInitialized = false;
  String? _error;
  bool _isAuthenticated = false;
  bool _hasCompletedOnboarding = true; // Default to true to avoid flash

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
       // Load env vars
      await dotenv.load(fileName: '.env');

      // Set orientation
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Init Hive
      await Hive.initFlutter();

      // Init Chat Persistence (Tutorbot memory)
      await ChatPersistenceService.init();

      // Init Content Review Queue
      await ReviewQueueService.init();

      // Check first launch
      final prefs = await SharedPreferences.getInstance();
      _hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;

      // Init Supabase
      debugPrint('🚀 Initializing Supabase...');
      try {
        await Supabase.initialize(
          url: AppConstants.supabaseUrl,
          anonKey: AppConstants.supabaseAnonKey,
        );
        debugPrint('✅ Supabase initialized');
        
        // Check session
        final session = Supabase.instance.client.auth.currentSession;
        _isAuthenticated = session != null;
        if (_isAuthenticated) {
          debugPrint('🔑 User already logged in: ${session!.user.email}');
        }
      } catch (e) {
        debugPrint('⚠️ Supabase initialization failed, continuing offline: $e');
      }

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('💥 Critical Initialization Error: $e');
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: StudyRepsTheme.darkTheme,
        home: Scaffold(
          backgroundColor: StudyRepsTheme.warmCream,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Logo Placeholder
                Container(
                  width: 80,
                  height: 80,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        StudyRepsTheme.warmOrange,
                        StudyRepsTheme.warmOrangeDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: StudyRepsTheme.warmOrange.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 32),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Error: $_error\nRunning in offline mode.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  )
                else
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: StudyRepsTheme.warmOrange,
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: StudyRepsTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: _hasCompletedOnboarding
          ? Consumer(
              builder: (context, ref, child) {
                final authState = ref.watch(authStateStreamProvider);
                
                return authState.when(
                  data: (user) {
                    if (user != null) {
                      return const MainNavigationShell();
                    }
                    return const LoginScreen();
                  },
                  loading: () {
                    if (_isAuthenticated) {
                       return const MainNavigationShell();
                    }
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  },
                  error: (e, st) => const LoginScreen(),
                );
              },
            )
          : const IntroScreen(),
    );
  }
}
