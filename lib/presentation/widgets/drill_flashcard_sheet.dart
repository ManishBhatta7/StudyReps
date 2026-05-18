import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../domain/models/video_model.dart';

/// "Drill Me" — Rapid-Fire Flashcard Stack
class DrillFlashcardSheet extends StatelessWidget {
  final VideoModel video;
  const DrillFlashcardSheet({super.key, required this.video});

  static void show(BuildContext context, VideoModel video) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85, minChildSize: 0.5, maxChildSize: 0.95,
        builder: (context, sc) => _DrillContent(video: video),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _DrillContent(video: video);
}

class _DrillContent extends StatefulWidget {
  final VideoModel video;
  const _DrillContent({required this.video});
  @override
  State<_DrillContent> createState() => _DrillContentState();
}

class _DrillContentState extends State<_DrillContent> {
  bool _isLoading = true;
  List<_FC> _deck = [];
  int _idx = 0;
  bool _flipped = false;
  int _knew = 0, _missed = 0;
  bool _done = false;
  double _dragX = 0;

  @override
  void initState() { super.initState(); _gen(); }

  Future<void> _gen() async {
    try {
      final c = await _fetch();
      if (mounted) setState(() { _deck = c; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _deck = _fallback(); _isLoading = false; });
    }
  }

  Future<List<_FC>> _fetch() async {
    final k = AppConstants.geminiApiKey;
    if (k.isEmpty || k == 'YOUR_GEMINI_API_KEY') return _fallback();
    final p = 'Generate 6 flashcards as JSON array for "${widget.video.title}" (${widget.video.subject}). Transcript: "${widget.video.transcript}". Each: {"front":"question","back":"answer","difficulty":"easy|medium|hard"}. Return ONLY JSON array.';
    final url = Uri.parse('${AppConstants.geminiBaseUrl}/models/${AppConstants.geminiModel}:generateContent?key=$k');
    final r = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({
      'contents': [{'parts': [{'text': p}]}],
      'generationConfig': {'temperature': 0.8, 'maxOutputTokens': 600, 'responseMimeType': 'application/json'},
    }));
    if (r.statusCode == 200) {
      final d = jsonDecode(r.body);
      final parts = d['candidates']?[0]?['content']?['parts'] as List?;
      if (parts != null && parts.isNotEmpty) {
        var t = (parts[0]['text'] as String).replaceAll('```json','').replaceAll('```','').trim();
        if (t.contains('[')) t = t.substring(t.indexOf('['), t.lastIndexOf(']') + 1);
        return (jsonDecode(t) as List).map((c) => _FC(front: c['front']??'', back: c['back']??'', diff: c['difficulty']??'medium')).toList();
      }
    }
    return _fallback();
  }

  List<_FC> _fallback() => [
    _FC(front: 'What is the main idea of "${widget.video.title}"?', back: 'Core concepts in ${widget.video.subject}.', diff: 'easy'),
    _FC(front: 'Why is this topic important?', back: 'It builds the foundation for advanced topics.', diff: 'medium'),
    _FC(front: 'Give a real-world application.', back: 'Applied across many fields in ${widget.video.subject}.', diff: 'hard'),
  ];

  void _right() { HapticFeedback.lightImpact(); setState(() { _knew++; _flipped = false; _dragX = 0; _idx < _deck.length - 1 ? _idx++ : _done = true; }); }
  void _left() { HapticFeedback.mediumImpact(); setState(() { _missed++; _flipped = false; _dragX = 0; _deck.add(_deck[_idx]); _idx < _deck.length - 2 ? _idx++ : _done = true; }); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF1C1C1E), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        Center(child: Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: const LinearGradient(colors: [StudyRepsTheme.warmOrange, StudyRepsTheme.warmOrangeDark]), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Drill Mode', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(_isLoading ? 'Generating...' : '${_deck.length} cards', style: GoogleFonts.outfit(fontSize: 13, color: Colors.white54)),
          ])),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.white54)),
        ])),
        if (!_isLoading && !_done) Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0), child: Row(children: [
          _pill(Icons.check_circle_rounded, '$_knew', StudyRepsTheme.warmGreen),
          const SizedBox(width: 8),
          _pill(Icons.replay_rounded, '$_missed', StudyRepsTheme.errorPink),
          const Spacer(),
          Text('${_idx + 1}/${_deck.length}', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white30)),
        ])),
        const SizedBox(height: 16),
        Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator(color: StudyRepsTheme.warmOrange)) : _done ? _results() : _card()),
        if (!_isLoading && !_done && _flipped) Padding(padding: const EdgeInsets.only(bottom: 20), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _btn(Icons.close_rounded, "Didn't know", StudyRepsTheme.errorPink, _left),
          const SizedBox(width: 32),
          _btn(Icons.check_rounded, 'Knew it!', StudyRepsTheme.warmGreen, _right),
        ])),
        if (!_isLoading && !_done && !_flipped) Padding(padding: const EdgeInsets.only(bottom: 20),
          child: Text('Tap to flip', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white24))),
      ]),
    );
  }

  Widget _pill(IconData i, String c, Color col) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: col.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(i, size: 16, color: col), const SizedBox(width: 4), Text(c, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: col))]));

  Widget _card() {
    final c = _deck[_idx];
    final dc = c.diff == 'easy' ? StudyRepsTheme.warmGreen : c.diff == 'hard' ? StudyRepsTheme.errorPink : StudyRepsTheme.warmOrange;
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); setState(() => _flipped = !_flipped); },
      onPanUpdate: (d) => setState(() => _dragX += d.delta.dx),
      onPanEnd: (_) { if (_dragX > 100) {
        _right();
      } else if (_dragX < -100) _left(); else setState(() => _dragX = 0); },
      child: AnimatedContainer(duration: 200.ms,
        transform: Matrix4.identity()..translate(_dragX, 0.0)..rotateZ(_dragX * 0.001),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Container(
          width: double.infinity, padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_flipped ? 0.08 : 0.04), borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _dragX > 50 ? StudyRepsTheme.warmGreen.withOpacity(0.5) : _dragX < -50 ? StudyRepsTheme.errorPink.withOpacity(0.5) : Colors.white10, width: 2)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: dc.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Text(c.diff.toUpperCase(), style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: dc, letterSpacing: 1))),
            const SizedBox(height: 24),
            AnimatedSwitcher(duration: 300.ms, child: _flipped
              ? Column(key: const ValueKey('b'), children: [
                  Text('ANSWER', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: StudyRepsTheme.warmOrange, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  Text(c.back, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, height: 1.5))])
              : Column(key: const ValueKey('f'), children: [
                  Text('QUESTION', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white38, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  Text(c.front, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, height: 1.5))])),
          ]),
        ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95))),
      ),
    );
  }

  Widget _btn(IconData i, String l, Color c, VoidCallback tap) => GestureDetector(onTap: tap,
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(30), border: Border.all(color: c.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(i, color: c, size: 20), const SizedBox(width: 6), Text(l, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: c))])));

  Widget _results() {
    final t = _knew + _missed; final p = t > 0 ? (_knew / t * 100).round() : 0;
    return Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(p >= 80 ? '🔥' : p >= 50 ? '💪' : '📚', style: const TextStyle(fontSize: 56)),
      const SizedBox(height: 16),
      Text(p >= 80 ? 'Crushing it!' : p >= 50 ? 'Good effort!' : 'Keep drilling!', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
      const SizedBox(height: 8),
      Text('$p% recall rate', style: GoogleFonts.outfit(fontSize: 16, color: Colors.white54)),
      const SizedBox(height: 32),
      GestureDetector(onTap: () => Navigator.pop(context), child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [StudyRepsTheme.warmOrange, StudyRepsTheme.warmOrangeDark]), borderRadius: BorderRadius.circular(30)),
        child: Text('Done', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)))),
    ]).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1)));
  }
}

class _FC { final String front, back, diff; _FC({required this.front, required this.back, required this.diff}); }
