import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../data/services/rep_generator_service.dart';
import '../../domain/models/video_model.dart';

/// AI Rep Review Sheet
///
/// Shown after AI generates a rep from a PDF/image upload.
/// Displays the generated question for review, allows editing,
/// and lets the user confirm to add it to their feed.
class AiRepReviewSheet extends StatefulWidget {
  final Uint8List fileBytes;
  final String mimeType;
  final String? fileName;
  final bool isMultiple;

  const AiRepReviewSheet({
    super.key,
    required this.fileBytes,
    required this.mimeType,
    this.fileName,
    this.isMultiple = false,
  });

  /// Show the review sheet and return generated reps
  static Future<List<VideoModel>?> show(
    BuildContext context, {
    required Uint8List fileBytes,
    required String mimeType,
    String? fileName,
    bool isMultiple = false,
  }) {
    return showModalBottomSheet<List<VideoModel>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => AiRepReviewSheet(
          fileBytes: fileBytes,
          mimeType: mimeType,
          fileName: fileName,
          isMultiple: isMultiple,
        ),
      ),
    );
  }

  @override
  State<AiRepReviewSheet> createState() => _AiRepReviewSheetState();
}

class _AiRepReviewSheetState extends State<AiRepReviewSheet> {
  List<VideoModel> _generatedReps = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateReps();
  }

  Future<void> _generateReps() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.isMultiple) {
        final reps = await RepGeneratorService.generateMultipleFromFile(
          fileBytes: widget.fileBytes,
          mimeType: widget.mimeType,
          fileName: widget.fileName,
          count: 3,
        );
        setState(() {
          _generatedReps = reps;
          _isLoading = false;
        });
      } else {
        final rep = await RepGeneratorService.generateFromFile(
          fileBytes: widget.fileBytes,
          mimeType: widget.mimeType,
          fileName: widget.fileName,
        );
        setState(() {
          _generatedReps = rep != null ? [rep] : [];
          _isLoading = false;
        });
      }

      if (_generatedReps.isEmpty) {
        setState(() => _error = 'Could not generate a rep from this file.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to analyze: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgPrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: StudyRepsTheme.primaryPurple.withOpacity(0.3),
        ),
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

          // Header
          _buildHeader(),
          const SizedBox(height: 8),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),

          // Content
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _error != null
                    ? _buildErrorState()
                    : _buildRepsList(),
          ),

          // Action Buttons
          if (!_isLoading && _generatedReps.isNotEmpty)
            _buildActionBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Rep Generator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.fileName ?? 'Analyzing content...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: Colors.white.withOpacity(0.4), size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated brain icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                StudyRepsTheme.primaryPurple.withOpacity(0.2),
                StudyRepsTheme.accentCyan.withOpacity(0.1),
              ]),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: StudyRepsTheme.accentCyan,
              size: 48,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1500.ms, color: StudyRepsTheme.primaryPurple.withOpacity(0.3))
              .then()
              .shake(hz: 1, duration: 300.ms),
          const SizedBox(height: 24),
          const Text(
            'Analyzing your content...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getLoadingMessage(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                StudyRepsTheme.primaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLoadingMessage() {
    if (widget.mimeType.contains('pdf')) {
      return 'Reading PDF and extracting key concepts...';
    } else {
      return 'Analyzing image content with Gemini Vision...';
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: StudyRepsTheme.errorPink.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: StudyRepsTheme.errorPink, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Something went wrong',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _generateReps,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: StudyRepsTheme.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _generatedReps.length,
      itemBuilder: (context, index) {
        return _buildRepCard(_generatedReps[index], index);
      },
    );
  }

  Widget _buildRepCard(VideoModel rep, int index) {
    final question = rep.question;
    final correctIdx = question.options.indexOf(question.correctAnswer);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rep number + subject badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    StudyRepsTheme.primaryPurple,
                    StudyRepsTheme.accentCyan,
                  ]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Rep ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rep.subject,
                  style: TextStyle(
                    color: StudyRepsTheme.accentCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.auto_awesome,
                  color: StudyRepsTheme.primaryPurple.withOpacity(0.6), size: 16),
            ],
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            rep.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Question
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: StudyRepsTheme.primaryPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: StudyRepsTheme.primaryPurple.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.help_outline_rounded,
                    color: StudyRepsTheme.accentCyan, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    question.prompt,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Options
          ...List.generate(question.options.length, (i) {
            final isCorrect = i == correctIdx;
            final labels = ['A', 'B', 'C', 'D'];
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isCorrect
                    ? StudyRepsTheme.successGreen.withOpacity(0.1)
                    : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCorrect
                      ? StudyRepsTheme.successGreen.withOpacity(0.4)
                      : Colors.white.withOpacity(0.06),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? StudyRepsTheme.successGreen.withOpacity(0.2)
                          : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      i < labels.length ? labels[i] : '${i + 1}',
                      style: TextStyle(
                        color: isCorrect
                            ? StudyRepsTheme.successGreen
                            : Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      question.options[i],
                      style: TextStyle(
                        color: Colors.white.withOpacity(isCorrect ? 0.95 : 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (isCorrect)
                    const Icon(Icons.check_circle_rounded,
                        color: StudyRepsTheme.successGreen, size: 18),
                ],
              ),
            );
          }),

          // Explanation
          if (question.explanation.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: Colors.amber.withOpacity(0.7), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.explanation,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 150)).slideY(begin: 0.05);
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgPrimary,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Regenerate
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _generateReps,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Regenerate'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white.withOpacity(0.7),
                  side: BorderSide(color: Colors.white.withOpacity(0.15)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Add to Feed
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, _generatedReps),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  _generatedReps.length == 1
                      ? 'Add Rep to Feed'
                      : 'Add ${_generatedReps.length} Reps',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: StudyRepsTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
