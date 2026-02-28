import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../domain/models/video_model.dart';
import '../widgets/ai_rep_review_sheet.dart';
import '../widgets/create_rep_dialog.dart';
import 'swipe_gated_feed_screen.dart';
import 'discover_screen.dart';
import 'streak_screen.dart';
import 'profile_stats_screen.dart';
import '../providers/video_feed_provider.dart';

/// Main Navigation Shell
///
/// Implements a floating glassmorphic bottom navigation bar
/// for a premium user experience.
class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    SwipeGatedFeedScreen(),
    DiscoverScreen(),
    SizedBox(), // Placeholder for Create button (opens modal)
    StreakScreen(),
    ProfileStatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudyRepsTheme.bgPrimary,
      extendBody: true, // Required for floating glassmorphic nav bar
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex, // Skip create index
        children: _screens,
      ),
      bottomNavigationBar: _buildFloatingGlassNav(),
    );
  }

  Widget _buildFloatingGlassNav() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, bottom: 32, top: 12),
        child: Semantics(
          label: 'Application Navigation Bar',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: StudyRepsTheme.bgSecondary.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: StudyRepsTheme.borderSubtle.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_rounded, 'Home'),
                    _buildNavItem(1, Icons.explore_rounded, 'Discover'),
                    _buildCreateButton(),
                    _buildNavItem(
                        3, Icons.local_fire_department_rounded, 'Streak'),
                    _buildNavItem(4, Icons.person_rounded, 'Profile'),
                  ],
                ),
              ),
            ),
          ),
        )
            .animate()
            .slideY(begin: 1.0, curve: Curves.easeOutBack, duration: 800.ms),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Navigate to $label tab',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _currentIndex = index);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuint,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: isSelected
                  ? StudyRepsTheme.primaryIndigo.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? StudyRepsTheme.primaryIndigo.withOpacity(0.3)
                    : Colors.transparent,
              )),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  color: isSelected
                      ? StudyRepsTheme.primaryIndigoLight
                      : StudyRepsTheme.textMuted,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: isSelected
                    ? Text(
                        label,
                        style: const TextStyle(
                          color: StudyRepsTheme.primaryIndigoLight,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ).animate().fadeIn()
                    : const SizedBox(width: 0, height: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Semantics(
      button: true,
      label: 'Create new Rep',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          _showGlassCreateSheet();
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: StudyRepsTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: StudyRepsTheme.primaryIndigo.withOpacity(0.5),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  void _showGlassCreateSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const _CreateRepSheet(),
    );
  }
}

/// Glassmorphic Create Rep Sheet
class _CreateRepSheet extends ConsumerStatefulWidget {
  const _CreateRepSheet();

  @override
  ConsumerState<_CreateRepSheet> createState() => _CreateRepSheetState();
}

class _CreateRepSheetState extends ConsumerState<_CreateRepSheet> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: StudyRepsTheme.bgSecondary.withOpacity(0.8),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(
                  color: StudyRepsTheme.borderSubtle.withOpacity(0.5)),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: StudyRepsTheme.borderSubtle,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Create Rep',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: StudyRepsTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),

                  const SizedBox(height: 8),
                  Text(
                    'Upload content and let AI generate study reps',
                    style: TextStyle(
                      color: StudyRepsTheme.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 16),

                  // AI Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                        color: StudyRepsTheme.bgPrimary.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: StudyRepsTheme.accentCyan.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: StudyRepsTheme.accentCyan.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: StudyRepsTheme.accentCyan, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Powered by Gemini AI',
                          style: TextStyle(
                            color: StudyRepsTheme.accentCyan,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(delay: 200.ms),
                  const SizedBox(height: 32),

                  _CreateOption(
                    icon: Icons.description_rounded,
                    title: 'Upload Document',
                    subtitle: 'PDF, notes — AI generates study questions',
                    color: const Color(0xFF4285F4),
                    onTap: () {
                      Navigator.pop(context);
                      _pickDocument();
                    },
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
                  const SizedBox(height: 16),

                  _CreateOption(
                    icon: Icons.camera_alt_rounded,
                    title: 'Scan Image',
                    subtitle: 'Photo of textbook, notes, or diagram',
                    color: const Color(0xFF34A853),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage();
                    },
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
                  const SizedBox(height: 16),

                  _CreateOption(
                    icon: Icons.videocam_rounded,
                    title: 'Upload Video',
                    subtitle: 'Add a video and create questions',
                    color: StudyRepsTheme.primaryIndigoLight,
                    onTap: () {
                      Navigator.pop(context);
                      _pickVideo();
                    },
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),
                  const SizedBox(height: 16),

                  _CreateOption(
                    icon: Icons.quiz_rounded,
                    title: 'Create Question',
                    subtitle: 'Manually create a rep with your own question',
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.pop(context);
                      _showManualCreateDialog();
                    },
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),

                  const SizedBox(height: 48), // Bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════
  //  FILE PICKERS
  // ═════════════════════════════════════

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.bytes == null) {
        _showSnackBar('Could not read the file');
        return;
      }

      final mimeType = _getDocMimeType(file.extension ?? 'pdf');

      if (!mounted) return;
      final reps = await AiRepReviewSheet.show(
        context,
        fileBytes: file.bytes!,
        mimeType: mimeType,
        fileName: file.name,
        isMultiple: true,
      );

      if (reps != null && reps.isNotEmpty) {
        _addRepsToFeed(reps);
      }
    } catch (e) {
      _showSnackBar('Error picking document: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? photo = await picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (photo == null) return;
      final bytes = await photo.readAsBytes();
      final mimeType = _getImageMimeType(photo.name);

      if (!mounted) return;
      final reps = await AiRepReviewSheet.show(
        context,
        fileBytes: bytes,
        mimeType: mimeType,
        fileName: photo.name,
        isMultiple: false,
      );

      if (reps != null && reps.isNotEmpty) {
        _addRepsToFeed(reps);
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video == null) return;

      if (!mounted) return;
      final newVideo = await showDialog<VideoModel>(
        context: context,
        builder: (_) => const CreateRepDialog(),
      );

      if (newVideo != null) {
        _addRepsToFeed([newVideo]);
      }
    } catch (e) {
      _showSnackBar('Error picking video: $e');
    }
  }

  Future<void> _showManualCreateDialog() async {
    final newVideo = await showDialog<VideoModel>(
      context: context,
      builder: (_) => const CreateRepDialog(),
    );

    if (newVideo != null && mounted) {
      _addRepsToFeed([newVideo]);
    }
  }

  void _addRepsToFeed(List<VideoModel> reps) {
    ref
        .read(userCreatedVideosProvider.notifier)
        .update((state) => [...reps, ...state]);
    _showSnackBar(
        '✨ ${reps.length} rep${reps.length > 1 ? 's' : ''} added to your feed!',
        isSuccess: true);
  }

  // ═════════════════════════════════════
  //  HELPERS
  // ═════════════════════════════════════

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: StudyRepsTheme.bgSecondary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: StudyRepsTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Choose Image Source',
                style: TextStyle(
                  color: StudyRepsTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: const Color(0xFF4285F4),
                      onTap: () => Navigator.pop(ctx, ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      color: const Color(0xFF34A853),
                      onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  String _getDocMimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/pdf';
    }
  }

  String _getImageMimeType(String filename) {
    final ext = filename.toLowerCase().split('.').last;
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  void _showSnackBar(String msg, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style:
              const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor:
            isSuccess ? StudyRepsTheme.successGreen : StudyRepsTheme.errorPink,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 10,
      ),
    );
  }
}

/// A highly stylized option tile for the create bottom sheet
class _CreateOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _CreateOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title, $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          highlightColor: color.withOpacity(0.1),
          splashColor: color.withOpacity(0.2),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: StudyRepsTheme.bgPrimary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: StudyRepsTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: StudyRepsTheme.textSecondary,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: StudyRepsTheme.textMuted,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small source button for Camera/Gallery picker
class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: StudyRepsTheme.bgPrimary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
