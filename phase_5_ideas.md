# Phase 5: Advanced AI & Monetization (Ideas)

Now that the core loop (Video Feed), AI Validation, and Backend Auth are complete, here are the potential directions we can take for Phase 5 (after or alongside Gamification in Phase 4):

## Idea 1: TutorBot (The Conversational AI Coach)
**Description:** Instead of just getting a "Correct/Incorrect" banner on a study rep, users can swipe open a chat panel to have a full conversation with an AI Tutor about the exact concept they just struggled with.
**Tasks:**
- Integrate `ChatPersistenceService` with a sliding modal sheet `TutorBotSheet`
- Stream Gemini AI responses directly into the chat UI
- Pass the current video's context/transcript automatically to the AI

## Idea 2: Automated Content Pipeline Workflow
**Description:** Build out the toolset that allows teachers/creators to easily upload a PDF (like you did with NotebookLM) and have the app automatically chop it into short videos, generate the lock timestamps, and build the multiple choice questions.
**Tasks:**
- Add an "Admin/Creator Dashboard" screen
- Allow uploading MP3 + Text pairs, and auto-generating the video metadata in Supabase
- Build a web-only view for easy bulk-uploading

## Idea 3: Multiplayer "Logic Battles" (Peer vs Peer)
**Description:** The ultimate TikTok duel. Users challenge their friends or random peers to a specific Chapter. They watch the same 5 short videos in real-time, and whoever answers the Lock questions fastest and most accurately wins the battle.
**Tasks:**
- Implement real-time Supabase WebSockets (Broadcast channels)
- Build a matchmaking lobby screen
- Add a real-time progress bar showing the opponent's score

## Idea 4: Teacher & Parent Dashboard
**Description:** A separate UI where a Parent or Teacher can see exactly what their student is struggling with.
**Tasks:**
- Build a web-focused dashboard using `flutter_web`
- Display graphs of User Reps (Correct vs Incorrect rates by topic)
- Implement role-based row level security (RLS) in Supabase so teachers can securely query their classroom's students.
