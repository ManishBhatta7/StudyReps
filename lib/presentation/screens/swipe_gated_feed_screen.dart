import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/study_reps_theme.dart';
import '../providers/video_feed_provider.dart';
import '../../domain/models/video_model.dart';
import '../../data/services/spaced_repetition_service.dart';
import '../providers/adaptive_feed_provider.dart';
import '../widgets/create_rep_dialog.dart';
import '../widgets/lock_overlay.dart';
import '../widgets/mascot_reactor.dart';
import '../widgets/video_tutorbot_sheet.dart';
import '../widgets/comment_section.dart';

import 'drill_screen.dart';

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
  bool _feedLoaded = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    if (widget.initialVideos != null && widget.initialVideos!.isNotEmpty) {
      _videos = widget.initialVideos!;
      _feedLoaded = true;
    } else {
      _loadAdaptiveFeed();
    }
  }

  Future<void> _loadAdaptiveFeed() async {
    final feed = await ref.read(adaptiveFeedProvider.future);
    if (mounted) {
      setState(() {
        _videos = feed;
        _feedLoaded = true;
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

  // Add new video from Creator Mode
  void _addVideo(VideoModel newVideo) {
    setState(() {
      _videos.insert(0, newVideo); // Add to top
      _currentPage = 0; // Jump to new video
    });
    // Need to jump after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(0);
    });
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
              _feedLoaded = true;
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
      backgroundColor: StudyRepsTheme.bgPrimary,
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
                  return SwipeGatedVideoItem(
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
            style: StudyRepsTheme.darkTheme.textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Create your first spaced repetition\nvideo to get started.',
            textAlign: TextAlign.center,
            style: StudyRepsTheme.darkTheme.textTheme.bodyLarge?.copyWith(
              color: StudyRepsTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 48),
          // Arrow pointing to FAB
          const Icon(
            Icons.arrow_downward_rounded,
            color: StudyRepsTheme.primaryPurple,
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
  bool _isInitialized = false;
  
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
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
        _overlayIcon = Icons.play_arrow_rounded; // Show Play icon when paused
        _showPlayPauseOverlay = true; // Keep visible while paused
      } else {
        _controller!.play();
        _isPlaying = true;
        _overlayIcon = Icons.pause_rounded; // Flash pause icon
        _showPlayPauseOverlay = true;
        
        // Hide overlay after animation when resuming
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
  }

  Future<void> _initializeVideo() async {
    try {
      // On web, dart:io File is not available. Always use network URL.
      if (kIsWeb || widget.video.videoUrl.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.video.videoUrl),
        );
      } else {
        // Mobile/Desktop only: local file playback
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.video.videoUrl), // Fallback to network for safety
        );
      }

      await _controller!.initialize();
      _controller!.setLooping(false); // We manage looping manually
      
      // Listen for video completion
      _controller!.addListener(_onVideoProgress);

      if (mounted) {
        setState(() => _isInitialized = true);
        if (widget.isActive) {
          _controller!.play();
          ref.read(videosRepositoryProvider).logView(widget.video.id);
        }
      }
    } catch (e) {
      debugPrint('❌ Error initializing video: $e');
      if (mounted) {
        setState(() => _isInitialized = false); // Keep false to show error/loading
      }
    }
  }

  void _onVideoProgress() {
    if (!mounted || _controller == null) return;
    
    final position = _controller!.value.position;
    final duration = _controller!.value.duration;
    
    // Check if video completed a loop
    if (position >= duration - const Duration(milliseconds: 200)) {
      _handleLoopComplete();
    }
  }

  void _handleLoopComplete() {
    _loopCount++;
    // print('🔄 Loop $_loopCount completed');
    
    if (_loopCount >= _maxLoops && !_isAnswered) {
      // LOCK THE FEED
      _controller!.pause();
      setState(() => _showGate = true);
      widget.onLockTriggered();
      // print('🔒 GATE LOCKED - Answer required!');
    } else if (!_isAnswered) {
      // Restart for next loop
      _controller!.seekTo(Duration.zero);
      _controller!.play();
      setState(() {}); // Trigger dim update
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

    // MOCK VALIDATION LOGIC
    await Future.delayed(const Duration(milliseconds: 1500)); // Simulate API delay

    if (!mounted) return;

    final isCorrect = answer.trim().toLowerCase() ==
        (widget.video.question?.correctAnswer.trim().toLowerCase() ?? '');

    setState(() {
      _isChecking = false;
      if (isCorrect) {
        _isCorrect = true;
        _handleCorrectAnswer();
      } else {
        _isIncorrect = true;
        _handleWrongAnswer();
      }
    });
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
    
    // After delay, unlock and advance
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _showGate = false);
        widget.onUnlockAndAdvance();
      }
    });
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
    
    // Provide some mock AI feedback based on the answer
    setState(() {
      _aiFeedback = "Not quite. Think about the core principles related to ${widget.video.subject}. Try reviewing the clip again.";
    });
    
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
        _controller?.play();
        ref.read(videosRepositoryProvider).logView(widget.video.id);
      } else {
        _controller?.pause();
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _controller?.removeListener(_onVideoProgress);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // Specific black background for video
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player with Dim Effect
          if (_isInitialized)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _dimFactor,
              child: Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: StudyRepsTheme.primaryPurple,
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
                      StudyRepsTheme.bgPrimary.withOpacity(0.6),
                      Colors.transparent,
                      Colors.transparent,
                      StudyRepsTheme.bgPrimary.withOpacity(0.95),
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
            IgnorePointer( // Allow clicks to pass through to screen tap handler
              child: Center(
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(_overlayIcon), // Force restart on icon change
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
          if (_isInitialized)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true, // Enable user seeking/rewinding
                padding: const EdgeInsets.only(top: 12, bottom: 8), // Increase hit area
                colors: VideoProgressColors(
                  playedColor: StudyRepsTheme.primaryPurple,
                  bufferedColor: Colors.white.withOpacity(0.5),
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
            ),

          // THE QUESTION GATE
          if (_showGate)
            _buildQuestionGate(),
        ],
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
          color: StudyRepsTheme.primaryPurple.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.swipe_up_rounded,
            color: StudyRepsTheme.primaryPurple,
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
                gradient: LinearGradient(
                  colors: [StudyRepsTheme.primaryPurple, StudyRepsTheme.accentCyan],
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
              const Icon(Icons.verified, color: Colors.blueAccent, size: 14),
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
          // Tutorbot
          _buildActionButton(
            icon: Icons.smart_toy_outlined,
            label: 'Coach',
            onTap: () => VideoTutorbotSheet.show(context, widget.video),
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
           
           // Share (Mock)
           _buildActionButton(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: () {
              ref.read(videosRepositoryProvider).logShare(widget.video.id, platform: 'link');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing link copied! (Mock)')),
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
            color: _isSaved ? StudyRepsTheme.accentCyan : Colors.white,
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
              color: _isSaved ? StudyRepsTheme.accentCyan : Colors.white,
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
                    shadows: [
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
    if (widget.video.question == null) return const SizedBox();

    return LockOverlay(
      video: widget.video,
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
