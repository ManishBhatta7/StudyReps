/**
 * Simple test to generate script + audio
 */
import 'dotenv/config';
import { generateScript } from './gemini-script.js';
import { generateAudio } from './audio-generator.js';
import fs from 'fs';

async function test() {
    console.log('🚀 Testing Script + Audio Generation\n');

    // Step 1: Generate Script
    console.log('Step 1: Generating script with Gemini...');
    const script = await generateScript({
        topic: 'Newton First Law',
        content: 'A body continues in rest or uniform motion unless external force acts. Law of Inertia. Examples: bus stopping, tablecloth trick.',
        difficulty: 1,
    });
    console.log(`✅ Script generated (${script.length} chars)\n`);
    console.log('Preview:', script.substring(0, 200) + '...\n');

    // Save script
    fs.writeFileSync('./output/test_script.txt', script);

    // Step 2: Generate Audio with ElevenLabs
    console.log('Step 2: Converting to audio with ElevenLabs...');
    const audioPath = await generateAudio({
        script,
        outputDir: './output',
        filename: 'test_newton_law.mp3',
    });

    const stats = fs.statSync(audioPath);
    console.log(`✅ Audio generated: ${audioPath}`);
    console.log(`   File size: ${(stats.size / 1024).toFixed(1)} KB\n`);

    console.log('🎉 SUCCESS! Open the MP3 file to listen to the audio.');
}

test().catch(err => {
    console.error('❌ Error:', err.message);
    process.exit(1);
});
