// Mock Video Data for Physics Force Chapter
// Ready for NotebookLM-generated audio/video integration

import '../../domain/models/video_model.dart';

/// Mock videos for the Force chapter
/// In production, URLs would point to NotebookLM-generated content
class ForceChapterVideos {
  
  /// All videos for the Force chapter
  static List<VideoModel> getVideos() => [
    const VideoModel(
      id: 'physics_force_intro',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      lockTimestamp: 8,
      title: 'What is Force? — Introduction',
      subject: 'Physics',
      creatorName: 'StudyReps',
      difficultyLevel: 1,
      topicId: 'force',
      conceptCluster: 'force_basics',
      tags: ['force', 'physics', 'basics', 'ICSE'],
      likesCount: 342,
      question: QuestionModel(
        id: 'q_force_intro',
        prompt: 'What is the SI unit of Force?',
        correctAnswer: 'Newton (N)',
        type: QuestionType.multipleChoice,
        options: ['Joule (J)', 'Newton (N)', 'Pascal (Pa)', 'Watt (W)'],
        hint: 'Named after Sir Isaac Newton',
        explanation: 'Force is measured in Newtons (N). 1 N = 1 kg⋅m/s²',
      ),
    ),
    const VideoModel(
      id: 'physics_newton_first',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      lockTimestamp: 10,
      title: "Newton's First Law of Motion — Inertia",
      subject: 'Physics',
      creatorName: 'StudyReps',
      difficultyLevel: 2,
      topicId: 'newton_laws',
      conceptCluster: 'newton_laws',
      tags: ['newton', 'inertia', 'first law', 'physics'],
      prerequisiteIds: ['physics_force_intro'],
      likesCount: 510,
      question: QuestionModel(
        id: 'q_newton_first',
        prompt: "Newton's First Law is also known as the Law of ___",
        correctAnswer: 'Inertia',
        type: QuestionType.multipleChoice,
        options: ['Acceleration', 'Inertia', 'Gravity', 'Momentum'],
        hint: 'It describes the tendency of an object to resist change in motion',
        explanation: 'Inertia is the tendency of objects to keep moving at the same speed and direction.',
      ),
    ),
    const VideoModel(
      id: 'physics_newton_second',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      lockTimestamp: 12,
      title: "Newton's Second Law — F = ma",
      subject: 'Physics',
      creatorName: 'PhysicsGuru',
      difficultyLevel: 3,
      topicId: 'newton_laws',
      conceptCluster: 'newton_laws',
      tags: ['newton', 'F=ma', 'acceleration', 'physics'],
      prerequisiteIds: ['physics_newton_first'],
      likesCount: 729,
      question: QuestionModel(
        id: 'q_newton_second',
        prompt: 'A 5 kg object accelerates at 3 m/s². What is the force?',
        correctAnswer: '15 N',
        type: QuestionType.multipleChoice,
        options: ['8 N', '15 N', '1.67 N', '53 N'],
        hint: 'Use F = m × a',
        explanation: 'F = m × a = 5 kg × 3 m/s² = 15 N',
      ),
    ),
    const VideoModel(
      id: 'physics_newton_third',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      lockTimestamp: 9,
      title: "Newton's Third Law — Action & Reaction",
      subject: 'Physics',
      creatorName: 'ScienceAcademy',
      difficultyLevel: 2,
      topicId: 'newton_laws',
      conceptCluster: 'newton_laws',
      tags: ['newton', 'action reaction', 'third law'],
      prerequisiteIds: ['physics_force_intro'],
      likesCount: 418,
      question: QuestionModel(
        id: 'q_newton_third',
        prompt: 'When you push a wall, the wall pushes back with:',
        correctAnswer: 'Equal and opposite force',
        type: QuestionType.multipleChoice,
        options: ['Greater force', 'Equal and opposite force', 'No force', 'Half the force'],
        hint: 'For every action...',
        explanation: 'Newton\'s Third Law: Every action has an equal and opposite reaction.',
      ),
    ),
    const VideoModel(
      id: 'physics_momentum',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      lockTimestamp: 11,
      title: 'Momentum — Mass in Motion',
      subject: 'Physics',
      creatorName: 'StudyReps',
      difficultyLevel: 3,
      topicId: 'momentum',
      conceptCluster: 'force_applications',
      tags: ['momentum', 'mass', 'velocity', 'physics'],
      prerequisiteIds: ['physics_newton_second'],
      likesCount: 295,
      question: QuestionModel(
        id: 'q_momentum',
        prompt: 'What is the formula for momentum?',
        correctAnswer: 'p = mv',
        type: QuestionType.multipleChoice,
        options: ['p = ma', 'p = mv', 'p = F/a', 'p = mgh'],
        hint: 'It involves mass and velocity',
        explanation: 'Momentum (p) = mass (m) × velocity (v). It is a vector quantity.',
      ),
    ),
    const VideoModel(
      id: 'math_quadratic',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      lockTimestamp: 10,
      title: 'Quadratic Equations — Solving by Factoring',
      subject: 'Mathematics',
      creatorName: 'MathWhiz',
      difficultyLevel: 2,
      topicId: 'quadratic',
      conceptCluster: 'algebra',
      tags: ['quadratic', 'algebra', 'factoring', 'math'],
      likesCount: 612,
      question: QuestionModel(
        id: 'q_quadratic',
        prompt: 'Solve: x² - 5x + 6 = 0',
        correctAnswer: 'x = 2 or x = 3',
        type: QuestionType.multipleChoice,
        options: ['x = 1 or x = 6', 'x = 2 or x = 3', 'x = -2 or x = -3', 'x = 5 or x = 1'],
        hint: 'Factor the quadratic: (x-?)(x-?) = 0',
        explanation: 'x² - 5x + 6 = (x-2)(x-3) = 0, so x = 2 or x = 3',
      ),
    ),
  ];

  /// Get a subset for different difficulty levels
  static List<VideoModel> getBeginnerVideos() => 
      getVideos().where((v) => ['physics_force_intro', 'physics_momentum', 'physics_equilibrium'].contains(v.id)).toList();
  
  static List<VideoModel> getIntermediateVideos() =>
      getVideos().where((v) => ['physics_newton_first', 'physics_newton_third', 'physics_cog'].contains(v.id)).toList();
  
  static List<VideoModel> getAdvancedVideos() =>
      getVideos().where((v) => ['physics_newton_second', 'physics_equations_motion', 'physics_torque', 'physics_circular_motion'].contains(v.id)).toList();
}

/// Helper to integrate with existing mock data provider
extension ForceChapterExtension on List<VideoModel> {
  /// Add Force chapter videos to existing list
  List<VideoModel> withForceChapter() => [...this, ...ForceChapterVideos.getVideos()];
}
