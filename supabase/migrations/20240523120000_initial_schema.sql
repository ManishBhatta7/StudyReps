-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. PROFILES (Extends Supabase Auth)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  username TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  xp INTEGER DEFAULT 0,
  streak_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for Profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public profiles are viewable by everyone."
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can insert their own profile."
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile."
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- Trigger to create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url)
  VALUES (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- 2. VIDEOS (Content)
CREATE TABLE public.videos (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  creator_id UUID REFERENCES public.profiles(id),
  title TEXT NOT NULL,
  description TEXT,
  video_url TEXT NOT NULL,
  thumbnail_url TEXT,
  subject TEXT NOT NULL, -- e.g., 'Math', 'Physics'
  
  -- The core mechanism: when does the video lock?
  lock_timestamp_ms INTEGER NOT NULL, 
  
  -- Flexible JSON structure for questions (MC, DragDrop, Equation)
  question_json JSONB NOT NULL,
  
  -- Public metrics
  likes_count INTEGER DEFAULT 0,
  views_count INTEGER DEFAULT 0,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for Videos
ALTER TABLE public.videos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Videos are viewable by everyone."
  ON public.videos FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can create videos."
  ON public.videos FOR INSERT
  WITH CHECK (auth.role() = 'authenticated'); -- Or restrict to 'creators' role if needed

CREATE POLICY "Creators can update their own videos."
  ON public.videos FOR UPDATE
  USING (auth.uid() = creator_id);


-- 3. USER REPS (The Learning Record - Synced from Hive)
CREATE TABLE public.user_reps (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) NOT NULL,
  video_id UUID REFERENCES public.videos(id) NOT NULL,
  
  -- Interaction Outcome
  is_correct BOOLEAN NOT NULL,
  user_answer TEXT, -- What they typed/selected
  ai_feedback TEXT, -- Cached feedback from Gemini
  
  -- Pedagogical Metrics
  dwell_time_ms INTEGER NOT NULL, -- "Struggle time"
  attempt_count INTEGER DEFAULT 1,
  quality_score INTEGER DEFAULT 0, -- SM-2 Quality (0-5)
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(), -- When it happened on client
  synced_at TIMESTAMPTZ DEFAULT NOW()   -- When it reached server
);

-- RLS for User Reps
ALTER TABLE public.user_reps ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own reps."
  ON public.user_reps FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own reps."
  ON public.user_reps FOR INSERT
  WITH CHECK (auth.uid() = user_id);


-- 4. COGNITIVE LOAD LOGS (Analytics)
CREATE TABLE public.cognitive_load_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id),
  session_id UUID, 
  video_id UUID REFERENCES public.videos(id),
  
  event_type TEXT NOT NULL, -- 'pause', 'rewind', 'idle', 'rage_click'
  metadata JSONB, -- { "position": 1200, "speed": 2.0 }
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for Logs
ALTER TABLE public.cognitive_load_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert logs."
  ON public.cognitive_load_logs FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Only admins/analysts can view logs (omitted for now, or add specific policy)


-- 5. SPACED REPETITION STATE (Server-side Master Record)
-- This table tracks the CURRENT state of a user's mastery for each video.
-- It is updated via Edge Functions based on `user_reps`.
CREATE TABLE public.learning_state (
  user_id UUID REFERENCES public.profiles(id),
  video_id UUID REFERENCES public.videos(id),
  
  ease_factor FLOAT DEFAULT 2.5,
  interval_days INTEGER DEFAULT 0,
  next_review_at TIMESTAMPTZ,
  mastery_score FLOAT DEFAULT 0.0, -- 0.0 to 1.0
  
  last_reviewed_at TIMESTAMPTZ,
  
  PRIMARY KEY (user_id, video_id)
);

ALTER TABLE public.learning_state ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own learning state."
  ON public.learning_state FOR SELECT
  USING (auth.uid() = user_id);
