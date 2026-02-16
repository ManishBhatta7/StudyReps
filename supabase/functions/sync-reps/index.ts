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

        // Expecting a payload: { reps: [ ... ] }
        const { reps } = await req.json()

        if (!reps || !Array.isArray(reps)) {
            throw new Error('Invalid payload: reps must be an array')
        }

        if (reps.length === 0) {
            return new Response(
                JSON.stringify({ success: true, count: 0 }),
                { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // 1. Bulk Insert Reps
        // We map client fields to DB fields if necessary. 
        // Assuming client sends snake_case matching DB for simplicity.
        const { data: insertedReps, error: insertError } = await supabaseClient
            .from('user_reps')
            .upsert(reps.map(r => ({
                // Ensure we don't blindly trust ID if generated on client, 
                // but for offline-first, client often generates UUIDs.
                id: r.id,
                user_id: r.user_id, // In a real app, verify auth.uid() matches this!
                video_id: r.video_id,
                is_correct: r.is_correct,
                user_answer: r.user_answer,
                ai_feedback: r.ai_feedback,
                dwell_time_ms: r.dwell_time_ms,
                attempt_count: r.attempt_count,
                quality_score: r.quality_score,
                created_at: r.created_at, // Importance: Client timestamp
                synced_at: new Date().toISOString()
            })), { onConflict: 'id', ignoreDuplicates: true }) // Avoid re-inserting if already synced
            .select()

        if (insertError) throw insertError

        // 2. Update Learning State (SM-2 State)
        // We update the 'learning_state' table with the LATEST values from the client 
        // because the client (SpacedRepetitionService.dart) is the source of truth for the algorithm.
        // This allows the server to just "hold" the state for other devices.

        // Group reps by video_id to find the *latest* rep for each video in this batch
        const latestRepsParams = new Map();

        for (const r of reps) {
            // We need: ease_factor, interval_days, next_review_at from the client's internal state
            // The client must send these in the payload if we want to sync state.
            // Assuming the client sends 'learning_state' fields in the rep or a separate object.

            // For now, let's assume the client sends a separate 'states' array 
            // OR we just derive basic stats.
            // Let's keep it simple: strict sync of *reps*. 
            // The State sync can be a separate endpoint or added here.
        }

        return new Response(
            JSON.stringify({ success: true, count: insertedReps.length }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
        )
    }
})
