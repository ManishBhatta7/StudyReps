import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../domain/models/video_model.dart';

/// Teach-Back Prompt Widget
///
/// After completing a video, prompts the user to "teach it back" by recording
/// a short explainer video. Based on constructionism: "learning by doing" and
/// constructing knowledge is far more effective than just instruction.
///
/// "If you can't explain it simply, you don't understand it well enough."
class TeachBackPrompt extends StatefulWidget {
  final VideoModel video;
  final VoidCallback? onDismiss;
  final VoidCallback? onRecorded;

  const TeachBackPrompt({
    super.key,
    required this.video,
    this.onDismiss,
    this.onRecorded,
  });

  @override
  State<TeachBackPrompt> createState() => _TeachBackPromptState();
}

class _TeachBackPromptState extends State<TeachBackPrompt>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnim = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    setState(() => _isRecording = true);

    try {
      final picker = ImagePicker();
      final video = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 60),
      );

      if (video != null) {
        debugPrint('🎥 Teach-back video recorded: ${video.path}');
        // TODO: Upload to Supabase Storage
        widget.onRecorded?.call();
      }
    } catch (e) {
      debugPrint('❌ Camera error: $e');
    } finally {
      if (mounted) setState(() => _isRecording = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _slideAnim.value),
        child: Opacity(
          opacity: _fadeAnim.value,
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              StudyRepsTheme.primaryPurple.withOpacity(0.15),
              StudyRepsTheme.accentCyan.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: StudyRepsTheme.primaryPurple.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [StudyRepsTheme.primaryPurple, StudyRepsTheme.accentCyan],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teach It Back! 🎓',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Record a 30-60s explanation',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _controller.reverse().then((_) => widget.onDismiss?.call());
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Challenge text
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Can you explain "${widget.video.title}" in your own words? '
                'Teaching is the strongest form of learning!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Record button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRecording ? null : _startRecording,
                icon: Icon(
                  _isRecording ? Icons.hourglass_empty : Icons.fiber_manual_record,
                  size: 18,
                ),
                label: Text(_isRecording ? 'Recording...' : 'Start Recording'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: StudyRepsTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Skip
            TextButton(
              onPressed: widget.onDismiss,
              child: Text(
                'Maybe later',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 13,
                ),
              ),
            ),

            // XP bonus hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt, color: StudyRepsTheme.accentCyan, size: 14),
                const SizedBox(width: 4),
                Text(
                  '+50 XP bonus for teaching back!',
                  style: TextStyle(
                    color: StudyRepsTheme.accentCyan.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
