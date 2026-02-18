import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'leaderboard_screen.dart';
import '../providers/video_feed_provider.dart';

/// Main Navigation Shell
/// 
/// Bottom navigation wrapper for all main screens
class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const SwipeGatedFeedScreen(),
    const DiscoverScreen(),
    const SizedBox(), // Placeholder for Create button (opens modal)
    const StreakScreen(),
    const ProfileStatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex, // Skip create index
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgSecondary,
        border: Border(
          top: BorderSide(color: StudyRepsTheme.borderSubtle),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.explore_rounded, 'Discover'),
              _buildCreateButton(),
              _buildNavItem(3, Icons.local_fire_department_rounded, 'Streak'),
              _buildNavItem(4, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? StudyRepsTheme.primaryIndigo.withOpacity(0.15) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? StudyRepsTheme.primaryIndigo 
                  : StudyRepsTheme.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? StudyRepsTheme.primaryIndigo 
                    : StudyRepsTheme.textMuted,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showCreateBottomSheet();
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: StudyRepsTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: StudyRepsTheme.primaryIndigo.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  void _showCreateBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.65,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: StudyRepsTheme.bgSecondary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: StudyRepsTheme.borderSubtle),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: StudyRepsTheme.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Create Rep',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: StudyRepsTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload content and let AI generate study reps',
                  style: TextStyle(color: StudyRepsTheme.textSecondary),
                ),
                const SizedBox(height: 8),
                // AI badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      StudyRepsTheme.primaryPurple.withOpacity(0.2),
                      StudyRepsTheme.accentCyan.withOpacity(0.1),
                    ]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: StudyRepsTheme.primaryPurple.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome,
                          color: StudyRepsTheme.accentCyan, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Powered by Gemini AI',
                        style: TextStyle(
                          color: StudyRepsTheme.accentCyan,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Upload Document (PDF) ──
                _CreateOption(
                  icon: Icons.description_rounded,
                  title: 'Upload Document',
                  subtitle: 'PDF, notes — AI generates study questions',
                  color: const Color(0xFF4285F4),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickDocument();
                  },
                ),
                const SizedBox(height: 12),

                // ── Scan Image ──
                _CreateOption(
                  icon: Icons.camera_alt_rounded,
                  title: 'Scan Image',
                  subtitle: 'Photo of textbook, notes, or diagram',
                  color: const Color(0xFF34A853),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage();
                  },
                ),
                const SizedBox(height: 12),

                // ── Upload Video ──
                _CreateOption(
                  icon: Icons.videocam_rounded,
                  title: 'Upload Video',
                  subtitle: 'Add a video and create questions',
                  color: StudyRepsTheme.primaryIndigo,
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickVideo();
                  },
                ),
                const SizedBox(height: 12),

                // ── Create Question Manually ──
                _CreateOption(
                  icon: Icons.quiz_rounded,
                  title: 'Create Question',
                  subtitle: 'Manually create a rep with your own question',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(ctx);
                    _showManualCreateDialog();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════
  //  FILE PICKERS
  // ═════════════════════════════════════

  /// Pick a PDF document and generate reps via Gemini
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

  /// Pick an image and generate a rep via Gemini Vision
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

  /// Pick a video and open manual create dialog
  Future<void> _pickVideo() async {
    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video == null) return;

      // Open the manual create dialog with the video
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

  /// Show manual create question dialog
  Future<void> _showManualCreateDialog() async {
    final newVideo = await showDialog<VideoModel>(
      context: context,
      builder: (_) => const CreateRepDialog(),
    );

    if (newVideo != null) {
      _addRepsToFeed([newVideo]);
    }
  }

  /// Add generated reps to the feed
  void _addRepsToFeed(List<VideoModel> reps) {
    // Add to local state so they appear immediately in the feed
    ref.read(userCreatedVideosProvider.notifier).update((state) => [...reps, ...state]);

    _showSnackBar(
      '✨ ${reps.length} rep${reps.length > 1 ? 's' : ''} added to your feed!',
      isSuccess: true,
    );
    // Switch to Home tab to show the new reps
    setState(() => _currentIndex = 0);
  }

  // ═════════════════════════════════════
  //  HELPERS
  // ═════════════════════════════════════

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: StudyRepsTheme.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: StudyRepsTheme.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose Source',
                style: TextStyle(
                  color: StudyRepsTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
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
                  const SizedBox(width: 12),
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
        content: Text(msg),
        backgroundColor: isSuccess
            ? StudyRepsTheme.successGreen
            : StudyRepsTheme.errorPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: StudyRepsTheme.bgTertiary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: StudyRepsTheme.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
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
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: StudyRepsTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: StudyRepsTheme.textMuted,
              size: 16,
            ),
          ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
