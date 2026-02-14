/**
 * Complete Pipeline Test
 * Generates: Script → Audio → Video
 */
import 'dotenv/config';
import fs from 'fs';
import { generateScript } from './gemini-script.js';
import { generateAudio } from './audio-generator.js';
import { generateVideo } from './video-generator.js';

async function runPipeline() {
    const topic = 'Newton First Law - Inertia';
    const content = `
    A body continues in its state of rest or uniform motion in a straight line unless an external force acts on it.
    This is called the Law of Inertia.
    Examples: passenger lurching forward when bus stops, tablecloth trick, spacecraft moving in space.
  `;

    console.log('🚀 StudyReps Content Pipeline\n');
    console.log(`📚 Topic: ${topic}\n`);
    console.log('━'.repeat(50));

    // Step 1: Generate Script
    console.log('\n📝 Step 1: Generating script with Gemini AI...');
    const startScript = Date.now();
    const script = await generateScript({ topic, content, difficulty: 1 });
    const scriptTime = ((Date.now() - startScript) / 1000).toFixed(1);
    console.log(`   ✅ Script generated (${script.length} chars) in ${scriptTime}s`);

    // Save script
    fs.writeFileSync('./output/newton_first_law_script.txt', script);
    console.log('   📄 Script saved to: output/newton_first_law_script.txt');

    // Step 2: Generate Audio
    console.log('\n🎙️ Step 2: Converting to audio with ElevenLabs TTS...');
    const startAudio = Date.now();
    const audioPath = await generateAudio({
        script,
        outputDir: './output',
        filename: 'newton_first_law.mp3',
    });
    const audioTime = ((Date.now() - startAudio) / 1000).toFixed(1);
    const audioSize = (fs.statSync(audioPath).size / 1024 / 1024).toFixed(2);
    console.log(`   ✅ Audio generated (${audioSize} MB) in ${audioTime}s`);
    console.log(`   🔊 Audio saved to: ${audioPath}`);

    // Step 3: Generate Video
    console.log('\n🎬 Step 3: Creating video with FFmpeg...');
    const startVideo = Date.now();
    const videoPath = await generateVideo({
        audioPath,
        topic,
        outputDir: './output',
        filename: 'newton_first_law.mp4',
    });
    const videoTime = ((Date.now() - startVideo) / 1000).toFixed(1);
    const videoSize = (fs.statSync(videoPath).size / 1024 / 1024).toFixed(2);
    console.log(`   ✅ Video generated (${videoSize} MB) in ${videoTime}s`);
    console.log(`   🎥 Video saved to: ${videoPath}`);

    // Summary
    console.log('\n' + '━'.repeat(50));
    console.log('🎉 PIPELINE COMPLETE!\n');
    console.log('📦 Generated Files:');
    console.log(`   📄 Script: output/newton_first_law_script.txt`);
    console.log(`   🔊 Audio:  output/newton_first_law.mp3 (${audioSize} MB)`);
    console.log(`   🎥 Video:  output/newton_first_law.mp4 (${videoSize} MB)`);
    console.log('\n⏱️ Total Time:', ((Date.now() - startScript) / 1000).toFixed(1) + 's');
    console.log('\n💡 Open the video file to watch your educational content!');
}

runPipeline().catch(err => {
    console.error('\n❌ Pipeline Error:', err.message);
    process.exit(1);
});
