import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final apiKey = 'sk_7025337571d19f2604065e2262de878c415dce245a10d17c';
  final url = Uri.parse('https://api.elevenlabs.io/v1/voices');
  
  try {
    final response = await http.get(url, headers: {'xi-api-key': apiKey});
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final voices = json['voices'] as List;
      for (var v in voices.take(10)) {
        if (v['category'] == 'premade') {
          debugPrint('${v['name']}: ${v['voice_id']}');
        }
      }
    }
  } catch (e) {
    debugPrint('Exception: $e');
  }
}

