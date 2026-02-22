-- Update Gamification RLS to allow public reading for Leaderboards and Profiles

-- 1. Update user_xp policy to allow public reads
DROP POLICY IF EXISTS "Users can view their own xp" ON public.user_xp;
CREATE POLICY "user_xp is viewable by everyone" ON public.user_xp FOR SELECT TO public USING (true);

-- 2. Update user_streaks policy to allow public reads
DROP POLICY IF EXISTS "Users can view their own streaks" ON public.user_streaks;
CREATE POLICY "user_streaks is viewable by everyone" ON public.user_streaks FOR SELECT TO public USING (true);

-- 3. Update user_achievements policy to allow public reads
DROP POLICY IF EXISTS "Users can view their own achievements" ON public.user_achievements;
CREATE POLICY "user_achievements is viewable by everyone" ON public.user_achievements FOR SELECT TO public USING (true);

-- 4. Create public.profiles table if it doesn't exist (useful for displaying names & avatars in leaderboards and friends)
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid references auth.users not null primary key,
  full_name text,
  avatar_url text,
  role text,
  school text,
  preferences jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Allow public read access to profiles
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles FOR SELECT TO public USING (true);

-- Allow users to update their own profiles
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
CREATE POLICY "Users can insert their own profile" ON public.profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id);

-- 5. Trigger to automatically create a profile when a new user signs up in auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url, role)
  VALUES (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url', new.raw_user_meta_data->>'role');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists and recreate
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- For existing users, create profiles if they don't exist
INSERT INTO public.profiles (id, full_name, avatar_url, role)
SELECT id, raw_user_meta_data->>'full_name', raw_user_meta_data->>'avatar_url', raw_user_meta_data->>'role'
FROM auth.users
ON CONFLICT (id) DO NOTHING;
