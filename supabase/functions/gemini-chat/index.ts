import "https://deno.land/x/xhr@0.3.0/mod.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY')!;

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders });
    }

    try {
        const { message, contextFiles } = await req.json();

        // Construct the prompt with context
        let prompt = `You are the 'StudyReps Coach', a helpful, encouraging, and Socratic AI tutor.
    The student is using the StudyReps app to learn through spaced repetition and active recall.
    
    Your Goals:
    1. Help the student understand the concept, not just give the answer.
    2. Be concise. Mobile screens are small.
    3. Use emojis occasionally to keep the tone light and engaging.
    4. If the student is frustrated, be empathetic.
    
    Student's Message: "${message}"`;

        if (contextFiles && contextFiles.length > 0) {
            prompt += `\n\nRelevant Context ( Video Info / Transcript / Previous Attempts ):\n${contextFiles.join('\n')}`;
        }

        // Call Gemini API (gemini-1.5-flash for speed/cost)
        const response = await fetch(
            `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`,
            {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    contents: [{
                        parts: [{ text: prompt }]
                    }]
                }),
            }
        );

        const data = await response.json();

        if (!response.ok) {
            throw new Error(data.error?.message || 'Gemini API Error');
        }

        // Extract text from response
        const generatedText = data.candidates?.[0]?.content?.parts?.[0]?.text || "I'm having trouble thinking right now. Try again later!";

        return new Response(
            JSON.stringify({ response: generatedText }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
        );
    }
});
