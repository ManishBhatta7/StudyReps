import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/study_reps_theme.dart';
import '../providers/video_feed_provider.dart';
import '../../domain/models/video_model.dart';
import '../../data/services/spaced_repetition_service.dart';
import '../providers/adaptive_feed_provider.dart';
import '../../data/services/gemini_coach_service.dart';
import '../providers/streak_provider.dart';
import '../providers/xp_provider.dart';
import '../widgets/lock_overlay.dart';
import '../widgets/mascot_reactor.dart';
import '../widgets/video_tutorbot_sheet.dart';
import '../widgets/comment_section.dart';
import '../widgets/explain_storyboard_sheet.dart';
import '../widgets/drill_flashcard_sheet.dart';
import '../widgets/quiz_assessment_sheet.dart';
import '../widgets/xp_reward_overlay.dart';
import '../widgets/achievement_unlock_toast.dart';
import '../providers/achievement_provider.dart';
import '../widgets/flashcard_feed_item.dart';


/// Swipe-Gated Video Feed Screen
/// Users cannot swipe until they answer the question correctly
class SwipeGatedFeedScreen extends ConsumerStatefulWidget {
  final List<VideoModel>? initialVideos;
  final int initialIndex;

  const SwipeGatedFeedScreen({
    super.key,
    this.initialVideos,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<SwipeGatedFeedScreen> createState() => _SwipeGatedFeedScreenState();
}

class _SwipeGatedFeedScreenState extends ConsumerState<SwipeGatedFeedScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isLocked = false; // Can user swipe?
  
  List<VideoModel> _videos = [];

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    if (widget.initialVideos != null && widget.initialVideos!.isNotEmpty) {
      _videos = widget.initialVideos!;
    } else {
      _loadAdaptiveFeed();
    }
  }

  Future<void> _loadAdaptiveFeed() async {
    final feed = await ref.read(adaptiveFeedProvider.future);
    if (mounted) {
      setState(() {
        _videos = feed;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Lock the feed (prevent swiping)
  void _lockFeed() {
    setState(() => _isLocked = true);
  }

  // Unlock and animate to next video
  void _unlockAndAdvance() {
    setState(() => _isLocked = false);
    
    // Animate to next video
    if (_currentPage < _videos.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // Listen for feed updates (e.g. from fallback or new reps)
    ref.listen(adaptiveFeedProvider, (previous, next) {
      next.whenData((feed) {
        if (feed.isNotEmpty) {
          // If we have no videos, or if the feed was just reloaded/updated
          // We update the local state.
          // Note: Only update if empty to avoid disrupting current view, 
          // unless we want to force refresh on new content.
          if (_videos.isEmpty) {
            setState(() {
              _videos = feed;
            });
            // If we just loaded fresh content, ensure we're at page 0
            if (_pageController.hasClients) {
               _pageController.jumpToPage(0);
            }
          }
        }
      });
    });

    return Scaffold(
      backgroundColor: StudyRepsTheme.warmCream,
      body: Stack(
        children: [
          if (_videos.isEmpty)
            _buildEmptyState()
          else
            NotificationListener<ScrollNotification>(
              // SWIPE GATE: Block scroll when locked
              onNotification: (notification) {
                if (_isLocked && notification is ScrollUpdateNotification) {
                  // Force scroll back to current page
                  _pageController.jumpToPage(_currentPage);
                  return true; // Block the scroll
                }
                return false;
              },
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                physics: _isLocked 
                    ? const NeverScrollableScrollPhysics() 
                    : null, // Use platform default (PageScrollPhysics) for better snap
                itemCount: _videos.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                    _isLocked = false; // Reset lock on new video
                  });
                },
                itemBuilder: (context, index) {
                  return HorizontalMatrixItem(
                    video: _videos[index],
                    isActive: _currentPage == index,
                    onLockTriggered: _lockFeed,
                    onUnlockAndAdvance: _unlockAndAdvance,
                  );
                },
              ),
            ),
          

        ],
      ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MascotReactor(state: MascotState.idle, size: 150),
          const SizedBox(height: 24),
          Text(
            'No Reps Yet!',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: StudyRepsTheme.warmTextDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create your first spaced repetition\nvideo to get started.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 17,
              color: StudyRepsTheme.warmTextMedium,
            ),
          ),
          const SizedBox(height: 48),
          // Arrow pointing to FAB
          const Icon(
            Icons.arrow_downward_rounded,
            color: StudyRepsTheme.warmOrange,
            size: 32,
          ),
        ],
      ),
    );
  }
}

/// Individual Video Item with Loop Tracking and Question Gate
class SwipeGatedVideoItem extends ConsumerStatefulWidget {
  final VideoModel video;
  final bool isActive;
  final bool isReviewItem;
  final VoidCallback onLockTriggered;
  final VoidCallback onUnlockAndAdvance;

  const SwipeGatedVideoItem({
    super.key,
    required this.video,
    required this.isActive,
    this.isReviewItem = false,
    required this.onLockTriggered,
    required this.onUnlockAndAdvance,
  });

  @override
  ConsumerState<SwipeGatedVideoItem> createState() => _SwipeGatedVideoItemState();
}

class _SwipeGatedVideoItemState extends ConsumerState<SwipeGatedVideoItem> 
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  YoutubePlayerController? _ytController;
  bool _isInitialized = false;
  bool _isYoutube = false;
  // Loop tracking
  int _loopCount = 0;
  static const int _maxLoops = 2;
  
  // Question gate state
  bool _showGate = false;
  bool _isAnswered = false; // true when correct
  bool _isChecking = false;
  bool _isCorrect = false;
  bool _isIncorrect = false;
  String? _aiFeedback;
  QuestionModel? _dynamicQuestion; // 🎯 AI-generated question context
  
  // ── Expert Video vs AI Coaching Toggle ──
  bool _isAiCoachingMode = false;
  
  // Interaction State
  late bool _isLiked;
  late int _likesCount;
  late bool _isSaved;
  
  // Animation
  late AnimationController _shakeController;
  
  // ── Adaptive Feed: Dwell Time Tracking ──
  final Stopwatch _dwellStopwatch = Stopwatch();
  int _attemptCount = 0;
  
  // Dim factor for loop 2
  double get _dimFactor => _loopCount >= 1 ? 0.7 : 1.0;

  // Play/Pause Overlay State
  bool _showPlayPauseOverlay = false;
  bool _isPlaying = true; // defaulting to true as we auto-play
  IconData _overlayIcon = Icons.pause;

  void _togglePlayPause() {
    if (_showGate) return; // Don't toggle if gate is active

    setState(() {
      if (_isYoutube && _ytController != null) {
        // Toggle YT playback
        // Note: YT player iframe doesn't have a simple isPlaying property easily accessible, 
        // we'll toggle based on our local state which is updated via listener or just by calling play/pause.
        if (_isPlaying) {
          _ytController!.pauseVideo();
          _isPlaying = false;
          _overlayIcon = Icons.play_arrow_rounded;
        } else {
          _ytController!.playVideo();
          _isPlaying = true;
          _overlayIcon = Icons.pause_rounded;
        }
        _showPlayPauseOverlay = true;
      } else if (_controller != null && _controller!.value.isInitialized) {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
          _isPlaying = false;
          _overlayIcon = Icons.play_arrow_rounded;
        } else {
          _controller!.play();
          _isPlaying = true;
          _overlayIcon = Icons.pause_rounded;
        }
        _showPlayPauseOverlay = true;
      }
      
      // Hide overlay after animation
      if (_isPlaying) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted && _isPlaying) {
            setState(() => _showPlayPauseOverlay = false);
          }
        });
      }
    });
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
    _dwellStopwatch.start();
    _initializeVideo();
    _prefetchDynamicQuestion(); // 🎯 Start AI generation in background
  }

  Future<void> _prefetchDynamicQuestion() async {
    // Only generate if we have a transcript to work with
    if (widget.video.transcript.isNotEmpty) {
      try {
        final aiQuestion = await GeminiCoachService.generateDynamicQuestion(widget.video);
        if (mounted) {
          setState(() {
            _dynamicQuestion = aiQuestion;
          });
          debugPrint('✨ AI Question Generated for ${widget.video.id}: ${aiQuestion.prompt}');
        }
      } catch (e) {
        debugPrint('⚠️ AI Question Prefetch failed: $e');
      }
    }
  }

  /// Use the dynamic question if available, otherwise fallback to hardcoded
  QuestionModel get _activeQuestion => _dynamicQuestion ?? widget.video.question;

  Future<void> _initializeVideo() async {
    final url = widget.video.videoUrl;
    _isYoutube = url.contains('youtube.com') || url.contains('youtu.be');

    try {
      if (_isYoutube) {
        final videoId = YoutubePlayerController.convertUrlToId(url);
        if (videoId != null) {
          _ytController = YoutubePlayerController.fromVideoId(
            videoId: videoId,
            autoPlay: false, // Wait for activation
            startSeconds: widget.video.startSeconds.toDouble(),
            endSeconds: widget.video.endSeconds?.toDouble(),
            params: const YoutubePlayerParams(
              showControls: false, // We use our own UI
              showFullscreenButton: false,
              mute: false,
              loop: false, // We handle loop
              pointerEvents: PointerEvents.none, // Allow our taps to pass through
            ),
          );

          // YT states: unStarted(-1), ended(0), playing(1), paused(2), buffering(3), videoCued(5)
          _ytController!.listen((state) async {
             // 🎯 Lock at specific timestamp if set (Active Recall)
             final position = await _ytController!.currentTime;
             if (widget.video.lockTimestamp > 0 && 
                 position >= widget.video.lockTimestamp && 
                 !_isAnswered && !_showGate) {
                _ytController!.pauseVideo();
                if (mounted) setState(() => _showGate = true);
                widget.onLockTriggered();
             }

             if (state.playerState == PlayerState.ended) {
                _handleLoopComplete();
             }
          });

          if (mounted) {
            setState(() => _isInitialized = true);
            if (widget.isActive) {
              _ytController!.playVideo();
              ref.read(videosRepositoryProvider).logView(widget.video.id);
            }
          }
        }
      } else {
        // Non-YouTube URL — on web we cannot reliably play arbitrary MP4s
        if (kIsWeb) {
          // Gracefully skip: show initialized=true but no controller
          // The build will show a placeholder instead of crashing
          debugPrint('⚠️ Skipping non-YouTube video on web: $url');
          if (mounted) setState(() => _isInitialized = true);
          return;
        }

        // Native platforms: use video_player normally
        if (url.startsWith('assets/')) {
          _controller = VideoPlayerController.asset(url);
        } else {
          _controller = VideoPlayerController.networkUrl(Uri.parse(url));
        }

        await _controller!.initialize();
        _controller!.setLooping(false);
        _controller!.addListener(_onVideoProgress);

        if (mounted) {
          setState(() => _isInitialized = true);
          if (widget.isActive) {
            _controller!.play();
            ref.read(videosRepositoryProvider).logView(widget.video.id);
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error initializing video: $e');
      if (mounted) {
        setState(() => _isInitialized = false);
      }
    }
  }

  void _onVideoProgress() {
    if (!mounted || _controller == null) return;
    
    final position = _controller!.value.position;
    final duration = _controller!.value.duration;
    
    // 🎯 Lock at specific timestamp if set (Active Recall)
    if (widget.video.lockTimestamp > 0 && 
        position.inSeconds >= widget.video.lockTimestamp && 
        !_isAnswered && !_showGate) {
      _controller!.pause();
      setState(() => _showGate = true);
      widget.onLockTriggered();
      return;
    }

    // Check if video completed a loop
    if (position >= duration - const Duration(milliseconds: 200)) {
      _handleLoopComplete();
    }
  }

  void _handleLoopComplete() {
    _loopCount++;
    // debugPrint('🔄 Loop $_loopCount completed');
    
    if (_isYoutube) {
      if (_loopCount >= _maxLoops && !_isAnswered) {
        _ytController!.pauseVideo();
        setState(() => _showGate = true);
        widget.onLockTriggered();
      } else if (!_isAnswered) {
        _ytController!.seekTo(seconds: 0);
        _ytController!.playVideo();
        setState(() {});
      }
    } else {
      if (_loopCount >= _maxLoops && !_isAnswered) {
        // LOCK THE FEED
        _controller!.pause();
        setState(() => _showGate = true);
        widget.onLockTriggered();
      } else if (!_isAnswered) {
        // Restart for next loop
        _controller!.seekTo(Duration.zero);
        _controller!.play();
        setState(() {}); // Trigger dim update
      }
    }
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
        correctAnswer: _activeQuestion.correctAnswer,
        questionPrompt: _activeQuestion.prompt,
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
    
    // Log learning record for adaptive algorithm
    SpacedRepetitionService.recordInteraction(
      userId: 'local_user',
      videoId: widget.video.id,
      isCorrect: true,
      dwellTimeMs: _dwellStopwatch.elapsedMilliseconds,
      quality: _attemptCount <= 1 ? 5 : 3, // Perfect if first try
    );

    // Capture old XP state BEFORE awarding
    final oldXpState = ref.read(xpProvider).valueOrNull;
    final oldLevel = oldXpState?.currentLevel ?? 1;

    // Track the streak & rep completion
    ref.read(streakProvider.notifier).logRep();
    
    // Add XP!
    ref.read(xpProvider.notifier).addXp();
    
    // Show XP reward overlay with level-up detection
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final newXpState = ref.read(xpProvider).valueOrNull;
      final newLevel = newXpState?.currentLevel ?? oldLevel;
      final xpGained = newXpState?.recentXpGain ?? 15;
      final streakState = ref.read(streakProvider).valueOrNull;
      final hitDailyGoal = streakState?.todayReps == 10; // Exactly hit the goal

      XpRewardOverlay.show(
        context,
        xpGained: xpGained,
        newLevel: newLevel,
        oldLevel: oldLevel,
        currentStreak: streakState?.currentStreak,
        hitDailyGoal: hitDailyGoal,
      );

      // Check for newly unlocked achievements
      _checkAchievementUnlocks();
    });
    
    // After delay, unlock and advance
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() => _showGate = false);
        widget.onUnlockAndAdvance();
      }
    });
  }

  /// Check if any achievements were just unlocked and show toasts
  Future<void> _checkAchievementUnlocks() async {
    try {
      // Force a refresh of achievements after XP/streak update
      ref.invalidate(achievementProvider);
      
      // Small delay to let the provider rebuild
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      final achievements = ref.read(achievementProvider).valueOrNull ?? [];
      final newlyUnlocked = achievements.where(
        (a) => a.isUnlocked && a.unlockedAt != null &&
               DateTime.now().difference(a.unlockedAt!).inSeconds < 10,
      ).toList();

      // Show toast for each newly unlocked achievement (stagger them)
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
      // Silently fail — achievements are nice-to-have, not critical
      debugPrint('🏆 Achievement check error: $e');
    }
  }

  void _handleWrongAnswer() {
    _attemptCount++;
    
    // Log incorrect attempt
    SpacedRepetitionService.recordInteraction(
      userId: 'local_user',
      videoId: widget.video.id,
      isCorrect: false,
      dwellTimeMs: _dwellStopwatch.elapsedMilliseconds,
      quality: 1, // Poor recall
    );
    
    // _aiFeedback is already set in _handleAnswerSubmit from the API.
    // Except if it isn't set.
    if (_aiFeedback == null) {
      setState(() {
        _aiFeedback = 'Not quite. Think about the core principles related to ${widget.video.subject}. Try reviewing the clip again.';
      });
    }
    
    // Shake animation
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
    
    // Optimistic Update
    setState(() {
        _isLiked = newStatus;
        _likesCount = newCount;
    });
    
    try {
        final repo = ref.read(videosRepositoryProvider);
        // Assuming current user is "local_user" for now or fetch from auth logic
        // Use Supabase auth logic in real app
        final userId = Supabase.instance.client.auth.currentUser?.id ?? 'anon';
        await repo.toggleLike(widget.video.id, userId);
    } catch (e) {
        // Revert on error
        setState(() {
            _isLiked = !newStatus;
            _likesCount = _isLiked ? _likesCount + 1 : _likesCount - 1;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update like: $e')),
        );
    }
  }

  Future<void> _toggleSave() async {
    final newStatus = !_isSaved;
    
    // Optimistic Update
    setState(() => _isSaved = newStatus);
    
    try {
      final repo = ref.read(videosRepositoryProvider);
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'anon';
      await repo.toggleSave(widget.video.id, userId);
      ref.invalidate(savedVideosProvider);
    } catch (e) {
      setState(() => _isSaved = !newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update bookmark: $e')),
        );
      }
    }
  }

  @override
  void didUpdateWidget(SwipeGatedVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive && !_showGate) {
        if (_isYoutube) {
           _ytController?.playVideo();
        } else {
           _controller?.play();
        }
        ref.read(videosRepositoryProvider).logView(widget.video.id);
      } else {
        if (_isYoutube) {
           _ytController?.pauseVideo();
        } else {
           _controller?.pause();
        }
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _controller?.removeListener(_onVideoProgress);
    _controller?.dispose();
    _ytController?.close();
    super.dispose();
  }

  // ── Toggle between Expert Video and AI Coaching ──
  void _switchToAiCoaching() {
    if (_isAiCoachingMode) return;
    // Pause the video before switching
    if (_isYoutube && _ytController != null) {
      _ytController!.pauseVideo();
    } else if (_controller != null) {
      _controller!.pause();
    }
    setState(() {
      _isAiCoachingMode = true;
      _isPlaying = false;
    });
  }

  void _switchToExpertVideo() {
    if (!_isAiCoachingMode) return;
    setState(() {
      _isAiCoachingMode = false;
    });
    // Resume video playback
    if (widget.isActive) {
      if (_isYoutube && _ytController != null) {
        _ytController!.playVideo();
      } else if (_controller != null) {
        _controller!.play();
      }
      setState(() => _isPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _isAiCoachingMode ? const Color(0xFF1C1C1E) : Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── AI COACHING MODE (Full Screen) ──
          if (_isAiCoachingMode)
            Positioned.fill(
              top: 90, // space for the toggle
              child: _buildAiCoachingView(),
            )
          else ...[
            // ── EXPERT VIDEO MODE ──
            // Video Player with Dim Effect
            if (_isInitialized)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _dimFactor,
                child: Center(
                  child: _isYoutube 
                    ? YoutubePlayer(controller: _ytController!)
                    : _controller != null
                      ? AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        )
                      // Web fallback: non-YouTube video, show placeholder
                      : Container(
                          color: Colors.black,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.play_circle_outline,
                                    color: Colors.white54, size: 72),
                                const SizedBox(height: 16),
                                Text(
                                  widget.video.title,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Video coming soon',
                                  style: TextStyle(color: Colors.white38, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(
                  color: StudyRepsTheme.warmOrange,
                ),
              ),

            // 👆 Tap Area (Full Screen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _togglePlayPause,
                child: Container(color: Colors.transparent),
              ),
            ),

            // Gradient Overlay for Readability (Reels Style)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        StudyRepsTheme.warmTextDark.withOpacity(0.6),
                        Colors.transparent,
                        Colors.transparent,
                        StudyRepsTheme.warmTextDark.withOpacity(0.95),
                      ],
                      stops: const [0.0, 0.2, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Loop 2 Toast
            if (_loopCount >= 1 && !_showGate && !_isAnswered)
              Positioned(
                bottom: 150,
                left: 0,
                right: 0,
                child: Center(
                  child: _buildLoopToast(),
                ),
              ),

            // Play/Pause Icon Overlay
            if (_showPlayPauseOverlay)
              IgnorePointer(
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(_overlayIcon),
                    tween: Tween(begin: 1.5, end: 1.0),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) => Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _overlayIcon,
                          size: 60,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Video Info Overlay
            _buildVideoInfo(),

            // Right side action bar (Tutorbot, Comments, Accessibility)
            _buildActionBar(),

            // Progress Indicator
            if (_isInitialized && !_isYoutube)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  colors: VideoProgressColors(
                    playedColor: StudyRepsTheme.warmOrange,
                    bufferedColor: Colors.white.withOpacity(0.5),
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),

            // THE QUESTION GATE
            if (_showGate)
              _buildQuestionGate(),
          ],

          // ── Expert vs AI Toggle (always visible at top) ──
          _buildModeToggle(),
        ],
      ),
    );
  }

  /// Premium segmented control: "Expert Video" vs "AI Coaching"
  Widget _buildModeToggle() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: _isAiCoachingMode
                ? Colors.white.withOpacity(0.12)
                : Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _isAiCoachingMode
                  ? StudyRepsTheme.warmOrange.withOpacity(0.4)
                  : Colors.white.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Expert Video Tab
              GestureDetector(
                onTap: _switchToExpertVideo,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: !_isAiCoachingMode
                        ? Colors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: !_isAiCoachingMode
                        ? [BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_circle_fill_rounded,
                        size: 16,
                        color: !_isAiCoachingMode
                            ? StudyRepsTheme.warmOrange
                            : Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Expert Video',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: !_isAiCoachingMode
                              ? StudyRepsTheme.warmTextDark
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 2),
              // AI Coaching Tab
              GestureDetector(
                onTap: _switchToAiCoaching,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isAiCoachingMode
                        ? StudyRepsTheme.warmOrange
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: _isAiCoachingMode
                        ? [BoxShadow(
                            color: StudyRepsTheme.warmOrange.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          )]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.psychology_rounded,
                        size: 16,
                        color: _isAiCoachingMode
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'AI Coaching',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isAiCoachingMode
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Full-screen AI Coaching view (replaces the video)
  Widget _buildAiCoachingView() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
      ),
      child: Column(
        children: [
          // Context banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  StudyRepsTheme.warmOrange.withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: StudyRepsTheme.warmOrange.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: StudyRepsTheme.warmOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: StudyRepsTheme.warmOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Coach • ${widget.video.subject}',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ask anything about "${widget.video.title}"',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Quick action chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildQuickActionChip(
                  icon: Icons.lightbulb_outline_rounded,
                  label: 'Explain this',
                  onTap: () {
                    ExplainStoryboardSheet.show(context, widget.video);
                  },
                ),
                const SizedBox(width: 8),
                _buildQuickActionChip(
                  icon: Icons.fitness_center_rounded,
                  label: 'Drill me',
                  onTap: () {
                    DrillFlashcardSheet.show(context, widget.video);
                  },
                ),
                const SizedBox(width: 8),
                _buildQuickActionChip(
                  icon: Icons.quiz_rounded,
                  label: 'Quiz',
                  onTap: () {
                    QuizAssessmentSheet.show(context, widget.video);
                  },
                ),
              ],
            ),
          ),
          // Main AI Chat Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: StudyRepsTheme.warmOrange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        color: StudyRepsTheme.warmOrange,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your AI Coach is ready',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Tap a quick action or open full chat to get instant explanations, drills, and tutoring.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.5),
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Open Full Chat Button
                    GestureDetector(
                      onTap: () => VideoTutorbotSheet.show(context, widget.video),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [StudyRepsTheme.warmOrange, StudyRepsTheme.warmOrangeDark],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: StudyRepsTheme.warmOrange.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.chat_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Open Full Chat',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: StudyRepsTheme.warmOrange, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoopToast() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: StudyRepsTheme.warmOrange.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.swipe_up_rounded,
            color: StudyRepsTheme.warmOrange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Get ready to solve!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Positioned(
      left: 16,
      right: 80,
      bottom: 20, // Lowered for Reels style
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Review badge
          if (widget.isReviewItem)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [StudyRepsTheme.warmOrange, StudyRepsTheme.warmOrangeDark],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.replay_rounded, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text('Review', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                ],
              ),
            ),

          // Username
          Row(
            children: [
              Text(
                '@${widget.video.creatorName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2)],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.verified, color: StudyRepsTheme.warmOrange, size: 14),
            ],
          ),
          const SizedBox(height: 8),

          // Title / Caption
          Text(
            widget.video.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.3,
              shadows: [Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2)],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          // Music / Audio Tag (Mock)
          Row(
            children: [
              const Icon(Icons.music_note_rounded, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              SizedBox(
                width: 150,
                child: Text(
                  'Original Audio • ${widget.video.subject}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Bottom padding
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
          // AI Coach (Replaces Ask AI + drawing logic)
          _buildActionButton(
            icon: Icons.psychology_rounded,
            label: 'Coach',
            onTap: () {
              if (mounted) {
                VideoTutorbotSheet.show(context, widget.video);
              }
            },
          ),
          const SizedBox(height: 20),
          
          // Like Button (New)
          _buildLikeButton(),
           const SizedBox(height: 20),
          
          // Comments
          _buildActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Discuss',
            onTap: () => CommentSection.show(context, widget.video.id),
          ),
          const SizedBox(height: 20),



          // Save / Bookmark Button (New)
          _buildSaveButton(),
           const SizedBox(height: 20),
           
           // Share
           _buildActionButton(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: () async {
              ref.read(videosRepositoryProvider).logShare(widget.video.id, platform: 'link');
              final shareText = '💪 Check out "${widget.video.title}" on StudyReps!\n\n'
                  'Learn through micro-struggles — one rep at a time.\n'
                  'https://studyreps.app/video/${widget.video.id}';
              // Use clipboard as universal fallback (works on web + mobile)
              await Clipboard.setData(ClipboardData(text: shareText));
              if (!mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                        SizedBox(width: 8),
                        Expanded(child: Text('Share link copied! Paste it anywhere 🚀')),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.grey[900],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
            },
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
            _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: _isSaved ? StudyRepsTheme.warmOrange : Colors.white,
            size: 32,
            shadows: const [
              Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 6),
            ],
          ).animate(target: _isSaved ? 1 : 0)
              .scale(begin: const Offset(0.85, 0.85), end: const Offset(1.15, 1.15), duration: 200.ms)
              .then()
              .scale(begin: const Offset(1.15, 1.15), end: const Offset(1.0, 1.0), duration: 100.ms),
          const SizedBox(height: 4),
          Text(
            _isSaved ? 'Saved' : 'Save',
            style: TextStyle(
              color: _isSaved ? StudyRepsTheme.warmOrange : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              shadows: const [
                Shadow(color: Colors.black54, offset: Offset(0, 1), blurRadius: 2),
              ],
            ),
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
                    _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: _isLiked ? StudyRepsTheme.errorPink : Colors.white,
                    size: 32,
                    shadows: const [
                        Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 6),
                    ],
                ).animate(target: _isLiked ? 1 : 0).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 200.ms).then().scale(begin: const Offset(1.2, 1.2), end: const Offset(1.0, 1.0), duration: 100.ms),
                const SizedBox(height: 4),
                Text(
                    '$_likesCount',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                         shadows: [
                            Shadow(color: Colors.black54, offset: Offset(0, 1), blurRadius: 2),
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
          // Icon with Shadow (Reels Style)
          Container(
             // Transparent container for hit target
             color: Colors.transparent,
             child: Icon(
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

  Widget _buildQuestionGate() {
    return LockOverlay(
      video: widget.video.copyWith(question: _activeQuestion), // 🎯 Pass enriched question
      isChecking: _isChecking,
      isCorrect: _isCorrect,
      isIncorrect: _isIncorrect,
      aiFeedback: _aiFeedback,
      onCorrectAnswer: _handleCorrectAnswer,
      onSubmit: _handleAnswerSubmit,
      onTryAgain: _handleTryAgain,
    );
  }
}

/// A 2D Matrix Item that wraps the Main Video, Study Drawer, and Deep Dive Videos
class HorizontalMatrixItem extends StatefulWidget {
  final VideoModel video;
  final bool isActive;
  final VoidCallback onLockTriggered;
  final VoidCallback onUnlockAndAdvance;

  const HorizontalMatrixItem({
    super.key,
    required this.video,
    required this.isActive,
    required this.onLockTriggered,
    required this.onUnlockAndAdvance,
  });

  @override
  State<HorizontalMatrixItem> createState() => _HorizontalMatrixItemState();
}

class _HorizontalMatrixItemState extends State<HorizontalMatrixItem> {
  late PageController _horizontalController;
  int _currentHorizontalPage = 1;

  @override
  void initState() {
    super.initState();
    _horizontalController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── Flashcard: single-page (no horizontal deep dives) ──
    if (widget.video.contentType == ContentType.flashcard) {
      return FlashcardFeedItem(
        video: widget.video,
        isActive: widget.isActive,
        onLockTriggered: widget.onLockTriggered,
        onUnlockAndAdvance: widget.onUnlockAndAdvance,
      );
    }

    // ── Video: horizontal matrix (drawer, main, deep dives) ──
    bool isCenterActive = widget.isActive && _currentHorizontalPage == 1;

    return PageView.builder(
      controller: _horizontalController,
      scrollDirection: Axis.horizontal,
      onPageChanged: (index) {
        setState(() {
          _currentHorizontalPage = index;
        });
      },
      itemCount: 4, // 0: Drawer, 1: Main, 2-3: Deep Dives (Mock)
      itemBuilder: (context, index) {
        if (index == 0) {
          return StudyDrawerPane(video: widget.video);
        } else if (index == 1) {
          return SwipeGatedVideoItem(
            video: widget.video,
            isActive: isCenterActive,
            onLockTriggered: widget.onLockTriggered,
            onUnlockAndAdvance: widget.onUnlockAndAdvance,
          );
        } else {
          return DeepDiveVideoItem(
            originalVideo: widget.video,
            deepDiveIndex: index - 1, // 1, 2...
            isActive: widget.isActive && _currentHorizontalPage == index,
          );
        }
      },
    );
  }
}

class StudyDrawerPane extends StatelessWidget {
  final VideoModel video;
  
  const StudyDrawerPane({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: StudyRepsTheme.warmCream,
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded, color: StudyRepsTheme.warmOrange, size: 28),
              const SizedBox(width: 12),
              Text(
                'Study Drawer',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: StudyRepsTheme.warmTextDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Resources for: ${video.title}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: StudyRepsTheme.warmTextMedium, fontSize: 14),
          ),
          const SizedBox(height: 32),
          
          _buildResourceCard(
            icon: Icons.picture_as_pdf_rounded,
            title: 'Topic Notes (PDF)',
            subtitle: 'Read the summary notes',
            color: StudyRepsTheme.errorPink,
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Opening PDF Notes... (Mock)')),
               );
            },
          ),
          const SizedBox(height: 16),
          
          _buildResourceCard(
            icon: Icons.history_edu_rounded,
            title: 'Past Year Questions',
            subtitle: 'Practice previous exam patterns',
            color: Colors.amber,
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Loading PYQs... (Mock)')),
               );
            },
          ),
          const SizedBox(height: 16),
          
          _buildResourceCard(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Class Discussion',
            subtitle: 'Join the comment section',
            color: StudyRepsTheme.accentCyan,
            onTap: () => CommentSection.show(context, video.id),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard({
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: StudyRepsTheme.warmTextDark, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: StudyRepsTheme.warmTextMedium, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }
}

class DeepDiveVideoItem extends StatelessWidget {
  final VideoModel originalVideo;
  final int deepDiveIndex;
  final bool isActive;

  const DeepDiveVideoItem({
    super.key,
    required this.originalVideo,
    required this.deepDiveIndex,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the subject or next part for the deep dive tile
    final partName = deepDiveIndex == 1 ? 'Part 2' : 'Part 3';
    
    final mockVideo = originalVideo.copyWith(
      id: '${originalVideo.id}_deepdive_$deepDiveIndex',
      title: 'Deep Dive $partName:\n${originalVideo.title}',
      isLiked: false,
      likesCount: originalVideo.likesCount ~/ 2, 
    );

    return Stack(
      children: [
        SwipeGatedVideoItem(
          video: mockVideo,
          isActive: isActive,
          onLockTriggered: () {}, 
          onUnlockAndAdvance: () {}, 
        ),
        Positioned(
          top: 70,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: StudyRepsTheme.warmCream.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: StudyRepsTheme.warmOrange, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.explore_rounded, color: StudyRepsTheme.warmOrange, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Deep Dive • $partName',
                  style: const TextStyle(color: StudyRepsTheme.warmTextDark, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

