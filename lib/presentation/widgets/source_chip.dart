import 'package:flutter/material.dart';
import '../../core/theme/study_reps_theme.dart';

/// Source Chip - Glassmorphic pill for displaying active sources
///
/// Matches NotebookLM's context pill design with:
/// - Translucent background
/// - Thin border
/// - Source-type icon and color
class SourceChip extends StatelessWidget {
  final String label;
  final SourceType type;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool isSelected;

  const SourceChip({
    super.key,
    required this.label,
    this.type = SourceType.document,
    this.onTap,
    this.onRemove,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor();
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.1) 
              : StudyRepsTheme.warmWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? color.withOpacity(0.3) 
                : StudyRepsTheme.warmBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getTypeIcon(),
              size: 14,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected 
                    ? color 
                    : StudyRepsTheme.warmTextMedium,
              ),
            ),
            if (onRemove != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: StudyRepsTheme.warmTextLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (type) {
      case SourceType.pdf:
        return Colors.red.shade400;
      case SourceType.image:
        return Colors.green.shade400;
      case SourceType.assignment:
        return StudyRepsTheme.warmOrange;
      case SourceType.report:
        return Colors.teal.shade400;
      case SourceType.quiz:
        return Colors.deepPurple.shade300;
      case SourceType.essay:
        return Colors.pink.shade300;
      case SourceType.document:
        return StudyRepsTheme.warmTextMedium;
    }
  }

  IconData _getTypeIcon() {
    switch (type) {
      case SourceType.pdf:
        return Icons.picture_as_pdf;
      case SourceType.image:
        return Icons.image;
      case SourceType.assignment:
        return Icons.assignment;
      case SourceType.report:
        return Icons.analytics;
      case SourceType.quiz:
        return Icons.quiz;
      case SourceType.essay:
        return Icons.edit_document;
      case SourceType.document:
        return Icons.description;
    }
  }
}

enum SourceType {
  pdf,
  image,
  assignment,
  report,
  quiz,
  essay,
  document,
}
