import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/study_reps_theme.dart';

/// Accessibility Controls Widget
///
/// Universal design: text size, high contrast, reduced motion, TTS toggle.
/// Persists to SharedPreferences via Riverpod state.
class AccessibilityPanel extends StatelessWidget {
  const AccessibilityPanel({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AccessibilityContent(),
    );
  }

  @override
  Widget build(BuildContext context) => const _AccessibilityContent();
}

// ── Accessibility state providers ──
final textScaleProvider = StateProvider<double>((ref) => 1.0);
final highContrastProvider = StateProvider<bool>((ref) => false);
final reducedMotionProvider = StateProvider<bool>((ref) => false);
final ttsEnabledProvider = StateProvider<bool>((ref) => false);
final captionsEnabledProvider = StateProvider<bool>((ref) => true);

class _AccessibilityContent extends ConsumerWidget {
  const _AccessibilityContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textScale = ref.watch(textScaleProvider);
    final highContrast = ref.watch(highContrastProvider);
    final reducedMotion = ref.watch(reducedMotionProvider);
    final ttsEnabled = ref.watch(ttsEnabledProvider);
    final captionsEnabled = ref.watch(captionsEnabledProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgPrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Accessibility ♿',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Text size
          _buildSliderRow(
            'Text Size',
            Icons.text_fields,
            textScale,
            0.8,
            1.6,
            (v) => ref.read(textScaleProvider.notifier).state = v,
            '${(textScale * 100).round()}%',
          ),
          const SizedBox(height: 12),

          // Toggles
          _buildToggle('High Contrast', Icons.contrast, highContrast,
              (v) => ref.read(highContrastProvider.notifier).state = v),
          _buildToggle('Reduced Motion', Icons.animation, reducedMotion,
              (v) => ref.read(reducedMotionProvider.notifier).state = v),
          _buildToggle('Text-to-Speech', Icons.record_voice_over, ttsEnabled,
              (v) => ref.read(ttsEnabledProvider.notifier).state = v),
          _buildToggle('Auto Captions', Icons.subtitles, captionsEnabled,
              (v) => ref.read(captionsEnabledProvider.notifier).state = v),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, IconData icon, double value,
      double min, double max, ValueChanged<double> onChanged, String display) {
    return Row(
      children: [
        Icon(icon, color: StudyRepsTheme.accentCyan, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const Spacer(),
        Text(display, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        SizedBox(
          width: 120,
          child: SliderTheme(
            data: const SliderThemeData(
              activeTrackColor: StudyRepsTheme.primaryPurple,
              thumbColor: StudyRepsTheme.accentCyan,
              inactiveTrackColor: Colors.white12,
              trackHeight: 3,
            ),
            child: Slider(value: value, min: min, max: max, onChanged: onChanged),
          ),
        ),
      ],
    );
  }

  Widget _buildToggle(String label, IconData icon, bool value,
      ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: StudyRepsTheme.accentCyan, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const Spacer(),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: StudyRepsTheme.primaryPurple,
          ),
        ],
      ),
    );
  }
}
