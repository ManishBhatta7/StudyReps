import 'package:flutter/material.dart';
import '../../core/theme/study_reps_theme.dart';

/// Equation Builder Widget for "The Lock"
///
/// Allows users to drag and drop variables/numbers to form an equation.
/// Used when QuestionType is equation or dragDrop.
class EquationBuilderRep extends StatefulWidget {
  final List<String> availableTokens; // e.g. ["F", "m", "a", "=", "+"]
  final Function(String constructedEquation) onEquationChanged;

  const EquationBuilderRep({
    super.key,
    required this.availableTokens,
    required this.onEquationChanged,
  });

  @override
  State<EquationBuilderRep> createState() => _EquationBuilderRepState();
}

class _EquationBuilderRepState extends State<EquationBuilderRep> {
  // The equation slots. Null means empty.
  // We'll assume a standard physics equation length for now, or dynamic.
  // Let's start with a flexible list of slots.
  final List<String?> _equationSlots = List.filled(5, null); 
  
  // Tokens still available in the pool (initially all)
  // We track indices to allow duplicate tokens if needed, but for now simple string matching
  late List<String> _poolTokens;

  @override
  void initState() {
    super.initState();
    _poolTokens = List.from(widget.availableTokens);
  }

  void _updateEquation() {
    // Construct the string, ignoring nulls
    final equation = _equationSlots.where((t) => t != null).join('');
    widget.onEquationChanged(equation);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. The Equation Construction Area (Target)
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: StudyRepsTheme.warmCream,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: StudyRepsTheme.warmBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_equationSlots.length, (index) {
              return _buildDropZone(index);
            }),
          ),
        ),

        const SizedBox(height: 32),

        // 2. The Token Pool (Source)
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _poolTokens.map((token) {
            return _buildDraggableToken(token);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropZone(int index) {
    final filledToken = _equationSlots[index];

    return DragTarget<String>(
      onWillAccept: (data) => true,
      onAccept: (data) {
        setState(() {
          // If slot was already filled, return item to pool (optional logic)
          if (filledToken != null) {
            _poolTokens.add(filledToken);
          }
          
          _equationSlots[index] = data;
          _poolTokens.remove(data); // Remove one instance from pool
          _updateEquation();
        });
      },
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: filledToken != null 
                ? StudyRepsTheme.warmOrange.withOpacity(0.1)
                : isActive 
                    ? StudyRepsTheme.warmOrange.withOpacity(0.05) 
                    : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: filledToken != null
                  ? StudyRepsTheme.warmOrange
                  : isActive
                      ? StudyRepsTheme.warmOrange
                      : StudyRepsTheme.warmBorder,
              width: isActive || filledToken != null ? 2 : 1,
              style: filledToken == null ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          child: filledToken != null
              ? Center(
                  child: Text(
                    filledToken,
                    style: const TextStyle(
                      color: StudyRepsTheme.warmTextDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null, // Empty slot
        );
      },
    );
  }

  Widget _buildDraggableToken(String token) {
    return Draggable<String>(
      data: token,
      feedback: Transform.scale(
        scale: 1.2,
        child: _TokenCard(token: token, isDragging: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _TokenCard(token: token),
      ),
      child: _TokenCard(token: token),
    );
  }
}

class _TokenCard extends StatelessWidget {
  final String token;
  final bool isDragging;

  const _TokenCard({required this.token, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDragging ? StudyRepsTheme.warmOrange : StudyRepsTheme.warmBorder,
        ),
        boxShadow: isDragging 
            ? [
                BoxShadow(
                  color: StudyRepsTheme.warmOrange.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ] 
            : [],
      ),
      child: Center(
        child: Text(
          token,
          style: const TextStyle(
            color: StudyRepsTheme.warmTextDark,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
