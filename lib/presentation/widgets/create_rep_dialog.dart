import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../domain/models/video_model.dart';
import 'package:uuid/uuid.dart';

/// Create Rep Dialog — BoldVoice warm cream design
class CreateRepDialog extends StatefulWidget {
  const CreateRepDialog({super.key});

  @override
  State<CreateRepDialog> createState() => _CreateRepDialogState();
}

class _CreateRepDialogState extends State<CreateRepDialog> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  
  // Video Source
  XFile? _selectedVideo;
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
        _selectedVideo = video;
        _isUrlMode = false;
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
          SnackBar(
            content: Text(
              'Please select a video or enter a URL',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
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
        lockTimestamp: 5,
        duration: const Duration(seconds: 30),
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
      backgroundColor: StudyRepsTheme.warmCream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: StudyRepsTheme.warmOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_circle_outline, color: StudyRepsTheme.warmOrange),
                ),
                const SizedBox(width: 12),
                Text(
                  'Create New Rep',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: StudyRepsTheme.warmTextDark,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: StudyRepsTheme.warmTextLight),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: StudyRepsTheme.warmBorder),
            
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
                            color: StudyRepsTheme.warmCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: StudyRepsTheme.warmBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.movie, color: StudyRepsTheme.warmGreen),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedVideo!.path.split('/').last,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(color: StudyRepsTheme.warmTextDark),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
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
                                icon: const Icon(Icons.video_library, color: Colors.white),
                                label: Text(
                                  'Gallery',
                                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                                onPressed: _pickVideo,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: StudyRepsTheme.warmOrange,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
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
                        icon: Icons.check_circle_outline, color: StudyRepsTheme.warmGreen),
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
            
            // Footer Button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: StudyRepsTheme.warmOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                  shadowColor: StudyRepsTheme.warmOrange.withOpacity(0.4),
                ),
                child: Text(
                  'Create Rep',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
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
      style: GoogleFonts.outfit(
        color: StudyRepsTheme.warmTextLight,
        fontSize: 12,
        fontWeight: FontWeight.w700,
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
        style: GoogleFonts.outfit(color: color ?? StudyRepsTheme.warmTextDark),
        maxLines: maxLines,
        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(
            color: (color ?? StudyRepsTheme.warmTextMedium).withOpacity(0.7),
          ),
          prefixIcon: icon != null ? Icon(icon, color: color, size: 20) : null,
          filled: true,
          fillColor: StudyRepsTheme.warmCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: StudyRepsTheme.warmBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: StudyRepsTheme.warmBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: StudyRepsTheme.warmOrange, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
