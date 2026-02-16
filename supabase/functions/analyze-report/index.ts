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
        const { image, filename } = await req.json();

        if (!image) {
            throw new Error("No image provided");
        }

        // Simple MIME type detection based on extension
        let mimeType = "image/jpeg";
        if (filename.toLowerCase().endsWith(".png")) mimeType = "image/png";
        if (filename.toLowerCase().endsWith(".webp")) mimeType = "image/webp";

        const prompt = `Analyze this image (filename: ${filename}). 
    
    1. **If it's a Report Card**:
       - Extract the subjects and grades.
       - Identify any subjects with grades below B (or < 80%).
       - Suggest specific topics to focus on based on teacher comments if visible.
    
    2. **If it's a Problem/Homework**:
       - Identify the subject (e.g., Algebra, Calculus, Physics).
       - Isolate the core concept being tested.
       - Provide a hint (Socratic method) rather than the solution.
    
    Format the output as a clear innovative markdown summary.`;

        const response = await fetch(
            `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`,
            {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    contents: [{
                        parts: [
                            { text: prompt },
                            {
                                inline_data: {
                                    mime_type: mimeType,
                                    data: image
                                }
                            }
                        ]
                    }]
                }),
            }
        );

        const data = await response.json(); // Gemini API returns strict JSON

        if (!response.ok) {
            throw new Error(data.error?.message || 'Gemini Vision API Error');
        }

        const generatedText = data.candidates?.[0]?.content?.parts?.[0]?.text || "I see the image, but I'm not sure what to make of it.";

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
