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
      videoUrl: 'https://www.youtube.com/watch?v=E-kn4sYdBFg',
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
      videoUrl: 'https://www.youtube.com/watch?v=kKKM8Y-u7ds',
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
      videoUrl: 'https://www.youtube.com/watch?v=BPhT8hCR7bY',
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
      videoUrl: 'https://www.youtube.com/watch?v=0RRVV4Diomg',
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
      videoUrl: 'https://www.youtube.com/watch?v=tGHtIeKEFiU',
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
      videoUrl: 'https://www.youtube.com/watch?v=f-ldPgEfAHI',
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
      videoUrl: 'https://www.youtube.com/watch?v=MvuYATh7Y74',
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
      videoUrl: 'https://www.youtube.com/watch?v=2MSi6S9hFmo',
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
      videoUrl: 'https://www.youtube.com/watch?v=uzkc-qNVoOk',
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
      videoUrl: 'https://www.youtube.com/watch?v=_pcuTbkfz8g',
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
      videoUrl: 'https://www.youtube.com/watch?v=rBJbhbBq7DY',
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

    // ══════════════════════════════════════════════
    // ══  FLASHCARDS — AI-Generated Text Cards  ══
    // ══════════════════════════════════════════════

    // ── PHYSICS FLASHCARD 1 ──
    const VideoModel(
      id: 'fc_physics_ohms_law',
      contentType: ContentType.flashcard,
      title: "Ohm's Law: V = IR",
      subject: 'Physics',
      creatorName: 'StudyReps AI',
      flashcardEmoji: '⚡',
      flashcardFrontText:
          "Ohm's Law states that the current flowing through a conductor is directly proportional to the voltage across it, provided the temperature remains constant.\n\n"
          "📐 Formula: V = I × R\n\n"
          "Where:\n"
          "• V = Voltage (Volts)\n"
          "• I = Current (Amperes)\n"
          "• R = Resistance (Ohms, Ω)\n\n"
          "💡 Think of it like water in a pipe:\n"
          "Voltage = water pressure\n"
          "Current = water flow rate\n"
          "Resistance = pipe narrowness",
      flashcardBackText: "The higher the resistance, the lower the current for a given voltage.",
      difficultyLevel: 1,
      topicId: 'electricity',
      conceptCluster: 'ohms_law',
      tags: ['physics', 'electricity', 'ohms law', 'circuits'],
      likesCount: 420,
      question: QuestionModel(
        id: 'q_fc_ohm_1',
        prompt: 'A circuit has a resistance of 10Ω and a voltage of 20V. What is the current?',
        correctAnswer: '2 A',
        type: QuestionType.multipleChoice,
        options: ['0.5 A', '2 A', '200 A', '10 A'],
        hint: 'Use V = IR → I = V/R',
        explanation: 'I = V/R = 20/10 = 2 Amperes.',
      ),
    ),

    // ── PHYSICS FLASHCARD 2 ──
    const VideoModel(
      id: 'fc_physics_refraction',
      contentType: ContentType.flashcard,
      title: 'Refraction of Light',
      subject: 'Physics',
      creatorName: 'StudyReps AI',
      flashcardEmoji: '🌈',
      flashcardFrontText:
          "Refraction is the bending of light as it passes from one medium to another (e.g., air → water).\n\n"
          "📏 Snell's Law: n₁ sin θ₁ = n₂ sin θ₂\n\n"
          "Key facts:\n"
          "• Light bends TOWARDS the normal when entering a denser medium\n"
          "• Light bends AWAY from the normal when entering a rarer medium\n"
          "• Speed of light decreases in denser media\n\n"
          "🥤 Real-life example: A straw in a glass of water looks 'bent' due to refraction!",
      difficultyLevel: 2,
      topicId: 'optics',
      conceptCluster: 'refraction',
      tags: ['physics', 'light', 'refraction', 'optics'],
      likesCount: 380,
      question: QuestionModel(
        id: 'q_fc_refraction_1',
        prompt: 'When light enters a denser medium, it bends:',
        correctAnswer: 'Towards the normal',
        type: QuestionType.multipleChoice,
        options: ['Away from the normal', 'Towards the normal', 'Does not bend', 'Backwards'],
        hint: 'Denser medium = slower speed = bending towards',
        explanation: 'Light bends towards the normal when entering a denser medium because it slows down.',
      ),
    ),

    // ── CHEMISTRY FLASHCARD ──
    const VideoModel(
      id: 'fc_chem_mole_concept',
      contentType: ContentType.flashcard,
      title: 'The Mole Concept',
      subject: 'Chemistry',
      creatorName: 'StudyReps AI',
      flashcardEmoji: '⚗️',
      flashcardFrontText:
          "A 'mole' is the chemist's counting unit, just like a 'dozen' means 12.\n\n"
          "🔢 1 mole = 6.022 × 10²³ particles\n"
          "(This is called Avogadro's Number)\n\n"
          "📦 Molar Mass = mass of 1 mole of a substance (in grams)\n"
          "• 1 mole of Carbon (C) = 12 g\n"
          "• 1 mole of Water (H₂O) = 18 g\n"
          "• 1 mole of Oxygen gas (O₂) = 32 g\n\n"
          "💡 Formula: n = mass / molar mass\n"
          "Where n = number of moles",
      difficultyLevel: 2,
      topicId: 'mole_concept',
      conceptCluster: 'stoichiometry',
      tags: ['chemistry', 'mole', 'avogadro', 'stoichiometry'],
      likesCount: 510,
      question: QuestionModel(
        id: 'q_fc_mole_1',
        prompt: 'How many moles are in 36 grams of water (H₂O)?',
        correctAnswer: '2',
        type: QuestionType.numerical,
        options: [],
        hint: 'Molar mass of H₂O = 18 g/mol. Use n = mass / molar mass',
        explanation: 'n = 36 / 18 = 2 moles of water.',
      ),
    ),

    // ── BIOLOGY FLASHCARD ──
    const VideoModel(
      id: 'fc_bio_photosynthesis',
      contentType: ContentType.flashcard,
      title: 'Photosynthesis Equation',
      subject: 'Biology',
      creatorName: 'StudyReps AI',
      flashcardEmoji: '🌿',
      flashcardFrontText:
          "Photosynthesis is how plants make their own food using sunlight.\n\n"
          "🧪 Equation:\n"
          "6CO₂ + 6H₂O → C₆H₁₂O₆ + 6O₂\n"
          "(Carbon Dioxide + Water → Glucose + Oxygen)\n\n"
          "📍 Where: In the chloroplasts (specifically in chlorophyll)\n\n"
          "🔑 Key conditions:\n"
          "• Sunlight (energy source)\n"
          "• Chlorophyll (light-absorbing pigment)\n"
          "• CO₂ from air, H₂O from soil\n\n"
          "🌍 Fun fact: Photosynthesis produces the oxygen we breathe!",
      difficultyLevel: 1,
      topicId: 'plant_biology',
      conceptCluster: 'photosynthesis',
      tags: ['biology', 'photosynthesis', 'plants', 'chlorophyll'],
      likesCount: 620,
      question: QuestionModel(
        id: 'q_fc_photo_1',
        prompt: 'What are the TWO products of photosynthesis?',
        correctAnswer: 'Glucose and Oxygen',
        type: QuestionType.multipleChoice,
        options: ['CO₂ and Water', 'Glucose and Oxygen', 'Starch and CO₂', 'ATP and NADPH'],
        hint: 'Look at the right side of the equation',
        explanation: 'Photosynthesis produces glucose (C₆H₁₂O₆) and oxygen (O₂).',
      ),
    ),

    // ── MATH FLASHCARD ──
    const VideoModel(
      id: 'fc_math_quadratic',
      contentType: ContentType.flashcard,
      title: 'Quadratic Formula',
      subject: 'Mathematics',
      creatorName: 'StudyReps AI',
      flashcardEmoji: '📊',
      flashcardFrontText:
          "For any quadratic equation ax² + bx + c = 0, the solutions are:\n\n"
          "📐 x = (-b ± √(b² - 4ac)) / 2a\n\n"
          "The part under the square root (b² - 4ac) is called the Discriminant (D):\n\n"
          "• D > 0 → Two real & distinct roots\n"
          "• D = 0 → Two equal (repeated) roots\n"
          "• D < 0 → No real roots (complex roots)\n\n"
          "🎵 Memory trick: \"x equals negative b, plus or minus the square root, of b squared minus 4ac, all over 2a\" — sing it!",
      difficultyLevel: 2,
      topicId: 'algebra',
      conceptCluster: 'quadratics',
      tags: ['math', 'quadratic', 'algebra', 'formula'],
      likesCount: 780,
      question: QuestionModel(
        id: 'q_fc_quad_1',
        prompt: 'For x² - 5x + 6 = 0, what is the discriminant (b² - 4ac)?',
        correctAnswer: '1',
        type: QuestionType.numerical,
        options: [],
        hint: 'a=1, b=-5, c=6. D = b² - 4ac',
        explanation: 'D = (-5)² - 4(1)(6) = 25 - 24 = 1. Since D > 0, two distinct real roots exist.',
      ),
    ),

    // ── HISTORY FLASHCARD ──
    const VideoModel(
      id: 'fc_hist_french_rev',
      contentType: ContentType.flashcard,
      title: 'The French Revolution (1789)',
      subject: 'History',
      creatorName: 'StudyReps AI',
      flashcardEmoji: '🏰',
      flashcardFrontText:
          "The French Revolution (1789–1799) was a period of radical political and social change in France.\n\n"
          "📜 Key causes:\n"
          "• Extreme inequality (3 Estates system)\n"
          "• Heavy taxation on peasants (Third Estate)\n"
          "• Bread shortages and famine\n"
          "• Inspiration from American Revolution\n\n"
          "⚔️ Major events:\n"
          "• Storming of the Bastille (July 14, 1789)\n"
          "• Declaration of Rights of Man\n"
          "• Execution of King Louis XVI\n"
          "• Rise of Napoleon Bonaparte\n\n"
          "🇫🇷 Motto: Liberté, Égalité, Fraternité",
      difficultyLevel: 2,
      topicId: 'world_history',
      conceptCluster: 'revolutions',
      tags: ['history', 'french revolution', 'europe', '1789'],
      likesCount: 340,
      question: QuestionModel(
        id: 'q_fc_french_1',
        prompt: 'What event marked the beginning of the French Revolution in 1789?',
        correctAnswer: 'Storming of the Bastille',
        type: QuestionType.multipleChoice,
        options: ['Execution of Louis XVI', 'Storming of the Bastille', 'Reign of Terror', 'Napoleon\'s coronation'],
        hint: 'July 14, 1789 — now celebrated as Bastille Day',
        explanation: 'The Storming of the Bastille on July 14, 1789 is considered the symbolic start of the French Revolution.',
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
