import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/theme/study_reps_theme.dart';
import '../../data/services/chat_persistence_service.dart';
import '../../data/services/screen_capture.dart' as screen_capture;
import '../../domain/models/video_model.dart';
import '../providers/tutorbot_provider.dart';

/// Video Tutorbot Sheet — AI Adaptive Coach
///
/// Features:
/// - Persistent conversation memory (Hive-backed)
/// - Context-aware AI responses via Gemini
/// - 📸 Gemini Vision: camera, gallery, screen share
/// - 🎤 Voice input via speech-to-text
/// - Markdown rendering for rich responses
class VideoTutorbotSheet extends StatelessWidget {
  final VideoModel video;

  const VideoTutorbotSheet({super.key, required this.video});

  static void show(BuildContext context, VideoModel video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.3,
        maxChildSize: 0.92,
        builder: (context, scrollController) => _TutorbotContent(
          video: video,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _TutorbotContent(video: video);
  }
}

class _TutorbotContent extends ConsumerStatefulWidget {
  final VideoModel video;
  final ScrollController? scrollController;

  const _TutorbotContent({required this.video, this.scrollController});

  @override
  ConsumerState<_TutorbotContent> createState() => _TutorbotContentState();
}

class _TutorbotContentState extends ConsumerState<_TutorbotContent>
    with SingleTickerProviderStateMixin {
  final _inputController = TextEditingController();
  final _listScrollController = ScrollController();
  final _inputFocusNode = FocusNode();
  final _imagePicker = ImagePicker();

  // ── Voice Input ──
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  String _lastRecognized = '';

  // ── Text-to-Speech (Voice Output) ──
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  String? _speakingMessageId;

  // ── Vision ──
  bool _showVisionOptions = false;

  // ── Animations ──
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  /// Initialize TTS engine for voice feedback
  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _tts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _speakingMessageId = null;
          });
        }
      });
      _tts.setCancelHandler(() {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _speakingMessageId = null;
          });
        }
      });
      debugPrint('🔊 TTS initialized');
    } catch (e) {
      debugPrint('🔊 TTS init error: $e');
    }
  }

  /// Speak a message aloud or stop speaking
  Future<void> _toggleSpeak(ChatMessage msg) async {
    try {
      if (_isSpeaking && _speakingMessageId == msg.id) {
        // Currently speaking this message — stop it
        await _tts.stop();
        setState(() {
          _isSpeaking = false;
          _speakingMessageId = null;
        });
        return;
      }

      // Stop any ongoing speech first
      if (_isSpeaking) await _tts.stop();

      // Strip markdown formatting for cleaner speech
      final cleanText = msg.text
          .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'\1') // bold
          .replaceAll(RegExp(r'\*(.+?)\*'), r'\1')     // italic
          .replaceAll(RegExp(r'`(.+?)`'), r'\1')       // code
          .replaceAll(RegExp(r'#{1,6}\s'), '')          // headings
          .replaceAll(RegExp(r'\[(.+?)\]\(.+?\)'), r'\1') // links
          .replaceAll(RegExp(r'[\n\r]+'), '. ')         // newlines to pauses
          .replaceAll(RegExp(r'\s+'), ' ')              // multiple spaces
          .trim();

      setState(() {
        _isSpeaking = true;
        _speakingMessageId = msg.id;
      });

      await _tts.speak(cleanText);
    } catch (e) {
      debugPrint('🔊 TTS speak error: $e');
      setState(() {
        _isSpeaking = false;
        _speakingMessageId = null;
      });
    }
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          debugPrint('🎤 Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            if (mounted) {
              setState(() => _isListening = false);
              _pulseController.stop();
              // Submit the recognized text if we have something
              if (_lastRecognized.isNotEmpty) {
                _inputController.text = _lastRecognized;
              }
            }
          }
        },
        onError: (error) {
          debugPrint('🎤 Speech error: $error');
          if (mounted) {
            setState(() => _isListening = false);
            _pulseController.stop();
          }
        },
      );
      debugPrint('🎤 Speech available: $_speechAvailable');
    } catch (e) {
      debugPrint('🎤 Speech init error: $e');
      _speechAvailable = false;
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _listScrollController.dispose();
    _inputFocusNode.dispose();
    _pulseController.dispose();
    if (_isListening) _speech.stop();
    if (_isSpeaking) _tts.stop();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_listScrollController.hasClients) {
        _listScrollController.animateTo(
          _listScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ═════════════════════════════════
  //  TEXT MESSAGE
  // ═════════════════════════════════

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _inputController.clear();
    ref
        .read(tutorbotControllerProvider(widget.video).notifier)
        .sendMessage(text);
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 500), _scrollToBottom);
  }

  // ═════════════════════════════════
  //  VOICE INPUT
  // ═════════════════════════════════

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() async {
    if (!_speechAvailable) {
      _showError('Voice input is not available on this device.');
      return;
    }

    setState(() {
      _isListening = true;
      _lastRecognized = '';
      _inputController.text = '';
    });
    _pulseController.repeat(reverse: true);

    await _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _lastRecognized = result.recognizedWords;
            _inputController.text = _lastRecognized;
            _inputController.selection = TextSelection.fromPosition(
              TextPosition(offset: _inputController.text.length),
            );
          });
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenMode: stt.ListenMode.dictation,
    );
  }

  void _stopListening() async {
    await _speech.stop();
    _pulseController.stop();
    setState(() => _isListening = false);
  }

  // ═════════════════════════════════
  //  VISION: Camera / Gallery
  // ═════════════════════════════════

  Future<void> _captureFromCamera() async {
    setState(() => _showVisionOptions = false);
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (photo != null) await _processImage(photo);
    } catch (e) {
      _showError('Could not access camera: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _showVisionOptions = false);
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (photo != null) await _processImage(photo);
    } catch (e) {
      _showError('Could not access gallery: $e');
    }
  }

  Future<void> _processImage(XFile image) async {
    final bytes = await image.readAsBytes();
    final mimeType = _getMimeType(image.name);
    final prompt = _inputController.text.trim();
    _inputController.clear();

    ref
        .read(tutorbotControllerProvider(widget.video).notifier)
        .sendImageMessage(
          imageBytes: bytes,
          mimeType: mimeType,
          userPrompt: prompt.isNotEmpty ? prompt : null,
        );

    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 500), _scrollToBottom);
  }

  // ═════════════════════════════════
  //  SCREEN SHARE (Web only)
  // ═════════════════════════════════

  Future<void> _shareScreen() async {
    setState(() => _showVisionOptions = false);

    if (!screen_capture.isScreenCaptureSupported) {
      _showError(
          'Screen sharing is only supported on web. Use camera on mobile.');
      return;
    }

    try {
      final bytes = await screen_capture.captureScreen();
      if (bytes == null) {
        // User cancelled
        return;
      }

      final prompt = _inputController.text.trim();
      _inputController.clear();

      ref
          .read(tutorbotControllerProvider(widget.video).notifier)
          .sendImageMessage(
            imageBytes: bytes,
            mimeType: 'image/jpeg',
            userPrompt: prompt.isNotEmpty
                ? '🖥️ Screen share: $prompt'
                : '🖥️ Analyze this screenshot',
          );

      _scrollToBottom();
      Future.delayed(const Duration(milliseconds: 500), _scrollToBottom);
    } catch (e) {
      _showError('Screen capture failed: $e');
    }
  }

  String _getMimeType(String filename) {
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

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: StudyRepsTheme.errorPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StudyRepsTheme.bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Conversation?',
            style: TextStyle(color: StudyRepsTheme.textPrimary)),
        content: const Text(
          'This will erase the tutorbot history for this video.',
          style: TextStyle(color: StudyRepsTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancel', style: TextStyle(color: StudyRepsTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(tutorbotControllerProvider(widget.video).notifier)
                  .clearConversation();
              Navigator.pop(ctx);
            },
            child: const Text('Clear',
                style: TextStyle(color: StudyRepsTheme.errorPink)),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════
  //  BUILD
  // ═════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(tutorbotControllerProvider(widget.video));
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Container(
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgPrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border:
            Border.all(color: StudyRepsTheme.primaryPurple.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: StudyRepsTheme.primaryPurple.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          _buildHeader(chatState),
          const SizedBox(height: 8),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),

          // Quick Actions
          if (chatState.messages.length <= 2) ...[
            const SizedBox(height: 12),
            _buildQuickActions(),
            const SizedBox(height: 8),
            Divider(color: Colors.white.withOpacity(0.08), height: 1),
          ],

          // Voice Listening Banner
          if (_isListening) _buildListeningBanner(),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _listScrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: chatState.messages.length +
                  (chatState.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatState.messages.length &&
                    chatState.isLoading) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(chatState.messages[index]);
              },
            ),
          ),

          // Vision Panel
          if (_showVisionOptions) _buildVisionPanel(),

          // Input Bar
          _buildInputBar(chatState.isLoading),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════
  //  HEADER
  // ═════════════════════════════════════════════

  Widget _buildHeader(TutorbotState chatState) {
    final messageCount = chatState.messages.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                StudyRepsTheme.primaryPurple,
                StudyRepsTheme.accentCyan,
              ]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: StudyRepsTheme.primaryPurple.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.psychology_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Adaptive Coach',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        )),
                    const SizedBox(width: 6),
                    // Vision + Voice badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          const Color(0xFF4285F4),
                          const Color(0xFF34A853),
                        ]),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: StudyRepsTheme.successGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.video.title,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (messageCount > 1)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$messageCount msgs',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 11)),
            ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: _clearChat,
            icon: Icon(Icons.delete_outline_rounded,
                color: Colors.white.withOpacity(0.4), size: 20),
            tooltip: 'Clear chat',
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════
  //  QUICK ACTIONS (with Scan + Voice)
  // ═════════════════════════════════════════════

  Widget _buildQuickActions() {
    final actions = <(String, IconData, VoidCallback)>[
      ('📸 Scan', Icons.camera_alt_rounded,
          () => setState(() => _showVisionOptions = true)),
      ('🎤 Voice', Icons.mic_rounded, _toggleListening),
      ('Explain', Icons.lightbulb_outline_rounded,
          () => _sendMessage('Explain this concept in simple terms')),
      ('Quiz me', Icons.quiz_outlined,
          () => _sendMessage('Quiz me on this video')),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (label, icon, onTap) = actions[index];
          final isHighlight = index <= 1; // Scan + Voice highlighted
          return GestureDetector(
            onTap: onTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isHighlight
                    ? LinearGradient(colors: [
                        const Color(0xFF4285F4).withOpacity(0.2),
                        const Color(0xFF34A853).withOpacity(0.1),
                      ])
                    : LinearGradient(colors: [
                        StudyRepsTheme.primaryPurple.withOpacity(0.15),
                        StudyRepsTheme.accentCyan.withOpacity(0.08),
                      ]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isHighlight
                      ? const Color(0xFF4285F4).withOpacity(0.35)
                      : StudyRepsTheme.primaryPurple.withOpacity(0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      color: isHighlight
                          ? const Color(0xFF4285F4)
                          : StudyRepsTheme.accentCyan,
                      size: 15),
                  const SizedBox(width: 6),
                  Text(label,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                        fontWeight:
                            isHighlight ? FontWeight.w700 : FontWeight.w500,
                      )),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: index * 80))
              .slideX(begin: 0.1);
        },
      ),
    );
  }

  // ═════════════════════════════════════════════
  //  LISTENING BANNER (active mic)
  // ═════════════════════════════════════════════

  Widget _buildListeningBanner() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.red.withOpacity(0.08 + _pulseController.value * 0.08),
              const Color(0xFF4285F4)
                  .withOpacity(0.05 + _pulseController.value * 0.05),
            ]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  Colors.red.withOpacity(0.3 + _pulseController.value * 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red
                      .withOpacity(0.6 + _pulseController.value * 0.4),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8 + _pulseController.value * 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Listening...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        )),
                    if (_lastRecognized.isNotEmpty)
                      Text(
                        _lastRecognized,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _stopListening,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.stop_rounded,
                      color: Colors.red, size: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═════════════════════════════════════════════
  //  VISION PANEL (Camera + Gallery + Screen Share)
  // ═════════════════════════════════════════════

  Widget _buildVisionPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          const Color(0xFF4285F4).withOpacity(0.08),
          const Color(0xFF34A853).withOpacity(0.05),
        ]),
        border: Border(
          top: BorderSide(color: const Color(0xFF4285F4).withOpacity(0.2)),
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome,
                  color: Color(0xFF4285F4), size: 16),
              const SizedBox(width: 8),
              Text('Gemini Vision',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  )),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showVisionOptions = false),
                child: Icon(Icons.close_rounded,
                    color: Colors.white.withOpacity(0.4), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
              'Point your camera at any problem, share your screen, or pick an image',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              )),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildVisionButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  sublabel: 'Take photo',
                  color: const Color(0xFF4285F4),
                  onTap: _captureFromCamera,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVisionButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  sublabel: 'Pick image',
                  color: const Color(0xFF34A853),
                  onTap: _pickFromGallery,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVisionButton(
                  icon: Icons.screen_share_rounded,
                  label: 'Screen',
                  sublabel: kIsWeb ? 'Share tab' : 'Camera',
                  color: const Color(0xFFFBBC05),
                  onTap: kIsWeb ? _shareScreen : _captureFromCamera,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildVisionButton({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                )),
            Text(sublabel,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 9,
                )),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════
  //  MESSAGE BUBBLE (with image support)
  // ═════════════════════════════════════════════

  Widget _buildMessageBubble(ChatMessage msg) {
    final isBot = msg.isBot;
    final isSpeakingThis = _isSpeaking && _speakingMessageId == msg.id;

    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment:
              isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            if (isBot)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.psychology_rounded,
                        size: 12,
                        color: StudyRepsTheme.accentCyan.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text('Coach',
                        style: TextStyle(
                          color: StudyRepsTheme.accentCyan.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),

            // Image preview
            if (msg.hasImage) _buildImagePreview(msg),

            // Text bubble
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isBot
                    ? Colors.white.withOpacity(0.07)
                    : StudyRepsTheme.primaryPurple.withOpacity(0.25),
                borderRadius: BorderRadius.only(
                  topLeft:
                      Radius.circular(msg.hasImage && !isBot ? 14 : 18),
                  topRight:
                      Radius.circular(msg.hasImage && !isBot ? 14 : 18),
                  bottomLeft: Radius.circular(isBot ? 4 : 18),
                  bottomRight: Radius.circular(isBot ? 18 : 4),
                ),
                border: isBot
                    ? Border.all(color: Colors.white.withOpacity(0.08))
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isBot
                      ? MarkdownBody(
                          data: msg.text,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              height: 1.5,
                            ),
                            strong: const TextStyle(
                              color: StudyRepsTheme.accentCyan,
                              fontWeight: FontWeight.w700,
                            ),
                            em: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontStyle: FontStyle.italic,
                            ),
                            code: TextStyle(
                              color: StudyRepsTheme.accentCyan,
                              backgroundColor:
                                  Colors.white.withOpacity(0.05),
                              fontSize: 13,
                            ),
                            listBullet: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                            blockquoteDecoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: StudyRepsTheme.primaryPurple
                                      .withOpacity(0.5),
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Text(msg.text,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 14,
                            height: 1.4,
                          )),

                  // 🔊 Speaker button for bot messages
                  if (isBot && !msg.id.startsWith('welcome_'))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _toggleSpeak(msg),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSpeakingThis
                                    ? StudyRepsTheme.accentCyan.withOpacity(0.15)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSpeakingThis
                                      ? StudyRepsTheme.accentCyan.withOpacity(0.4)
                                      : Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSpeakingThis
                                        ? Icons.stop_rounded
                                        : Icons.volume_up_rounded,
                                    size: 14,
                                    color: isSpeakingThis
                                        ? StudyRepsTheme.accentCyan
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isSpeakingThis ? 'Stop' : 'Listen',
                                    style: TextStyle(
                                      color: isSpeakingThis
                                          ? StudyRepsTheme.accentCyan
                                          : Colors.white.withOpacity(0.5),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Timestamp
            Padding(
              padding: EdgeInsets.only(
                  top: 3, left: isBot ? 4 : 0, right: isBot ? 0 : 4),
              child: Text(_formatTime(msg.timestamp),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.25),
                    fontSize: 10,
                  )),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.05);
  }

  Widget _buildImagePreview(ChatMessage msg) {
    try {
      final bytes = base64Decode(msg.imageBase64!);
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        constraints: const BoxConstraints(maxHeight: 200, maxWidth: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF4285F4).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            children: [
              Image.memory(
                Uint8List.fromList(bytes),
                fit: BoxFit.cover,
                width: 250,
                errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          msg.text.contains('Screen')
                              ? Icons.screen_share_rounded
                              : Icons.auto_awesome,
                          color: const Color(0xFF4285F4),
                          size: 10),
                      const SizedBox(width: 3),
                      Text(
                          msg.text.contains('Screen')
                              ? 'Screen'
                              : 'Vision',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (_) {
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      width: 200,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF4285F4).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: const Color(0xFF4285F4).withOpacity(0.3)),
      ),
      child: const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_rounded,
                color: Color(0xFF4285F4), size: 20),
            SizedBox(width: 8),
            Text('Image analyzed',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final m = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  // ═════════════════════════════════════════════
  //  TYPING INDICATOR
  // ═════════════════════════════════════════════

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.psychology_rounded,
                size: 16,
                color: StudyRepsTheme.accentCyan.withOpacity(0.6)),
            const SizedBox(width: 10),
            ...[0, 1, 2].map((i) => _buildAnimatedDot(i)),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildAnimatedDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: StudyRepsTheme.accentCyan.withOpacity(value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  // ═════════════════════════════════════════════
  //  INPUT BAR (Camera + Mic + Input + Send)
  // ═════════════════════════════════════════════

  Widget _buildInputBar(bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgPrimary,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // ── Camera Button ──
            _buildInputAction(
              icon: _showVisionOptions
                  ? Icons.camera_alt_rounded
                  : Icons.camera_alt_outlined,
              isActive: _showVisionOptions,
              activeColor: const Color(0xFF4285F4),
              onTap: isLoading
                  ? null
                  : () => setState(
                      () => _showVisionOptions = !_showVisionOptions),
              tooltip: 'Vision',
            ),
            const SizedBox(width: 6),

            // ── Mic Button ──
            _buildInputAction(
              icon: _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
              isActive: _isListening,
              activeColor: Colors.red,
              onTap: isLoading ? null : _toggleListening,
              tooltip: 'Voice',
              showPulse: _isListening,
            ),
            const SizedBox(width: 6),

            // ── Text Input ──
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isListening
                        ? Colors.red.withOpacity(0.3)
                        : _inputFocusNode.hasFocus
                            ? StudyRepsTheme.primaryPurple.withOpacity(0.4)
                            : Colors.white.withOpacity(0.08),
                  ),
                ),
                child: TextField(
                  controller: _inputController,
                  focusNode: _inputFocusNode,
                  enabled: !isLoading,
                  style:
                      const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: _isListening
                        ? 'Listening... speak now'
                        : isLoading
                            ? 'Coach is thinking...'
                            : _showVisionOptions
                                ? 'Add a question (optional)...'
                                : 'Ask or use 🎤 voice...',
                    hintStyle: TextStyle(
                      color: _isListening
                          ? Colors.red.withOpacity(0.5)
                          : Colors.white.withOpacity(0.3),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                  onSubmitted: isLoading ? null : _sendMessage,
                  textInputAction: TextInputAction.send,
                ),
              ),
            ),
            const SizedBox(width: 6),

            // ── Send Button ──
            GestureDetector(
              onTap: isLoading
                  ? null
                  : () {
                      if (_isListening) _stopListening();
                      _sendMessage(_inputController.text);
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: isLoading
                      ? null
                      : LinearGradient(colors: [
                          StudyRepsTheme.primaryPurple,
                          StudyRepsTheme.accentCyan,
                        ]),
                  color: isLoading
                      ? Colors.white.withOpacity(0.1)
                      : null,
                  shape: BoxShape.circle,
                  boxShadow: isLoading
                      ? []
                      : [
                          BoxShadow(
                            color: StudyRepsTheme.primaryPurple
                                .withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Icon(
                  isLoading
                      ? Icons.hourglass_top_rounded
                      : Icons.send_rounded,
                  color:
                      Colors.white.withOpacity(isLoading ? 0.3 : 1.0),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputAction({
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    VoidCallback? onTap,
    String? tooltip,
    bool showPulse = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withOpacity(0.2)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? activeColor.withOpacity(0.5)
                : Colors.white.withOpacity(0.08),
          ),
          boxShadow: showPulse
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Icon(icon,
            color: isActive
                ? activeColor
                : Colors.white.withOpacity(0.5),
            size: 19),
      ),
    );
  }
}
