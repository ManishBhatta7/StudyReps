import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application-wide constants for StudyReps
/// 
/// StudyReps: "TikTok for Logic" - Learn through micro-struggles
/// Videos pause at key moments ("The Lock") requiring answers ("The Rep")
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'StudyReps';
  static const String appTagline = 'TikTok for Logic';
  static const String appVersion = '1.0.0';

  // Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Google Gemini API Configuration
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String geminiModel = 'gemini-2.5-flash';
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  // Thinking Mode Configuration
  // Gemini 2.5 Flash supports native thinking — enable it for deeper reasoning
  static const bool enableThinking = true;
  static const int thinkingBudget = 1024; // Token budget for internal reasoning

  // ElevenLabs TTS Configuration (deprecated — credits exhausted)
  static String get elevenLabsApiKey => dotenv.env['ELEVENLABS_API_KEY'] ?? '';
  static const String elevenLabsVoiceId = 'Xb7hH8MSUJpSbSDYk0k2'; // Alice - Clear, Engaging Educator (Free Tier Compatible)
  static const String elevenLabsBaseUrl = 'https://api.elevenlabs.io/v1';

  // Google Cloud Text-to-Speech Configuration
  // Free tier: 1M chars/month (WaveNet/Neural2), 4M chars/month (Standard)
  // Enable API: https://console.cloud.google.com/apis/library/texttospeech.googleapis.com
  // Uses the same Google Cloud project as Gemini — may use the same API key if TTS API is enabled.
  static String get googleTtsApiKey => dotenv.env['GOOGLE_TTS_API_KEY'] ?? dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String googleTtsVoiceName = 'en-IN-Wavenet-A'; // Natural Indian English female voice
  static const String googleTtsLanguageCode = 'en-IN';
  
  // Gemini Prompt Templates
  static const String coachPrompt = '''
You are a strict logic coach. The user answered: {user_answer}. 
The correct answer is: {correct_answer}. 
If wrong, give 1 sentence of specific feedback (no fluff). 
If correct, respond with exactly: "CORRECT"
''';

  // Video Feed Configuration
  static const Duration lockCheckInterval = Duration(milliseconds: 100);
  static const double lockOverlayBlur = 15.0;

  // Local Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themePreferenceKey = 'theme_preference';
  static const String streakDataKey = 'streak_data';

  // Hive Box Names
  static const String userBox = 'user_box';
  static const String cacheBox = 'cache_box';
  static const String settingsBox = 'settings_box';
  static const String repsBox = 'reps_box';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheExpiry = Duration(hours: 24);

  // Gamification
  static const int repsPerStreak = 5;
  static const int streakBonusXp = 50;
}
