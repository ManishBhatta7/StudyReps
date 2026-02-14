import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';
import 'dart:io';
import '../../core/theme/study_reps_theme.dart';
import '../../domain/models/video_model.dart';
import '../../data/services/spaced_repetition_service.dart';
import '../providers/adaptive_feed_provider.dart';
import '../widgets/create_rep_dialog.dart';
import '../widgets/gate_overlay.dart';
import '../widgets/mascot_reactor.dart';
import '../widgets/video_tutorbot_sheet.dart';
import '../widgets/comment_section.dart';
import '../widgets/accessibility_panel.dart';
import 'drill_screen.dart';

/// Swipe-Gated Video Feed Screen
/// Users cannot swipe until they answer the question correctly
class SwipeGatedFeedScreen extends ConsumerStatefulWidget {
  const SwipeGatedFeedScreen({super.key});

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
    _pageController = PageController();
    _loadAdaptiveFeed();
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
    return Scaffold(
      backgroundColor: StudyRepsTheme.bgPrimary,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // Move above video info
        child: FloatingActionButton(
          onPressed: () async {
            final newVideo = await showDialog<VideoModel>(
              context: context,
              builder: (context) => const CreateRepDialog(),
            );
            if (newVideo != null) {
              _addVideo(newVideo);
            }
          },
          backgroundColor: StudyRepsTheme.primaryPurple,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
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
                    : const BouncingScrollPhysics(),
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
          
          // Coach Mode Button (Top Right)
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DrillScreen()),
                );
              },
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                  border: Border.all(color: StudyRepsTheme.primaryPurple, width: 2),
                ),
                child: const Icon(Icons.psychology, color: Colors.white, size: 28),
              ),
              tooltip: 'Adaptive Coach',
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
class SwipeGatedVideoItem extends StatefulWidget {
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
  State<SwipeGatedVideoItem> createState() => _SwipeGatedVideoItemState();
}

class _SwipeGatedVideoItemState extends State<SwipeGatedVideoItem> 
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  
  // Loop tracking
  int _loopCount = 0;
  static const int _maxLoops = 2;
  
  // Question gate state
  bool _showGate = false;
  bool _isAnswered = false;
  int? _selectedOption;
  bool _showHint = false;
  
  // Animation
  late AnimationController _shakeController;
  
  // ── Adaptive Feed: Dwell Time Tracking ──
  final Stopwatch _dwellStopwatch = Stopwatch();
  int _attemptCount = 0;
  
  // Dim factor for loop 2
  double get _dimFactor => _loopCount >= 1 ? 0.7 : 1.0;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _dwellStopwatch.start();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      if (widget.video.videoUrl.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.video.videoUrl),
        );
      } else {
        _controller = VideoPlayerController.file(
          File(widget.video.videoUrl),
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
    print('🔄 Loop $_loopCount completed');
    
    if (_loopCount >= _maxLoops && !_isAnswered) {
      // LOCK THE FEED
      _controller!.pause();
      setState(() => _showGate = true);
      widget.onLockTriggered();
      print('🔒 GATE LOCKED - Answer required!');
    } else if (!_isAnswered) {
      // Restart for next loop
      _controller!.seekTo(Duration.zero);
      _controller!.play();
      setState(() {}); // Trigger dim update
    }
  }

  void _handleOptionTap(int index) {
    setState(() {
      _selectedOption = index;
      _showHint = false;
    });
    
    final correctIndex = widget.video.question?.options?.indexOf(
      widget.video.question!.correctAnswer
    ) ?? 0;
    
    if (index == correctIndex) {
      // CORRECT!
      _handleCorrectAnswer();
    } else {
      // WRONG - Shake and show hint
      _handleWrongAnswer();
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
    
    // Show success animation
    _showSuccessOverlay();
    
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
    
    // Shake animation
    _shakeController.forward().then((_) => _shakeController.reset());
    
    // Show hint
    setState(() => _showHint = true);
  }

  void _showSuccessOverlay() {
    // Replace gate content with success
    setState(() {});
  }

  @override
  void didUpdateWidget(SwipeGatedVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive && !_showGate) {
        _controller?.play();
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

          // Gradient Overlay for Readability (Reels Style)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2), // Top dim
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.8), // Bottom text protection
                  ],
                  stops: const [0.0, 0.2, 0.7, 1.0],
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
              child: SizedBox(
                height: 2,
                child: VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: false,
                  colors: VideoProgressColors(
                    playedColor: Colors.white,
                    bufferedColor: Colors.white.withOpacity(0.5),
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
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
          
          // Comments
          _buildActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Discuss',
            onTap: () => CommentSection.show(context, widget.video.id),
          ),
          const SizedBox(height: 20),

          // Accessibility
          _buildActionButton(
            icon: Icons.accessibility_new_rounded,
            label: 'Views', // Simplified label
            onTap: () => AccessibilityPanel.show(context),
          ),
           const SizedBox(height: 20),
           
           // Share (Mock)
           _buildActionButton(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: () {},
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
    final question = widget.video.question;
    if (question == null) return const SizedBox();

    return GateOverlay(
      question: question,
      isAnswered: _isAnswered,
      showHint: _showHint,
      selectedOption: _selectedOption,
      onOptionSelected: (index) => _isAnswered ? null : _handleOptionTap(index),
      shakeAnimation: _shakeController,
    );
  }
}
