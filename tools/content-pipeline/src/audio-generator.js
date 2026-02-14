/**
 * Audio Generator
 * 
 * Converts text scripts to audio using:
 * - ElevenLabs (preferred - natural voices)
 * - Google Cloud Text-to-Speech (backup)
 * 
 * The generated audio is optimized for educational content.
 */

import 'dotenv/config';
import fs from 'fs';
import path from 'path';

/**
 * Generate audio from script text
 * @param {Object} options - Audio generation options
 * @param {string} options.script - The script text to convert
 * @param {string} options.outputDir - Output directory
 * @param {string} options.filename - Output filename
 * @param {string} options.provider - 'google' or 'elevenlabs'
 * @returns {Promise<string>} - Path to generated audio file
 */
export async function generateAudio({
    script,
    outputDir = './output',
    filename = 'audio.mp3',
    provider = process.env.TTS_PROVIDER || 'elevenlabs'
}) {
    // Ensure output directory exists
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
    }

    const outputPath = path.join(outputDir, filename);

    // Prefer ElevenLabs if API key is available
    if (process.env.ELEVENLABS_API_KEY && (provider === 'elevenlabs' || !process.env.GOOGLE_TTS_API_KEY)) {
        console.log('🎙️ Using ElevenLabs TTS...');
        return await generateWithElevenLabs(script, outputPath);
    } else if (process.env.GOOGLE_TTS_API_KEY) {
        console.log('🔊 Using Google TTS...');
        return await generateWithGoogleTTS(script, outputPath);
    } else {
        console.warn('⚠️ No TTS configured. Creating placeholder audio.');
        return await createPlaceholderAudio(script, outputPath);
    }
}

/**
 * Generate audio using Google Cloud Text-to-Speech
 */
async function generateWithGoogleTTS(script, outputPath) {
    // Check if we have Google Cloud TTS configured
    if (process.env.GOOGLE_TTS_API_KEY || process.env.GOOGLE_APPLICATION_CREDENTIALS) {
        const textToSpeech = await import('@google-cloud/text-to-speech');
        const client = new textToSpeech.TextToSpeechClient();

        const request = {
            input: { text: script },
            voice: {
                languageCode: 'en-IN', // Indian English for ICSE students
                name: 'en-IN-Wavenet-B', // Natural male voice
                ssmlGender: 'MALE',
            },
            audioConfig: {
                audioEncoding: 'MP3',
                speakingRate: 0.95, // Slightly slower for clarity
                pitch: 0,
                volumeGainDb: 0,
            },
        };

        const [response] = await client.synthesizeSpeech(request);
        fs.writeFileSync(outputPath, response.audioContent, 'binary');
        return outputPath;
    }

    // Fallback: Use browser-based TTS or placeholder
    console.warn('⚠️ Google TTS not configured. Creating placeholder audio.');
    return await createPlaceholderAudio(script, outputPath);
}

/**
 * Generate audio using ElevenLabs API
 * More natural, conversational voices
 */
async function generateWithElevenLabs(script, outputPath) {
    const response = await fetch('https://api.elevenlabs.io/v1/text-to-speech/pNInz6obpgDQGcFmaJgB', {
        method: 'POST',
        headers: {
            'Accept': 'audio/mpeg',
            'Content-Type': 'application/json',
            'xi-api-key': process.env.ELEVENLABS_API_KEY,
        },
        body: JSON.stringify({
            text: script,
            model_id: 'eleven_multilingual_v2',
            voice_settings: {
                stability: 0.5,
                similarity_boost: 0.75,
                style: 0.5,
                use_speaker_boost: true,
            },
        }),
    });

    if (!response.ok) {
        throw new Error(`ElevenLabs API error: ${response.statusText}`);
    }

    const audioBuffer = await response.arrayBuffer();
    fs.writeFileSync(outputPath, Buffer.from(audioBuffer));
    return outputPath;
}

/**
 * Create placeholder audio for testing
 * Uses simple text file as placeholder until TTS is configured
 */
async function createPlaceholderAudio(script, outputPath) {
    // Write script to text file for manual TTS conversion
    const textPath = outputPath.replace('.mp3', '_script.txt');
    fs.writeFileSync(textPath, script);

    // Download a sample audio for testing
    // In production, this would be replaced with actual TTS
    const sampleAudioUrl = 'https://www.soundjay.com/misc/sounds/bell-ringing-05.mp3';

    try {
        const fetch = (await import('node-fetch')).default;
        const response = await fetch(sampleAudioUrl);
        const buffer = await response.buffer();
        fs.writeFileSync(outputPath, buffer);
        console.log(`📝 Script saved to: ${textPath}`);
        console.log(`🔊 Placeholder audio saved to: ${outputPath}`);
        return outputPath;
    } catch (error) {
        // Create empty placeholder if download fails
        fs.writeFileSync(outputPath, Buffer.alloc(1024));
        console.log(`📝 Script saved to: ${textPath}`);
        console.log(`⚠️ Empty placeholder audio created at: ${outputPath}`);
        return outputPath;
    }
}

/**
 * Estimate audio duration from word count
 * Average speaking rate: 130-150 words per minute
 */
export function estimateDuration(script) {
    const wordCount = script.split(/\s+/).length;
    const wordsPerMinute = 140;
    const durationMinutes = wordCount / wordsPerMinute;
    return Math.round(durationMinutes * 60); // seconds
}

// Test function
if (process.argv.includes('--test')) {
    console.log('Testing Audio Generator...\n');

    const testScript = `
    Hey there! Today we're going to learn about Newton's First Law of Motion.
    
    Have you ever wondered why you lurch forward when a bus suddenly stops?
    That's inertia in action!
    
    Newton's First Law says that an object at rest stays at rest, 
    and an object in motion stays in motion, unless an external force acts on it.
    
    This is why it's also called the Law of Inertia.
    
    Remember: no force means no change in motion. Pretty cool, right?
  `;

    console.log(`Estimated duration: ${estimateDuration(testScript)} seconds`);

    try {
        const audioPath = await generateAudio({
            script: testScript,
            outputDir: './test-output',
            filename: 'test_audio.mp3',
        });
        console.log(`\nAudio generated at: ${audioPath}`);
    } catch (error) {
        console.error('Test failed:', error.message);
    }
}
