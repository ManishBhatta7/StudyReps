-- ============================================================
-- StudyReps: Phase 1 Database Schema Extensions
-- Supabase PostgreSQL Migration
-- ============================================================

-- 1. Extend videos table with adaptive feed fields
ALTER TABLE videos
  ADD COLUMN IF NOT EXISTS transcript      TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS tags            TEXT[] DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS prerequisite_ids TEXT[] DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS difficulty_level INTEGER DEFAULT 1 CHECK (difficulty_level BETWEEN 1 AND 5),
  ADD COLUMN IF NOT EXISTS topic_id        TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS concept_cluster TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS language        TEXT DEFAULT 'en';

-- 2. Learning records table (per-user, per-video tracking)
CREATE TABLE IF NOT EXISTS learning_records (
  id               TEXT PRIMARY KEY,    -- '{userId}_{videoId}'
  user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  video_id         TEXT NOT NULL,
  dwell_time_ms    INTEGER DEFAULT 0,
  attempts         INTEGER DEFAULT 0,
  is_correct       BOOLEAN DEFAULT FALSE,
  correct_count    INTEGER DEFAULT 0,
  ease_factor      DOUBLE PRECISION DEFAULT 2.5,
  interval_days    INTEGER DEFAULT 0,
  repetition       INTEGER DEFAULT 0,
  next_review_at   TIMESTAMPTZ,
  last_reviewed_at TIMESTAMPTZ,
  mastery_score    DOUBLE PRECISION DEFAULT 0.0,
  is_mastered      BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ
);

-- Index for fast review queries
CREATE INDEX IF NOT EXISTS idx_learning_records_review
  ON learning_records(user_id, next_review_at)
  WHERE NOT is_mastered;

CREATE INDEX IF NOT EXISTS idx_learning_records_user
  ON learning_records(user_id);

-- 3. Comments table
CREATE TABLE IF NOT EXISTS video_comments (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  video_id     TEXT NOT NULL,
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content      TEXT NOT NULL,
  sentiment    TEXT DEFAULT 'neutral' CHECK (sentiment IN ('positive', 'negative', 'confused', 'neutral')),
  helpful_count INTEGER DEFAULT 0,
  parent_id    UUID REFERENCES video_comments(id) ON DELETE CASCADE,
  is_ai        BOOLEAN DEFAULT FALSE,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_comments_video ON video_comments(video_id);

-- 4. Teach-back submissions
CREATE TABLE IF NOT EXISTS teach_back_submissions (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  video_id     TEXT NOT NULL,
  recording_url TEXT NOT NULL,
  xp_awarded   INTEGER DEFAULT 50,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Quiz results
CREATE TABLE IF NOT EXISTS quiz_results (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  video_id     TEXT NOT NULL,
  question     TEXT NOT NULL,
  user_answer  TEXT NOT NULL,
  is_correct   BOOLEAN NOT NULL,
  score        DOUBLE PRECISION DEFAULT 0.0,
  feedback     TEXT,
  question_type TEXT DEFAULT 'open_input',
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_quiz_results_user ON quiz_results(user_id, video_id);

-- 6. Row Level Security
ALTER TABLE learning_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE teach_back_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_results ENABLE ROW LEVEL SECURITY;

-- Users can only read/write their own learning records
CREATE POLICY "Users manage own learning records"
  ON learning_records FOR ALL
  USING (auth.uid() = user_id);

-- Comments are readable by all, writable by owner
CREATE POLICY "Comments readable by all"
  ON video_comments FOR SELECT
  USING (true);

CREATE POLICY "Users create own comments"
  ON video_comments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users manage own teach-back submissions
CREATE POLICY "Users manage own teach-backs"
  ON teach_back_submissions FOR ALL
  USING (auth.uid() = user_id);

-- Users manage own quiz results
CREATE POLICY "Users manage own quiz results"
  ON quiz_results FOR ALL
  USING (auth.uid() = user_id);
