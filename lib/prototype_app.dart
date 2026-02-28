import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:web/web.dart' as web;

void main() {
  runApp(const StudyRepsPrototypeApp());
}

class StudyRepsPrototypeApp extends StatelessWidget {
  const StudyRepsPrototypeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyReps Prototype',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Deep Slate
        primaryColor: const Color(0xFF6366F1), // Indigo
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF10B981), // Emerald success
        ),
      ),
      home: const ActiveVideoPlayerScreen(),
    );
  }
}

class ActiveVideoPlayerScreen extends StatefulWidget {
  const ActiveVideoPlayerScreen({super.key});

  @override
  State<ActiveVideoPlayerScreen> createState() => _ActiveVideoPlayerScreenState();
}

class _ActiveVideoPlayerScreenState extends State<ActiveVideoPlayerScreen> {
  late YoutubePlayerController _controller;
  
  bool _isFullscreen = false;
  bool _isQuestionLocked = false;
  bool _isListening = false;
  bool _isSuccess = false;
  
  // A mock question that appears at the 10 second mark
  final int _lockTimeSeconds = 10;
  bool _hasTriggeredLock = false;
  
  StreamSubscription? _videoStateSubscription;

  @override
  void initState() {
    super.initState();
    
    // Initialize YouTube Controller
    // We'll use a standard biology video as a mock
    _controller = YoutubePlayerController.fromVideoId(
      videoId: '1eO7M236XnU', // Example Video ID (arbitrary educational)
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: false, // 100% Locked down
        showFullscreenButton: false,
        mute: false,
      ),
    );

    // Monitor video progress to trigger the "Vocal Lock"
    _videoStateSubscription = _controller.videoStateStream.listen((state) {
      if (!_hasTriggeredLock && state.position.inSeconds >= _lockTimeSeconds) {
        _triggerVocalLock();
      }
    });

    // Handle Page Visibility API to detect "Loss of Focus"
    web.document.addEventListener('visibilitychange', (_handleVisibilityChange).toJS);
  }

  // A JS interop handler for when the user switches tabs (Distraction tracking)
  void _handleVisibilityChange(web.Event event) {
    if (web.document.hidden) {
      _controller.pauseVideo();
      // Track this offline or send a webhook
      debugPrint("🚨 DISTRACTION EVENT LOGGED: User tabbed out.");
      
      if (mounted && !_isQuestionLocked) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ Focus lost! Your mom was notified via WhatsApp."),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _requestBrowserFullscreen() {
    try {
      web.document.documentElement?.requestFullscreen();
      setState(() {
        _isFullscreen = true;
      });
      _controller.playVideo();
    } catch (e) {
      debugPrint("Fullscreen failed: $e");
    }
  }

  void _triggerVocalLock() {
    setState(() {
      _isQuestionLocked = true;
      _hasTriggeredLock = true;
    });
    _controller.pauseVideo();
  }

  void _simulateVoiceAnswer() async {
    setState(() {
      _isListening = true;
    });
    
    // Simulate AI processing speech to text for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    
    setState(() {
      _isListening = false;
      _isSuccess = true;
    });
    
    // Show success for 2 seconds, then resume
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isSuccess = false;
      _isQuestionLocked = false;
    });
    
    _controller.playVideo();
  }

  @override
  void dispose() {
    _videoStateSubscription?.cancel();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. The Core Video Feed
          Center(
            child: YoutubePlayer(
              controller: _controller,
              aspectRatio: 16 / 9,
            ),
          ),
          
          // 2. The "Start Study Session" Barrier (Forces Fullscreen)
          if (!_isFullscreen)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.school, size: 80, color: Colors.white),
                    const SizedBox(height: 20),
                    const Text(
                      "Ready to focus?",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "This session requires full attention.\nLeaving the tab will break your streak.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: _requestBrowserFullscreen,
                      icon: const Icon(Icons.fullscreen),
                      label: const Text("Enter Study Mode"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
          // 3. The Vocal Lock Engine Overlay
          if (_isQuestionLocked)
            Container(
              color: Colors.black.withOpacity(0.85), // Blurs/dimms the screen
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // The AI Question
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B), // Slate 800
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.5), width: 2),
                        ),
                        child: Column(
                          children: [
                             Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.smart_toy, color: Colors.indigoAccent),
                                SizedBox(width: 10),
                                Text(
                                  "Ed Coach",
                                  style: TextStyle(
                                    color: Colors.indigoAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Okay, pause. Based on what was just covered, explain how osmosis is different from standard diffusion in your own words.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // The Vocalization Interface
                      if (_isSuccess)
                        const Column(
                          children: [
                            Icon(Icons.check_circle, color: Color(0xFF10B981), size: 80),
                            SizedBox(height: 16),
                            Text(
                              "Nailed it! Continuing lecture...",
                              style: TextStyle(color: Color(0xFF10B981), fontSize: 20, fontWeight: FontWeight.bold),
                            )
                          ],
                        )
                      else
                        GestureDetector(
                          onLongPress: _simulateVoiceAnswer,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _isListening ? 120 : 100,
                            height: _isListening ? 120 : 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isListening ? Colors.redAccent : const Color(0xFF6366F1),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isListening ? Colors.redAccent : const Color(0xFF6366F1)).withOpacity(0.5),
                                  blurRadius: _isListening ? 50 : 20,
                                  spreadRadius: _isListening ? 10 : 5,
                                )
                              ],
                            ),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        
                      if (!_isSuccess) ...[
                        const SizedBox(height: 24),
                        Text(
                          _isListening ? "Listening to your explanation..." : "Hold to speak your answer",
                          style: TextStyle(
                            color: _isListening ? Colors.white : Colors.white54,
                            fontSize: 16,
                            fontWeight: _isListening ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
