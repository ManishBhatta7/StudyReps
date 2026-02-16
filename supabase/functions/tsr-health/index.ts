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

        const { user_id } = await req.json();

        if (!user_id) throw new Error('user_id is required');

        // 1. Fetch User Reps
        const { data: reps, error } = await supabaseClient
            .from('user_reps')
            .select('is_correct, attempt_count, dwell_time_ms, created_at')
            .eq('user_id', user_id)
            .order('created_at', { ascending: false })
            .limit(50); // Analyze last 50 interactions

        if (error) throw error;

        if (!reps || reps.length === 0) {
            return new Response(
                JSON.stringify({ health_score: 100, status: 'healthy', advice: 'Start learning!' }),
                { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            );
        }

        // 2. Calculate TSR Metrics
        let frustrationEvents = 0;
        let engagementScore = 0;

        for (const rep of reps) {
            // High dwell time + incorrect answer = Frustration?
            if (!rep.is_correct && rep.dwell_time_ms > 45000) {
                frustrationEvents++;
            }

            // High attempts = Grit (Good!)
            if (rep.attempt_count > 2) {
                engagementScore += 5;
            }
        }

        // Recent Accuracy (last 10)
        const recentReps = reps.slice(0, 10);
        const recentCorrect = recentReps.filter(r => r.is_correct).length;
        const accuracy = recentCorrect / recentReps.length;

        // 3. Determine Health Status
        // Score 0-100
        // Frustration penalizes heavily.
        let healthScore = 80; // Baseline
        healthScore -= (frustrationEvents * 5);
        healthScore += (engagementScore);
        healthScore += (accuracy * 20); // Bonus for being correct

        healthScore = Math.min(100, Math.max(0, healthScore));

        let status = 'healthy';
        let advice = 'Great job! You are in the flow.';

        if (healthScore < 50) {
            status = 'at_risk';
            advice = 'It seems you might be struggling. Try reviewing easier topics or taking a break.';
        } else if (healthScore < 70) {
            status = 'needs_attention';
            advice = 'You are doing okay, but accuracy is slipping. Focus on quality over quantity.';
        }

        return new Response(
            JSON.stringify({
                health_score: healthScore,
                status,
                advice,
                metrics: {
                    frustration_events: frustrationEvents,
                    recent_accuracy: accuracy
                }
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
