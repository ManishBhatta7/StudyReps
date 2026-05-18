
/// Stub for non-web platforms — uses flutter_tts normally
class WebTtsService {
  static bool get isSupported => false;
  
  static Future<List<Map<String, String>>> getAvailableVoices() async => [];
  
  static Future<void> speak(String text, {
    String? voiceName,
    double rate = 0.45,
    double pitch = 1.15,
    void Function()? onComplete,
  }) async {}
  
  static Future<void> stop() async {}
}
