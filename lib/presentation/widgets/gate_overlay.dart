import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../domain/models/video_model.dart';
import 'mascot_reactor.dart';

class GateOverlay extends StatelessWidget {
  final QuestionModel question;
  final bool isAnswered;
  final bool showHint;
  final int? selectedOption;
  final Function(int) onOptionSelected;
  final Animation<double> shakeAnimation;

  const GateOverlay({
    super.key,
    required this.question,
    required this.isAnswered,
    required this.showHint,
    required this.selectedOption,
    required this.onOptionSelected,
    required this.shakeAnimation,
  });

  MascotState get _mascotState {
    if (isAnswered) return MascotState.success;
    if (showHint) return MascotState.hint;
    return MascotState.idle;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shakeAnimation,
      builder: (context, child) {
        final shakeOffset = shakeAnimation.value < 0.5
            ? shakeAnimation.value * 20 - 5
            : (1 - shakeAnimation.value) * 20 - 5;
            
        return Transform.translate(
          offset: Offset(shakeOffset * (shakeAnimation.isCompleted || shakeAnimation.isDismissed ? 0 : 1), 0),
          child: child,
        );
      },
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Glass Card
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 24), // Top padding for Mascot
                    decoration: BoxDecoration(
                      color: StudyRepsTheme.bgSecondary.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isAnswered 
                            ? StudyRepsTheme.successGreen 
                            : StudyRepsTheme.borderSubtle,
                        width: isAnswered ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: isAnswered 
                        ? _buildSuccessContent()
                        : _buildQuestionContent(),
                  ),
                ),
              ),

              // VOLT MASCOT (Peeking over top)
              Positioned(
                top: -60,
                child: MascotReactor(
                  state: _mascotState,
                  size: 100,
                ),
              ),

              // COACH HINT BUBBLE (If Hint Active)
              if (showHint && question.hint != null)
                Positioned(
                  top: -80,
                  right: -20, // Offset to right of mascot
                  child: _buildHintBubble(question.hint!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHintBubble(String text) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.zero,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: StudyRepsTheme.bgPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: StudyRepsTheme.successGreen,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: StudyRepsTheme.successGreen.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 50,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '+10 XP',
          style: TextStyle(
            color: StudyRepsTheme.successGreen,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Great job! 🎉',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionContent() {
    final options = question.options as List<String>?;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_rounded,
              color: StudyRepsTheme.primaryPurple,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'LOGIC GATE',
              style: TextStyle(
                color: StudyRepsTheme.primaryPurple,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Question
        Text(
          question.prompt ?? 'Answer this question:',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Options
        if (options != null)
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = selectedOption == index;
            final correctIndex = options.indexOf(question.correctAnswer);
            final showAsCorrect = isAnswered && index == correctIndex;
            final showAsWrong = selectedOption == index && 
                               showHint && 
                               index != correctIndex;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: isAnswered ? null : () => onOptionSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: showAsCorrect
                        ? StudyRepsTheme.successGreen.withOpacity(0.2)
                        : showAsWrong
                            ? Colors.red.withOpacity(0.2)
                            : isSelected
                                ? StudyRepsTheme.primaryPurple.withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: showAsCorrect
                          ? StudyRepsTheme.successGreen
                          : showAsWrong
                              ? Colors.red
                              : isSelected
                                  ? StudyRepsTheme.primaryPurple
                                  : Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: showAsCorrect
                              ? StudyRepsTheme.successGreen
                              : showAsWrong
                                  ? Colors.red
                                  : StudyRepsTheme.primaryPurple.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (showAsCorrect)
                        const Icon(Icons.check_circle, color: StudyRepsTheme.successGreen),
                      if (showAsWrong)
                        const Icon(Icons.cancel, color: Colors.red),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}
