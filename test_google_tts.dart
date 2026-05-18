// Quick test: Does Google Cloud TTS API work with the existing Gemini API key?
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  // Load API key from .env
  final envFile = File('.env');
  final envLines = await envFile.readAsLines();
  String apiKey = '';
  for (final line in envLines) {
    if (line.startsWith('GOOGLE_TTS_API_KEY=')) {
      apiKey = line.split('=').skip(1).join('=');
    }
  }
  if (apiKey.isEmpty) {
    for (final line in envLines) {
      if (line.startsWith('GEMINI_API_KEY=')) {
        apiKey = line.split('=').skip(1).join('=');
      }
    }
  }

  print('🔑 API Key: ${apiKey.substring(0, 10)}...');

  final url = Uri.parse(
      'https://texttospeech.googleapis.com/v1/text:synthesize?key=$apiKey');

  final body = jsonEncode({
    'input': {'text': 'Hello! Welcome to StudyReps. Let us learn together.'},
    'voice': {
      'languageCode': 'en-IN',
      'name': 'en-IN-Wavenet-A',
    },
    'audioConfig': {
      'audioEncoding': 'MP3',
      'speakingRate': 1.0,
      'pitch': 0.0,
    },
  });

  print('📡 Sending request to Google Cloud TTS...');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: body,
    );

    print('📡 Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final audioBase64 = json['audioContent'] as String?;
      if (audioBase64 != null) {
        final bytes = base64Decode(audioBase64);
        final outFile = File('test_tts_output.mp3');
        await outFile.writeAsBytes(bytes);
        print('✅ SUCCESS! Audio saved to test_tts_output.mp3 (${bytes.length} bytes)');
        print('🎧 Open test_tts_output.mp3 to hear the voice!');
      }
    } else {
      print('❌ FAILED: ${response.body}');
      if (response.statusCode == 403) {
        print('');
        print('👉 You need to enable the Cloud Text-to-Speech API:');
        print('   https://console.cloud.google.com/apis/library/texttospeech.googleapis.com');
      }
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}
