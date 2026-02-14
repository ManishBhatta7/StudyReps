# StudyReps + NotebookLM Integration Guide
## ICSE Physics Chapter 1: Force

This guide shows how to generate engaging audio content using NotebookLM and integrate it into StudyReps.

---

## 🎯 How to Use NotebookLM for StudyReps Content

### Step 1: Upload Your PDF
1. Go to [notebooklm.google.com](https://notebooklm.google.com)
2. Create a new notebook
3. Upload `DOC-20260124-WA0014.pdf` (Force chapter)

### Step 2: Generate Audio Overview
1. Click "Audio Overview" in NotebookLM
2. Choose "Podcast-style conversation"
3. Download the generated MP3

### Step 3: Convert to Video
Use tools like:
- **Canva** - Add waveform animations
- **Headliner** - Auto-generates video from audio
- **Kapwing** - Add visuals and text overlays

---

## 📝 Optimized NotebookLM Prompts

Copy these into NotebookLM for each topic:

### Topic 1: Introduction to Force
```
Create an engaging 2-minute explanation about Force.
Cover:
- Definition: physical cause that changes state of rest/motion
- Units: Newton (SI), Dyne (CGS), 1N = 10⁵ dyne
- Types: Contact (friction, push) vs Non-contact (gravity, magnetic)

Use real examples like:
- Pushing a door (contact)
- Apple falling (non-contact gravity)
- Magnet attracting iron (non-contact magnetic)

Make it conversational, like two friends discussing physics!
```

### Topic 2: Newton's First Law (Inertia)
```
Explain Newton's First Law in an exciting, memorable way!

Key points:
- A body stays at rest or uniform motion unless external force acts
- This is WHY it's called "Law of Inertia"

Amazing examples:
- Passenger lurching forward when bus STOPS suddenly
- Tablecloth trick (objects stay put when cloth pulled)
- Spacecraft moving forever in space (no friction!)
- Shaking ketchup bottle (ketchup keeps moving when bottle stops)

Make students say "Ohhhh, THAT'S why that happens!"
```

### Topic 3: Newton's Second Law (F=ma)
```
Break down the most important equation in physics: F = ma

Build up to it:
- Force changes momentum
- Rate of change of momentum = F = Δp/Δt
- Since p = mv and m is constant: F = m(Δv/Δt) = ma

Real-world connections:
- Why heavier cars need more powerful engines
- Why a cricket ball hurts more when bowled FAST
- Why you lean back when car accelerates

Include a quick calculation example:
"If a 5 kg object needs to accelerate at 3 m/s², you need F = 5 × 3 = 15 Newtons!"
```

### Topic 4: Newton's Third Law (Action-Reaction)
```
Make Newton's Third Law unforgettable!

The rule: Every action has an EQUAL and OPPOSITE reaction
Key insight: Forces act on DIFFERENT bodies!

Mind-blowing examples:
- Walking: You push ground backward, ground pushes YOU forward
- Swimming: Push water backward, water pushes you forward
- Rocket: Pushes gases down, gases push rocket UP
- Gun recoil: Bullet goes forward, gun goes backward
- Jumping: Push Earth down (tiny!), Earth pushes you up

Common mistake to avoid:
"If action = reaction, why doesn't everything stay still?"
Because they act on DIFFERENT objects!
```

### Topic 5: Momentum
```
Explain Momentum as "mass in motion" - p = mv

Key concepts:
- It's a VECTOR (has direction!)
- Units: kg·m/s (SI), g·cm/s (CGS)
- More mass OR more velocity = more momentum

The truck vs bicycle comparison:
"A 1000 kg truck at 10 m/s has momentum = 10,000 kg·m/s
A 10 kg bicycle at 10 m/s has momentum = 100 kg·m/s
That's why you DON'T want to get hit by a truck!"

Connect to Newton's 2nd Law:
F = Δp/Δt (force is rate of change of momentum)
```

### Topic 6: Equations of Motion
```
Master the 3 MAGIC equations of motion!

The equations:
1. v = u + at (find final velocity)
2. s = ut + ½at² (find distance traveled)
3. v² = u² + 2as (when you don't know time!)

Variable meanings:
- u = initial velocity (starting speed)
- v = final velocity (ending speed)
- a = acceleration
- t = time
- s = displacement (distance)

Pro tip: "No time in the problem? Use equation 3!"

Example walkthrough:
"Car starts from rest (u=0), accelerates at 2 m/s² for 5 seconds.
Final velocity: v = 0 + 2(5) = 10 m/s
Distance: s = 0(5) + ½(2)(5²) = 25 meters!"
```

### Topic 7: Moment of Force (Torque)
```
Explain Torque - the TURNING effect of force!

Formula: τ = F × d
Where d is PERPENDICULAR distance from pivot

Why this matters:
- Door handles are far from hinges (more torque = easier to open)
- Long spanners are easier to use than short ones
- Seesaws work because of balanced moments

Clockwise vs Anticlockwise:
- Clockwise = negative (by convention)
- Anticlockwise = positive

Quick calculation:
"20N force, 0.5m from pivot = 20 × 0.5 = 10 Nm of torque"
```

### Topic 8: Equilibrium
```
When is a body in Equilibrium? When nothing changes!

Two types:
1. STATIC equilibrium = body at REST (book on table)
2. DYNAMIC equilibrium = body in UNIFORM motion (car at constant speed)

Two conditions for equilibrium:
1. Net force = 0 (no acceleration)
2. Net moment = 0 (no rotation)

Principle of Moments (SO important for exams!):
Sum of clockwise moments = Sum of anticlockwise moments

Seesaw example:
"If a 40 kg kid sits 2m from pivot, a 20 kg kid must sit 4m on other side!
40 × 2 = 80 Nm clockwise
20 × 4 = 80 Nm anticlockwise
BALANCED!"
```

### Topic 9: Centre of Gravity
```
Where is the Centre of Gravity? Where ALL the weight "acts"!

For regular shapes (memorize these!):
- Circle/Ring → CENTER (even though it's empty!)
- Disc → CENTER
- Rectangle → Where diagonals meet
- Triangle → Centroid (⅓ from base)
- Uniform Rod → Midpoint
- Cylinder → Midpoint of axis

Cool fact about the ring:
"The C.G. of a ring is at the CENTER... which is empty space! 
You can't even touch the C.G.!"

Why objects topple:
When C.G. goes OUTSIDE the base of support = TIMBER! 🪵
```

### Topic 10: Circular Motion
```
Uniform Circular Motion - constant SPEED but changing VELOCITY!

Wait, what? Velocity is a vector (has direction).
In a circle, direction keeps changing, so it's ACCELERATED motion!

The two forces everyone confuses:

CENTRIPETAL FORCE (Real!) 🎯
- Points TOWARDS center
- Examples: tension in string, gravity for planets
- "Center-seeking"

CENTRIFUGAL FORCE (Fake!) ❌
- Points AWAY from center
- It's not real! Just feels like it
- "Center-fleeing"

"When you're in a car turning right and feel pushed left...
That's not a real force! Your body just wants to go straight (inertia)!"

Exam trap: "Is centrifugal force real?" → NO, it's fictitious/pseudo!
```

---

## 🔒 Lock Point Strategy

For each 2-minute video, place "The Lock" at:
- **45-70 seconds** into the video
- Right AFTER a key concept is explained
- BEFORE moving to the next topic

This tests recall while the concept is fresh!

---

## 📊 Question Type Distribution

For optimal engagement, use this mix:
- 30% Multiple Choice (quick, confidence-building)
- 25% Numerical (apply formulas)
- 20% True/False (fast-paced)
- 15% Fill-in-blank (active recall)
- 10% Scenario-based (deep understanding)

---

## 🚀 Integration Code

```dart
// In your video provider, add Force chapter videos:
import 'package:study_reps/data/content/force_chapter_videos.dart';

final allVideos = [...existingVideos, ...ForceChapterVideos.getVideos()];

// Or filter by difficulty:
final beginnerVideos = ForceChapterVideos.getBeginnerVideos();
final advancedVideos = ForceChapterVideos.getAdvancedVideos();
```

---

## ✅ Checklist for Each Topic

- [ ] Generated NotebookLM audio
- [ ] Converted to video format
- [ ] Uploaded to cloud storage
- [ ] Updated video URL in code
- [ ] Set correct lock timestamp
- [ ] Added 2-3 question variants
- [ ] Tested in app

---

Happy content creating! 🎓
