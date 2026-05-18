// Required for ImageFilter.blur() in BackdropFilter widgets
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../data/services/engines/review_queue_service.dart';
import 'content_review_screen.dart';
import 'login_screen.dart';

// Settings Providers
final autoLockEnabledProvider = StateProvider<bool>((ref) => true);
final soundEffectsEnabledProvider = StateProvider<bool>((ref) => true);
final hapticFeedbackEnabledProvider = StateProvider<bool>((ref) => true);
final autoPlayVideosProvider = StateProvider<bool>((ref) => true);
final darkModeEnabledProvider = StateProvider<bool>((ref) => true);
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
final dailyGoalProvider = StateProvider<int>((ref) => 10);
final streakReminderTimeProvider = StateProvider<String>((ref) => '09:00 AM');

/// Settings Screen — BoldVoice warm cream design
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: StudyRepsTheme.warmCream,
      appBar: AppBar(
        backgroundColor: StudyRepsTheme.warmCream,
        elevation: 0,
        leading: Semantics(
          button: true,
          label: 'Go back',
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: StudyRepsTheme.warmTextDark, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(
            color: StudyRepsTheme.warmTextDark,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 16, bottom: 40),
          children: [
            const _ProfileSection(),
            const SizedBox(height: 24),

            _buildSectionHeader('Learning Preferences'),
            _WarmSettingsCard(
              children: [
                _SettingToggle(
                  icon: Icons.lock_clock_rounded,
                  title: 'Auto Lock',
                  subtitle: 'Pause videos at lock points',
                  provider: autoLockEnabledProvider,
                ),
                const _WarmDivider(),
                _SettingsSlider(
                  icon: Icons.flag_rounded,
                  title: 'Daily Goal',
                  provider: dailyGoalProvider,
                  min: 5,
                  max: 50,
                ),
                const _WarmDivider(),
                _SettingOption(
                  icon: Icons.alarm_rounded,
                  title: 'Reminder Time',
                  valueProvider: streakReminderTimeProvider,
                  onTap: () => _showTimePicker(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Playback'),
            _WarmSettingsCard(
              children: [
                _SettingToggle(
                  icon: Icons.play_circle_outlined,
                  title: 'Auto-play Videos',
                  subtitle: 'Play next video automatically',
                  provider: autoPlayVideosProvider,
                ),
                const _WarmDivider(),
                _SettingToggle(
                  icon: Icons.surround_sound_rounded,
                  title: 'Sound Effects',
                  subtitle: 'UI sounds and feedback',
                  provider: soundEffectsEnabledProvider,
                ),
                const _WarmDivider(),
                _SettingToggle(
                  icon: Icons.vibration_rounded,
                  title: 'Haptic Feedback',
                  subtitle: 'Vibrate on interactions',
                  provider: hapticFeedbackEnabledProvider,
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Notifications'),
            _WarmSettingsCard(
              children: [
                _SettingToggle(
                  icon: Icons.notifications_active_rounded,
                  title: 'Push Notifications',
                  subtitle: 'Streak reminders & updates',
                  provider: notificationsEnabledProvider,
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Content Studio'),
            _ContentStudioCard(),
            const SizedBox(height: 24),

            _buildSectionHeader('Account'),
            _WarmSettingsCard(
              children: [
                _SettingNavItem(icon: Icons.person_rounded, title: 'Edit Profile', onTap: () {}),
                const _WarmDivider(),
                _SettingNavItem(icon: Icons.lock_outline_rounded, title: 'Change Password', onTap: () {}),
                const _WarmDivider(),
                _SettingNavItem(icon: Icons.help_outline_rounded, title: 'Help & Support', onTap: () {}),
                const _WarmDivider(),
                _SettingNavItem(icon: Icons.info_outline_rounded, title: 'About', onTap: () {}),
              ],
            ),
            const SizedBox(height: 32),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Semantics(
                button: true,
                label: 'Log out of your account',
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true)
                          .pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFFE57373)),
                  label: Text(
                    'Log Out',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFE57373),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: const Color(0xFFE57373).withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ).copyWith(
                    overlayColor: WidgetStateProperty.all(const Color(0xFFE57373).withOpacity(0.08)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // App Version
            Center(
              child: Text(
                'StudyReps v1.0.0',
                style: GoogleFonts.outfit(
                  color: StudyRepsTheme.warmTextLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Semantics(
        header: true,
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.outfit(
            color: StudyRepsTheme.warmTextLight,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 50.ms).slideX(begin: 0.05);
  }

  void _showTimePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _TimePickerSheet(),
    );
  }
}

/// Profile Section — warm card
class _ProfileSection extends StatelessWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Your profile: Student Pro',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: StudyRepsTheme.warmDarkCard,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [StudyRepsTheme.warmOrange, StudyRepsTheme.warmOrangeDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: StudyRepsTheme.warmDarkCard,
                ),
                child: const Icon(Icons.person_rounded, color: StudyRepsTheme.warmTextOnDark, size: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@StudentPro',
                    style: GoogleFonts.outfit(
                      color: StudyRepsTheme.warmTextOnDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'student@example.com',
                    style: GoogleFonts.outfit(
                      color: StudyRepsTheme.warmTextMutedOnDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [StudyRepsTheme.warmOrange, StudyRepsTheme.warmOrangeDark],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'PRO',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOutBack),
    );
  }
}

/// Warm Card Container for settings groups
class _WarmSettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _WarmSettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: StudyRepsTheme.warmCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05);
  }
}

/// Setting Toggle (Switch) Item
class _SettingToggle extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final StateProvider<bool> provider;

  const _SettingToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(provider);

    return Semantics(
      toggled: isEnabled,
      label: '$title. $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ref.read(provider.notifier).state = !isEnabled,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _IconBox(icon: icon, isActive: isEnabled),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          color: StudyRepsTheme.warmTextDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          color: StudyRepsTheme.warmTextLight,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: isEnabled,
                  onChanged: (value) => ref.read(provider.notifier).state = value,
                  activeColor: StudyRepsTheme.warmOrange,
                  activeTrackColor: StudyRepsTheme.warmOrange.withOpacity(0.3),
                  inactiveThumbColor: StudyRepsTheme.warmTextLight,
                  inactiveTrackColor: StudyRepsTheme.warmBorder,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom Slider Setting
class _SettingsSlider extends ConsumerWidget {
  final IconData icon;
  final String title;
  final StateProvider<int> provider;
  final int min;
  final int max;

  const _SettingsSlider({
    required this.icon,
    required this.title,
    required this.provider,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(provider);

    return Semantics(
      slider: true,
      value: '$value',
      label: title,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _IconBox(icon: Icons.flag_rounded, isActive: true),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: StudyRepsTheme.warmTextDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: StudyRepsTheme.warmOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: StudyRepsTheme.warmOrange.withOpacity(0.25)),
                  ),
                  child: Text(
                    '$value reps',
                    style: GoogleFonts.outfit(
                      color: StudyRepsTheme.warmOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: StudyRepsTheme.warmOrange,
                inactiveTrackColor: StudyRepsTheme.warmBorder,
                thumbColor: StudyRepsTheme.warmOrange,
                overlayColor: StudyRepsTheme.warmOrange.withOpacity(0.2),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: value.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: (max - min) ~/ 5,
                onChanged: (newValue) =>
                    ref.read(provider.notifier).state = newValue.round(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A generic Setting Item that displays a value and can be tapped
class _SettingOption extends ConsumerWidget {
  final IconData icon;
  final String title;
  final StateProvider<String> valueProvider;
  final VoidCallback onTap;

  const _SettingOption({
    required this.icon,
    required this.title,
    required this.valueProvider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(valueProvider);

    return Semantics(
      button: true,
      label: '$title, current value is $value',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _IconBox(icon: icon, isActive: true),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: StudyRepsTheme.warmTextDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    color: StudyRepsTheme.warmTextMedium,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded,
                    color: StudyRepsTheme.warmTextLight, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A Navigation Item for settings
class _SettingNavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingNavItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _IconBox(icon: icon, isActive: false),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: StudyRepsTheme.warmTextDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: StudyRepsTheme.warmTextLight, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small reusable icon box
class _IconBox extends StatelessWidget {
  final IconData icon;
  final bool isActive;

  const _IconBox({required this.icon, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive
            ? StudyRepsTheme.warmOrange.withOpacity(0.12)
            : StudyRepsTheme.warmChipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? StudyRepsTheme.warmOrange.withOpacity(0.25)
              : Colors.transparent,
        ),
      ),
      child: Icon(
        icon,
        color: isActive ? StudyRepsTheme.warmOrange : StudyRepsTheme.warmTextMedium,
        size: 20,
      ),
    );
  }
}

/// Warm Divider
class _WarmDivider extends StatelessWidget {
  const _WarmDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: StudyRepsTheme.warmBorder.withOpacity(0.5),
      height: 1,
      indent: 76,
    );
  }
}

/// Time Picker Bottom Sheet
class _TimePickerSheet extends ConsumerWidget {
  const _TimePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: StudyRepsTheme.warmCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: StudyRepsTheme.warmBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Set Reminder Time',
            style: GoogleFonts.outfit(
              color: StudyRepsTheme.warmTextDark,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: [
                '08:00 AM',
                '09:00 AM',
                '10:00 AM',
                '12:00 PM',
                '06:00 PM',
                '08:00 PM'
              ].map((time) {
                final isSelected = ref.watch(streakReminderTimeProvider) == time;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                  title: Text(
                    time,
                    style: GoogleFonts.outfit(
                      color: isSelected ? StudyRepsTheme.warmTextDark : StudyRepsTheme.warmTextMedium,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: StudyRepsTheme.warmOrange)
                      : null,
                  onTap: () {
                    ref.read(streakReminderTimeProvider.notifier).state = time;
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// --- Content Studio Card -----------------------------------------------------

/// Settings entry point for the AI Content Pipeline with live pending badge.
class _ContentStudioCard extends StatelessWidget {
  const _ContentStudioCard();

  @override
  Widget build(BuildContext context) {
    final stats = ReviewQueueService.stats;
    final pending = stats['pending'] ?? 0;
    final approved = stats['approved'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: StudyRepsTheme.warmCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => ContentReviewScreen.show(context),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.rate_review_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Content Review Queue',
                          style: GoogleFonts.outfit(
                              color: StudyRepsTheme.warmTextDark,
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 3),
                      Text('$pproved approved � $pending pending review',
                          style: GoogleFonts.outfit(
                              color: StudyRepsTheme.warmTextLight, fontSize: 12)),
                    ],
                  ),
                ),
                if (pending > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: StudyRepsTheme.warmOrange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$pending',
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                  )
                else
                  const Icon(Icons.chevron_right_rounded,
                      color: StudyRepsTheme.warmTextLight, size: 20),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05);
  }
}
