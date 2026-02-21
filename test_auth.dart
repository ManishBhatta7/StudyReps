import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final supabase = SupabaseClient(
    'https://gwarmogcmeehajnevbmi.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd3YXJtb2djbWVlaGFqbmV2Ym1pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyOTc1MjAsImV4cCI6MjA2MDg3MzUyMH0.EiTIeIZMrDjMIufMUEuDr74ydPFHtRAIveTvAkBxTds',
  );

  print('Testing Supabase Auth...');

  try {
    print('Trying Sign Up...');
    final response = await supabase.auth.signUp(
      email: 'testuser_${DateTime.now().millisecondsSinceEpoch}@example.com',
      password: 'TestPassword123!',
      data: {'full_name': 'Test User'},
    );
    print('Sign Up returned...');
    print('User: ${response.user}');
  } catch (e, st) {
    print('Auth Error: $e');
    print(st);
  }
  exit(0);
}
