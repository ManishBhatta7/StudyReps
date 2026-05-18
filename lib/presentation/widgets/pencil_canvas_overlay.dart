import 'package:flutter/material.dart';
import '../../core/theme/study_reps_theme.dart';

class PencilCanvasOverlay extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onDone;

  const PencilCanvasOverlay({
    super.key,
    required this.onCancel,
    required this.onDone,
  });

  @override
  State<PencilCanvasOverlay> createState() => PencilCanvasOverlayState();
}

class PencilCanvasOverlayState extends State<PencilCanvasOverlay> {
  Offset? _startPoint;
  Offset? _endPoint;

  void _clear() {
    setState(() {
      _startPoint = null;
      _endPoint = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Transparent detector for rectangular selection
        GestureDetector(
          onPanStart: (details) {
            setState(() {
              RenderBox renderBox = context.findRenderObject() as RenderBox;
              _startPoint = renderBox.globalToLocal(details.globalPosition);
              _endPoint = _startPoint;
            });
          },
          onPanUpdate: (details) {
            setState(() {
              RenderBox renderBox = context.findRenderObject() as RenderBox;
              _endPoint = renderBox.globalToLocal(details.globalPosition);
            });
          },
          child: CustomPaint(
            painter: _HighlightPainter(start: _startPoint, end: _endPoint),
            size: Size.infinite,
          ),
        ),

        // Action Toolbar
        Positioned(
          top: 60,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Cancel Button
              GestureDetector(
                onTap: widget.onCancel,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              // Instructions / Clear Button
              if (_startPoint == null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: StudyRepsTheme.primaryPurple.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Drag to highlight an area', style: TextStyle(color: Colors.white, fontSize: 12)),
                )
              else
                GestureDetector(
                  onTap: _clear,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                  ),
                ),
              // Done Button
              GestureDetector(
                onTap: widget.onDone,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: StudyRepsTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Ask AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HighlightPainter extends CustomPainter {
  final Offset? start;
  final Offset? end;

  _HighlightPainter({this.start, this.end});

  @override
  void paint(Canvas canvas, Size size) {
    if (start == null || end == null) return;

    // Create the rect
    final rect = Rect.fromPoints(start!, end!);

    // Draw dark semi-transparent overlay over EVERYTHING
    final overlayPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;
    
    // We use saveLayer and BlendMode.clear to "punch a hole" in the overlay
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    
    // 1. Draw the dark overlay
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);
    
    // 2. Clear the rectangular selection (punch hole)
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear;
    canvas.drawRect(rect, clearPaint);
    
    canvas.restore();

    // 3. Draw a bright border around the selection
    final borderPaint = Paint()
      ..color = StudyRepsTheme.errorPink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    canvas.drawRect(rect, borderPaint);
    
    // 4. Draw corner handles (optional polish)
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
      
    double handleRadius = 4.0;
    canvas.drawCircle(rect.topLeft, handleRadius, handlePaint);
    canvas.drawCircle(rect.topRight, handleRadius, handlePaint);
    canvas.drawCircle(rect.bottomLeft, handleRadius, handlePaint);
    canvas.drawCircle(rect.bottomRight, handleRadius, handlePaint);
  }

  @override
  bool shouldRepaint(covariant _HighlightPainter oldDelegate) {
    return oldDelegate.start != start || oldDelegate.end != end;
  }
}
