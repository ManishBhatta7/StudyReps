import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class GeminiRepository {
  final SupabaseClient _supabase;

  GeminiRepository(this._supabase);

  /// Sends a chat message to Gemini and returns a stream of the response.
  /// 
  /// Utilizes the 'gemini-chat' Edge Function.
  Stream<String> sendChatMessage({
    required String message,
    required List<String> contextIds,
  }) async* {
    try {
      final response = await _supabase.functions.invoke(
        'gemini-chat',
        body: {
          'message': message,
          'contextFiles': contextIds,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to get response: ${response.status}');
      }
      
      final data = response.data;
      String text = '';
      
      if (data is Map && data.containsKey('response')) {
        text = data['response'];
      } else if (data is Map && data.containsKey('text')) {
         text = data['text'];
      } else {
        text = data.toString();
      }

      yield text;
      
    } catch (e) {
      throw Exception('Gemini Error: $e');
    }
  }

  /// Analyzes a report card image using 'analyze-report' Edge Function.
  /// 
  /// Accepts raw bytes and filename for cross-platform compatibility (web + mobile).
  Future<Map<String, dynamic>> analyzeReport(Uint8List imageBytes, String filename) async {
    try {
      final String base64Image = base64Encode(imageBytes);

      final response = await _supabase.functions.invoke(
        'analyze-report',
        body: {
          'image': base64Image,
          'filename': filename,
        },
      );

      if (response.status != 200) {
        throw Exception('Analysis failed: ${response.status}');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Analysis Error: $e');
    }
  }
}
