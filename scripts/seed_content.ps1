$SUPABASE_URL = "https://gwarmogcmeehajnevbmi.supabase.co"
$ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd3YXJtb2djbWVlaGFqbmV2Ym1pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyOTc1MjAsImV4cCI6MjA2MDg3MzUyMH0.EiTIeIZMrDjMIufMUEuDr74ydPFHtRAIveTvAkBxTds"
$headers = @{
    "apikey"        = $ANON_KEY
    "Authorization" = "Bearer $ANON_KEY"
    "Content-Type"  = "application/json"
    "Prefer"        = "return=minimal"
}
$PV = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"

$jsonPayload = @"
[
  {
    "id": "physics_newtons_laws",
    "title": "Newton's 3 Laws of Motion",
    "subject": "Physics",
    "videoUrl": "$PV",
    "lockTimestamp": 12,
    "creatorName": "PhysicsWallah",
    "difficultyLevel": 1,
    "topicId": "classical_mechanics",
    "conceptCluster": "newton_laws",
    "tags": ["physics","newton","motion","laws"],
    "language": "en",
    "question": {
      "id": "q_newton_laws_1",
      "prompt": "Which of Newton's laws states that F = ma?",
      "correctAnswer": "Second Law",
      "type": "multiple_choice",
      "options": ["First Law","Second Law","Third Law","Law of Gravitation"],
      "hint": "Force equals mass times acceleration",
      "explanation": "Newton's Second Law relates force, mass, and acceleration: F = ma."
    }
  },
  {
    "id": "physics_projectile",
    "title": "Projectile Motion Explained",
    "subject": "Physics",
    "videoUrl": "$PV",
    "lockTimestamp": 15,
    "creatorName": "ScienceGuy",
    "difficultyLevel": 2,
    "topicId": "classical_mechanics",
    "conceptCluster": "kinematics",
    "tags": ["physics","projectile","motion","parabola"],
    "language": "en",
    "question": {
      "id": "q_projectile_1",
      "prompt": "What is the shape of a projectile trajectory (ignoring air resistance)?",
      "correctAnswer": "Parabola",
      "type": "multiple_choice",
      "options": ["Circle","Parabola","Straight line","Spiral"],
      "hint": "Think of a ball thrown at an angle",
      "explanation": "A projectile follows a parabolic path due to constant gravity acting downward."
    }
  },
  {
    "id": "physics_optics_reflection",
    "title": "Reflection and Mirrors",
    "subject": "Physics",
    "videoUrl": "$PV",
    "lockTimestamp": 10,
    "creatorName": "PhysicsWallah",
    "difficultyLevel": 1,
    "topicId": "optics",
    "conceptCluster": "light_reflection",
    "tags": ["physics","optics","mirrors","reflection"],
    "language": "en",
    "question": {
      "id": "q_optics_1",
      "prompt": "The angle of incidence equals the angle of ___",
      "correctAnswer": "Reflection",
      "type": "fill_blank",
      "options": [],
      "hint": "Law of Reflection",
      "explanation": "The Law of Reflection states: angle of incidence = angle of reflection."
    }
  },
  {
    "id": "physics_electric_current",
    "title": "Ohm's Law: V = IR",
    "subject": "Physics",
    "videoUrl": "$PV",
    "lockTimestamp": 14,
    "creatorName": "ScienceGuy",
    "difficultyLevel": 2,
    "topicId": "electricity",
    "conceptCluster": "circuits",
    "tags": ["physics","electricity","ohm","current"],
    "language": "en",
    "question": {
      "id": "q_ohm_1",
      "prompt": "If voltage is 12V and resistance is 4 Ohms, what is the current?",
      "correctAnswer": "3",
      "type": "numerical",
      "options": [],
      "hint": "V = I x R, so I = V / R",
      "explanation": "Using Ohm's law: I = V/R = 12/4 = 3 Amperes."
    }
  },
  {
    "id": "chem_chemical_bonding",
    "title": "Ionic vs Covalent Bonds",
    "subject": "Chemistry",
    "videoUrl": "$PV",
    "lockTimestamp": 11,
    "creatorName": "ChemPossible",
    "difficultyLevel": 1,
    "topicId": "chemical_bonding",
    "conceptCluster": "bond_types",
    "tags": ["chemistry","bonds","ionic","covalent"],
    "language": "en",
    "question": {
      "id": "q_bonds_1",
      "prompt": "NaCl (table salt) is an example of which type of bond?",
      "correctAnswer": "Ionic bond",
      "type": "multiple_choice",
      "options": ["Ionic bond","Covalent bond","Metallic bond","Hydrogen bond"],
      "hint": "A metal (Na) + a non-metal (Cl)",
      "explanation": "NaCl forms an ionic bond through electron transfer from sodium to chlorine."
    }
  },
  {
    "id": "chem_acids_bases",
    "title": "Acids, Bases and pH Scale",
    "subject": "Chemistry",
    "videoUrl": "$PV",
    "lockTimestamp": 13,
    "creatorName": "ChemPossible",
    "difficultyLevel": 2,
    "topicId": "acids_bases",
    "conceptCluster": "ph_reactions",
    "tags": ["chemistry","acids","bases","ph","litmus"],
    "language": "en",
    "question": {
      "id": "q_ph_1",
      "prompt": "A solution with pH 3 is ___",
      "correctAnswer": "Acidic",
      "type": "multiple_choice",
      "options": ["Acidic","Basic","Neutral","Cannot determine"],
      "hint": "pH less than 7 means...",
      "explanation": "pH below 7 indicates an acidic solution. pH 3 is strongly acidic."
    }
  },
  {
    "id": "chem_balancing_equations",
    "title": "How to Balance Chemical Equations",
    "subject": "Chemistry",
    "videoUrl": "$PV",
    "lockTimestamp": 18,
    "creatorName": "ChemPossible",
    "difficultyLevel": 2,
    "topicId": "stoichiometry",
    "conceptCluster": "balancing",
    "tags": ["chemistry","equations","balancing","stoichiometry"],
    "language": "en",
    "question": {
      "id": "q_balance_1",
      "prompt": "In H2 + O2 -> H2O, what coefficient goes before H2O when balanced?",
      "correctAnswer": "2",
      "type": "numerical",
      "options": [],
      "hint": "Count hydrogen and oxygen atoms on both sides",
      "explanation": "Balanced: 2H2 + O2 -> 2H2O. So coefficient for H2O is 2."
    }
  },
  {
    "id": "chem_mole_concept",
    "title": "The Mole Concept and Avogadro's Number",
    "subject": "Chemistry",
    "videoUrl": "$PV",
    "lockTimestamp": 16,
    "creatorName": "ChemPossible",
    "difficultyLevel": 3,
    "topicId": "mole_concept",
    "conceptCluster": "quantitative_chemistry",
    "tags": ["chemistry","mole","avogadro","atoms"],
    "language": "en",
    "question": {
      "id": "q_mole_1",
      "prompt": "Avogadro's number is approximately?",
      "correctAnswer": "6.022 x 10^23",
      "type": "multiple_choice",
      "options": ["6.022 x 10^23","3.14 x 10^23","6.022 x 10^20","1.602 x 10^-19"],
      "hint": "Number of particles in one mole",
      "explanation": "One mole = 6.022 x 10^23 particles (Avogadro's constant)."
    }
  },
  {
    "id": "bio_photosynthesis",
    "title": "Photosynthesis: How Plants Make Food",
    "subject": "Biology",
    "videoUrl": "$PV",
    "lockTimestamp": 12,
    "creatorName": "BioBytes",
    "difficultyLevel": 1,
    "topicId": "plant_biology",
    "conceptCluster": "photosynthesis",
    "tags": ["biology","photosynthesis","plants","chlorophyll"],
    "language": "en",
    "question": {
      "id": "q_photo_1",
      "prompt": "Which pigment absorbs sunlight in photosynthesis?",
      "correctAnswer": "Chlorophyll",
      "type": "multiple_choice",
      "options": ["Melanin","Chlorophyll","Hemoglobin","Keratin"],
      "hint": "It gives leaves their green color",
      "explanation": "Chlorophyll absorbs sunlight and gives plants their green color."
    }
  },
  {
    "id": "bio_dna_structure",
    "title": "DNA: The Double Helix",
    "subject": "Biology",
    "videoUrl": "$PV",
    "lockTimestamp": 14,
    "creatorName": "BioBytes",
    "difficultyLevel": 2,
    "topicId": "genetics",
    "conceptCluster": "dna_structure",
    "tags": ["biology","dna","genetics","double helix"],
    "language": "en",
    "question": {
      "id": "q_dna_1",
      "prompt": "Which base pairs with Adenine (A) in DNA?",
      "correctAnswer": "Thymine (T)",
      "type": "multiple_choice",
      "options": ["Guanine (G)","Thymine (T)","Cytosine (C)","Uracil (U)"],
      "hint": "A-T and G-C are complementary pairs",
      "explanation": "In DNA, Adenine always pairs with Thymine, and Guanine pairs with Cytosine."
    }
  },
  {
    "id": "bio_human_heart",
    "title": "The Human Heart: 4 Chambers",
    "subject": "Biology",
    "videoUrl": "$PV",
    "lockTimestamp": 10,
    "creatorName": "BioBytes",
    "difficultyLevel": 1,
    "topicId": "human_anatomy",
    "conceptCluster": "circulatory_system",
    "tags": ["biology","heart","circulation","anatomy"],
    "language": "en",
    "question": {
      "id": "q_heart_1",
      "prompt": "Which chamber pumps oxygenated blood to the body?",
      "correctAnswer": "Left Ventricle",
      "type": "multiple_choice",
      "options": ["Right Atrium","Left Atrium","Right Ventricle","Left Ventricle"],
      "hint": "The most muscular chamber",
      "explanation": "The left ventricle pumps oxygenated blood through the aorta to the entire body."
    }
  },
  {
    "id": "bio_ecosystem",
    "title": "Food Chains and Food Webs",
    "subject": "Biology",
    "videoUrl": "$PV",
    "lockTimestamp": 13,
    "creatorName": "BioBytes",
    "difficultyLevel": 1,
    "topicId": "ecology",
    "conceptCluster": "ecosystems",
    "tags": ["biology","ecology","food chain","ecosystem"],
    "language": "en",
    "question": {
      "id": "q_eco_1",
      "prompt": "Producers in a food chain are also called?",
      "correctAnswer": "Autotrophs",
      "type": "multiple_choice",
      "options": ["Heterotrophs","Autotrophs","Decomposers","Consumers"],
      "hint": "They make their own food",
      "explanation": "Producers (autotrophs) make their own food through photosynthesis."
    }
  },
  {
    "id": "math_quadratic",
    "title": "Solving Quadratic Equations",
    "subject": "Mathematics",
    "videoUrl": "$PV",
    "lockTimestamp": 15,
    "creatorName": "MathAntics",
    "difficultyLevel": 2,
    "topicId": "algebra",
    "conceptCluster": "quadratics",
    "tags": ["math","algebra","quadratic","equations"],
    "language": "en",
    "question": {
      "id": "q_quad_1",
      "prompt": "What are the roots of x^2 - 5x + 6 = 0?",
      "correctAnswer": "2 and 3",
      "type": "multiple_choice",
      "options": ["1 and 6","2 and 3","-2 and -3","3 and 4"],
      "hint": "Factor the equation",
      "explanation": "(x-2)(x-3) = 0, so x = 2 and x = 3."
    }
  },
  {
    "id": "math_trigonometry",
    "title": "SOH-CAH-TOA: Trigonometric Ratios",
    "subject": "Mathematics",
    "videoUrl": "$PV",
    "lockTimestamp": 12,
    "creatorName": "MathAntics",
    "difficultyLevel": 2,
    "topicId": "trigonometry",
    "conceptCluster": "trig_ratios",
    "tags": ["math","trigonometry","sine","cosine"],
    "language": "en",
    "question": {
      "id": "q_trig_1",
      "prompt": "sin(theta) = ?",
      "correctAnswer": "Opposite / Hypotenuse",
      "type": "multiple_choice",
      "options": ["Adjacent / Hypotenuse","Opposite / Hypotenuse","Opposite / Adjacent","Hypotenuse / Opposite"],
      "hint": "SOH: Sine = Opposite / Hypotenuse",
      "explanation": "In a right triangle, sin(theta) = Opposite side / Hypotenuse."
    }
  },
  {
    "id": "math_probability_basics",
    "title": "Probability: Coin Flips and Dice",
    "subject": "Mathematics",
    "videoUrl": "$PV",
    "lockTimestamp": 10,
    "creatorName": "MathAntics",
    "difficultyLevel": 1,
    "topicId": "probability",
    "conceptCluster": "basic_probability",
    "tags": ["math","probability","dice","coin"],
    "language": "en",
    "question": {
      "id": "q_prob_1",
      "prompt": "What is the probability of rolling a 6 on a fair die?",
      "correctAnswer": "1/6",
      "type": "multiple_choice",
      "options": ["1/2","1/3","1/6","1/12"],
      "hint": "A die has 6 faces",
      "explanation": "Each face has equal probability: P(6) = 1/6."
    }
  },
  {
    "id": "math_calculus_limits",
    "title": "Introduction to Limits",
    "subject": "Mathematics",
    "videoUrl": "$PV",
    "lockTimestamp": 18,
    "creatorName": "MathAntics",
    "difficultyLevel": 3,
    "topicId": "calculus",
    "conceptCluster": "limits",
    "tags": ["math","calculus","limits"],
    "language": "en",
    "question": {
      "id": "q_limits_1",
      "prompt": "What is the limit of (x^2-1)/(x-1) as x approaches 1?",
      "correctAnswer": "2",
      "type": "numerical",
      "options": [],
      "hint": "Factor the numerator: x^2-1 = (x+1)(x-1)",
      "explanation": "(x^2-1)/(x-1) = (x+1)(x-1)/(x-1) = x+1. At x=1, this equals 2."
    }
  },
  {
    "id": "hist_independence",
    "title": "Indian Independence Movement: Key Events",
    "subject": "History",
    "videoUrl": "$PV",
    "lockTimestamp": 15,
    "creatorName": "HistoryHub",
    "difficultyLevel": 1,
    "topicId": "indian_history",
    "conceptCluster": "freedom_struggle",
    "tags": ["history","india","independence","gandhi"],
    "language": "en",
    "question": {
      "id": "q_hist_1",
      "prompt": "In which year did India gain independence from British rule?",
      "correctAnswer": "1947",
      "type": "numerical",
      "options": [],
      "hint": "15th August...",
      "explanation": "India gained independence on 15th August 1947."
    }
  },
  {
    "id": "hist_world_war_2",
    "title": "World War II: Causes and Consequences",
    "subject": "History",
    "videoUrl": "$PV",
    "lockTimestamp": 20,
    "creatorName": "HistoryHub",
    "difficultyLevel": 2,
    "topicId": "world_history",
    "conceptCluster": "world_wars",
    "tags": ["history","ww2","world war","allies"],
    "language": "en",
    "question": {
      "id": "q_ww2_1",
      "prompt": "Which event triggered World War II in Europe?",
      "correctAnswer": "Germany's invasion of Poland",
      "type": "multiple_choice",
      "options": ["Treaty of Versailles","Germany's invasion of Poland","Pearl Harbor","Russian Revolution"],
      "hint": "September 1, 1939",
      "explanation": "Germany invaded Poland on September 1, 1939, leading Britain and France to declare war."
    }
  },
  {
    "id": "hist_mughal_empire",
    "title": "The Mughal Empire: Rise and Fall",
    "subject": "History",
    "videoUrl": "$PV",
    "lockTimestamp": 14,
    "creatorName": "HistoryHub",
    "difficultyLevel": 2,
    "topicId": "indian_history",
    "conceptCluster": "mughal_dynasty",
    "tags": ["history","mughals","akbar","india"],
    "language": "en",
    "question": {
      "id": "q_mughal_1",
      "prompt": "Which Mughal emperor built the Taj Mahal?",
      "correctAnswer": "Shah Jahan",
      "type": "multiple_choice",
      "options": ["Akbar","Shah Jahan","Aurangzeb","Babur"],
      "hint": "Built in memory of his wife Mumtaz Mahal",
      "explanation": "Shah Jahan built the Taj Mahal in Agra as a mausoleum for his wife Mumtaz Mahal."
    }
  },
  {
    "id": "hist_french_revolution",
    "title": "The French Revolution: Liberty, Equality, Fraternity",
    "subject": "History",
    "videoUrl": "$PV",
    "lockTimestamp": 16,
    "creatorName": "HistoryHub",
    "difficultyLevel": 2,
    "topicId": "world_history",
    "conceptCluster": "revolutions",
    "tags": ["history","france","revolution","democracy"],
    "language": "en",
    "question": {
      "id": "q_french_1",
      "prompt": "The storming of which prison marked the beginning of the French Revolution?",
      "correctAnswer": "Bastille",
      "type": "multiple_choice",
      "options": ["Versailles","Bastille","Louvre","Notre-Dame"],
      "hint": "July 14, 1789 - now a national holiday in France",
      "explanation": "The storming of the Bastille on July 14, 1789 symbolized the fall of royal authority."
    }
  }
]
"@

Write-Host "Seeding 20 new videos into Supabase..."

try {
    Invoke-RestMethod -Method POST -Uri "$SUPABASE_URL/rest/v1/educational_content" -Headers $headers -Body $jsonPayload
    Write-Host "Done! Videos inserted successfully." -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    # Try to get more detail
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Yellow
    }
}

# Verify
Write-Host ""
Write-Host "Verifying total count..."
$all = Invoke-RestMethod -Uri "$SUPABASE_URL/rest/v1/educational_content?select=id,title,subject" -Headers @{
    "apikey"        = $ANON_KEY
    "Authorization" = "Bearer $ANON_KEY"
}
Write-Host "Total videos in database: $($all.Count)" -ForegroundColor Cyan
$all | Group-Object -Property subject | ForEach-Object { Write-Host "  $($_.Name): $($_.Count) videos" }
