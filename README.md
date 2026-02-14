# StudyReps - "TikTok for Logic" 🧠💪

<div align="center">
  <img src="assets/images/logo.png" alt="StudyReps Logo" width="120"/>
  
  **Learn through micro-struggles. One rep at a time.**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.2+-blue.svg)](https://flutter.dev)
  [![Supabase](https://img.shields.io/badge/Supabase-Backend-green.svg)](https://supabase.com)
  [![Gemini](https://img.shields.io/badge/Gemini-AI-purple.svg)](https://ai.google.dev)
</div>

---

## 🎯 What is StudyReps?

**StudyReps** is a mobile-first educational platform that transforms passive video watching into active learning. Think TikTok, but your brain gets a workout.

### The Core Loop

1. **📱 Scroll the Feed** - Swipe through short, engaging educational videos
2. **🔒 The Lock** - Videos pause at key moments with a question
3. **💪 The Rep** - Answer correctly to unlock and continue
4. **🤖 AI Coach** - Get instant feedback from Gemini AI

---

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| **Vertical Video Feed** | TikTok-style infinite scroll with educational content |
| **The Lock System** | Videos pause at designated timestamps requiring interaction |
| **Glassmorphism UI** | Premium frosted glass overlay for question display |
| **AI Coaching** | Gemini 1.5 Flash provides instant, specific feedback |
| **Gamification** | Streak tracking, XP system, and progress stats |
| **Multiple Q Types** | Text input, multiple choice, drag & drop, equations |

---

## 🛠 Tech Stack

### Frontend
- **Flutter** (Dart) - Cross-platform mobile development
- **Riverpod** - State management
- **video_player** - Video playback
- **flutter_animate** - Premium animations

### Backend
- **Supabase** - Auth, PostgreSQL database, file storage
- **Google Gemini API** - AI-powered coaching feedback

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart     # App config, API keys
│   └── theme/
│       └── study_reps_theme.dart  # Dark, premium UI theme
├── domain/
│   └── models/
│       ├── video_model.dart       # Video + Question models
│       └── user_rep_model.dart    # User progress tracking
├── presentation/
│   ├── providers/
│   │   └── video_feed_provider.dart  # Riverpod state
│   ├── screens/
│   │   └── video_feed_screen.dart    # Main feed with PageView
│   └── widgets/
│       ├── video_feed_item.dart      # Individual video player
│       └── lock_overlay.dart         # Glassmorphism question UI
└── main.dart                         # App entry point
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.2+
- Dart SDK
- Android Studio / Xcode
- Supabase account

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/studyreps.git
cd studyreps

# Install dependencies
flutter pub get

# Generate Freezed models
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Environment Setup

1. Copy your Supabase credentials to `lib/core/constants/app_constants.dart`
2. Add your Gemini API key to the same file
3. Set up the Supabase database tables (see [Database Schema](#database-schema))

---

## 🗄 Database Schema

### `videos` table
```sql
CREATE TABLE videos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  video_url TEXT NOT NULL,
  lock_timestamp INT NOT NULL,
  question_json JSONB NOT NULL,
  creator_name TEXT,
  title TEXT,
  subject TEXT,
  likes_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### `user_reps` table
```sql
CREATE TABLE user_reps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  video_id UUID REFERENCES videos(id),
  is_correct BOOLEAN NOT NULL,
  user_answer TEXT,
  ai_feedback TEXT,
  attempt_date TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 📱 Implementation Phases

### Phase 1: Core Loop ✅
- [x] Flutter project setup with Riverpod
- [x] Mock video data (3 hardcoded videos)
- [x] VideoFeedItem with lock timestamp listener
- [x] Glassmorphism overlay UI

### Phase 2: Logic (In Progress)
- [ ] Mock correct/incorrect validation
- [ ] Gemini API integration
- [ ] AI coaching feedback display

### Phase 3: Backend
- [ ] Supabase Auth (Email + Google)
- [ ] Videos table with real data
- [ ] User reps tracking
- [ ] Progress persistence

### Phase 4: Gamification
- [ ] Streak system
- [ ] XP and levels
- [ ] Leaderboards
- [ ] Achievements

---

## 🎨 Design System

| Token | Value | Usage |
|-------|-------|-------|
| `primaryPurple` | `#8B5CF6` | Primary actions, highlights |
| `accentCyan` | `#22D3EE` | Success states, progress |
| `errorPink` | `#F472B6` | Errors, incorrect answers |
| `bgPrimary` | `#0A0A0F` | Main background |
| `bgGlass` | `rgba(255,255,255,0.2)` | Overlay backgrounds |

---

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines first.

---

## 📄 License

This project is licensed under the MIT License.

---

<div align="center">
  <strong>Built with 💪 for learners who want more than passive consumption.</strong>
</div>
