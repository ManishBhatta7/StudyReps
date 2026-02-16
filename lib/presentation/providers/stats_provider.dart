
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

// Models for the stats
class DashboardStats {
  final int totalReps;
  final String accuracy;
  final Map<String, dynamic> subjectBreakdown;

  DashboardStats({
    required this.totalReps,
    required this.accuracy,
    required this.subjectBreakdown,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalReps: json['total_reps'] ?? 0,
      accuracy: json['accuracy'] ?? '0%',
      subjectBreakdown: json['subject_breakdown'] ?? {},
    );
  }
}

class TSRHealthStats {
  final int score;
  final String status;
  final String advice;

  TSRHealthStats({
    required this.score,
    required this.status,
    required this.advice,
  });

  factory TSRHealthStats.fromJson(Map<String, dynamic> json) {
    return TSRHealthStats(
      score: json['health_score'] ?? 0,
      status: json['status'] ?? 'healthy',
      advice: json['advice'] ?? '',
    );
  }
}

/// Provider to fetch basic dashboard stats
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final user = ref.watch(currentDomainUserProvider);
  if (user == null) throw Exception('User not logged in');

  final response = await Supabase.instance.client.functions.invoke(
    'dashboard-stats',
    body: {'user_id': user.id},
  );

  if (response.status != 200) {
    throw Exception('Failed to fetch stats: ${response.status}');
  }

  return DashboardStats.fromJson(response.data);
});

/// Provider to fetch TSR Health Score
final tsrHealthProvider = FutureProvider<TSRHealthStats>((ref) async {
  final user = ref.watch(currentDomainUserProvider);
  if (user == null) throw Exception('User not logged in');

  final response = await Supabase.instance.client.functions.invoke(
    'tsr-health',
    body: {'user_id': user.id},
  );

  if (response.status != 200) {
    throw Exception('Failed to fetch health score: ${response.status}');
  }

  return TSRHealthStats.fromJson(response.data);
});
