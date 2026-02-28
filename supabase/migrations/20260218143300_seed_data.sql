-- Seed Data for StudyReps
-- Insert Mock Videos from ForceChapterVideos

INSERT INTO public.educational_content (
  id, 
  "videoUrl", 
  "lockTimestamp", 
  "question", 
  "creatorName", 
  "title", 
  "subject", 
  "thumbnailUrl", 
  "likesCount", 
  "difficultyLevel", 
  "topicId", 
  "conceptCluster", 
  "tags"
) VALUES 
(
  'physics_newton_apple',
  'assets/videos/sample.mp4',
  8,
  '{
    "id": "q_gravity_1",
    "prompt": "Does gravity act between any two masses in the universe?",
    "correctAnswer": "Yes, always attractive",
    "type": "multiple_choice",
    "options": ["Only on Earth", "Yes, always attractive", "Only in space", "No way"],
    "hint": "Universal Law of Gravitation",
    "explanation": "Gravity is a universal attractive force between all masses."
  }'::jsonb,
  'PhysicsWallah',
  'Newton''s Law of Gravitation',
  'Physics',
  'https://img.youtube.com/vi/placeholder/hqdefault.jpg',
  1205,
  1,
  'gravity',
  'gravity_basics',
  ARRAY['gravity', 'newton', 'physics']
),
(
  'chem_periodic_table',
  'assets/videos/sample.mp4',
  10,
  '{
    "id": "q_chem_1",
    "prompt": "Which element has the highest electronegativity?",
    "correctAnswer": "Fluorine (F)",
    "type": "multiple_choice",
    "options": ["Oxygen (O)", "Fluorine (F)", "Chlorine (Cl)", "Francium (Fr)"],
    "hint": "Top right corner (excluding noble gases)",
    "explanation": "Fluorine is the most electronegative element."
  }'::jsonb,
  'ChemPossible',
  'The Periodic Table: Trends',
  'Chemistry',
  'https://img.youtube.com/vi/placeholder/hqdefault.jpg',
  890,
  2,
  'periodic_table',
  'trends',
  ARRAY['chemistry', 'periodic table', 'elements']
),
(
  'bio_cell_division',
  'assets/videos/sample.mp4',
  15,
  '{
    "id": "q_bio_1",
    "prompt": "In which process do daughter cells have half the chromosomes?",
    "correctAnswer": "Meiosis",
    "type": "multiple_choice",
    "options": ["Mitosis", "Meiosis", "Binary Fission", "Cytokinesis"],
    "hint": "Produces gametes (sperm/egg)",
    "explanation": "Meiosis reduces chromosome number by half for sexual reproduction."
  }'::jsonb,
  'BioBytes',
  'Mitosis vs Meiosis',
  'Biology',
  'https://img.youtube.com/vi/placeholder/hqdefault.jpg',
  1540,
  2,
  'cell_bio',
  'cell_division',
  ARRAY['biology', 'cells', 'mitosis']
),
(
  'math_pythagoras',
  'assets/videos/sample.mp4',
  12,
  '{
    "id": "q_math_1",
    "prompt": "For a right triangle with legs 3 and 4, what is the hypotenuse?",
    "correctAnswer": "5",
    "type": "multiple_choice",
    "options": ["5", "6", "7", "8"],
    "hint": "a² + b² = c²",
    "explanation": "3² + 4² = 9 + 16 = 25. √25 = 5."
  }'::jsonb,
  'MathAntics',
  'Pythagorean Theorem Visualized',
  'Mathematics',
  'https://img.youtube.com/vi/placeholder/hqdefault.jpg',
  2300,
  1,
  'geometry',
  'triangles',
  ARRAY['math', 'geometry', 'triangles']
),
(
  'physics_thermo',
  'assets/videos/sample.mp4',
  20,
  '{
    "id": "q_thermo_1",
    "prompt": "Can entropy of an isolated system decrease over time?",
    "correctAnswer": "No, never",
    "type": "multiple_choice",
    "options": ["Yes, if cold", "No, never", "Maybe", "Only in vacuum"],
    "hint": "Second Law of Thermodynamics",
    "explanation": "Entropy of an isolated system always increases or stays constant."
  }'::jsonb,
  'ScienceGuy',
  'Thermodynamics: Entropy',
  'Physics',
  'https://img.youtube.com/vi/placeholder/hqdefault.jpg',
  670,
  3,
  'thermodynamics',
  'entropy',
  ARRAY['physics', 'heat', 'entropy']
)
ON CONFLICT (id) DO UPDATE SET 
  "videoUrl" = EXCLUDED."videoUrl",
  "title" = EXCLUDED."title",
  "likesCount" = EXCLUDED."likesCount";
