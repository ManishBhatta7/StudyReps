/**
 * Enhanced Video Generator with Image Slideshow
 * 
 * Creates educational videos with:
 * - AI-generated educational images as slideshow
 * - Audio narration
 * - Smooth transitions between images
 */

import 'dotenv/config';
import fs from 'fs';
import path from 'path';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

/**
 * Generate a video from images and audio
 * Creates a slideshow with the images synced to audio duration
 */
export async function generateSlideshowVideo({
    imagePaths, // Array of image paths
    audioPath,
    topic,
    outputDir = './output',
    filename = 'video.mp4',
}) {
    // Ensure output directory exists
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
    }

    const outputPath = path.join(outputDir, filename);

    // Get audio duration
    let audioDuration = 120;
    try {
        const durationCmd = `ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${audioPath}"`;
        const { stdout } = await execAsync(durationCmd);
        audioDuration = parseFloat(stdout.trim());
        console.log(`📏 Audio duration: ${audioDuration.toFixed(1)} seconds`);
    } catch (error) {
        console.warn('⚠️ Could not read audio duration');
    }

    // Calculate duration per image
    const numImages = imagePaths.length;
    const durationPerImage = audioDuration / numImages;
    console.log(`🖼️ ${numImages} images, ${durationPerImage.toFixed(1)}s each`);

    // Resize images to 1080x1920 (9:16 vertical) and create slideshow
    // First, create a concat file for FFmpeg
    const concatFilePath = path.resolve(outputDir, 'concat.txt');
    let concatContent = '';

    for (let i = 0; i < imagePaths.length; i++) {
        // Use absolute paths for FFmpeg concat
        const absImgPath = path.resolve(imagePaths[i]).replace(/\\/g, '/');
        concatContent += `file '${absImgPath}'\n`;
        concatContent += `duration ${durationPerImage}\n`;
    }
    // Repeat last image (FFmpeg quirk)
    const lastAbsPath = path.resolve(imagePaths[imagePaths.length - 1]).replace(/\\/g, '/');
    concatContent += `file '${lastAbsPath}'\n`;

    fs.writeFileSync(concatFilePath, concatContent);

    // FFmpeg command to create slideshow with audio
    // Scale and pad images to fit 1080x1920 (9:16)
    const ffmpegCmd = `ffmpeg -y -f concat -safe 0 -i "${concatFilePath}" -i "${audioPath}" -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=0F172A,format=yuv420p" -c:v libx264 -preset medium -crf 23 -c:a aac -b:a 128k -shortest "${outputPath}"`;

    console.log('🎬 Creating slideshow video...');

    try {
        await execAsync(ffmpegCmd, { maxBuffer: 50 * 1024 * 1024 });

        // Clean up concat file
        fs.unlinkSync(concatFilePath);

        const stats = fs.statSync(outputPath);
        console.log(`✅ Video created: ${outputPath}`);
        console.log(`   File size: ${(stats.size / 1024 / 1024).toFixed(2)} MB`);
        return outputPath;
    } catch (error) {
        console.error('FFmpeg error:', error.message);
        throw new Error(`Video generation failed: ${error.message}`);
    }
}

/**
 * Generate a video with Ken Burns effect (zoom/pan on images)
 */
export async function generateKenBurnsVideo({
    imagePaths,
    audioPath,
    outputDir = './output',
    filename = 'video.mp4',
}) {
    const outputPath = path.join(outputDir, filename);

    // Get audio duration
    let audioDuration = 120;
    try {
        const durationCmd = `ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${audioPath}"`;
        const { stdout } = await execAsync(durationCmd);
        audioDuration = parseFloat(stdout.trim());
    } catch (error) {
        console.warn('⚠️ Could not read audio duration');
    }

    const numImages = imagePaths.length;
    const durationPerImage = audioDuration / numImages;

    // Create input arguments for all images
    const inputArgs = imagePaths.map(img => `-loop 1 -t ${durationPerImage} -i "${img}"`).join(' ');

    // Create filter for Ken Burns effect with zoom
    const filterParts = [];
    for (let i = 0; i < numImages; i++) {
        // Alternate between zoom in and zoom out
        const zoomDirection = i % 2 === 0 ? 'zoom+0.001' : 'zoom-0.001';
        filterParts.push(`[${i}:v]scale=1920:1920,zoompan=z='min(1.5,${zoomDirection})':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=${Math.floor(durationPerImage * 25)}:s=1080x1920:fps=25[v${i}]`);
    }

    // Concatenate all videos
    const concatInputs = imagePaths.map((_, i) => `[v${i}]`).join('');
    const filterComplex = `${filterParts.join(';')};${concatInputs}concat=n=${numImages}:v=1:a=0[outv]`;

    const ffmpegCmd = `ffmpeg -y ${inputArgs} -i "${audioPath}" -filter_complex "${filterComplex}" -map "[outv]" -map ${numImages}:a -c:v libx264 -preset fast -crf 23 -c:a aac -b:a 128k -shortest "${outputPath}"`;

    console.log('🎬 Creating Ken Burns video...');

    try {
        await execAsync(ffmpegCmd, { maxBuffer: 50 * 1024 * 1024 });
        return outputPath;
    } catch (error) {
        // Fallback to simple slideshow
        console.warn('⚠️ Ken Burns failed, using simple slideshow');
        return await generateSlideshowVideo({ imagePaths, audioPath, outputDir, filename });
    }
}

// Test function
if (process.argv.includes('--test')) {
    console.log('Testing Enhanced Video Generator...\n');

    const imagePaths = [
        './output/image_01.png',
        './output/image_02.png',
        './output/image_03.png',
    ];

    const audioPath = './output/newton_first_law.mp3';

    if (!fs.existsSync(audioPath)) {
        console.log('❌ Audio file not found. Run test-full-pipeline.js first.');
        process.exit(1);
    }

    // Check images exist
    const existingImages = imagePaths.filter(img => fs.existsSync(img));
    if (existingImages.length === 0) {
        console.log('❌ No images found.');
        process.exit(1);
    }

    console.log(`Found ${existingImages.length} images`);

    try {
        const videoPath = await generateSlideshowVideo({
            imagePaths: existingImages,
            audioPath,
            topic: 'Newton First Law',
            outputDir: './output',
            filename: 'newton_with_visuals.mp4',
        });

        console.log('\n🎉 SUCCESS!');
        console.log(`Video with visuals: ${videoPath}`);
    } catch (error) {
        console.error('❌ Error:', error.message);
    }
}
