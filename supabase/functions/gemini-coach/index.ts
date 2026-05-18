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
        const body = await req.json();
        const action = body.action;

        let requestBody = {};
        
        if (action === 'validateAnswer') {
            const { userAnswer, correctAnswer, questionPrompt, enableThinking, thinkingBudget } = body;
            
            const prompt = `
You are a strict but encouraging logic coach in a learning app. 
The student was asked: "${questionPrompt}"
Their answer: "${userAnswer}"
The correct answer is: "${correctAnswer}"

Give EXACTLY 1 sentence of specific, actionable feedback. No fluff.
Be direct but kind. Focus on WHY they might have gotten it wrong.
`;
            requestBody = {
                contents: [{ parts: [{ text: prompt }] }],
                generationConfig: {
                    temperature: 0.7,
                    maxOutputTokens: 150,
                },
            };
            
            if (enableThinking && thinkingBudget) {
                requestBody.generationConfig.thinkingConfig = {
                    thinkingBudget: thinkingBudget,
                };
            }
        } 
        else if (action === 'generateDynamicQuestion') {
            const { title, subject, creatorName, tags, transcriptSnippet } = body;
            const prompt = `
You are an expert educator. Create a high-quality assessment question for this video clip.
Video Title: "${title}"
Subject: "${subject}"
Creator: "${creatorName}"
Tags: ${tags?.join(', ') || ''}
Transcript Snippet: "${transcriptSnippet}"

REQUIREMENTS:
1. The question must be related to the core concept of this specific clip.
2. Return ONLY a valid JSON object with these fields:
{
  "prompt": "The question text",
  "correctAnswer": "The exact correct answer string",
  "type": "multiple_choice",
  "options": ["Option A", "Option B", "Option C", "Option D"],
  "hint": "A subtle hint for a struggling student",
  "explanation": "A one-sentence explanation of why this is correct"
}
3. One of the "options" MUST be the "correctAnswer".
4. Focus on deep understanding, not just trivia.
`;
            requestBody = {
                contents: [{ parts: [{ text: prompt }] }],
                generationConfig: {
                    temperature: 0.8,
                    maxOutputTokens: 400,
                    responseMimeType: 'application/json',
                },
            };
        }
        else {
            throw new Error(`Unsupported action: ${action}`);
        }

        // Call Gemini API (gemini-2.5-flash for speed/cost and thinking mode)
        const response = await fetch(
            `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`,
            {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(requestBody),
            }
        );

        const data = await response.json();

        if (!response.ok) {
            throw new Error(data.error?.message || 'Gemini API Error');
        }

        return new Response(
            JSON.stringify(data),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
        );
    }
});
