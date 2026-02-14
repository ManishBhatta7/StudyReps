# StudyReps Content Creation Guide
## From PDF to Video Feed

---

## 🎯 The Big Picture

```
Your PDF     →    NotebookLM    →    Audio    →    Video    →    App
(Force.pdf)       (AI Audio)        (MP3)         (MP4)         (Feed)
    ↓                 ↓               ↓             ↓             ↓
  Content         2-min audio     Download     Convert &     Upload &
  planning        per topic         MP3        add visuals   configure
```

---

## 📊 Content Hierarchy

```
ICSE (Board)
  └── Physics (Subject)
        └── Chapter 1: Force (Chapter)
              ├── Topic 1: Force Intro (Video 1)
              ├── Topic 2: Newton's 1st Law (Video 2)
              ├── Topic 3: Newton's 2nd Law (Video 3)
              ├── ... (Videos 4-10)
```

**Rule of thumb:** 1 Topic = 1 Video = 1 Lock Question = ~2 minutes

---

## 📝 Content Planning Template

Use this template for EACH topic before going to NotebookLM:

```markdown
### Topic: [Title]
**Duration Target:** 90-120 seconds
**Difficulty:** Easy / Medium / Hard

**Key Concepts to Cover:**
1. [Concept 1]
2. [Concept 2]
3. [Concept 3]

**Formulas (if any):**
- [Formula 1]
- [Formula 2]

**Real-World Examples:**
- [Example 1]
- [Example 2]

**The Lock Question:**
- Type: MCQ / Numerical / True-False / Fill-blank
- Prompt: [Question text]
- Answer: [Correct answer]
- Hint: [Optional hint]

**Lock Timestamp:** ~45-60 seconds (after main concept explained)
```

---

## ✅ Force Chapter Content Tracker

| # | Topic | Duration | Prompt Ready | Audio Done | Video Done | Uploaded | Lock Set |
|---|-------|----------|--------------|------------|------------|----------|----------|
| 1 | Force Intro | 2 min | ✅ | ⬜ | ⬜ | ⬜ | ✅ |
| 2 | Newton's 1st Law | 2 min | ✅ | ⬜ | ⬜ | ⬜ | ✅ |
| 3 | Newton's 2nd Law | 2 min | ✅ | ⬜ | ⬜ | ⬜ | ✅ |
| 4 | Newton's 3rd Law | 2 min | ✅ | ⬜ | ⬜ | ⬜ | ✅ |
| 5 | Momentum | 2 min | ✅ | ⬜ | ⬜ | ⬜ | ✅ |
| 6 | Equations of Motion | 2.5 min | ✅ | ⬜ | ⬜ | ⬜ | ✅ |
| 7 | Torque | 2 min | ✅ | ⬜ | ⬜ | ⬜ | ✅ |
| 8 | Equilibrium | 2 min | ✅ | ⬜ | ⬜ | ⬜ | ✅ |
| 9 | Centre of Gravity | 2 min | ✅ | ⬜ | ⬜ | ⬜ | ✅ |
| 10 | Circular Motion | 2 min | ✅ | ⬜ | ⬜ | ⬜ | ✅ |

**Progress: 10/70 steps complete (14%)**

---

## 🔧 Step-by-Step Production Guide

### STEP 1: NotebookLM Audio Generation

**For Topic 1 (Force Intro):**

1. Go to [notebooklm.google.com](https://notebooklm.google.com)
2. Create notebook: "StudyReps - Physics Force"
3. Upload your Force chapter PDF
4. Click "Audio Overview" → "Customize"
5. Paste this prompt:

```
Create an engaging 2-minute explanation about Force for Class 10 students.

MUST COVER:
- Definition: Force is a physical cause that changes state of rest or motion
- SI Unit: Newton (N) - named after Isaac Newton
- CGS Unit: Dyne
- Conversion: 1 Newton = 100,000 dynes (10^5)
- Two types: Contact forces (friction, push, pull) vs Non-contact (gravity, magnetic)

STYLE:
- Conversational, like two friends discussing physics
- Use real examples (pushing a door, apple falling, magnet attracting iron)
- Make it memorable and engaging
- Target: 90-120 seconds
```

6. Generate and download MP3

### STEP 2: Audio to Video Conversion

**Option A: Canva (Recommended for beginners)**
1. Go to canva.com → Create Design → Video
2. Choose 9:16 (Mobile/TikTok format)
3. Upload your MP3
4. Add background (gradient, pattern, or subtle animation)
5. Add waveform visualizer
6. Add text overlays for key formulas: "F = Force, 1N = 10⁵ dyne"
7. Export as MP4

**Option B: Headliner.app**
1. Upload MP3
2. Auto-generates video with waveform
3. Add your branding/colors
4. Export

**Option C: Kapwing**
1. More advanced editing
2. Add images, diagrams from textbook
3. Animate formulas appearing

### STEP 3: Upload to Cloud Storage

**Using Supabase Storage:**
```bash
# In your Supabase dashboard:
# Storage → Create bucket: "studyreps-videos"
# Upload your MP4 file
# Copy the public URL
```

**Naming convention:**
```
physics_ch1_force_01_intro.mp4
physics_ch1_force_02_newton1.mp4
physics_ch1_force_03_newton2.mp4
...
```

### STEP 4: Update App Code

In `video_feed_provider.dart`, update the videoUrl:

```dart
VideoModel(
  id: 'physics_force_intro',
  videoUrl: 'https://YOUR_SUPABASE_URL/storage/v1/object/public/studyreps-videos/physics_ch1_force_01_intro.mp4',
  lockTimestamp: 45,
  // ... rest of config
),
```

---

## 🎬 Video Best Practices

### Duration
- **Ideal:** 90-120 seconds
- **Max:** 180 seconds (3 min)
- Too long = students lose attention

### Lock Placement
- **When:** 45-70 seconds into video
- **Where:** Right AFTER the key concept is explained
- **Why:** Tests immediate recall while info is fresh

### Visual Style
- **Format:** 9:16 (vertical/mobile-first)
- **Background:** Dark gradient matching app theme (#0F172A to #1E293B)
- **Text:** Large, readable (key formulas)
- **Waveform:** Subtle, not distracting

### Audio Quality
- NotebookLM produces clear audio
- No music in background (distracting)
- Conversation style keeps engagement

---

## 📱 Question Type Guidelines

| Question Type | Best For | Example |
|--------------|----------|---------|
| **MCQ** | Concept recognition | "SI unit of force?" |
| **Numerical** | Formula application | "F = 5kg × 3m/s² = ?" |
| **True/False** | Common misconceptions | "Centrifugal is real force" |
| **Fill Blank** | Key term recall | "Equal and ___ reaction" |
| **Scenario** | Deep understanding | "Bus stops, passengers lurch..." |

**Mix Recommendation:**
- 40% MCQ (confidence building)
- 30% Numerical (practice formulas)  
- 15% True/False (quick wins)
- 15% Scenario (application)

---

## 🚀 Scaling to More Content

Once you've done Force chapter, repeat for:

**Physics (10 chapters)**
- Force ✅ (in progress)
- Work, Energy, Power
- Machines
- Light
- Sound
- Electricity
- Magnetism
- Heat
- Modern Physics

**Other Subjects**
- Chemistry (10 chapters)
- Mathematics (15 chapters)
- Biology (10 chapters)

**Estimated Total Videos:** ~100-150 for full Class 10 ICSE

---

## 💡 Pro Tips

1. **Batch Process** - Generate all 10 Force audios in one NotebookLM session
2. **Templates** - Create Canva templates to speed up video creation
3. **Consistency** - Same visual style across all videos
4. **Test Early** - Test first 2-3 videos in app before doing all 10
5. **Student Feedback** - Get feedback on difficulty & question quality

---

## 📁 File Organization

```
studyreps-content/
├── physics/
│   ├── ch1_force/
│   │   ├── prompts/
│   │   │   ├── 01_intro.md
│   │   │   ├── 02_newton1.md
│   │   │   └── ...
│   │   ├── audio/
│   │   │   ├── 01_intro.mp3
│   │   │   ├── 02_newton1.mp3
│   │   │   └── ...
│   │   ├── video/
│   │   │   ├── 01_intro.mp4
│   │   │   ├── 02_newton1.mp4
│   │   │   └── ...
│   │   └── questions.json
│   ├── ch2_work_energy/
│   └── ...
├── chemistry/
├── mathematics/
└── content_tracker.xlsx
```

---

## Next Steps

1. ⬜ Generate audio for Topic 1 (Force Intro) in NotebookLM
2. ⬜ Convert to video using Canva
3. ⬜ Upload to Supabase Storage
4. ⬜ Update videoUrl in code
5. ⬜ Test in app
6. ⬜ Repeat for remaining 9 topics

**Need help?** The prompts for all 10 topics are in `NOTEBOOKLM_INTEGRATION.md`

Happy content creating! 🎓
