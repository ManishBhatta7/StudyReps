# StudyReps — "TikTok for Logic" 🧠💪

<div align="center">
  <img src="assets/images/logo.png" alt="StudyReps Logo" width="120"/>
  
  **Learn through micro-struggles. One rep at a time.**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.38+-blue.svg)](https://flutter.dev)
  [![Supabase](https://img.shields.io/badge/Supabase-Backend-green.svg)](https://supabase.com)
  [![Gemini](https://img.shields.io/badge/Gemini_2.5_Flash-AI-purple.svg)](https://ai.google.dev)
  [![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
</div>

---

## 🎯 What is StudyReps?

**StudyReps** is a mobile-first educational platform that transforms passive video watching into active learning. Think TikTok's addictive feed, but your brain gets a workout.

### The Core Loop

1. **📱 Scroll the Feed** — Swipe through short, engaging educational videos
2. **🔒 The Lock** — Videos pause after 2 loops with a question overlay
3. **💪 The Rep** — Answer correctly to unlock and continue swiping
4. **🤖 AI Coach** — Get instant Socratic feedback from Gemini 2.5 Flash (with thinking mode)

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| **Vertical Video Feed** | TikTok-style infinite scroll with educational content |
| **The Lock System** | Videos pause after 2 loops, requiring correct answers to continue |
| **Glassmorphism UI** | Premium frosted glass overlays for questions and navigation |
| **AI Coaching (Thinking Mode)** | Gemini 2.5 Flash with native thinking for deeper Socratic feedback |
| **AI Tutorbot** | Per-video AI chat with persistent memory and vision analysis |
| **Pencil Canvas** | Draw directly on frozen video frames to annotate problems |
| **Gamification** | Streak tracking, XP system, leaderboards, and achievements |
| **Multiple Q Types** | Multiple choice, numerical, fill-blank, true/false, open input |
| **Adaptive Feed** | Spaced repetition algorithm prioritizes content you need to review |
| **Discover & Search** | Browse by subject, trending topics, and search educational content |
| **Share & Comment** | Share videos to social media and discuss in comment threads |
| **Voice TTS** | ElevenLabs text-to-speech for AI responses |
| **Script Generator** | AI-powered video script generator for creators |
| **Quiz Generator** | Auto-generate quizzes from any topic |

---

## 🛠 Tech Stack

### Frontend
- **Flutter 3.38+** (Dart) — Cross-platform development
- **Riverpod** — Reactive state management
- **go_router** — Navigation & deep linking
- **video_player** + **youtube_player_iframe** — Video playback
- **flutter_animate** — Premium animations
- **glassmorphism** — Frosted glass UI effects
- **google_fonts** — Inter, Outfit typography

### Backend & AI
- **Supabase** — Auth, PostgreSQL database, file storage, RLS
- **Gemini 2.5 Flash** — AI coaching with native thinking mode (1024 token budget)
- **ElevenLabs** — Text-to-speech for AI responses

### Data
- **Hive** — Local storage for chat persistence & preferences
- **SharedPreferences** — Lightweight key-value storage
- **Freezed** — Immutable data models with JSON serialization

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart        # Config, API keys, thinking mode
│   └── theme/
│       ├── study_reps_theme.dart      # Dark premium theme
│       ├── retain_learn_theme.dart    # Alternative theme
│       └── app_colors.dart           # Color tokens
├── data/
│   ├── content/
│   │   └── force_chapter_videos.dart  # Offline fallback data
│   ├── repositories/
│   │   ├── supabase_auth_repository.dart
│   │   ├── videos_repository.dart     # Supabase + offline
│   │   └── gemini_repository.dart
│   └── services/
│       ├── gemini_coach_service.dart   # AI coaching (thinking mode)
│       ├── achievement_service.dart
│       ├── chat_persistence_service.dart
│       ├── elevenlabs_tts_service.dart
│       ├── quiz_generator_service.dart
│       ├── spaced_repetition_service.dart
│       ├── streak_service.dart
│       └── xp_service.dart
├── domain/
│   └── models/
│       ├── video_model.dart           # Video + Question models
│       ├── user_rep_model.dart        # User progress
│       ├── leaderboard_model.dart
│       ├── achievement_model.dart
│       └── ...
├── presentation/
│   ├── providers/
│   │   ├── tutorbot_provider.dart     # AI chat (thinking mode)
│   │   ├── adaptive_feed_provider.dart
│   │   ├── leaderboard_provider.dart
│   │   └── auth_provider.dart
│   ├── screens/
│   │   ├── swipe_gated_feed_screen.dart  # Main feed
│   │   ├── discover_screen.dart
│   │   ├── leaderboard_screen.dart
│   │   ├── profile_stats_screen.dart
│   │   ├── streak_screen.dart
│   │   ├── drill_screen.dart
│   │   └── settings_screen.dart
│   └── widgets/
│       ├── gate_overlay.dart          # Question gate UI
│       ├── lock_overlay.dart          # Glassmorphism overlay
│       ├── video_tutorbot_sheet.dart   # AI chat panel
│       ├── pencil_canvas_overlay.dart  # Draw-on-video
│       ├── comment_section.dart
│       └── ...
└── main.dart
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.38+
- Dart SDK 3.2+
- Android Studio / VS Code
- Supabase account
- Gemini API key

### Installation

```bash
# Clone the repository
git clone https://github.com/ManishBhatta7/StudyReps.git
cd StudyReps

# Install dependencies
flutter pub get

# Generate Freezed models
dart run build_runner build --delete-conflicting-outputs

# Create .env file
cp .env.example .env
# Fill in your API keys

# Run the app
flutter run
```

### Environment Variables

Create a `.env` file in the project root:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
GEMINI_API_KEY=your_gemini_api_key
ELEVENLABS_API_KEY=your_elevenlabs_api_key
```

---

## 🗄 Database Schema

### `educational_content` table
```sql
CREATE TABLE educational_content (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  subject TEXT NOT NULL,
  "videoUrl" TEXT NOT NULL,
  "lockTimestamp" INT NOT NULL,
  "creatorName" TEXT DEFAULT 'StudyReps',
  "difficultyLevel" INT DEFAULT 1,
  "topicId" TEXT DEFAULT '',
  "conceptCluster" TEXT DEFAULT '',
  tags JSONB DEFAULT '[]',
  language TEXT DEFAULT 'en',
  question JSONB NOT NULL,
  "thumbnailUrl" TEXT DEFAULT '',
  "likesCount" INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Content Subjects (25+ videos)
- Physics (6) — Newton's Laws, Projectile Motion, Optics, Ohm's Law, Gravity, Thermodynamics
- Chemistry (5) — Periodic Table, Bonding, pH, Equations, Mole Concept
- Biology (5) — Cell Division, Photosynthesis, DNA, Heart, Ecosystems
- Mathematics (5) — Pythagorean, Quadratics, Trigonometry, Probability, Calculus
- History (4) — Indian Independence, WW2, Mughal Empire, French Revolution

---

## 🎨 Design System

| Token | Value | Usage |
|-------|-------|-------|
| `primaryPurple` | `#8B5CF6` | Primary actions, highlights |
| `primaryIndigo` | `#6366F1` | Gradients, accents |
| `accentCyan` | `#22D3EE` | Success states, progress |
| `errorPink` | `#F472B6` | Errors, incorrect answers |
| `bgPrimary` | `#0A0A0F` | Main background |
| `bgGlass` | `rgba(255,255,255,0.1)` | Glassmorphism overlays |

---

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines first.

---

## 📄 License

This project is licensed under the MIT License.

---

<div align="center">
  <strong>Built with 💪 for learners who want more than passive consumption.</strong>
  <br/>
  <em>StudyReps — Where every swipe is a rep for your brain.</em>
</div>
