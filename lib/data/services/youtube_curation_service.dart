import '../../domain/models/video_model.dart';

/// Curated high-quality educational videos tailored to specific curriculums
///
/// Educational clips focused on CBSE, ICSE, and IGCSE curriculums.
class YoutubeCurationService {
  
  /// Get curated Shorts from popular science & education creators
  static List<VideoModel> getCuratedContent() {
    return [
      // ── CBSE Grade 9 — "Force and Laws of Motion" ──
      const VideoModel(
        id: 'cbse_force_9',
        videoUrl: 'https://www.youtube.com/watch?v=wX-yA7A3mGo',
        startSeconds: 0,
        endSeconds: 60,
        lockTimestamp: 30,
        title: 'Force and Laws of Motion',
        subject: 'Physics',
        creatorName: 'CBSE Science',
        creatorAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=CBSE',
        thumbnailUrl: 'https://img.youtube.com/vi/wX-yA7A3mGo/hqdefault.jpg',
        transcript: 'According to Newton\'s First Law of Motion, an object at rest stays at rest, and an object in motion stays in motion with the same speed and in the same direction unless acted upon by an unbalanced force. This tendency to resist changes in their state of motion is described as inertia.',
        difficultyLevel: 2,
        tags: ['CBSE', 'Physics', 'Motion', 'Newton', 'Force'],
        boards: ['CBSE'],
        grades: ['Grade 9'],
        question: QuestionModel(
          prompt: 'What principle describes an object\'s resistance to change its state of motion?',
          correctAnswer: 'Inertia',
          type: QuestionType.multipleChoice,
          options: ['Acceleration', 'Inertia', 'Velocity', 'Momentum'],
          explanation: 'Inertia is the inherent property of matter that resists changes to its state of motion or rest, forming the basis of Newton\'s First Law.',
        ),
      ),

      // ── ICSE Grade 7 — "Acids, Bases and Salts" ──
      const VideoModel(
        id: 'icse_acids_7',
        videoUrl: 'https://www.youtube.com/watch?v=Fvd-02YF8gI',
        startSeconds: 0,
        endSeconds: 60,
        lockTimestamp: 25,
        title: 'Acids, Bases and Salts',
        subject: 'Chemistry',
        creatorName: 'ICSE Chem',
        creatorAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=ICSE',
        thumbnailUrl: 'https://img.youtube.com/vi/Fvd-02YF8gI/hqdefault.jpg',
        transcript: 'Acids are sour tasting substances that turn blue litmus paper red. Bases are bitter tasting and soapy to touch, turning red litmus to blue. When an acid and a base react, they neutralize each other, typically forming a salt and water.',
        difficultyLevel: 1,
        tags: ['ICSE', 'Chemistry', 'Acids', 'Bases', 'Salts'],
        boards: ['ICSE'],
        grades: ['Grade 7'],
        question: QuestionModel(
          prompt: 'What happens to blue litmus paper when exposed to an acid?',
          correctAnswer: 'It turns red',
          type: QuestionType.multipleChoice,
          options: ['It turns red', 'It becomes transparent', 'It stays blue', 'It turns green'],
          explanation: 'Acids have the chemical property of turning blue litmus paper red, which is a common test used to identify acidic solutions.',
        ),
      ),

      // ── IGCSE Grade 8 — "Structure of the Cell" ──
      const VideoModel(
        id: 'igcse_cells_8',
        videoUrl: 'https://www.youtube.com/watch?v=8jlIGTXQ6A8',
        startSeconds: 0,
        endSeconds: 60,
        lockTimestamp: 35,
        title: 'Structure of the Cell',
        subject: 'Biology',
        creatorName: 'IGCSE Bio',
        creatorAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=IGCSE',
        thumbnailUrl: 'https://img.youtube.com/vi/8jlIGTXQ6A8/hqdefault.jpg',
        transcript: 'The cell is the basic building block of all living organisms. Animal and plant cells share key structures like the nucleus, which contains DNA; the cell membrane, which controls what enters and exits; and the cytoplasm where chemical reactions happen.',
        difficultyLevel: 2,
        tags: ['IGCSE', 'Biology', 'Cells', 'Nucleus', 'Membrane'],
        boards: ['IGCSE'],
        grades: ['Grade 8'],
        question: QuestionModel(
          prompt: 'Which organelle contains the genetic material (DNA) of the cell?',
          correctAnswer: 'Nucleus',
          type: QuestionType.multipleChoice,
          options: ['Cytoplasm', 'Cell Membrane', 'Nucleus', 'Mitochondria'],
          explanation: 'The nucleus acts as the control center of the cell and houses the DNA, which contains the genetic instructions necessary for the organism.',
        ),
      ),
    ];
  }
}

