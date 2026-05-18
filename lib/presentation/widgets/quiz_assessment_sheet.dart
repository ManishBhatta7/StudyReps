import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../domain/models/video_model.dart';

/// "Quiz" — Gamified MCQ Assessment
class QuizAssessmentSheet extends StatelessWidget {
  final VideoModel video;
  const QuizAssessmentSheet({super.key, required this.video});

  static void show(BuildContext context, VideoModel video) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85, minChildSize: 0.5, maxChildSize: 0.95,
        builder: (ctx, sc) => _QuizContent(video: video),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _QuizContent(video: video);
}

class _QuizContent extends StatefulWidget {
  final VideoModel video;
  const _QuizContent({required this.video});
  @override
  State<_QuizContent> createState() => _QuizContentState();
}

class _QuizContentState extends State<_QuizContent> {
  bool _loading = true;
  List<_Q> _questions = [];
  int _idx = 0;
  int? _selected;
  bool _answered = false;
  int _score = 0;
  bool _done = false;

  @override
  void initState() { super.initState(); _gen(); }

  Future<void> _gen() async {
    try {
      final q = await _fetch();
      if (mounted) setState(() { _questions = q; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _questions = _fallback(); _loading = false; });
    }
  }

  Future<List<_Q>> _fetch() async {
    final k = AppConstants.geminiApiKey;
    if (k.isEmpty || k == 'YOUR_GEMINI_API_KEY') return _fallback();
    final p = '''Generate 5 MCQ quiz questions as JSON array for "${widget.video.title}" (${widget.video.subject}).
Transcript: "${widget.video.transcript}"
Each: {"question":"...", "options":["A","B","C","D"], "correctIndex": 0-3, "explanation":"1 sentence why correct"}
Return ONLY JSON array.''';
    final url = Uri.parse('${AppConstants.geminiBaseUrl}/models/${AppConstants.geminiModel}:generateContent?key=$k');
    final r = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({
      'contents': [{'parts': [{'text': p}]}],
      'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 800, 'responseMimeType': 'application/json'},
    }));
    if (r.statusCode == 200) {
      final d = jsonDecode(r.body);
      final parts = d['candidates']?[0]?['content']?['parts'] as List?;
      if (parts != null && parts.isNotEmpty) {
        var t = (parts[0]['text'] as String).replaceAll('```json','').replaceAll('```','').trim();
        if (t.contains('[')) t = t.substring(t.indexOf('['), t.lastIndexOf(']') + 1);
        return (jsonDecode(t) as List).map((c) => _Q(
          question: c['question']??'', options: List<String>.from(c['options']??[]),
          correctIdx: c['correctIndex']??0, explanation: c['explanation']??'',
        )).toList();
      }
    }
    return _fallback();
  }

  List<_Q> _fallback() => [
    _Q(question: widget.video.question.prompt, options: widget.video.question.options.isNotEmpty ? widget.video.question.options : ['Option A','Option B','Option C','Option D'],
      correctIdx: widget.video.question.options.indexOf(widget.video.question.correctAnswer).clamp(0, 3), explanation: widget.video.question.explanation),
  ];

  void _select(int i) {
    if (_answered) return;
    HapticFeedback.selectionClick();
    setState(() { _selected = i; });
  }

  void _confirm() {
    if (_selected == null) return;
    final correct = _selected == _questions[_idx].correctIdx;
    HapticFeedback.heavyImpact();
    setState(() { _answered = true; if (correct) _score++; });
  }

  void _next() {
    if (_idx < _questions.length - 1) {
      setState(() { _idx++; _selected = null; _answered = false; });
    } else {
      setState(() => _done = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF1C1C1E), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        // Handle
        Center(child: Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
        // Header
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Row(children: [
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)]), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.quiz_rounded, color: Colors.white, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Quick Quiz', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(_loading ? 'Generating...' : '${_questions.length} questions', style: GoogleFonts.outfit(fontSize: 13, color: Colors.white54)),
          ])),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.white54)),
        ])),

        // Progress bar
        if (!_loading && !_done)
          Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Question ${_idx + 1} of ${_questions.length}', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white54)),
              Text('$_score correct', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: StudyRepsTheme.warmGreen)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
              value: (_idx + 1) / _questions.length,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(StudyRepsTheme.warmGreen),
              minHeight: 6,
            )),
          ])),

        const SizedBox(height: 20),
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator(color: StudyRepsTheme.warmGreen)) : _done ? _results() : _questionUI()),
      ]),
    );
  }

  Widget _questionUI() {
    final q = _questions[_idx];
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: [
      // Question
      Container(
        width: double.infinity, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
        child: Text(q.question, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white, height: 1.5)),
      ).animate().fadeIn(duration: 300.ms),
      const SizedBox(height: 20),

      // Options
      ...List.generate(q.options.length, (i) {
        final isCorrect = i == q.correctIdx;
        final isSelected = _selected == i;
        Color borderColor = Colors.white10;
        Color bgColor = Colors.white.withOpacity(0.04);
        Color textColor = Colors.white;

        if (_answered) {
          if (isCorrect) { borderColor = StudyRepsTheme.warmGreen; bgColor = StudyRepsTheme.warmGreen.withOpacity(0.15); }
          else if (isSelected && !isCorrect) { borderColor = StudyRepsTheme.errorPink; bgColor = StudyRepsTheme.errorPink.withOpacity(0.15); }
        } else if (isSelected) {
          borderColor = StudyRepsTheme.warmOrange; bgColor = StudyRepsTheme.warmOrange.withOpacity(0.1);
        }

        return Padding(padding: const EdgeInsets.only(bottom: 10), child: GestureDetector(
          onTap: () => _select(i),
          child: AnimatedContainer(duration: 200.ms, width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor, width: 1.5)),
            child: Row(children: [
              Container(width: 28, height: 28, decoration: BoxDecoration(
                color: isSelected ? (borderColor).withOpacity(0.2) : Colors.white10, shape: BoxShape.circle, border: Border.all(color: borderColor)),
                child: _answered && isCorrect ? const Icon(Icons.check_rounded, size: 16, color: StudyRepsTheme.warmGreen)
                  : _answered && isSelected && !isCorrect ? const Icon(Icons.close_rounded, size: 16, color: StudyRepsTheme.errorPink) : null),
              const SizedBox(width: 14),
              Expanded(child: Text(q.options[i], style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500, color: textColor))),
            ]),
          ),
        ));
      }),

      // Explanation
      if (_answered) Container(
        width: double.infinity, margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (_selected == q.correctIdx ? StudyRepsTheme.warmGreen : StudyRepsTheme.errorPink).withOpacity(0.08),
          borderRadius: BorderRadius.circular(16)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(_selected == q.correctIdx ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            color: _selected == q.correctIdx ? StudyRepsTheme.warmGreen : StudyRepsTheme.warmOrange, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(q.explanation, style: GoogleFonts.outfit(fontSize: 14, color: Colors.white70, height: 1.4))),
        ]),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),

      const Spacer(),

      // Confirm / Next button
      Padding(padding: const EdgeInsets.only(bottom: 20), child: GestureDetector(
        onTap: _answered ? _next : _confirm,
        child: Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: _selected != null
              ? [StudyRepsTheme.warmOrange, StudyRepsTheme.warmOrangeDark]
              : [Colors.white10, Colors.white10]),
            borderRadius: BorderRadius.circular(16)),
          child: Center(child: Text(
            _answered ? (_idx < _questions.length - 1 ? 'Next Question' : 'See Results') : 'Confirm',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: _selected != null ? Colors.white : Colors.white30),
          )),
        ),
      )),
    ]));
  }

  Widget _results() {
    final p = _questions.isNotEmpty ? (_score / _questions.length * 100).round() : 0;
    final xp = _score * 25;
    return Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      // XP burst
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(
        gradient: LinearGradient(colors: [StudyRepsTheme.warmOrange.withOpacity(0.2), Colors.transparent]),
        shape: BoxShape.circle),
        child: Text(p >= 80 ? '🏆' : p >= 50 ? '⭐' : '📖', style: const TextStyle(fontSize: 56))),
      const SizedBox(height: 16),
      Text(p >= 80 ? 'Outstanding!' : p >= 50 ? 'Well Done!' : 'Keep Learning!',
        style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
      const SizedBox(height: 8),
      Text('$_score / ${_questions.length} correct ($p%)', style: GoogleFonts.outfit(fontSize: 16, color: Colors.white54)),
      const SizedBox(height: 12),
      // XP gained
      Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: StudyRepsTheme.warmOrange.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.bolt_rounded, color: StudyRepsTheme.warmOrange, size: 20),
          const SizedBox(width: 6),
          Text('+$xp XP', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: StudyRepsTheme.warmOrange)),
        ])).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.8, 0.8)),
      const SizedBox(height: 32),
      GestureDetector(onTap: () => Navigator.pop(context), child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [StudyRepsTheme.warmOrange, StudyRepsTheme.warmOrangeDark]), borderRadius: BorderRadius.circular(30)),
        child: Text('Done', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)))),
    ]).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1)));
  }
}

class _Q { final String question; final List<String> options; final int correctIdx; final String explanation;
  _Q({required this.question, required this.options, required this.correctIdx, required this.explanation}); }
