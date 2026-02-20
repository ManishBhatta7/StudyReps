import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const supabaseClient = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
        )

        // Expecting payload: { userId, streak, xp, achievements }
        const { userId, streak, xp, achievements } = await req.json();

        if (!userId) {
            throw new Error('Invalid payload: userId is required');
        }

        const now = new Date().toISOString();

        // 1. Sync Streaks
        if (streak) {
            const { error: streakError } = await supabaseClient
                .from('user_streaks')
                .upsert({
                    user_id: userId,
                    current_streak: streak.currentStreak,
                    max_streak: streak.maxStreak,
                    today_reps: streak.todayReps,
                    last_rep_date: streak.lastRepDate,
                    completed_days: streak.completedDays?.map((d: string) => new Date(d).toISOString().split('T')[0]) || [],
                    synced_at: now
                }, { onConflict: 'user_id' });
            if (streakError) throw streakError;
        }

        // 2. Sync XP
        if (xp) {
            const { error: xpError } = await supabaseClient
                .from('user_xp')
                .upsert({
                    user_id: userId,
                    total_xp: xp.totalXp,
                    current_level: xp.currentLevel,
                    xp_for_next_level: xp.xpForNextLevel,
                    synced_at: now
                }, { onConflict: 'user_id' });
            if (xpError) throw xpError;
        }

        // 3. Sync Achievements
        if (achievements && Array.isArray(achievements)) {
            const achPayloads = achievements.map(a => ({
                user_id: userId,
                achievement_id: a.id,
                is_unlocked: a.isUnlocked,
                progress: a.progress,
                unlocked_at: a.unlockedAt,
                synced_at: now
            }));

            // Upsert works best with unique constraint combinations
            for (const ach of achPayloads) {
                const { error: achError } = await supabaseClient
                    .from('user_achievements')
                    .upsert(ach, { onConflict: 'user_id,achievement_id' });
                // We do it individually or in bulk if unique index is correctly defined in DB
            }
        }

        return new Response(
            JSON.stringify({ success: true }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
        )
    }
})
