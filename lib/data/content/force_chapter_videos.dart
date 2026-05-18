// Offline Fallback Video Data for StudyReps
// Used when Supabase is unreachable — mirrors the seeded database content

import '../../domain/models/video_model.dart';

/// Offline fallback videos across all 5 subjects
class ForceChapterVideos {
  
  /// All videos for the offline fallback feed
  static List<VideoModel> getVideos() => [
    // ── PHYSICS ──
    const VideoModel(
      id: 'physics_newton_apple',
      videoUrl: 'assets/videos/sample.mp4',
      lockTimestamp: 8,
      title: 'Newton\'s Law of Gravitation',
      subject: 'Physics',
      creatorName: 'PhysicsWallah',
      difficultyLevel: 1,
      topicId: 'gravity',
      conceptCluster: 'gravity_basics',
      tags: ['gravity', 'newton', 'physics'],
      likesCount: 1205,
      question: QuestionModel(
        id: 'q_gravity_1',
        prompt: 'Does gravity act between any two masses in the universe?',
        correctAnswer: 'Yes, always attractive',
        type: QuestionType.multipleChoice,
        options: ['Only on Earth', 'Yes, always attractive', 'Only in space', 'No way'],
        hint: 'Universal Law of Gravitation',
        explanation: 'Gravity is a universal attractive force between all masses.',
      ),
    ),
    const VideoModel(
      id: 'physics_newtons_laws',
      videoUrl: 'assets/videos/sample.mp4',
      lockTimestamp: 12,
      title: 'Newton\'s 3 Laws of Motion',
      subject: 'Physics',
      creatorName: 'PhysicsWallah',
      difficultyLevel: 1,
      topicId: 'classical_mechanics',
      conceptCluster: 'newton_laws',
      tags: ['physics', 'newton', 'motion'],
      likesCount: 980,
      question: QuestionModel(
        id: 'q_newton_laws_1',
        prompt: 'Which of Newton\'s laws states F = ma?',
        correctAnswer: 'Second Law',
        type: QuestionType.multipleChoice,
        options: ['First Law', 'Second Law', 'Third Law', 'Gravitation'],
        hint: 'Force = mass x acceleration',
        explanation: 'Newton\'s Second Law: F = ma.',
      ),
    ),
    const VideoModel(
      id: 'physics_thermo',
      videoUrl: 'assets/videos/sample.mp4',
      lockTimestamp: 20,
      title: 'Thermodynamics: Entropy',
      subject: 'Physics',
      creatorName: 'ScienceGuy',
      difficultyLevel: 3,
      topicId: 'thermodynamics',
      conceptCluster: 'entropy',
      tags: ['physics', 'heat', 'entropy'],
      likesCount: 670,
      question: QuestionModel(
        id: 'q_thermo_1',
        prompt: 'Can entropy of an isolated system decrease over time?',
        correctAnswer: 'No, never',
        type: QuestionType.multipleChoice,
        options: ['Yes, if cold', 'No, never', 'Maybe', 'Only in vacuum'],
        hint: 'Second Law of Thermodynamics',
        explanation: 'Entropy of an isolated system always increases or stays constant.',
      ),
    ),

    // ── CHEMISTRY ──
    const VideoModel(
      id: 'chem_periodic_table',
      videoUrl: 'assets/videos/sample.mp4',
      lockTimestamp: 10,
      title: 'The Periodic Table: Trends',
      subject: 'Chemistry',
      creatorName: 'ChemPossible',
      difficultyLevel: 2,
      topicId: 'periodic_table',
      conceptCluster: 'trends',
      tags: ['chemistry', 'periodic table', 'elements'],
      likesCount: 890,
      question: QuestionModel(
        id: 'q_chem_1',
        prompt: 'Which element has the highest electronegativity?',
        correctAnswer: 'Fluorine (F)',
        type: QuestionType.multipleChoice,
        options: ['Oxygen (O)', 'Fluorine (F)', 'Chlorine (Cl)', 'Francium (Fr)'],
        hint: 'Top right corner (excluding noble gases)',
        explanation: 'Fluorine is the most electronegative element.',
      ),
    ),
    const VideoModel(
      id: 'chem_acids_bases',
      videoUrl: 'assets/videos/sample.mp4',
      lockTimestamp: 13,
      title: 'Acids, Bases and pH Scale',
      subject: 'Chemistry',
      creatorName: 'ChemPossible',
      difficultyLevel: 2,
      topicId: 'acids_bases',
      conceptCluster: 'ph_reactions',
      tags: ['chemistry', 'acids', 'bases', 'ph'],
      likesCount: 750,
      question: QuestionModel(
        id: 'q_ph_1',
        prompt: 'A solution with pH 3 is ___',
        correctAnswer: 'Acidic',
        type: QuestionType.multipleChoice,
        options: ['Acidic', 'Basic', 'Neutral', 'Cannot determine'],
        hint: 'pH less than 7 means...',
        explanation: 'pH below 7 indicates an acidic solution.',
      ),
    ),

    // ── BIOLOGY ──
    const VideoModel(
      id: 'bio_cell_division',
      videoUrl: 'assets/videos/sample.mp4',
      lockTimestamp: 15,
      title: 'Mitosis vs Meiosis',
      subject: 'Biology',
      creatorName: 'BioBytes',
      difficultyLevel: 2,
      topicId: 'cell_bio',
      conceptCluster: 'cell_division',
      tags: ['biology', 'cells', 'mitosis'],
      likesCount: 1540,
      question: QuestionModel(
        id: 'q_bio_1',
        prompt: 'In which process do daughter cells have half the chromosomes?',
        correctAnswer: 'Meiosis',
        type: QuestionType.multipleChoice,
        options: ['Mitosis', 'Meiosis', 'Binary Fission', 'Cytokinesis'],
        hint: 'Produces gametes (sperm/egg)',
        explanation: 'Meiosis reduces chromosome number by half for sexual reproduction.',
      ),
    ),
    const VideoModel(
      id: 'bio_dna_structure',
      videoUrl: 'assets/videos/sample.mp4',
      lockTimestamp: 14,
      title: 'DNA: The Double Helix',
      subject: 'Biology',
      creatorName: 'BioBytes',
      difficultyLevel: 2,
      topicId: 'genetics',
      conceptCluster: 'dna_structure',
      tags: ['biology', 'dna', 'genetics'],
      likesCount: 1100,
      question: QuestionModel(
        id: 'q_dna_1',
        prompt: 'Which base pairs with Adenine (A) in DNA?',
        correctAnswer: 'Thymine (T)',
        type: QuestionType.multipleChoice,
        options: ['Guanine (G)', 'Thymine (T)', 'Cytosine (C)', 'Uracil (U)'],
        hint: 'A-T and G-C are complementary pairs',
        explanation: 'In DNA, Adenine always pairs with Thymine.',
      ),
    ),

    // ── MATHEMATICS ──
    const VideoModel(
      id: 'math_pythagoras',
      videoUrl: 'assets/videos/sample.mp4',
      lockTimestamp: 12,
      title: 'Pythagorean Theorem Visualized',
      subject: 'Mathematics',
      creatorName: 'MathAntics',
      difficultyLevel: 1,
      topicId: 'geometry',
      conceptCluster: 'triangles',
      tags: ['math', 'geometry', 'triangles'],
      likesCount: 2300,
      question: QuestionModel(
        id: 'q_math_1',
        prompt: 'For a right triangle with legs 3 and 4, what is the hypotenuse?',
        correctAnswer: '5',
        type: QuestionType.multipleChoice,
        options: ['5', '6', '7', '8'],
        hint: 'a^2 + b^2 = c^2',
        explanation: '3^2 + 4^2 = 9 + 16 = 25. sqrt(25) = 5.',
      ),
    ),
    const VideoModel(
      id: 'math_probability_basics',
      videoUrl: 'assets/videos/sample.mp4',
      lockTimestamp: 10,
      title: 'Probability: Coins and Dice',
      subject: 'Mathematics',
      creatorName: 'MathAntics',
      difficultyLevel: 1,
      topicId: 'probability',
      conceptCluster: 'basic_probability',
      tags: ['math', 'probability', 'dice'],
      likesCount: 920,
      question: QuestionModel(
        id: 'q_prob_1',
        prompt: 'What is the probability of rolling a 6 on a fair die?',
        correctAnswer: '1/6',
        type: QuestionType.multipleChoice,
        options: ['1/2', '1/3', '1/6', '1/12'],
        hint: 'A die has 6 faces',
        explanation: 'Each face has equal probability: P(6) = 1/6.',
      ),
    ),

    // ── HISTORY ──
    const VideoModel(
      id: 'hist_independence',
      videoUrl: 'assets/videos/sample.mp4',
      lockTimestamp: 15,
      title: 'Indian Independence Movement',
      subject: 'History',
      creatorName: 'HistoryHub',
      difficultyLevel: 1,
      topicId: 'indian_history',
      conceptCluster: 'freedom_struggle',
      tags: ['history', 'india', 'independence'],
      likesCount: 1400,
      question: QuestionModel(
        id: 'q_hist_1',
        prompt: 'In which year did India gain independence?',
        correctAnswer: '1947',
        type: QuestionType.numerical,
        options: [],
        hint: '15th August...',
        explanation: 'India gained independence on 15th August 1947.',
      ),
    ),
    const VideoModel(
      id: 'hist_mughal_empire',
      videoUrl: 'assets/videos/sample.mp4',
      lockTimestamp: 14,
      title: 'The Mughal Empire',
      subject: 'History',
      creatorName: 'HistoryHub',
      difficultyLevel: 2,
      topicId: 'indian_history',
      conceptCluster: 'mughal_dynasty',
      tags: ['history', 'mughals', 'india'],
      likesCount: 860,
      question: QuestionModel(
        id: 'q_mughal_1',
        prompt: 'Which Mughal emperor built the Taj Mahal?',
        correctAnswer: 'Shah Jahan',
        type: QuestionType.multipleChoice,
        options: ['Akbar', 'Shah Jahan', 'Aurangzeb', 'Babur'],
        hint: 'Built in memory of his wife Mumtaz Mahal',
        explanation: 'Shah Jahan built the Taj Mahal for his wife Mumtaz Mahal.',
      ),
    ),
  ];

  /// Get a subset for different difficulty levels
  static List<VideoModel> getBeginnerVideos() => 
      getVideos().where((v) => v.difficultyLevel == 1).toList();
  
  static List<VideoModel> getIntermediateVideos() =>
      getVideos().where((v) => v.difficultyLevel == 2).toList();
  
  static List<VideoModel> getAdvancedVideos() =>
      getVideos().where((v) => v.difficultyLevel >= 3).toList();

  /// Get videos by subject
  static List<VideoModel> getBySubject(String subject) =>
      getVideos().where((v) => v.subject == subject).toList();

  /// Get all available subjects
  static List<String> getSubjects() =>
      getVideos().map((v) => v.subject).toSet().toList()..sort();
}

/// Helper to integrate with existing mock data provider
extension ForceChapterExtension on List<VideoModel> {
  /// Add Force chapter videos to existing list
  List<VideoModel> withForceChapter() => [...this, ...ForceChapterVideos.getVideos()];
}
