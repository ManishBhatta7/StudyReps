import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      decoration: const BoxDecoration(
        color: Color(0xB3FFF7ED), // Warm Cream (StudyRepsTheme.warmCream) with transparency
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
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
          color: StudyRepsTheme.warmGreen,
          boxShadow: [
            BoxShadow(
              color: StudyRepsTheme.warmGreen.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
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
        color: StudyRepsTheme.warmOrange,
        boxShadow: [
          BoxShadow(
            color: StudyRepsTheme.warmOrange.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: StudyRepsTheme.warmOrange.withOpacity(0.2),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Subject Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: StudyRepsTheme.warmOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.video.subject.toUpperCase(),
              style: const TextStyle(
                color: StudyRepsTheme.warmOrange,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Question Text
          Text(
            widget.video.question.prompt,
            style: GoogleFonts.outfit(
              fontSize: 24,
              color: StudyRepsTheme.warmTextDark,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Hint (optional)
          if (widget.video.question.hint.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: StudyRepsTheme.warmOrange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.video.question.hint,
                  style: const TextStyle(
                    color: StudyRepsTheme.warmTextMedium,
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? StudyRepsTheme.warmOrange.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? StudyRepsTheme.warmOrange 
                        : StudyRepsTheme.warmBorder,
                    width: isSelected ? 2 : 1.5,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: StudyRepsTheme.warmOrange.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ] : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: GoogleFonts.outfit(
                    color: isSelected ? StudyRepsTheme.warmOrange : StudyRepsTheme.warmTextDark,
                    fontSize: isSelected ? 17 : 16,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                  child: Text(option),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StudyRepsTheme.warmBorder),
      ),
      child: TextField(
        controller: _answerController,
        enabled: !widget.isChecking,
        style: GoogleFonts.outfit(
          color: StudyRepsTheme.warmTextDark,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: 'Type your answer...',
          hintStyle: GoogleFonts.outfit(color: StudyRepsTheme.warmTextLight),
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
      child: Container(
        decoration: BoxDecoration(
          color: widget.isChecking ? StudyRepsTheme.warmBorder : StudyRepsTheme.warmOrange,
          borderRadius: BorderRadius.circular(20),
          boxShadow: widget.isChecking ? null : [
            BoxShadow(
              color: StudyRepsTheme.warmOrange.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: widget.isChecking ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
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
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Submit Rep',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: StudyRepsTheme.successGreen,
              ),
              SizedBox(width: 12),
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
        const Text(
          'Video resuming...',
          style: TextStyle(
            color: StudyRepsTheme.warmTextMedium,
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
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: StudyRepsTheme.warmOrange,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'AI Coach Feedback',
                    style: TextStyle(
                      color: StudyRepsTheme.warmOrange,
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
                    color: StudyRepsTheme.warmOrange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: StudyRepsTheme.warmOrange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.insights_rounded,
                          color: StudyRepsTheme.warmOrange,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.aiFeedback!,
                          style: GoogleFonts.outfit(
                            color: StudyRepsTheme.warmTextDark,
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
              backgroundColor: StudyRepsTheme.warmOrangeLight,
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
