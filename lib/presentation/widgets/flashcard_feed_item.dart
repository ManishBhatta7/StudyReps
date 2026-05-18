import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../domain/models/video_model.dart';
import '../../data/services/spaced_repetition_service.dart';
import '../../data/services/gemini_coach_service.dart';
import '../providers/streak_provider.dart';
import '../providers/xp_provider.dart';
import '../providers/video_feed_provider.dart';
import '../providers/achievement_provider.dart';
import '../widgets/lock_overlay.dart';
import '../widgets/xp_reward_overlay.dart';
import '../widgets/achievement_unlock_toast.dart';
import '../widgets/video_tutorbot_sheet.dart';
import '../widgets/comment_section.dart';

/// A full-screen flashcard feed item that replaces the video player
/// when the content type is [ContentType.flashcard].
///
/// Flow:
/// 1. User sees the flashcard front (concept explanation) with a read timer.
/// 2. After a few seconds (or user tap), the question gate appears.
/// 3. User answers → AI validates → XP/streak awarded on correct answer.
class FlashcardFeedItem extends ConsumerStatefulWidget {
  final VideoModel video; // Reusing VideoModel with contentType == flashcard
  final bool isActive;
  final VoidCallback onLockTriggered;
  final VoidCallback onUnlockAndAdvance;

  const FlashcardFeedItem({
    super.key,
    required this.video,
    required this.isActive,
    required this.onLockTriggered,
    required this.onUnlockAndAdvance,
  });

  @override
  ConsumerState<FlashcardFeedItem> createState() => _FlashcardFeedItemState();
}

class _FlashcardFeedItemState extends ConsumerState<FlashcardFeedItem>
    with TickerProviderStateMixin {
  // Question gate state
  bool _showGate = false;
  bool _isAnswered = false;
  bool _isChecking = false;
  bool _isCorrect = false;
  bool _isIncorrect = false;
  String? _aiFeedback;

  // Read timer
  bool _hasReadCard = false;
  static const int _readDelaySeconds = 4;

  // Interaction state
  late bool _isLiked;
  late int _likesCount;
  late bool _isSaved;

  // Animation
  late AnimationController _shakeController;
  late AnimationController _pulseController;

  // Dwell time
  final Stopwatch _dwellStopwatch = Stopwatch();
  int _attemptCount = 0;

  // Subject color mapping
  Color get _subjectColor {
    switch (widget.video.subject.toLowerCase()) {
      case 'physics':
        return const Color(0xFF6366F1); // Indigo
      case 'chemistry':
        return const Color(0xFF10B981); // Emerald
      case 'biology':
        return const Color(0xFFF472B6); // Pink
      case 'mathematics':
      case 'math':
        return const Color(0xFFF59E0B); // Amber
      case 'history':
        return const Color(0xFFEF4444); // Red
      default:
        return StudyRepsTheme.warmOrange;
    }
  }

  IconData get _subjectIcon {
    switch (widget.video.subject.toLowerCase()) {
      case 'physics':
        return Icons.bolt_rounded;
      case 'chemistry':
        return Icons.science_rounded;
      case 'biology':
        return Icons.biotech_rounded;
      case 'mathematics':
      case 'math':
        return Icons.functions_rounded;
      case 'history':
        return Icons.history_edu_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    _isLiked = widget.video.isLiked;
    _likesCount = widget.video.likesCount;
    _isSaved = widget.video.isSaved;

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _dwellStopwatch.start();

    // Auto-show gate after read delay
    if (widget.isActive) {
      _startReadTimer();
    }
  }

  void _startReadTimer() {
    Future.delayed(Duration(seconds: _readDelaySeconds), () {
      if (mounted && !_hasReadCard && !_showGate && !_isAnswered) {
        setState(() {
          _hasReadCard = true;
          _showGate = true;
        });
        widget.onLockTriggered();
      }
    });
  }

  @override
  void didUpdateWidget(FlashcardFeedItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startReadTimer();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _showGateNow() {
    if (_showGate || _isAnswered) return;
    setState(() {
      _hasReadCard = true;
      _showGate = true;
    });
    widget.onLockTriggered();
  }

  Future<void> _handleAnswerSubmit(String answer) async {
    if (_isChecking || _isAnswered) return;

    setState(() {
      _isChecking = true;
      _isCorrect = false;
      _isIncorrect = false;
      _aiFeedback = null;
    });

    try {
      final result = await GeminiCoachService.validateAnswer(
        userAnswer: answer,
        correctAnswer: widget.video.question.correctAnswer,
        questionPrompt: widget.video.question.prompt,
      );

      if (!mounted) return;

      setState(() {
        _isChecking = false;
        if (result.isCorrect) {
          _isCorrect = true;
          _handleCorrectAnswer();
        } else {
          _isIncorrect = true;
          _aiFeedback = result.feedback;
          _handleWrongAnswer();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isChecking = false;
        _isIncorrect = true;
        _aiFeedback = 'Failed to connect to AI Coach. Try again.';
        _handleWrongAnswer();
      });
    }
  }

  void _handleCorrectAnswer() {
    setState(() => _isAnswered = true);
    _dwellStopwatch.stop();

    SpacedRepetitionService.recordInteraction(
      userId: 'local_user',
      videoId: widget.video.id,
      isCorrect: true,
      dwellTimeMs: _dwellStopwatch.elapsedMilliseconds,
      quality: _attemptCount <= 1 ? 5 : 3,
    );

    final oldXpState = ref.read(xpProvider).valueOrNull;
    final oldLevel = oldXpState?.currentLevel ?? 1;

    ref.read(streakProvider.notifier).logRep();
    ref.read(xpProvider.notifier).addXp();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final newXpState = ref.read(xpProvider).valueOrNull;
      final newLevel = newXpState?.currentLevel ?? oldLevel;
      final xpGained = newXpState?.recentXpGain ?? 15;
      final streakState = ref.read(streakProvider).valueOrNull;
      final hitDailyGoal = streakState?.todayReps == 10;

      XpRewardOverlay.show(
        context,
        xpGained: xpGained,
        newLevel: newLevel,
        oldLevel: oldLevel,
        currentStreak: streakState?.currentStreak,
        hitDailyGoal: hitDailyGoal,
      );
      _checkAchievementUnlocks();
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() => _showGate = false);
        widget.onUnlockAndAdvance();
      }
    });
  }

  Future<void> _checkAchievementUnlocks() async {
    try {
      ref.invalidate(achievementProvider);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      final achievements = ref.read(achievementProvider).valueOrNull ?? [];
      final newlyUnlocked = achievements
          .where((a) =>
              a.isUnlocked &&
              a.unlockedAt != null &&
              DateTime.now().difference(a.unlockedAt!).inSeconds < 10)
          .toList();

      for (int i = 0; i < newlyUnlocked.length; i++) {
        final ach = newlyUnlocked[i];
        Future.delayed(Duration(milliseconds: i * 1500), () {
          if (mounted) {
            AchievementUnlockToast.show(
              context,
              title: ach.title,
              emoji: ach.icon,
              description: ach.description,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('🏆 Achievement check error: $e');
    }
  }

  void _handleWrongAnswer() {
    _attemptCount++;

    SpacedRepetitionService.recordInteraction(
      userId: 'local_user',
      videoId: widget.video.id,
      isCorrect: false,
      dwellTimeMs: _dwellStopwatch.elapsedMilliseconds,
      quality: 1,
    );

    _aiFeedback ??=
        'Not quite. Think about the core principles. Try again!';
    _shakeController.forward().then((_) => _shakeController.reset());
  }

  void _handleTryAgain() {
    setState(() {
      _isIncorrect = false;
      _aiFeedback = null;
    });
  }

  Future<void> _toggleLike() async {
    final newStatus = !_isLiked;
    final newCount = _isLiked ? _likesCount - 1 : _likesCount + 1;
    setState(() {
      _isLiked = newStatus;
      _likesCount = newCount;
    });

    try {
      final repo = ref.read(videosRepositoryProvider);
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'anon';
      await repo.toggleLike(widget.video.id, userId);
    } catch (e) {
      setState(() {
        _isLiked = !newStatus;
        _likesCount = _isLiked ? _likesCount + 1 : _likesCount - 1;
      });
    }
  }

  Future<void> _toggleSave() async {
    final newStatus = !_isSaved;
    setState(() => _isSaved = newStatus);

    try {
      final repo = ref.read(videosRepositoryProvider);
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'anon';
      await repo.toggleSave(widget.video.id, userId);
    } catch (e) {
      setState(() => _isSaved = !newStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final emoji = widget.video.flashcardEmoji.isNotEmpty
        ? widget.video.flashcardEmoji
        : '🧠';

    return Container(
      color: const Color(0xFF0A0A0F),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── FLASHCARD BACKGROUND ──
          _buildFlashcardBackground(),

          // ── FLASHCARD CONTENT ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 60), // Space for top bar

                  // ── Subject Badge ──
                  _buildSubjectBadge(),

                  const SizedBox(height: 24),

                  // ── Emoji Header ──
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 48),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1.0, 1.0),
                          duration: 500.ms,
                          curve: Curves.elasticOut),

                  const SizedBox(height: 16),

                  // ── Title ──
                  Text(
                    widget.video.title,
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 20),

                  // ── Flashcard Front Text (the "teach" content) ──
                  Expanded(
                    child: _buildFlashcardContent(),
                  ),

                  // ── "Test Yourself" CTA ──
                  if (!_showGate && !_isAnswered)
                    _buildTestYourselfButton()
                        .animate()
                        .fadeIn(delay: Duration(seconds: _readDelaySeconds - 1)),

                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),

          // ── Action Bar (right side) ──
          _buildActionBar(),

          // ── Bottom Info ──
          _buildBottomInfo(),

          // ── "FLASHCARD" Badge (top left) ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _subjectColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _subjectColor.withOpacity(0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.style_rounded,
                      color: _subjectColor, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Flashcard',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _subjectColor,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),
          ),

          // ── QUESTION GATE ──
          if (_showGate)
            LockOverlay(
              video: widget.video,
              isChecking: _isChecking,
              isCorrect: _isCorrect,
              isIncorrect: _isIncorrect,
              aiFeedback: _aiFeedback,
              onCorrectAnswer: _handleCorrectAnswer,
              onSubmit: _handleAnswerSubmit,
              onTryAgain: _handleTryAgain,
            ),
        ],
      ),
    );
  }

  Widget _buildFlashcardBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _subjectColor.withOpacity(0.15),
              const Color(0xFF0A0A0F),
              const Color(0xFF0A0A0F),
              _subjectColor.withOpacity(0.08),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _subjectColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _subjectColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_subjectIcon, color: _subjectColor, size: 16),
          const SizedBox(width: 6),
          Text(
            widget.video.subject,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _subjectColor,
            ),
          ),
          if (widget.video.difficultyLevel > 0) ...[
            const SizedBox(width: 8),
            ...List.generate(
              widget.video.difficultyLevel.clamp(1, 5),
              (i) => Padding(
                padding: const EdgeInsets.only(left: 1),
                child: Icon(
                  Icons.circle,
                  size: 5,
                  color: _subjectColor.withOpacity(
                      i < widget.video.difficultyLevel ? 1.0 : 0.3),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 50.ms, duration: 300.ms);
  }

  Widget _buildFlashcardContent() {
    final frontText = widget.video.flashcardFrontText;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Did you know?" label
            Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded,
                    color: _subjectColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Learn this concept',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _subjectColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main content text
            Text(
              frontText.isNotEmpty ? frontText : widget.video.title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
              ),
            ),

            // Tags
            if (widget.video.tags.isNotEmpty) ...[
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: widget.video.tags.take(4).map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _subjectColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#$tag',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _subjectColor.withOpacity(0.8),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      )
          .animate()
          .fadeIn(delay: 200.ms, duration: 500.ms)
          .slideY(begin: 0.05, end: 0),
    );
  }

  Widget _buildTestYourselfButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: _showGateNow,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1.0 + (_pulseController.value * 0.03);
            return Transform.scale(
              scale: scale,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_subjectColor, _subjectColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: _subjectColor.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.fitness_center_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Test Yourself',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Positioned(
      left: 16,
      right: 80,
      bottom: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Creator
          Row(
            children: [
              Text(
                '@${widget.video.creatorName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 1),
                        blurRadius: 2)
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.auto_awesome,
                  color: _subjectColor, size: 14),
            ],
          ),
          const SizedBox(height: 6),

          // Concept cluster
          if (widget.video.conceptCluster.isNotEmpty)
            Text(
              widget.video.conceptCluster.replaceAll('_', ' '),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Positioned(
      right: 8,
      bottom: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI Coach
          _buildActionButton(
            icon: Icons.psychology_rounded,
            label: 'Coach',
            onTap: () => VideoTutorbotSheet.show(context, widget.video),
          ),
          const SizedBox(height: 20),

          // Like
          _buildLikeButton(),
          const SizedBox(height: 20),

          // Discuss
          _buildActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Discuss',
            onTap: () => CommentSection.show(context, widget.video.id),
          ),
          const SizedBox(height: 20),

          // Save
          _buildSaveButton(),
          const SizedBox(height: 20),

          // Share
          _buildActionButton(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: () async {
              ref
                  .read(videosRepositoryProvider)
                  .logShare(widget.video.id, platform: 'link');
              final shareText =
                  '💪 Check out "${widget.video.title}" on StudyReps!\n\n'
                  'Learn through micro-struggles — one rep at a time.\n'
                  'https://studyreps.app/card/${widget.video.id}';
              await Clipboard.setData(ClipboardData(text: shareText));
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.greenAccent, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                          child:
                              Text('Share link copied! Paste it anywhere 🚀')),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLikeButton() {
    return GestureDetector(
      onTap: _toggleLike,
      child: Column(
        children: [
          Icon(
            _isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: _isLiked ? StudyRepsTheme.errorPink : Colors.white,
            size: 32,
            shadows: const [
              Shadow(
                  color: Colors.black54,
                  offset: Offset(0, 2),
                  blurRadius: 6),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$_likesCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                    color: Colors.black54,
                    offset: Offset(0, 1),
                    blurRadius: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _toggleSave,
      child: Column(
        children: [
          Icon(
            _isSaved
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            color: _isSaved ? StudyRepsTheme.warmOrange : Colors.white,
            size: 32,
            shadows: const [
              Shadow(
                  color: Colors.black54,
                  offset: Offset(0, 2),
                  blurRadius: 6),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _isSaved ? 'Saved' : 'Save',
            style: TextStyle(
              color: _isSaved ? StudyRepsTheme.warmOrange : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              shadows: const [
                Shadow(
                    color: Colors.black54,
                    offset: Offset(0, 1),
                    blurRadius: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
