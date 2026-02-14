import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../domain/models/video_model.dart';
import 'package:uuid/uuid.dart';

class CreateRepDialog extends StatefulWidget {
  const CreateRepDialog({super.key});

  @override
  State<CreateRepDialog> createState() => _CreateRepDialogState();
}

class _CreateRepDialogState extends State<CreateRepDialog> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  
  // Video Source
  File? _selectedVideo;
  String? _videoUrl;
  bool _isUrlMode = false;
  
  // Form Fields
  final _titleController = TextEditingController();
  final _questionController = TextEditingController();
  final _correctAnswerController = TextEditingController();
  final _wrong1Controller = TextEditingController();
  final _wrong2Controller = TextEditingController();
  final _wrong3Controller = TextEditingController();
  final _explanationController = TextEditingController();
  
  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _selectedVideo = File(video.path);
        _isUrlMode = false;
        // Auto-fill title from filename if empty
        if (_titleController.text.isEmpty) {
          _titleController.text = video.name.split('.').first;
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedVideo == null && (_videoUrl == null || _videoUrl!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a video or enter a URL')),
        );
        return;
      }

      final options = [
        _correctAnswerController.text,
        _wrong1Controller.text,
        _wrong2Controller.text,
        _wrong3Controller.text,
      ]..shuffle();

      final newVideo = VideoModel(
        id: const Uuid().v4(),
        videoUrl: _isUrlMode ? _videoUrl! : _selectedVideo!.path,
        title: _titleController.text,
        creatorName: 'You',
        subject: 'Custom Rep',
        lockTimestamp: 5, // Default lock time for custom videos
        duration: const Duration(seconds: 30), // Placeholder
        question: QuestionModel(
          prompt: _questionController.text,
          type: QuestionType.multipleChoice,
          correctAnswer: _correctAnswerController.text,
          options: options,
          explanation: _explanationController.text,
        ),
      );

      Navigator.of(context).pop(newVideo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: StudyRepsTheme.bgSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.add_circle_outline, color: StudyRepsTheme.primaryPurple),
                const SizedBox(width: 12),
                Text(
                  'Create New Rep',
                  style: StudyRepsTheme.darkTheme.textTheme.headlineLarge?.copyWith(fontSize: 20),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: Colors.white10),
            
            // Scrollable Form
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      
                      // Video Picker
                      _buildSectionLabel('VIDEO SOURCE'),
                      const SizedBox(height: 8),
                      if (_selectedVideo != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.movie, color: Colors.green),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedVideo!.path.split('/').last,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => setState(() => _selectedVideo = null),
                              ),
                            ],
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.video_library),
                                label: const Text('Gallery'),
                                onPressed: _pickVideo,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2A2A40),
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 24),
                      _buildSectionLabel('DETAILS'),
                      _buildTextField(_titleController, 'Title / Topic'),
                      
                      const SizedBox(height: 16),
                      _buildSectionLabel('THE LOCK (QUESTION)'),
                      _buildTextField(_questionController, 'Question Prompt', maxLines: 2),
                      const SizedBox(height: 8),
                      _buildTextField(_correctAnswerController, '✅ Correct Answer', 
                        icon: Icons.check_circle_outline, color: Colors.green),
                      const SizedBox(height: 8),
                      _buildTextField(_wrong1Controller, '❌ Wrong Option 1'),
                      const SizedBox(height: 8),
                      _buildTextField(_wrong2Controller, '❌ Wrong Option 2'),
                      const SizedBox(height: 8),
                      _buildTextField(_wrong3Controller, '❌ Wrong Option 3'),
                      
                      const SizedBox(height: 16),
                      _buildSectionLabel('EXPLANATION'),
                      _buildTextField(_explanationController, 'Why is it correct?', maxLines: 2),
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer Buttons
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: StudyRepsTheme.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Create Rep'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {
    int maxLines = 1,
    IconData? icon,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: color ?? Colors.white),
        maxLines: maxLines,
        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: (color ?? Colors.white).withOpacity(0.5)),
          prefixIcon: icon != null ? Icon(icon, color: color, size: 20) : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
