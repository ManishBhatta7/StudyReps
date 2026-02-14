import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/theme/study_reps_theme.dart';

/// Script Generator Screen
///
/// "Agile Production" tool — creators enter a topic/prompt and
/// Gemini generates a structured video script with timing cues,
/// visual suggestions, and question placement.
class ScriptGeneratorScreen extends StatefulWidget {
  const ScriptGeneratorScreen({super.key});

  @override
  State<ScriptGeneratorScreen> createState() => _ScriptGeneratorScreenState();
}

class _ScriptGeneratorScreenState extends State<ScriptGeneratorScreen> {
  final _topicController = TextEditingController();
  final _subjectController = TextEditingController();
  String _generatedScript = '';
  bool _isGenerating = false;
  int _durationSeconds = 60;
  String _targetLevel = 'Intermediate';

  @override
  void dispose() {
    _topicController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _generateScript() async {
    if (_topicController.text.trim().isEmpty) return;

    setState(() {
      _isGenerating = true;
      _generatedScript = '';
    });

    try {
      final script = await _callGemini();
      setState(() {
        _generatedScript = script;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _generatedScript = 'Error generating script: $e';
        _isGenerating = false;
      });
    }
  }

  Future<String> _callGemini() async {
    final apiKey = AppConstants.geminiApiKey;
    if (apiKey == 'YOUR_GEMINI_API_KEY') {
      return _fallbackScript();
    }

    final prompt = '''
You are a video script writer for StudyReps, a TikTok-style educational platform.

Create a structured video script for:
- TOPIC: "${_topicController.text}"
- SUBJECT: "${_subjectController.text.isNotEmpty ? _subjectController.text : 'General'}"
- DURATION: ${_durationSeconds}s
- LEVEL: $_targetLevel

FORMAT YOUR RESPONSE AS:

## Script: [Title]

### Hook (0-5s)
[Attention-grabbing opening line]

### Core Content (5-${_durationSeconds - 15}s)
[Main explanation broken into short segments]
[Include TIMESTAMPS for each segment]
[Mark where VISUALS should appear: 🎨]
[Mark key terms to highlight: **bold**]

### Lock Question (${_durationSeconds - 15}s)
🔒 QUESTION: [Active recall question based on content]
TYPE: [multiple_choice / open_input / true_false]
ANSWER: [Correct answer]
OPTIONS: [If multiple choice, list 4 options]

### Wrap-up (${_durationSeconds - 10}s-${_durationSeconds}s)
[Quick summary + call to action]

---
VISUAL SUGGESTIONS: [List 3-5 background/overlay ideas]
TAGS: [5 searchable tags]
DIFFICULTY: [1-5]
PREREQUISITES: [Topics students should know first]
''';

    final url = Uri.parse(
      '${AppConstants.geminiBaseUrl}/models/${AppConstants.geminiModel}:generateContent?key=$apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {'parts': [{'text': prompt}]}
        ],
        'generationConfig': {
          'temperature': 0.9,
          'maxOutputTokens': 2000,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
          _fallbackScript();
    }

    return _fallbackScript();
  }

  String _fallbackScript() {
    return '''
## Script: ${_topicController.text}

### Hook (0-5s)
"Did you know that [interesting fact about ${_topicController.text}]?"

### Core Content (5-45s)
**Segment 1 (5-15s):** Define the concept
🎨 Show simple diagram

**Segment 2 (15-30s):** Key principles
🎨 Animated example

**Segment 3 (30-45s):** Real-world application
🎨 Photo/video of real example

### Lock Question (45s)
🔒 QUESTION: "What is the main principle of ${_topicController.text}?"
TYPE: open_input
ANSWER: [Expected answer]

### Wrap-up (50-60s)
Quick recap + "Try teaching this to a friend!"

---
TAGS: ${_topicController.text.toLowerCase()}, education, learning
DIFFICULTY: 2
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudyRepsTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('AI Script Generator ✍️'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                StudyRepsTheme.primaryPurple.withOpacity(0.2),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topic Input
            _buildLabel('Topic / Concept'),
            TextField(
              controller: _topicController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('e.g. Newton\'s Third Law'),
            ),
            const SizedBox(height: 16),

            // Subject
            _buildLabel('Subject (optional)'),
            TextField(
              controller: _subjectController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('e.g. Physics'),
            ),
            const SizedBox(height: 16),

            // Duration slider
            _buildLabel('Duration: ${_durationSeconds}s'),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: StudyRepsTheme.primaryPurple,
                thumbColor: StudyRepsTheme.accentCyan,
                inactiveTrackColor: Colors.white12,
              ),
              child: Slider(
                value: _durationSeconds.toDouble(),
                min: 30,
                max: 180,
                divisions: 5,
                label: '${_durationSeconds}s',
                onChanged: (v) => setState(() => _durationSeconds = v.round()),
              ),
            ),
            const SizedBox(height: 12),

            // Level selector
            _buildLabel('Target Level'),
            Wrap(
              spacing: 8,
              children: ['Beginner', 'Intermediate', 'Advanced'].map((level) {
                final isSelected = _targetLevel == level;
                return ChoiceChip(
                  label: Text(level),
                  selected: isSelected,
                  selectedColor: StudyRepsTheme.primaryPurple,
                  backgroundColor: Colors.white10,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                  onSelected: (_) => setState(() => _targetLevel = level),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Generate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateScript,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_isGenerating ? 'Generating...' : 'Generate Script'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: StudyRepsTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Generated script output
            if (_generatedScript.isNotEmpty) ...[
              _buildLabel('Generated Script'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: StudyRepsTheme.primaryPurple.withOpacity(0.2),
                  ),
                ),
                child: SelectableText(
                  _generatedScript,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _generateScript,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Regenerate'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to video recording with script as teleprompter
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Script saved! Record your video next.')),
                        );
                      },
                      icon: const Icon(Icons.videocam),
                      label: const Text('Use Script'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StudyRepsTheme.accentCyan,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    );
  }
}
