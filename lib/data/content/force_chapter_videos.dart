// Mock Video Data for diverse subjects
// Ready for NotebookLM-generated audio/video integration

import '../../domain/models/video_model.dart';

/// Mock videos for the diverse subjects (Chemistry, Biology, Math, Physics)
class ForceChapterVideos {
  
  /// All videos for the mock feed
  static List<VideoModel> getVideos() => [
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
        hint: 'a² + b² = c²',
        explanation: '3² + 4² = 9 + 16 = 25. √25 = 5.',
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
  ];

  /// Get a subset for different difficulty levels (Updated to use valid IDs)
  static List<VideoModel> getBeginnerVideos() => 
      getVideos().where((v) => v.difficultyLevel == 1).toList();
  
  static List<VideoModel> getIntermediateVideos() =>
      getVideos().where((v) => v.difficultyLevel == 2).toList();
  
  static List<VideoModel> getAdvancedVideos() =>
      getVideos().where((v) => v.difficultyLevel >= 3).toList();
}

/// Helper to integrate with existing mock data provider
extension ForceChapterExtension on List<VideoModel> {
  /// Add Force chapter videos to existing list
  List<VideoModel> withForceChapter() => [...this, ...ForceChapterVideos.getVideos()];
}
