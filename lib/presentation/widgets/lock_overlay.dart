import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../domain/models/video_model.dart';
import 'equation_builder_rep.dart';

/// Glassmorphism Overlay for "The Lock"
/// 
/// Appears when video pauses at lock timestamp.
/// Contains the question and answer input.
class LockOverlay extends StatefulWidget {
  final VideoModel video;
  final VoidCallback onCorrectAnswer;
  final Function(String answer) onSubmit;
  final VoidCallback? onTryAgain; // NEW: Callback to reset state
  final bool isChecking;
  final bool isCorrect;
  final bool isIncorrect;
  final String? aiFeedback;

  const LockOverlay({
    super.key,
    required this.video,
    required this.onCorrectAnswer,
    required this.onSubmit,
    this.onTryAgain,
    this.isChecking = false,
    this.isCorrect = false,
    this.isIncorrect = false,
    this.aiFeedback,
  });

  @override
  State<LockOverlay> createState() => _LockOverlayState();
}

class _LockOverlayState extends State<LockOverlay> {
  final _answerController = TextEditingController();
  String? _selectedOption;
  int _retryCount = 0; // Track retries to force-reset child widgets

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final answer = widget.video.question.type == QuestionType.multipleChoice
        ? _selectedOption ?? ''
        : _answerController.text.trim();
    
    if (answer.isNotEmpty) {
      widget.onSubmit(answer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: StudyRepsTheme.lockGradient,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lock Icon with Animation
                _buildLockIcon(),
                
                const SizedBox(height: 32),
                
                // Question Card
                _buildQuestionCard(),
                
                const SizedBox(height: 24),
                
                // Answer Input
                _buildAnswerInput(),
                
                const SizedBox(height: 24),
                
                // Submit Button or Feedback
                if (widget.isCorrect)
                  _buildSuccessFeedback()
                else if (widget.isIncorrect)
                  _buildIncorrectFeedback()
                else
                  _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildLockIcon() {
    if (widget.isCorrect) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: StudyRepsTheme.successGradient,
          boxShadow: [StudyRepsTheme.successGlow],
        ),
        child: const Icon(
          Icons.lock_open_rounded,
          color: Colors.white,
          size: 40,
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.elasticOut);
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: StudyRepsTheme.primaryGradient,
        boxShadow: [StudyRepsTheme.primaryGlow],
      ),
      child: const Icon(
        Icons.lock_rounded,
        color: Colors.white,
        size: 40,
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).scale(
      begin: const Offset(1, 1),
      end: const Offset(1.05, 1.05),
      duration: 1.seconds,
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgGlass,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StudyRepsTheme.borderSubtle),
      ),
      child: Column(
        children: [
          // Subject Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: StudyRepsTheme.primaryPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.video.subject.toUpperCase(),
              style: TextStyle(
                color: StudyRepsTheme.primaryPurpleLight,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Question Text
          Text(
            widget.video.question.prompt,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: StudyRepsTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Hint (optional)
          if (widget.video.question.hint.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: StudyRepsTheme.accentCyan,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.video.question.hint,
                  style: TextStyle(
                    color: StudyRepsTheme.textMuted,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerInput() {
    final question = widget.video.question;
    
    // Drag & Drop / Equation Builder
    if (question.type == QuestionType.equation || question.type == QuestionType.dragDrop) {
      return EquationBuilderRep(
        key: ValueKey('eq_${widget.video.id}_$_retryCount'), // Rebuild on retry
        availableTokens: question.options,
        onEquationChanged: (equation) {
          // Auto-submit logic could go here, or just store for button press
          // Storing in _answerController for now to reuse submit logic
          _answerController.text = equation;
        },
      );
    }
    
    if (question.type == QuestionType.multipleChoice) {
      return Column(
        children: question.options.map((option) {
          final isSelected = _selectedOption == option;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: widget.isChecking ? null : () {
                setState(() => _selectedOption = option);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? StudyRepsTheme.primaryPurple.withOpacity(0.3)
                      : StudyRepsTheme.bgGlass,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected 
                        ? StudyRepsTheme.primaryPurple 
                        : StudyRepsTheme.borderSubtle,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: StudyRepsTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    // Text input for other question types
    return Container(
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StudyRepsTheme.borderSubtle),
      ),
      child: TextField(
        controller: _answerController,
        enabled: !widget.isChecking,
        style: const TextStyle(
          color: StudyRepsTheme.textPrimary,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: 'Type your answer...',
          hintStyle: TextStyle(color: StudyRepsTheme.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        onSubmitted: (_) => _handleSubmit(),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.isChecking ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: StudyRepsTheme.primaryPurple,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: widget.isChecking
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Submit Rep',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSuccessFeedback() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: StudyRepsTheme.successGreen.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: StudyRepsTheme.successGreen),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: StudyRepsTheme.successGreen,
              ),
              const SizedBox(width: 12),
              Text(
                'CORRECT! 🎉',
                style: TextStyle(
                  color: StudyRepsTheme.successGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Video resuming...',
          style: TextStyle(
            color: StudyRepsTheme.textMuted,
            fontSize: 14,
          ),
        ),
      ],
    ).animate().slideY(begin: 0.3, duration: 300.ms).fadeIn();
  }

  Widget _buildIncorrectFeedback() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: StudyRepsTheme.errorPink.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: StudyRepsTheme.errorPink),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: StudyRepsTheme.primaryPurpleLight,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI Coach Feedback',
                    style: TextStyle(
                      color: StudyRepsTheme.primaryPurpleLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (widget.aiFeedback != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: StudyRepsTheme.primaryPurple.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.insights_rounded,
                          color: StudyRepsTheme.accentCyan,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.aiFeedback!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 15,
                            height: 1.4,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Try Again Button - Now properly resets state
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Clear input
              _answerController.clear();
              setState(() {
                _selectedOption = null;
                _retryCount++;
              });
              // Reset the answer state via callback
              widget.onTryAgain?.call();
            },
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            label: const Text(
              'Try Again',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: StudyRepsTheme.primaryIndigo,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    ).animate().shake(duration: 300.ms);
  }
}
