/**
 * Video Analyzer - Gemini Vision Pipeline
 * 
 * 1. Downloads video from YouTube (or takes local file).
 * 2. Uploads to Gemini File Manager.
 * 3. Asks Gemini to "watch" the video and generate "The Lock" metadata.
 */

import 'dotenv/config';
import fs from 'fs';
import path from 'path';
import { GoogleGenerativeAI } from '@google/generative-ai';
import { GoogleAIFileManager } from '@google/generative-ai/server';
import ytdl from '@distube/ytdl-core'; // Correct import for distube version? Actually typically 'ytdl-core' but mapped.
// Commonjs vs ESM: @distube/ytdl-core handles ESM.

const API_KEY = process.env.GEMINI_API_KEY;
const genAI = new GoogleGenerativeAI(API_KEY);
const fileManager = new GoogleAIFileManager(API_KEY);

const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

/**
 * Main Analyzer Function
 */
export async function analyzeVideo(videoSource) {
    console.log(`👁️ Analyzing video: ${videoSource}`);

    let filePath = videoSource;
    let isTempFile = false;

    // 1. Download if URL
    if (videoSource.startsWith('http')) {
        console.log('⬇️ Downloading from YouTube...');
        filePath = await downloadVideo(videoSource);
        isTempFile = true;
        console.log(`✅ Downloaded to: ${filePath}`);
    }

    // 2. Upload to Gemini
    console.log('KX Uploading to Gemini Vision...');
    const uploadResult = await fileManager.uploadFile(filePath, {
        mimeType: "video/mp4",
        displayName: "StudyReps Video",
    });

    // Wait for processing
    let file = await fileManager.getFile(uploadResult.file.name);
    while (file.state === "PROCESSING") {
        process.stdout.write(".");
        await new Promise((resolve) => setTimeout(resolve, 2000));
        file = await fileManager.getFile(uploadResult.file.name);
    }
    console.log(`\n✅ Video processed by Gemini: ${file.uri}`);

    // 3. Analyze content
    console.log('🧠 Gemini is watching the video...');

    const prompt = `
    You are an expert physics teacher designing an interactive video lesson.
    Watch this video carefully.
    
    1. Identify the CORE concept being explained.
    2. Find the perfect moment (timestamp in seconds) to PAUSE the video and ask a question ("The Lock").
       - The timestamp should be right AFTER the concept is introduced but BEFORE the final conclusion/result if possible, or at a cliffhanger.
       - Or simply at a key moment 50-70% through the video.
    3. detailed Question: Create a multiple-choice question or fill-in-the-blank based VISUALLY on what is shown.
    
    Return JSON format:
    {
      "title": "Catchy Short Title",
      "summary": "1 sentence study summary",
      "lockTimestamp": 45,
      "question": {
         "type": "multiple_choice",
         "prompt": "Why did the ball apple fall?",
         "options": ["Gravity", "Magic", "Magnetism", "Wind"],
         "correctAnswer": "Gravity",
         "explanation": "Gravity pulls objects to Earth..."
      }
    }
    RETURN JSON ONLY.
    `;

    const result = await model.generateContent([
        {
            fileData: {
                mimeType: file.mimeType,
                fileUri: file.uri
            }
        },
        { text: prompt }
    ]);

    const responseText = result.response.text();
    // Clean JSON
    const jsonStr = responseText.replace(/```json/g, '').replace(/```/g, '').trim();
    const data = JSON.parse(jsonStr);

    console.log('\n✨ Analysis Complete! ✨');
    console.log(data);

    // Cleanup
    if (isTempFile) {
        fs.unlinkSync(filePath);
    }
    await fileManager.deleteFile(uploadResult.file.name);

    return data;
}

async function downloadVideo(url) {
    const output = path.join('temp', `yt_${Date.now()}.mp4`);
    if (!fs.existsSync('temp')) fs.mkdirSync('temp');

    return new Promise((resolve, reject) => {
        const stream = ytdl(url, { quality: '18' }); // 18 is usually 360p mp4 (good enough for AI analysis and fast)
        stream.pipe(fs.createWriteStream(output));
        stream.on('end', () => resolve(output));
        stream.on('error', reject);
    });
}

// CLI Support
if (process.argv[1] === import.meta.url || process.argv[1].endsWith('analyze-video.js')) {
    const url = process.argv[2];
    if (!url) {
        console.log("Usage: node src/analyze-video.js <youtube_url_or_file>");
    } else {
        analyzeVideo(url);
    }
}
