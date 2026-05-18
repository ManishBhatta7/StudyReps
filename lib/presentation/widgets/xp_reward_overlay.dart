import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/study_reps_theme.dart';

/// A gorgeous full-screen XP reward overlay that appears after a correct answer.
///
/// Shows:
/// - "+15 XP" floating upward with particle burst
/// - Level-up celebration if the user crossed a level threshold
/// - Streak milestone if applicable
///
/// Usage:
/// ```dart
/// XpRewardOverlay.show(context, xpGained: 15, newLevel: 3, oldLevel: 2);
/// ```
class XpRewardOverlay extends StatefulWidget {
  final int xpGained;
  final int? newLevel;
  final int? oldLevel;
  final int? currentStreak;
  final bool hitDailyGoal;
  final VoidCallback? onDismiss;

  const XpRewardOverlay({
    super.key,
    required this.xpGained,
    this.newLevel,
    this.oldLevel,
    this.currentStreak,
    this.hitDailyGoal = false,
    this.onDismiss,
  });

  /// Show the overlay as a full-screen route overlay
  static Future<void> show(
    BuildContext context, {
    required int xpGained,
    int? newLevel,
    int? oldLevel,
    int? currentStreak,
    bool hitDailyGoal = false,
  }) {
    final bool leveledUp = newLevel != null && oldLevel != null && newLevel > oldLevel;
    final int displayDuration = leveledUp ? 3000 : 1800;

    HapticFeedback.mediumImpact();

    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'XP Reward',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        return XpRewardOverlay(
          xpGained: xpGained,
          newLevel: newLevel,
          oldLevel: oldLevel,
          currentStreak: currentStreak,
          hitDailyGoal: hitDailyGoal,
          onDismiss: () => Navigator.of(ctx).pop(),
        );
      },
    ).timeout(
      Duration(milliseconds: displayDuration + 500),
      onTimeout: () {
        return null;
      },
    );
  }

  @override
  State<XpRewardOverlay> createState() => _XpRewardOverlayState();
}

class _XpRewardOverlayState extends State<XpRewardOverlay>
    with TickerProviderStateMixin {
  late final bool _leveledUp;
  final List<_Particle> _particles = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _leveledUp = widget.newLevel != null &&
        widget.oldLevel != null &&
        widget.newLevel! > widget.oldLevel!;

    // Generate particles
    for (int i = 0; i < (_leveledUp ? 24 : 12); i++) {
      _particles.add(_Particle(
        angle: _random.nextDouble() * 2 * pi,
        distance: 60 + _random.nextDouble() * 120,
        size: 4 + _random.nextDouble() * 6,
        color: [
          StudyRepsTheme.warmOrange,
          const Color(0xFFFFD700),
          StudyRepsTheme.accentCyan,
          StudyRepsTheme.primaryPurple,
          StudyRepsTheme.warmGreen,
        ][_random.nextInt(5)],
      ));
    }

    // Auto-dismiss
    final duration = _leveledUp ? 3000 : 1800;
    Future.delayed(Duration(milliseconds: duration), () {
      if (mounted) widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.3),
      child: GestureDetector(
        onTap: widget.onDismiss,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // XP Burst
              SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Particles
                    ..._particles.map((p) => _buildParticle(p)),

                    // Main XP Badge
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            StudyRepsTheme.warmOrange.withOpacity(0.3),
                            StudyRepsTheme.warmOrange.withOpacity(0.05),
                          ],
                        ),
                        border: Border.all(
                          color: StudyRepsTheme.warmOrange.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '+${widget.xpGained}',
                            style: GoogleFonts.outfit(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: StudyRepsTheme.warmOrange,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            'XP',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: StudyRepsTheme.warmOrange.withOpacity(0.7),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0, 0),
                          end: const Offset(1, 1),
                          curve: Curves.elasticOut,
                          duration: 800.ms,
                        )
                        .then()
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.05, 1.05),
                          duration: 500.ms,
                        )
                        .then()
                        .scale(
                          begin: const Offset(1.05, 1.05),
                          end: const Offset(0.95, 0.95),
                          duration: 300.ms,
                        ),
                  ],
                ),
              ),

              // Level Up Section
              if (_leveledUp) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), StudyRepsTheme.warmOrange],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⚡', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        'LEVEL ${widget.newLevel}!',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(delay: 400.ms)
                    .scale(
                      begin: const Offset(0, 0),
                      curve: Curves.elasticOut,
                      duration: 700.ms,
                    )
                    .shimmer(
                      delay: 1100.ms,
                      duration: 1200.ms,
                      color: Colors.white.withOpacity(0.3),
                    ),
              ],

              // Streak milestone
              if (widget.hitDailyGoal) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: StudyRepsTheme.warmGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: StudyRepsTheme.warmGreen.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        'Daily Goal Complete!',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: StudyRepsTheme.warmGreen,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(delay: 600.ms)
                    .fadeIn()
                    .slideY(begin: 0.3),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildParticle(_Particle p) {
    final dx = cos(p.angle) * p.distance;
    final dy = sin(p.angle) * p.distance;

    return Positioned(
      left: 130 + dx - p.size / 2,
      top: 130 + dy - p.size / 2,
      child: Container(
        width: p.size,
        height: p.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: p.color,
        ),
      )
          .animate()
          .scale(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            delay: Duration(milliseconds: 100 + _random.nextInt(300)),
            duration: 400.ms,
            curve: Curves.easeOut,
          )
          .fadeOut(
            delay: 800.ms,
            duration: 600.ms,
          ),
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final double size;
  final Color color;

  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
  });
}
