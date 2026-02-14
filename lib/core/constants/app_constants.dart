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
  // TODO: Move to environment variables for production
  static const String supabaseUrl = 'https://gwarmogcmeehajnevbmi.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd3YXJtb2djbWVlaGFqbmV2Ym1pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyOTc1MjAsImV4cCI6MjA2MDg3MzUyMH0.EiTIeIZMrDjMIufMUEuDr74ydPFHtRAIveTvAkBxTds';

  // Google Gemini API Configuration
  // TODO: Move to environment variables for production
  static const String geminiApiKey = 'AIzaSyBktbMaT76dgrgQHB4QoXnmQ3bFbZOnkiI';
  static const String geminiModel = 'gemini-1.5-flash';
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  
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
