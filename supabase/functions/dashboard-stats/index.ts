import "https://deno.land/x/xhr@0.3.0/mod.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders });
    }

    try {
        const supabaseClient = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
        );

        const { user_id, range = 'week' } = await req.json();

        if (!user_id) throw new Error('user_id is required');

        // Stats:
        // 1. Total Reps
        // 2. Accuracy
        // 3. Subject Breakdown

        // Fetch aggregates
        const { data: reps, error } = await supabaseClient
            .from('user_reps')
            .select('is_correct, videos(subject)')
            .eq('user_id', user_id);

        if (error) throw error;

        const totalReps = reps.length;
        const correctReps = reps.filter(r => r.is_correct).length;
        const accuracy = totalReps > 0 ? (correctReps / totalReps * 100).toFixed(1) : 0;

        // Subject Breakdown
        const subjectCounts = {};
        for (const r of reps) {
            const subject = r.videos?.subject || 'Unknown';
            subjectCounts[subject] = (subjectCounts[subject] || 0) + 1;
        }

        return new Response(
            JSON.stringify({
                total_reps: totalReps,
                accuracy: accuracy + '%',
                subject_breakdown: subjectCounts
            }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );

    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
        );
    }
});
