import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/study_reps_theme.dart';
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

/// Settings Screen
/// 
/// User preferences, account settings, and app configuration
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: StudyRepsTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: StudyRepsTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: StudyRepsTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildProfileSection(context),
            
            const SizedBox(height: 24),
            
            // Learning Preferences
            _buildSectionHeader('Learning Preferences'),
            _buildSettingsCard([
              _SettingToggle(
                icon: Icons.lock_clock_rounded,
                title: 'Auto Lock',
                subtitle: 'Pause videos at lock points',
                provider: autoLockEnabledProvider,
              ),
              _SettingsSlider(
                icon: Icons.flag_rounded,
                title: 'Daily Goal',
                provider: dailyGoalProvider,
                min: 5,
                max: 50,
              ),
              _SettingOption(
                icon: Icons.alarm_rounded,
                title: 'Reminder Time',
                value: ref.watch(streakReminderTimeProvider),
                onTap: () => _showTimePicker(context, ref),
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // Playback Settings
            _buildSectionHeader('Playback'),
            _buildSettingsCard([
              _SettingToggle(
                icon: Icons.play_circle_outlined,
                title: 'Auto-play Videos',
                subtitle: 'Play next video automatically',
                provider: autoPlayVideosProvider,
              ),
              _SettingToggle(
                icon: Icons.surround_sound_rounded,
                title: 'Sound Effects',
                subtitle: 'UI sounds and feedback',
                provider: soundEffectsEnabledProvider,
              ),
              _SettingToggle(
                icon: Icons.vibration_rounded,
                title: 'Haptic Feedback',
                subtitle: 'Vibrate on interactions',
                provider: hapticFeedbackEnabledProvider,
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // Appearance
            _buildSectionHeader('Appearance'),
            _buildSettingsCard([
              _SettingToggle(
                icon: Icons.dark_mode_rounded,
                title: 'Dark Mode',
                subtitle: 'Always on for the best experience',
                provider: darkModeEnabledProvider,
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // Notifications
            _buildSectionHeader('Notifications'),
            _buildSettingsCard([
              _SettingToggle(
                icon: Icons.notifications_active_rounded,
                title: 'Push Notifications',
                subtitle: 'Streak reminders & updates',
                provider: notificationsEnabledProvider,
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // Account
            _buildSectionHeader('Account'),
            _buildSettingsCard([
              _SettingNavItem(
                icon: Icons.person_rounded,
                title: 'Edit Profile',
                onTap: () {},
              ),
              _SettingNavItem(
                icon: Icons.lock_outline_rounded,
                title: 'Change Password',
                onTap: () {},
              ),
              _SettingNavItem(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                onTap: () {},
              ),
              _SettingNavItem(
                icon: Icons.info_outline_rounded,
                title: 'About',
                onTap: () {},
              ),
            ]),
            
            const SizedBox(height: 32),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                         MaterialPageRoute(builder: (_) => const LoginScreen()),
                         (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: StudyRepsTheme.errorPink),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: StudyRepsTheme.errorPink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: StudyRepsTheme.errorPink),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // App Version
            Center(
              child: Text(
                'StudyReps v1.0.0',
                style: TextStyle(
                  color: StudyRepsTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            StudyRepsTheme.primaryIndigo.withOpacity(0.2),
            StudyRepsTheme.bgSecondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: StudyRepsTheme.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: StudyRepsTheme.primaryIndigo, width: 2),
            ),
            child: const CircleAvatar(
              backgroundColor: StudyRepsTheme.bgTertiary,
              child: Icon(Icons.person_rounded, color: StudyRepsTheme.textSecondary, size: 30),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '@StudentPro',
                  style: TextStyle(
                    color: StudyRepsTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'student@example.com',
                  style: TextStyle(
                    color: StudyRepsTheme.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: StudyRepsTheme.primaryIndigo,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'PRO',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: StudyRepsTheme.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StudyRepsTheme.borderSubtle),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
                Divider(
                  color: StudyRepsTheme.borderSubtle,
                  height: 1,
                  indent: 56,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showTimePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: StudyRepsTheme.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set Reminder Time',
              style: TextStyle(
                color: StudyRepsTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            ...['08:00 AM', '09:00 AM', '10:00 AM', '12:00 PM', '06:00 PM', '08:00 PM'].map(
              (time) => ListTile(
                title: Text(time, style: const TextStyle(color: StudyRepsTheme.textPrimary)),
                trailing: ref.watch(streakReminderTimeProvider) == time
                    ? Icon(Icons.check_circle_rounded, color: StudyRepsTheme.primaryIndigo)
                    : null,
                onTap: () {
                  ref.read(streakReminderTimeProvider.notifier).state = time;
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

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
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: StudyRepsTheme.primaryIndigo.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: StudyRepsTheme.primaryIndigo, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: StudyRepsTheme.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: StudyRepsTheme.textMuted,
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: isEnabled,
        onChanged: (value) => ref.read(provider.notifier).state = value,
        activeColor: StudyRepsTheme.primaryIndigo,
        activeTrackColor: StudyRepsTheme.primaryIndigo.withOpacity(0.3),
        inactiveThumbColor: StudyRepsTheme.textMuted,
        inactiveTrackColor: StudyRepsTheme.bgTertiary,
      ),
    );
  }
}

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
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: StudyRepsTheme.primaryIndigo.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: StudyRepsTheme.primaryIndigo, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: StudyRepsTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: StudyRepsTheme.primaryIndigo,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$value reps',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: StudyRepsTheme.primaryIndigo,
              inactiveTrackColor: StudyRepsTheme.bgTertiary,
              thumbColor: StudyRepsTheme.primaryIndigo,
              overlayColor: StudyRepsTheme.primaryIndigo.withOpacity(0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: (max - min) ~/ 5,
              onChanged: (newValue) => ref.read(provider.notifier).state = newValue.round(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _SettingOption({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: StudyRepsTheme.primaryIndigo.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: StudyRepsTheme.primaryIndigo, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: StudyRepsTheme.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: StudyRepsTheme.textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: StudyRepsTheme.textMuted),
        ],
      ),
      onTap: onTap,
    );
  }
}

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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: StudyRepsTheme.bgTertiary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: StudyRepsTheme.textSecondary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: StudyRepsTheme.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: StudyRepsTheme.textMuted),
      onTap: onTap,
    );
  }
}
