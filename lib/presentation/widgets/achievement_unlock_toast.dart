import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/study_reps_theme.dart';

/// A beautiful slide-in toast notification for achievement unlocks.
///
/// Appears from the top of the screen with a satisfying haptic bump,
/// showing the badge emoji, title, and description.
///
/// Usage:
/// ```dart
/// AchievementUnlockToast.show(context,
///   title: 'First Rep',
///   emoji: '🎉',
///   description: 'Complete your first study rep.',
/// );
/// ```
class AchievementUnlockToast {
  static OverlayEntry? _currentOverlay;

  static void show(
    BuildContext context, {
    required String title,
    required String emoji,
    required String description,
  }) {
    // Remove any existing toast
    _currentOverlay?.remove();
    _currentOverlay = null;

    HapticFeedback.heavyImpact();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _AchievementToastWidget(
        title: title,
        emoji: emoji,
        description: description,
        onDismiss: () {
          entry.remove();
          if (_currentOverlay == entry) _currentOverlay = null;
        },
      ),
    );

    _currentOverlay = entry;
    overlay.insert(entry);
  }
}

class _AchievementToastWidget extends StatefulWidget {
  final String title;
  final String emoji;
  final String description;
  final VoidCallback onDismiss;

  const _AchievementToastWidget({
    required this.title,
    required this.emoji,
    required this.description,
    required this.onDismiss,
  });

  @override
  State<_AchievementToastWidget> createState() => _AchievementToastWidgetState();
}

class _AchievementToastWidgetState extends State<_AchievementToastWidget> {
  @override
  void initState() {
    super.initState();
    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).viewPadding.top;

    return Positioned(
      top: topPadding + 12,
      left: 20,
      right: 20,
      child: GestureDetector(
        onTap: widget.onDismiss,
        onVerticalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dy < -100) {
            widget.onDismiss();
          }
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: StudyRepsTheme.warmDarkCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.15),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Badge icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFD700).withOpacity(0.3),
                        const Color(0xFFFFD700).withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0, 0),
                      curve: Curves.elasticOut,
                      duration: 600.ms,
                      delay: 200.ms,
                    ),

                const SizedBox(width: 14),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            '🏆 ACHIEVEMENT UNLOCKED',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFFD700),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: StudyRepsTheme.warmTextOnDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: StudyRepsTheme.warmTextMutedOnDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate()
              .slideY(begin: -1.5, curve: Curves.easeOutBack, duration: 500.ms)
              .fadeIn(duration: 300.ms)
              .shimmer(
                delay: 800.ms,
                duration: 1500.ms,
                color: const Color(0xFFFFD700).withOpacity(0.15),
              ),
        ),
      ),
    );
  }
}
