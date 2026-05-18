// ICSE Class X Physics - Chapter 1: Force
// StudyReps Content Data with Creative Question Formats
// Generated from study material for NotebookLM video integration

import '../../domain/models/video_model.dart';

/// Physics Chapter 1: Force - Content Topics
class ForceChapterContent {
  static const String chapterId = 'physics_ch1_force';
  static const String chapterTitle = 'Force';
  static const String subject = 'Physics';
  static const String grade = 'Class X';
  static const String board = 'ICSE';

  /// All topics in this chapter
  static const List<TopicData> topics = [
    TopicData(
      id: 'force_intro',
      title: 'Introduction to Force',
      description: 'Understanding what force is and its types',
      notebookLMPrompt: '''
        Create an engaging 2-minute audio explanation about Force.
        Cover: Definition (physical cause that changes state of rest/motion), 
        Units (Newton in SI, Dyne in CGS, 1N = 10^5 dyne),
        Types (Contact forces like friction, push, pull vs Non-contact like gravity, magnetic).
        Use real-world examples like pushing a door, gravity pulling objects.
        Make it conversational and memorable.
      ''',
      lockTimestamp: 45,
      concepts: ['Force definition', 'SI & CGS units', 'Contact vs Non-contact forces'],
    ),
    TopicData(
      id: 'newtons_first_law',
      title: "Newton's First Law - Law of Inertia",
      description: 'Objects at rest stay at rest, objects in motion stay in motion',
      notebookLMPrompt: '''
        Explain Newton's First Law (Law of Inertia) in an exciting way.
        A body continues in rest or uniform motion unless an external force acts on it.
        Use examples: passenger lurching forward when bus stops, 
        tablecloth trick, spacecraft moving forever in space.
        Make it stick with memorable phrases!
      ''',
      lockTimestamp: 50,
      concepts: ['Inertia', 'State of rest', 'Uniform motion', 'External force'],
    ),
    TopicData(
      id: 'newtons_second_law',
      title: "Newton's Second Law - F=ma",
      description: 'Force equals mass times acceleration',
      notebookLMPrompt: '''
        Break down Newton's Second Law: F = ma.
        Rate of change of momentum is proportional to applied force.
        Derive: F = Δp/Δt = mΔv/Δt = ma
        Real examples: Heavier car needs more force to accelerate,
        cricket ball hurts more when bowled faster.
        Include the graphs showing F∝m and F∝a relationships.
      ''',
      lockTimestamp: 60,
      concepts: ['F=ma formula', 'Rate of momentum change', 'Mass-acceleration relationship'],
    ),
    TopicData(
      id: 'newtons_third_law',
      title: "Newton's Third Law - Action-Reaction",
      description: 'Every action has an equal and opposite reaction',
      notebookLMPrompt: '''
        Make Newton's Third Law come alive!
        For every action, there's an equal and opposite reaction.
        F₁₂ = -F₂₁ (action-reaction pairs).
        Examples: rocket propulsion, walking (you push ground, ground pushes you),
        swimming, gun recoil.
        Emphasize: forces act on DIFFERENT bodies!
      ''',
      lockTimestamp: 55,
      concepts: ['Action-reaction pairs', 'Equal magnitude', 'Opposite direction'],
    ),
    TopicData(
      id: 'momentum',
      title: 'Momentum',
      description: 'Mass in motion - p = mv',
      notebookLMPrompt: '''
        Explain Momentum (p = mv) as "mass in motion".
        It's a vector quantity (has direction).
        Unit: kg m/s (SI), g cm/s (CGS).
        Examples: truck vs bicycle at same speed,
        bullet (small mass, high velocity) vs bowling ball.
        Connect to Newton's 2nd law: F = Δp/Δt
      ''',
      lockTimestamp: 40,
      concepts: ['p=mv formula', 'Vector quantity', 'Conservation of momentum'],
    ),
    TopicData(
      id: 'equations_of_motion',
      title: 'Equations of Motion',
      description: 'The three kinematic equations',
      notebookLMPrompt: '''
        Master the 3 Equations of Motion!
        1. v = u + at (velocity-time)
        2. s = ut + ½at² (displacement-time)  
        3. v² = u² + 2as (velocity-displacement)
        Where: u=initial velocity, v=final velocity, a=acceleration, t=time, s=displacement.
        Use a car accelerating example to derive and apply each.
      ''',
      lockTimestamp: 70,
      concepts: ['v=u+at', 's=ut+½at²', 'v²=u²+2as', 'Kinematic variables'],
    ),
    TopicData(
      id: 'moment_of_force',
      title: 'Moment of Force (Torque)',
      description: 'The turning effect of force',
      notebookLMPrompt: '''
        Explain Moment of Force (Torque) - the turning effect!
        τ = F × d (force times perpendicular distance from pivot).
        Units: Nm (SI), dyne cm (CGS).
        Clockwise vs Anticlockwise moments.
        Examples: door handle far from hinge, seesaw, spanner.
        Why longer spanners work better!
      ''',
      lockTimestamp: 55,
      concepts: ['τ=F×d', 'Pivot/fulcrum', 'Clockwise/anticlockwise', 'Perpendicular distance'],
    ),
    TopicData(
      id: 'equilibrium',
      title: 'Equilibrium of Bodies',
      description: 'When forces balance out',
      notebookLMPrompt: '''
        What is Equilibrium? When a body has no change in motion.
        Two types: Static (at rest) vs Dynamic (uniform motion).
        Conditions: 1) Net force = 0, 2) Net moment = 0.
        Principle of Moments: Sum of clockwise moments = Sum of anticlockwise moments.
        Examples: balanced seesaw, book on table.
      ''',
      lockTimestamp: 50,
      concepts: ['Static equilibrium', 'Dynamic equilibrium', 'Principle of moments'],
    ),
    TopicData(
      id: 'centre_of_gravity',
      title: 'Centre of Gravity',
      description: 'Where all the weight acts',
      notebookLMPrompt: '''
        Find the Centre of Gravity (C.G.)!
        The point where entire weight seems to act.
        For regular shapes: Ring (center), Disc (center), 
        Triangle (centroid), Rectangle (intersection of diagonals),
        Cylinder (midpoint of axis), Rod (midpoint).
        Why do objects topple? C.G. and base of support!
      ''',
      lockTimestamp: 45,
      concepts: ['C.G. definition', 'C.G. of shapes', 'Stability'],
    ),
    TopicData(
      id: 'circular_motion',
      title: 'Uniform Circular Motion',
      description: 'Moving in circles at constant speed',
      notebookLMPrompt: '''
        Uniform Circular Motion - constant speed, changing direction!
        It's accelerated motion (velocity direction changes).
        Centripetal Force: towards center, REAL force (tension, gravity).
        Centrifugal Force: away from center, FICTITIOUS (not really a force!).
        Examples: car turning, planets orbiting, spinning bucket.
      ''',
      lockTimestamp: 55,
      concepts: ['Centripetal force', 'Centrifugal force', 'Accelerated motion'],
    ),
  ];
}

/// Topic data structure
class TopicData {
  final String id;
  final String title;
  final String description;
  final String notebookLMPrompt;
  final int lockTimestamp; // seconds into video
  final List<String> concepts;

  const TopicData({
    required this.id,
    required this.title,
    required this.description,
    required this.notebookLMPrompt,
    required this.lockTimestamp,
    required this.concepts,
  });
}

/// Creative Question Bank for Force Chapter
class ForceQuestionBank {
  
  /// Mixed question formats for engaging learning
  static List<QuestionData> getAllQuestions() => [
    // ============ QUICK RECALL ============
    const QuestionData(
      id: 'q1_force_definition',
      topicId: 'force_intro',
      type: QuestionType.multipleChoice,
      format: QuestionFormat.quickRecall,
      prompt: 'What is the SI unit of force?',
      options: ['Dyne', 'Newton', 'Joule', 'Watt'],
      correctAnswer: 'Newton',
      explanation: 'Force is measured in Newtons (N) in SI system. 1N = 10⁵ dyne (CGS unit).',
      difficulty: 1,
    ),
    
    const QuestionData(
      id: 'q2_force_types',
      topicId: 'force_intro',
      type: QuestionType.multipleChoice,
      format: QuestionFormat.quickRecall,
      prompt: 'Which is a NON-contact force?',
      options: ['Friction', 'Tension', 'Gravity', 'Normal force'],
      correctAnswer: 'Gravity',
      explanation: 'Gravity acts without physical contact. Friction, tension, and normal force require contact.',
      difficulty: 1,
    ),

    // ============ TRUE/FALSE FLASH ============
    const QuestionData(
      id: 'q3_inertia_tf',
      topicId: 'newtons_first_law',
      type: QuestionType.trueFalse,
      format: QuestionFormat.trueFalseFlash,
      prompt: "Newton's First Law is also called the Law of Inertia.",
      correctAnswer: 'True',
      explanation: 'Correct! Inertia is the tendency of objects to resist change in motion.',
      difficulty: 1,
    ),
    
    const QuestionData(
      id: 'q4_centrifugal_tf',
      topicId: 'circular_motion',
      type: QuestionType.trueFalse,
      format: QuestionFormat.trueFalseFlash,
      prompt: 'Centrifugal force is a real force.',
      correctAnswer: 'False',
      explanation: 'Centrifugal force is fictitious/pseudo! Only centripetal force is real.',
      difficulty: 2,
    ),

    // ============ CALCULATE IT ============
    const QuestionData(
      id: 'q5_fma_calc',
      topicId: 'newtons_second_law',
      type: QuestionType.numerical,
      format: QuestionFormat.calculateIt,
      prompt: 'A 5 kg object accelerates at 3 m/s². What force is applied?',
      correctAnswer: '15',
      explanation: 'F = ma = 5 × 3 = 15 N',
      difficulty: 2,
      hint: 'Use F = ma',
    ),
    
    const QuestionData(
      id: 'q6_momentum_calc',
      topicId: 'momentum',
      type: QuestionType.numerical,
      format: QuestionFormat.calculateIt,
      prompt: 'Calculate the momentum of a 2 kg ball moving at 10 m/s.',
      correctAnswer: '20',
      explanation: 'p = mv = 2 × 10 = 20 kg m/s',
      difficulty: 2,
      hint: 'Momentum = mass × velocity',
    ),
    
    const QuestionData(
      id: 'q7_motion_eq_calc',
      topicId: 'equations_of_motion',
      type: QuestionType.numerical,
      format: QuestionFormat.calculateIt,
      prompt: 'A car accelerates from 0 to 20 m/s in 5 seconds. Find acceleration.',
      correctAnswer: '4',
      explanation: 'Using v = u + at: 20 = 0 + a(5), so a = 4 m/s²',
      difficulty: 2,
      hint: 'Use v = u + at, u = 0',
    ),
    
    const QuestionData(
      id: 'q8_torque_calc',
      topicId: 'moment_of_force',
      type: QuestionType.numerical,
      format: QuestionFormat.calculateIt,
      prompt: 'A force of 20N acts at 0.5m from a pivot. What is the moment?',
      correctAnswer: '10',
      explanation: 'τ = F × d = 20 × 0.5 = 10 Nm',
      difficulty: 2,
      hint: 'Moment = Force × Distance',
    ),

    // ============ FILL THE BLANK ============
    const QuestionData(
      id: 'q9_third_law_fill',
      topicId: 'newtons_third_law',
      type: QuestionType.fillBlank,
      format: QuestionFormat.fillTheBlank,
      prompt: 'For every action, there is an equal and _____ reaction.',
      correctAnswer: 'opposite',
      explanation: "Newton's Third Law: Forces come in pairs, equal in magnitude but opposite in direction.",
      difficulty: 1,
    ),
    
    const QuestionData(
      id: 'q10_momentum_fill',
      topicId: 'momentum',
      type: QuestionType.fillBlank,
      format: QuestionFormat.fillTheBlank,
      prompt: 'Momentum is a _____ quantity (has magnitude and direction).',
      correctAnswer: 'vector',
      explanation: 'Momentum p = mv has direction (same as velocity), making it a vector.',
      difficulty: 2,
    ),

    // ============ APPLY IT (Scenario-based) ============
    const QuestionData(
      id: 'q11_apply_inertia',
      topicId: 'newtons_first_law',
      type: QuestionType.multipleChoice,
      format: QuestionFormat.applyIt,
      prompt: 'A bus suddenly stops. Passengers lurch forward because of:',
      options: ['Friction', 'Inertia', 'Gravity', 'Momentum only'],
      correctAnswer: 'Inertia',
      explanation: 'Bodies tend to maintain their state of motion (inertia). Passengers were moving, so they continue forward when bus stops.',
      difficulty: 2,
    ),
    
    const QuestionData(
      id: 'q12_apply_third_law',
      topicId: 'newtons_third_law',
      type: QuestionType.multipleChoice,
      format: QuestionFormat.applyIt,
      prompt: 'A rocket moves up by pushing gases down. This is explained by:',
      options: ['First Law', 'Second Law', 'Third Law', 'Law of Gravity'],
      correctAnswer: 'Third Law',
      explanation: 'Rocket pushes gases down (action), gases push rocket up (reaction). Action-reaction!',
      difficulty: 2,
    ),
    
    const QuestionData(
      id: 'q13_apply_equilibrium',
      topicId: 'equilibrium',
      type: QuestionType.multipleChoice,
      format: QuestionFormat.applyIt,
      prompt: 'A book resting on a table is in which type of equilibrium?',
      options: ['Static', 'Dynamic', 'Unstable', 'Neutral'],
      correctAnswer: 'Static',
      explanation: 'Static equilibrium = at rest + net force = 0. The book is not moving.',
      difficulty: 1,
    ),

    // ============ VISUAL MATCH ============
    const QuestionData(
      id: 'q14_cg_visual',
      topicId: 'centre_of_gravity',
      type: QuestionType.multipleChoice,
      format: QuestionFormat.visualMatch,
      prompt: 'Where is the Centre of Gravity of a uniform ring?',
      options: ['On the ring', 'At the center (empty space)', 'At the edge', 'Outside the ring'],
      correctAnswer: 'At the center (empty space)',
      explanation: 'For a ring, C.G. is at the geometric center, which is empty space!',
      difficulty: 2,
    ),

    // ============ FORMULA RECALL ============
    const QuestionData(
      id: 'q15_formula_motion',
      topicId: 'equations_of_motion',
      type: QuestionType.multipleChoice,
      format: QuestionFormat.formulaRecall,
      prompt: 'Which equation relates velocity, displacement, and acceleration (no time)?',
      options: ['v = u + at', 's = ut + ½at²', 'v² = u² + 2as', 'F = ma'],
      correctAnswer: 'v² = u² + 2as',
      explanation: 'v² = u² + 2as is the only equation without time (t).',
      difficulty: 2,
    ),

    // ============ CONCEPT CHECK ============
    const QuestionData(
      id: 'q16_concept_centripetal',
      topicId: 'circular_motion',
      type: QuestionType.multipleChoice,
      format: QuestionFormat.conceptCheck,
      prompt: 'In circular motion, centripetal force points:',
      options: ['Away from center', 'Towards center', 'Tangent to circle', 'Perpendicular to motion'],
      correctAnswer: 'Towards center',
      explanation: 'Centripetal = "center-seeking". It always points towards the center.',
      difficulty: 2,
    ),

    // ============ QUICK MATH ============
    const QuestionData(
      id: 'q17_quick_conversion',
      topicId: 'force_intro',
      type: QuestionType.numerical,
      format: QuestionFormat.quickMath,
      prompt: 'Convert 5 N to dyne. (Enter number only)',
      correctAnswer: '500000',
      explanation: '1 N = 10⁵ dyne, so 5 N = 5 × 10⁵ = 500000 dyne',
      difficulty: 2,
      hint: '1 N = 10⁵ dyne',
    ),

    // ============ MISTAKE FINDER ============
    const QuestionData(
      id: 'q18_find_error',
      topicId: 'newtons_second_law',
      type: QuestionType.multipleChoice,
      format: QuestionFormat.mistakeFinder,
      prompt: 'Find the error: "If I double the force on an object, its acceleration becomes half."',
      options: [
        'Force and acceleration are inversely proportional',
        'Force and acceleration are directly proportional',
        'Acceleration depends on mass only',
        'There is no error',
      ],
      correctAnswer: 'Force and acceleration are directly proportional',
      explanation: 'From F = ma, if F doubles, a doubles (for same mass). They\'re directly proportional!',
      difficulty: 3,
    ),
  ];
}

/// Question data structure
class QuestionData {
  final String id;
  final String topicId;
  final QuestionType type;
  final QuestionFormat format;
  final String prompt;
  final List<String>? options;
  final String correctAnswer;
  final String explanation;
  final int difficulty; // 1-3
  final String? hint;
  final String? imageUrl;

  const QuestionData({
    required this.id,
    required this.topicId,
    required this.type,
    required this.format,
    required this.prompt,
    this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
    this.hint,
    this.imageUrl,
  });
}

/// Different question formats for variety
enum QuestionFormat {
  quickRecall,      // Simple factual recall
  trueFalseFlash,   // Quick true/false
  calculateIt,      // Numerical problem
  fillTheBlank,     // Complete the sentence
  applyIt,          // Real-world scenario
  visualMatch,      // Match with diagram/image
  formulaRecall,    // Remember the formula
  conceptCheck,     // Understanding check
  quickMath,        // Fast calculation
  mistakeFinder,    // Find what's wrong
  orderSteps,       // Sequence ordering
}
