# StudyReps Development Plan

## Project Idea
StudyReps is a "TikTok for Logic" app—a mobile-first educational platform designed to transform passive watching into active learning. It features a vertical video feed, a "Lock" system that pauses videos for questions, and an AI Coach (Gemini) for instant feedback.

## Current State
Phase 1 (Core Loop) is completed.
Phases 2-4 are pending.

## Tech Stack
- Frontend: Flutter, Riverpod, video_player, flutter_animate
- Backend: Supabase (Auth, Postgres, Storage), Google Gemini API
- Design: Glassmorphism UI, Dark mode

## Phases & Tasks

### Phase 2: Logic & AI Integration
Focus on the core learning mechanics and the AI coaching system.
1. Implement mock correct/incorrect validation for the Lock system.
2. Integrate Google Gemini API for evaluating user answers.
3. Build the AI coaching feedback display UI.

### Phase 3: Backend & Persistence
Connect the app realistically to the cloud.
4. Integrate Supabase Auth (Email/Google).
5. Set up the Videos table and fetch real data instead of mocks.
6. Implement User Reps tracking (storing answers and AI feedback).
7. Implement offline/online progress persistence.

### Phase 4: Gamification
Keep users engaged with typical gaming elements.
8. Implement streak tracking system.
9. Add an XP and leveling system.
10. Build Leaderboards for social learning.
11. Introduce Achievements and badges.

## Orchestration Strategy
- We will use `staging` as the integration branch.
- For each phase, we will process one issue at a time on `feature/issue-{N}-{slug}` branches.
- Once an issue is done, it merges into `staging`.
- Once a phase is done, `staging` merges into `main`.
