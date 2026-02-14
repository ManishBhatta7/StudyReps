/**
 * Upload Test Script
 */
import 'dotenv/config';
import { uploadToSupabase } from './uploader.js';
import fs from 'fs';
import path from 'path';

async function uploadVideo() {
    const videoPath = './output/newton_with_visuals.mp4';

    if (!fs.existsSync(videoPath)) {
        console.error('❌ Video file not found at:', videoPath);
        return;
    }

    console.log('🚀 Uploading video to Supabase...');
    console.log(`Using credentials for: ${process.env.SUPABASE_URL}`);

    try {
        const url = await uploadToSupabase({
            filePath: videoPath,
            bucket: 'videos', // Assuming standard public bucket name
            path: 'force_chapter/newton_first_law_visuals.mp4',
        });

        console.log('\n✅ Upload Successful!');
        console.log(`🌍 Public URL: ${url}`);
    } catch (error) {
        console.error('\n❌ Upload Error:', error.message);
        console.log('\nNote: If this is a permissions error, you need to allow Public uploads in Supabase Storage policies or set SUPABASE_SERVICE_KEY in .env');
    }
}

uploadVideo();
