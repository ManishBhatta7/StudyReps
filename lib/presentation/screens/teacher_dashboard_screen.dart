import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/study_reps_theme.dart';

/// Prototype data model for a Student in the dashboard
class StudentProgress {
  final String id;
  final String name;
  final String avatarUrl;
  final int totalReps;
  final double accuracy;
  final String weakestTopic;
  final List<double> weeklyActivity; // 7 days of activity relative to max (0.0 - 1.0)
  final int currentStreak;
  final int focusLosses; // times the student left the app during a session
  final int minutesStudied;

  const StudentProgress({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.totalReps,
    required this.accuracy,
    required this.weakestTopic,
    required this.weeklyActivity,
    required this.currentStreak,
    this.focusLosses = 0,
    this.minutesStudied = 0,
  });
}

final mockStudentsProvider = Provider<List<StudentProgress>>((ref) {
  return [
    const StudentProgress(
      id: '1',
      name: 'Jimmy Smith',
      avatarUrl: 'https://i.pravatar.cc/150?u=jimmy',
      totalReps: 142,
      accuracy: 0.76,
      weakestTopic: 'Newton\'s Laws',
      weeklyActivity: [0.2, 0.5, 0.8, 1.0, 0.4, 0.0, 0.6],
      currentStreak: 4,
      focusLosses: 3,
      minutesStudied: 95,
    ),
    const StudentProgress(
      id: '2',
      name: 'Sarah Chen',
      avatarUrl: 'https://i.pravatar.cc/150?u=sarah',
      totalReps: 310,
      accuracy: 0.92,
      weakestTopic: 'Thermodynamics',
      weeklyActivity: [0.8, 0.9, 0.7, 0.6, 1.0, 0.9, 0.8],
      currentStreak: 12,
      focusLosses: 0,
      minutesStudied: 210,
    ),
    const StudentProgress(
      id: '3',
      name: 'Marcus Johnson',
      avatarUrl: 'https://i.pravatar.cc/150?u=marcus',
      totalReps: 45,
      accuracy: 0.48,
      weakestTopic: 'Ohm\'s Law',
      weeklyActivity: [0.0, 0.0, 0.4, 0.2, 0.0, 0.0, 0.2],
      currentStreak: 1,
      focusLosses: 8,
      minutesStudied: 22,
    ),
  ];
});

/// A dedicated web/tablet-focused dashboard for Teachers and Parents
class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends ConsumerState<TeacherDashboardScreen> {
  bool _weeklyReportEnabled = true;
  String _reportDay = 'Sunday';
  final _parentEmailController = TextEditingController(text: 'parent@example.com');
  final _teacherEmailController = TextEditingController(text: 'teacher@school.edu');

  @override
  void dispose() {
    _parentEmailController.dispose();
    _teacherEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final students = ref.watch(mockStudentsProvider);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: StudyRepsTheme.warmCream,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) _buildSideNav(context),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(context, isDesktop),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildOverviewCards(students),
                          const SizedBox(height: 32),

                          // ── Weekly Activity Report ──
                          _buildWeeklyReportSection(students),
                          const SizedBox(height: 32),

                          Text(
                            'Students Overview',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: StudyRepsTheme.warmTextDark,
                            ),
                          ),
                          const SizedBox(height: 16),

                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              mainAxisExtent: 240,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final delay = Duration(milliseconds: 100 * index);
                              return _buildStudentCard(students[index])
                                  .animate()
                                  .fadeIn(delay: delay)
                                  .slideY(begin: 0.1, delay: delay);
                            },
                          ),
                          const SizedBox(height: 64),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════
  // APP BAR
  // ════════════════════════════════════
  SliverAppBar _buildAppBar(BuildContext context, bool isDesktop) {
    return SliverAppBar(
      backgroundColor: StudyRepsTheme.warmCream,
      elevation: 0,
      pinned: true,
      leading: !isDesktop
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: StudyRepsTheme.warmTextDark),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Text(
        'Teacher & Parent Dashboard',
        style: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: StudyRepsTheme.warmTextDark,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: StudyRepsTheme.warmTextDark),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 16,
          backgroundColor: StudyRepsTheme.primaryPurple,
          child: Icon(Icons.person, size: 20, color: Colors.white),
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  // ════════════════════════════════════
  // SIDE NAV (Desktop only)
  // ════════════════════════════════════
  Widget _buildSideNav(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: const BoxDecoration(
        color: StudyRepsTheme.warmDarkCard,
        border: Border(
          right: BorderSide(color: StudyRepsTheme.warmBorder, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: StudyRepsTheme.warmOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'StudyReps',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: StudyRepsTheme.warmTextOnDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          _buildNavItem(Icons.dashboard_rounded, 'Dashboard', true),
          _buildNavItem(Icons.group_rounded, 'My Students', false),
          _buildNavItem(Icons.assignment_rounded, 'Assignments', false),
          _buildNavItem(Icons.bar_chart_rounded, 'Reports', false),
          const Spacer(),
          _buildNavItem(Icons.settings_rounded, 'Settings', false),
          _buildNavItem(Icons.logout_rounded, 'Exit Dashboard', false, onTap: () {
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? StudyRepsTheme.warmOrange.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: isActive ? StudyRepsTheme.warmOrange : StudyRepsTheme.warmTextMutedOnDark, size: 20),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: isActive ? StudyRepsTheme.warmOrange : StudyRepsTheme.warmTextMutedOnDark,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════
  // OVERVIEW CARDS — Fixed for mobile
  // ════════════════════════════════════
  Widget _buildOverviewCards(List<StudentProgress> students) {
    if (students.isEmpty) return const SizedBox.shrink();

    final avgAccuracy = students.map((s) => s.accuracy).reduce((a, b) => a + b) / students.length;
    final totalReps = students.map((s) => s.totalReps).reduce((a, b) => a + b);
    final needsHelp = students.where((s) => s.accuracy < 0.6).length;

    final card1 = _buildStatCard(
      title: 'Class Accuracy',
      value: '${(avgAccuracy * 100).toInt()}%',
      subtitle: '+4% this week',
      icon: Icons.check_circle_outline_rounded,
      color: StudyRepsTheme.warmGreen,
    );

    final card2 = _buildStatCard(
      title: 'Total Reps',
      value: '$totalReps',
      subtitle: 'Active learning!',
      icon: Icons.fitness_center_rounded,
      color: StudyRepsTheme.warmOrange,
    );

    final card3 = _buildStatCard(
      title: 'Needs Help',
      value: '$needsHelp',
      subtitle: 'Students below 60%',
      icon: Icons.warning_amber_rounded,
      color: StudyRepsTheme.errorPink,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile: stack cards
          return Column(
            children: [
              Row(children: [Expanded(child: card1), const SizedBox(width: 12), Expanded(child: card3)]),
              const SizedBox(height: 12),
              card2,
            ],
          );
        }
        // Desktop: single row
        return Row(
          children: [
            Expanded(child: card1),
            const SizedBox(width: 16),
            Expanded(child: card2),
            const SizedBox(width: 16),
            Expanded(child: card3),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: StudyRepsTheme.warmTextLight),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: StudyRepsTheme.warmTextDark, height: 1.0),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: GoogleFonts.outfit(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ════════════════════════════════════
  // WEEKLY ACTIVITY REPORT
  // ════════════════════════════════════
  Widget _buildWeeklyReportSection(List<StudentProgress> students) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StudyRepsTheme.primaryPurple.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: StudyRepsTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.mail_outline_rounded, color: StudyRepsTheme.primaryPurple, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Activity Report',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: StudyRepsTheme.warmTextDark),
                    ),
                    Text(
                      'Auto-sent to parents & teachers every week',
                      style: GoogleFonts.outfit(fontSize: 13, color: StudyRepsTheme.warmTextLight),
                    ),
                  ],
                ),
              ),
              // Toggle switch
              Switch.adaptive(
                value: _weeklyReportEnabled,
                onChanged: (v) => setState(() => _weeklyReportEnabled = v),
                activeColor: StudyRepsTheme.primaryPurple,
              ),
            ],
          ),

          if (_weeklyReportEnabled) ...[
            const SizedBox(height: 24),

            // Email recipients
            Row(
              children: [
                Expanded(child: _buildEmailField('Parent Email', _parentEmailController, Icons.family_restroom_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildEmailField('Teacher Email', _teacherEmailController, Icons.school_rounded)),
              ],
            ),

            const SizedBox(height: 16),

            // Schedule row
            Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 18, color: StudyRepsTheme.warmTextLight),
                const SizedBox(width: 8),
                Text('Send every', style: GoogleFonts.outfit(fontSize: 14, color: StudyRepsTheme.warmTextMedium)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: StudyRepsTheme.warmChipBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: StudyRepsTheme.warmBorder),
                  ),
                  child: DropdownButton<String>(
                    value: _reportDay,
                    isDense: true,
                    underline: const SizedBox(),
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: StudyRepsTheme.warmTextDark),
                    items: ['Sunday', 'Monday', 'Friday', 'Saturday']
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) { if (v != null) setState(() => _reportDay = v); },
                  ),
                ),
                const SizedBox(width: 8),
                Text('at 9:00 AM', style: GoogleFonts.outfit(fontSize: 14, color: StudyRepsTheme.warmTextMedium)),
              ],
            ),

            const SizedBox(height: 20),

            // Report Preview
            _buildReportPreview(students),

            const SizedBox(height: 16),

            // Send Now button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('📧 Weekly report sent to ${_parentEmailController.text} and ${_teacherEmailController.text}!',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      backgroundColor: StudyRepsTheme.warmGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 18),
                label: Text('Send Report Now', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: StudyRepsTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05);
  }

  Widget _buildEmailField(String label, TextEditingController ctrl, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: StudyRepsTheme.warmTextLight)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          style: GoogleFonts.outfit(fontSize: 14, color: StudyRepsTheme.warmTextDark),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: StudyRepsTheme.warmTextLight),
            filled: true,
            fillColor: StudyRepsTheme.warmChipBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: StudyRepsTheme.warmBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: StudyRepsTheme.warmBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: StudyRepsTheme.primaryPurple, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildReportPreview(List<StudentProgress> students) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StudyRepsTheme.warmCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StudyRepsTheme.warmBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.preview_rounded, size: 16, color: StudyRepsTheme.warmTextLight),
              const SizedBox(width: 6),
              Text('Report Preview', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: StudyRepsTheme.warmTextLight, letterSpacing: 0.5)),
            ],
          ),
          const Divider(height: 20),
          
          // Per-student summary
          ...students.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                CircleAvatar(radius: 14, backgroundImage: NetworkImage(s.avatarUrl)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: StudyRepsTheme.warmTextDark)),
                      Text(
                        '${s.minutesStudied} min studied · ${s.totalReps} reps · ${(s.accuracy * 100).toInt()}% accuracy${s.focusLosses > 0 ? ' · ⚠️ Lost focus ${s.focusLosses}x' : ''}',
                        style: GoogleFonts.outfit(fontSize: 12, color: StudyRepsTheme.warmTextMedium),
                      ),
                    ],
                  ),
                ),
                // Health badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (s.accuracy >= 0.7 ? StudyRepsTheme.warmGreen : s.accuracy >= 0.5 ? StudyRepsTheme.warmOrange : StudyRepsTheme.errorPink).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    s.accuracy >= 0.7 ? '✅ Great' : s.accuracy >= 0.5 ? '⚠️ OK' : '🆘 Help',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: s.accuracy >= 0.7 ? StudyRepsTheme.warmGreen : s.accuracy >= 0.5 ? StudyRepsTheme.warmOrange : StudyRepsTheme.errorPink,
                    ),
                  ),
                ),
              ],
            ),
          )),
          
          const Divider(height: 16),
          Text(
            'This report includes: study time, accuracy, focus losses, streak status, and weak topics. Sent automatically every $_reportDay at 9:00 AM.',
            style: GoogleFonts.outfit(fontSize: 11, color: StudyRepsTheme.warmTextLight, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════
  // STUDENT CARD
  // ════════════════════════════════════
  Widget _buildStudentCard(StudentProgress student) {
    bool needsHelp = student.accuracy < 0.6;
    Color healthColor = needsHelp ? StudyRepsTheme.errorPink : StudyRepsTheme.warmGreen;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: needsHelp ? Border.all(color: StudyRepsTheme.errorPink.withOpacity(0.5), width: 2) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 20, backgroundImage: NetworkImage(student.avatarUrl)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: StudyRepsTheme.warmTextDark)),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded, size: 14, color: StudyRepsTheme.warmOrange),
                        const SizedBox(width: 2),
                        Text('${student.currentStreak} day streak', style: GoogleFonts.outfit(fontSize: 12, color: StudyRepsTheme.warmTextLight)),
                        if (student.focusLosses > 0) ...[
                          const SizedBox(width: 8),
                          Text('⚠️ ${student.focusLosses}x focus loss', style: GoogleFonts.outfit(fontSize: 11, color: StudyRepsTheme.errorPink, fontWeight: FontWeight.w600)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(value: student.accuracy, strokeWidth: 3, backgroundColor: StudyRepsTheme.warmBorder, valueColor: AlwaysStoppedAnimation(healthColor)),
                    Text('${(student.accuracy * 100).toInt()}%', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: healthColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stats chips row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildMiniChip('${student.minutesStudied} min', Icons.timer_outlined, StudyRepsTheme.primaryPurple),
              _buildMiniChip('${student.totalReps} reps', Icons.fitness_center_rounded, StudyRepsTheme.warmOrange),
              _buildMiniChip(student.weakestTopic, Icons.warning_amber_rounded, StudyRepsTheme.errorPink),
            ],
          ),

          const Spacer(),

          // Activity chart
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: student.weeklyActivity.map((val) {
              return Container(
                width: 16,
                height: 40 * val + 4,
                decoration: BoxDecoration(
                  color: val == 0 ? StudyRepsTheme.warmBorder : StudyRepsTheme.primaryPurple.withOpacity(val < 0.3 ? 0.4 : 1.0),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((day) => SizedBox(
                      width: 16,
                      child: Text(day, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 10, color: StudyRepsTheme.warmTextLight)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

