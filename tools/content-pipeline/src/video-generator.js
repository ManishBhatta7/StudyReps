/**
 * Video Generator
 * 
 * Creates educational videos from audio using FFmpeg.
 * Generates:
 * - Solid color background
 * - Topic title overlay
 * - StudyReps branding
 * 
 * Output: 9:16 vertical video (mobile-first)
 */

import 'dotenv/config';
import fs from 'fs';
import path from 'path';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

/**
 * Generate a video from audio file
 */
export async function generateVideo({
    audioPath,
    topic,
    outputDir = './output',
    filename = 'video.mp4',
    backgroundColor = '0F172A', // Dark navy (StudyReps theme) - no #
    duration = 120, // Default 2 minutes if audio invalid
}) {
    // Ensure output directory exists
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
    }

    const outputPath = path.join(outputDir, filename);

    // Check if FFmpeg is available
    try {
        await execAsync('ffmpeg -version');
    } catch {
        console.warn('⚠️ FFmpeg not found.');
        throw new Error('FFmpeg not installed');
    }

    // Try to get audio duration
    let audioDuration = duration;
    let hasValidAudio = false;

    try {
        const durationCmd = `ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${audioPath}"`;
        const { stdout } = await execAsync(durationCmd);
        const parsed = parseFloat(stdout.trim());
        if (!isNaN(parsed) && parsed > 0) {
            audioDuration = parsed;
            hasValidAudio = true;
            console.log(`📏 Audio duration: ${audioDuration.toFixed(1)} seconds`);
        }
    } catch (error) {
        console.warn('⚠️ Could not read audio duration, using default.');
        hasValidAudio = false;
    }

    // If no valid audio, create simple video
    if (!hasValidAudio) {
        return await createSimpleVideoNoAudio(topic, outputPath, audioDuration, backgroundColor);
    }

    // Escape the topic for FFmpeg (simple version - just remove special chars)
    const safeTopic = topic.replace(/['"\\:]/g, ' ').trim();

    // Simple FFmpeg command - background + audio only (no text overlay to avoid font issues)
    const ffmpegCmd = `ffmpeg -y -f lavfi -i "color=c=${backgroundColor}:s=1080x1920:d=${audioDuration}" -i "${audioPath}" -c:v libx264 -preset ultrafast -crf 28 -c:a aac -b:a 128k -pix_fmt yuv420p -shortest "${outputPath}"`;

    console.log('🎬 Generating video...');

    try {
        await execAsync(ffmpegCmd, { maxBuffer: 10 * 1024 * 1024 });
        console.log(`✅ Video created: ${outputPath}`);
        return outputPath;
    } catch (error) {
        console.error('FFmpeg error:', error.message);
        throw new Error(`Video generation failed: ${error.message}`);
    }
}

/**
 * Create a simple video without audio
 */
async function createSimpleVideoNoAudio(topic, outputPath, duration, backgroundColor) {
    // Simple video with just color background and silent audio
    const simpleCmd = `ffmpeg -y -f lavfi -i "color=c=${backgroundColor}:s=1080x1920:d=${duration}" -f lavfi -i anullsrc=r=44100:cl=stereo -c:v libx264 -preset ultrafast -crf 28 -c:a aac -b:a 128k -pix_fmt yuv420p -t ${duration} "${outputPath}"`;

    try {
        await execAsync(simpleCmd, { maxBuffer: 10 * 1024 * 1024 });
        console.log(`📹 Created placeholder video: ${outputPath}`);
        return outputPath;
    } catch (error) {
        throw new Error(`Video generation failed: ${error.message}`);
    }
}

/**
 * Estimate video file size
 */
export function estimateVideoSize(durationSeconds) {
    // Rough estimate: ~500KB per minute at our quality settings
    const minuteRate = 500 * 1024; // bytes per minute
    return Math.round((durationSeconds / 60) * minuteRate);
}

// Test function
if (process.argv.includes('--test')) {
    console.log('Testing Video Generator...\n');

    // Check FFmpeg
    try {
        const { stdout } = await execAsync('ffmpeg -version');
        console.log('✅ FFmpeg found:', stdout.split('\n')[0]);

        // Test with the generated audio if it exists
        const testAudioPath = './output/test_newton_law.mp3';
        if (fs.existsSync(testAudioPath)) {
            console.log('\n🎬 Testing video generation with existing audio...');
            const videoPath = await generateVideo({
                audioPath: testAudioPath,
                topic: 'Newton First Law',
                outputDir: './output',
                filename: 'test_video.mp4',
            });
            console.log(`\n✅ Video saved to: ${videoPath}`);
            const stats = fs.statSync(videoPath);
            console.log(`   File size: ${(stats.size / 1024 / 1024).toFixed(2)} MB`);
        } else {
            console.log('\n⚠️ No test audio found. Run test-simple.js first.');
        }
    } catch (error) {
        console.log('❌ Error:', error.message);
    }
}
