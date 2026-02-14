/**
 * Veo Video Generation Test
 * Uses Google's Veo model to generate a video clip
 */
import 'dotenv/config';
import { GoogleGenerativeAI } from '@google/generative-ai'; // Note: Veo might use a specific REST endpoint different from standard chat
import fs from 'fs';
import { pipeline } from 'stream/promises';

// We'll use REST API directly for Veo as SDK support varies for beta models
async function generateVeoClip() {
    const apiKey = process.env.GEMINI_API_KEY;
    const url = `https://generativelanguage.googleapis.com/v1beta/models/veo-2.0-generate-001:predict?key=${apiKey}`;

    console.log('🚀 Testing Veo Video Generation...');
    console.log('URL:', url.replace(apiKey, 'HIDDEN_KEY'));

    // Payload for text-to-video
    // Note: The specific schema for Veo varies, attempting standard "predict" format for generative media
    const prompt = "A red soccer ball rolling on green grass, realistic, 4k, cinematic lighting";

    // This is a guess at the beta schema - often it's instances/prompt or input/prompt
    const requestBody = {
        instances: [
            {
                prompt: prompt
            }
        ]
    };

    try {
        // Attempting direct fetch since experimental models often require specific headers/endpoints
        const response = await fetch(url, {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(requestBody)
        });

        if (!response.ok) {
            const errText = await response.text();
            throw new Error(`API Error ${response.status}: ${errText}`);
        }

        const data = await response.json();
        console.log('✅ Response received. Parsing...');

        // Handling response - usually returns base64 video or a signed URL
        // This part depends heavily on the specific Veo API version output format
        if (data.predictions && data.predictions[0] && data.predictions[0].bytesBase64Encoded) {
            const buffer = Buffer.from(data.predictions[0].bytesBase64Encoded, 'base64');
            fs.writeFileSync('./output/veo_test.mp4', buffer);
            console.log('🎉 Video saved to output/veo_test.mp4');
        } else if (data.predictions && data.predictions[0] && data.predictions[0].videoUri) {
            console.log('Video URI received:', data.predictions[0].videoUri);
            // You would download it here
        } else {
            console.log('⚠️ Unexpected response structure:', JSON.stringify(data, null, 2));
        }

    } catch (err) {
        console.error('❌ Failed:', err.message);
    }
}

generateVeoClip();
