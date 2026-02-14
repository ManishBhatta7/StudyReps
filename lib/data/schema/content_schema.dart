/// StudyReps Content Schema
/// 
/// This defines the structure for all educational content in the app.
/// Content follows a hierarchy: Board → Subject → Chapter → Topic → Video
/// 
/// This schema is designed to be:
/// 1. Easy to populate from PDFs
/// 2. Compatible with NotebookLM workflow
/// 3. Scalable for multiple subjects/boards

// ============================================================
// LEVEL 1: BOARD (Top level organization)
// ============================================================
/// Represents an educational board (ICSE, CBSE, IB, etc.)
class BoardSchema {
  final String id;           // 'icse', 'cbse', 'ib'
  final String name;         // 'ICSE', 'CBSE', 'IB'
  final String country;      // 'India', 'International'
  final List<String> grades; // ['8', '9', '10', '11', '12']
  
  const BoardSchema({
    required this.id,
    required this.name,
    required this.country,
    required this.grades,
  });
}

// Example:
// BoardSchema(id: 'icse', name: 'ICSE', country: 'India', grades: ['9', '10'])

// ============================================================
// LEVEL 2: SUBJECT
// ============================================================
/// Represents a subject within a board
class SubjectSchema {
  final String id;           // 'physics_10_icse'
  final String boardId;      // 'icse'
  final String grade;        // '10'
  final String name;         // 'Physics'
  final String icon;         // '🔬' or icon asset path
  final String color;        // '#6366F1' for theming
  final int totalChapters;   // 12
  
  const SubjectSchema({
    required this.id,
    required this.boardId,
    required this.grade,
    required this.name,
    required this.icon,
    required this.color,
    required this.totalChapters,
  });
}

// ============================================================
// LEVEL 3: CHAPTER
// ============================================================
/// Represents a chapter within a subject
class ChapterSchema {
  final String id;           // 'physics_ch1_force'
  final String subjectId;    // 'physics_10_icse'
  final int chapterNumber;   // 1
  final String title;        // 'Force'
  final String description;  // 'Newton's laws, momentum, equilibrium'
  final int totalTopics;     // 10
  final int estimatedMinutes; // 25 (total learning time)
  
  // Source material info (for your reference)
  final String? sourcePdf;   // 'DOC-20260124-WA0014.pdf'
  final int? sourcePageStart; // 1
  final int? sourcePageEnd;   // 5
  
  const ChapterSchema({
    required this.id,
    required this.subjectId,
    required this.chapterNumber,
    required this.title,
    required this.description,
    required this.totalTopics,
    required this.estimatedMinutes,
    this.sourcePdf,
    this.sourcePageStart,
    this.sourcePageEnd,
  });
}

// ============================================================
// LEVEL 4: TOPIC (Maps to ONE video)
// ============================================================
/// Represents a single topic = one video in the feed
/// This is your CORE content unit
class TopicSchema {
  final String id;           // 'force_intro'
  final String chapterId;    // 'physics_ch1_force'
  final int topicNumber;     // 1
  final String title;        // 'Introduction to Force'
  final String description;  // 'What is force, units, types'
  
  // Content Generation Info
  final String notebookLMPrompt;  // The prompt to use in NotebookLM
  final List<String> keyConcepts; // ['Force definition', 'SI unit', 'CGS unit']
  final List<String> formulas;    // ['1N = 10^5 dyne']
  final List<String> examples;    // ['Pushing a door', 'Gravity pulling apple']
  
  // Video Info (filled after NotebookLM generation)
  final String? videoUrl;         // Cloud storage URL (null until generated)
  final String? audioUrl;         // Original audio from NotebookLM
  final String? thumbnailUrl;     // Video thumbnail
  final int? videoDurationSeconds; // 120
  
  // The Lock Configuration  
  final int lockTimestamp;        // 45 (seconds into video)
  final QuestionSchema question;  // The question to ask
  
  // Metadata
  final int difficulty;           // 1-3 (easy, medium, hard)
  final List<String> tags;        // ['newton', 'force', 'basics']
  
  const TopicSchema({
    required this.id,
    required this.chapterId,
    required this.topicNumber,
    required this.title,
    required this.description,
    required this.notebookLMPrompt,
    required this.keyConcepts,
    this.formulas = const [],
    this.examples = const [],
    this.videoUrl,
    this.audioUrl,
    this.thumbnailUrl,
    this.videoDurationSeconds,
    required this.lockTimestamp,
    required this.question,
    this.difficulty = 1,
    this.tags = const [],
  });
  
  /// Check if video is ready to publish
  bool get isPublishReady => videoUrl != null && videoUrl!.isNotEmpty;
}

// ============================================================
// QUESTION SCHEMA (For "The Lock")
// ============================================================
/// Represents a question for The Lock feature
class QuestionSchema {
  final String id;
  final QuestionFormatType format;  // How the question is presented
  final String prompt;              // The question text
  final String correctAnswer;       // Expected answer
  final List<String>? options;      // For MCQ type
  final String? hint;               // Optional hint
  final String explanation;         // Shown after answering
  final int points;                 // XP earned for correct answer
  
  // For numerical questions
  final double? tolerance;          // Acceptable error margin (e.g., 0.1)
  final String? unit;               // 'N', 'm/s', 'kg·m/s'
  
  const QuestionSchema({
    required this.id,
    required this.format,
    required this.prompt,
    required this.correctAnswer,
    this.options,
    this.hint,
    required this.explanation,
    this.points = 10,
    this.tolerance,
    this.unit,
  });
}

/// Question format types
enum QuestionFormatType {
  multipleChoice,    // Pick from options
  numerical,         // Enter a number (e.g., "15")
  textInput,         // Enter text (e.g., "Newton")
  trueFalse,         // True or False
  fillBlank,         // Complete the sentence
  formulaRecall,     // Which formula applies?
  scenarioBased,     // Real-world application
  visualMatch,       // Match with image/diagram
  orderSteps,        // Put in correct order
}

// ============================================================
// CONTENT CREATION TRACKER
// ============================================================
/// Tracks the status of content creation for each topic
class ContentCreationStatus {
  final String topicId;
  
  // Pipeline stages
  final bool promptWritten;      // NotebookLM prompt ready
  final bool audioGenerated;     // MP3 from NotebookLM
  final bool videoCreated;       // Audio converted to video
  final bool videoUploaded;      // Uploaded to cloud
  final bool questionAdded;      // Lock question configured
  final bool tested;             // Tested in app
  final bool published;          // Live in production
  
  // Timestamps
  final DateTime? audioGeneratedAt;
  final DateTime? publishedAt;
  
  // Notes
  final String? notes;           // Any issues or comments
  
  const ContentCreationStatus({
    required this.topicId,
    this.promptWritten = false,
    this.audioGenerated = false,
    this.videoCreated = false,
    this.videoUploaded = false,
    this.questionAdded = false,
    this.tested = false,
    this.published = false,
    this.audioGeneratedAt,
    this.publishedAt,
    this.notes,
  });
  
  double get completionPercentage {
    int completed = 0;
    if (promptWritten) completed++;
    if (audioGenerated) completed++;
    if (videoCreated) completed++;
    if (videoUploaded) completed++;
    if (questionAdded) completed++;
    if (tested) completed++;
    if (published) completed++;
    return completed / 7 * 100;
  }
}

// ============================================================
// EXAMPLE: FORCE CHAPTER DATA
// ============================================================
/// Complete example of how Force chapter would be structured
class ForceChapterData {
  static const chapter = ChapterSchema(
    id: 'physics_ch1_force',
    subjectId: 'physics_10_icse',
    chapterNumber: 1,
    title: 'Force',
    description: "Newton's Laws, Momentum, Equilibrium, Circular Motion",
    totalTopics: 10,
    estimatedMinutes: 25,
    sourcePdf: 'DOC-20260124-WA0014.pdf',
    sourcePageStart: 1,
    sourcePageEnd: 5,
  );
  
  static const List<TopicSchema> topics = [
    // Topic 1: Introduction to Force
    TopicSchema(
      id: 'force_intro',
      chapterId: 'physics_ch1_force',
      topicNumber: 1,
      title: 'Introduction to Force',
      description: 'What is force, SI & CGS units, types of forces',
      notebookLMPrompt: '''
Create an engaging 2-minute explanation about Force.
Cover: Definition (physical cause that changes state of rest/motion),
Units (Newton in SI, Dyne in CGS, 1N = 10^5 dyne),
Types (Contact vs Non-contact forces).
Use real examples like pushing a door, gravity.
Make it conversational and memorable!
      ''',
      keyConcepts: [
        'Force is a physical cause that changes state of rest or motion',
        'SI unit: Newton (N)',
        'CGS unit: Dyne',
        '1 N = 10^5 dyne',
        'Contact forces: friction, tension, normal',
        'Non-contact forces: gravity, magnetic, electric',
      ],
      formulas: ['1 N = 10^5 dyne'],
      examples: ['Pushing a door', 'Gravity pulling apple', 'Magnet attracting iron'],
      lockTimestamp: 45,
      question: QuestionSchema(
        id: 'q_force_intro',
        format: QuestionFormatType.multipleChoice,
        prompt: 'What is the SI unit of force?',
        options: ['Dyne', 'Newton', 'Joule', 'Watt'],
        correctAnswer: 'Newton',
        hint: 'Named after Sir Isaac ___',
        explanation: 'The SI unit of force is Newton (N), named after Isaac Newton. 1 N = 10^5 dyne (CGS unit).',
        points: 10,
      ),
      difficulty: 1,
      tags: ['force', 'units', 'basics'],
    ),
    
    // Topic 2: Newton's First Law
    TopicSchema(
      id: 'newton_first_law',
      chapterId: 'physics_ch1_force',
      topicNumber: 2,
      title: "Newton's First Law - Law of Inertia",
      description: 'Objects at rest stay at rest, objects in motion stay in motion',
      notebookLMPrompt: '''
Explain Newton's First Law (Law of Inertia) in an exciting way!
Key point: A body continues in rest or uniform motion unless external force acts.
Examples: Passenger lurching when bus stops, tablecloth trick, spacecraft in space.
Make it memorable with real-world connections!
      ''',
      keyConcepts: [
        'A body continues in rest or uniform motion unless external force acts',
        'Also called Law of Inertia',
        'Inertia = tendency to resist change in motion',
      ],
      examples: ['Passenger lurching in bus', 'Tablecloth trick', 'Spacecraft in space'],
      lockTimestamp: 50,
      question: QuestionSchema(
        id: 'q_newton1',
        format: QuestionFormatType.scenarioBased,
        prompt: 'A bus suddenly stops. Passengers lurch forward because of:',
        options: ['Friction', 'Inertia', 'Gravity', 'Air resistance'],
        correctAnswer: 'Inertia',
        hint: 'Objects in motion tend to stay in motion...',
        explanation: 'Due to inertia, passengers tend to maintain their forward motion even when the bus stops.',
        points: 15,
      ),
      difficulty: 1,
      tags: ['newton', 'inertia', 'first-law'],
    ),
    
    // Topic 3: Newton's Second Law
    TopicSchema(
      id: 'newton_second_law',
      chapterId: 'physics_ch1_force',
      topicNumber: 3,
      title: "Newton's Second Law - F=ma",
      description: 'Force equals mass times acceleration',
      notebookLMPrompt: '''
Break down the most important physics equation: F = ma!
Build up: Force = rate of change of momentum = m × (Δv/Δt) = m × a
Examples: Heavier cars need more power, cricket ball hurts more when fast.
Include a quick calculation example!
      ''',
      keyConcepts: [
        'F = ma (Force = mass × acceleration)',
        'Force causes change in momentum',
        'F = Δp/Δt = m × Δv/Δt = ma',
      ],
      formulas: ['F = ma', 'F = Δp/Δt'],
      examples: ['Heavy car needs more force', 'Fast cricket ball hurts more'],
      lockTimestamp: 60,
      question: QuestionSchema(
        id: 'q_newton2',
        format: QuestionFormatType.numerical,
        prompt: 'A 5 kg object accelerates at 3 m/s². What force is applied?',
        correctAnswer: '15',
        hint: 'Use F = m × a',
        explanation: 'F = ma = 5 kg × 3 m/s² = 15 N',
        points: 20,
        unit: 'N',
      ),
      difficulty: 2,
      tags: ['newton', 'f=ma', 'second-law', 'calculation'],
    ),
    
    // ... More topics would follow the same pattern
  ];
}

// ============================================================
// JSON EXPORT FORMAT (For database/API)
// ============================================================
/// This shows how content would be stored in Supabase/database
/// 
/// Tables:
/// - boards (id, name, country)
/// - subjects (id, board_id, grade, name, icon, color)
/// - chapters (id, subject_id, number, title, description)
/// - topics (id, chapter_id, number, title, video_url, lock_timestamp, ...)
/// - questions (id, topic_id, format, prompt, correct_answer, ...)
/// 
/// Example JSON for a topic:
/// {
///   "id": "force_intro",
///   "chapter_id": "physics_ch1_force",
///   "topic_number": 1,
///   "title": "Introduction to Force",
///   "video_url": "https://storage.supabase.co/videos/force_intro.mp4",
///   "thumbnail_url": "https://storage.supabase.co/thumbs/force_intro.jpg",
///   "duration_seconds": 120,
///   "lock_timestamp": 45,
///   "difficulty": 1,
///   "question": {
///     "format": "multiple_choice",
///     "prompt": "What is the SI unit of force?",
///     "options": ["Dyne", "Newton", "Joule", "Watt"],
///     "correct_answer": "Newton",
///     "explanation": "The SI unit is Newton (N), 1N = 10^5 dyne"
///   }
/// }
