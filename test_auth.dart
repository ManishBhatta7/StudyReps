import 'package:flutter/foundation.dart';
import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final supabase = SupabaseClient(
    'https://gwarmogcmeehajnevbmi.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd3YXJtb2djbWVlaGFqbmV2Ym1pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyOTc1MjAsImV4cCI6MjA2MDg3MzUyMH0.EiTIeIZMrDjMIufMUEuDr74ydPFHtRAIveTvAkBxTds',
  );

  debugPrint('Testing Supabase Auth...');

  try {
    debugPrint('Trying Sign Up...');
    final response = await supabase.auth.signUp(
      email: 'testuser_${DateTime.now().millisecondsSinceEpoch}@example.com',
      password: 'TestPassword123!',
      data: {'full_name': 'Test User'},
    );
    debugPrint('Sign Up returned...');
    debugPrint('User: ${response.user}');
  } catch (e, st) {
    debugPrint('Auth Error: $e');
    debugPrint(st.toString());
  }
  exit(0);
}

