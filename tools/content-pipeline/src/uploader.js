/**
 * Supabase Uploader
 * 
 * Uploads generated videos to Supabase Storage
 * and returns the public URL for use in the app.
 */

import 'dotenv/config';
import fs from 'fs';
import path from 'path';
import { createClient } from '@supabase/supabase-js';

// Initialize Supabase client
// Fallback to Anon Key if Service Key is placeholder
const serviceKey = process.env.SUPABASE_SERVICE_KEY && !process.env.SUPABASE_SERVICE_KEY.startsWith('YOUR_')
    ? process.env.SUPABASE_SERVICE_KEY
    : process.env.SUPABASE_ANON_KEY;

const supabase = createClient(
    process.env.SUPABASE_URL,
    serviceKey
);

/**
 * Upload a file to Supabase Storage
 * @param {Object} options - Upload options
 * @param {string} options.filePath - Local file path
 * @param {string} options.bucket - Supabase storage bucket name
 * @param {string} options.path - Path within the bucket
 * @returns {Promise<string>} - Public URL of uploaded file
 */
export async function uploadToSupabase({
    filePath,
    bucket = 'studyreps-videos',
    path: storagePath,
}) {
    // Ensure bucket exists
    const { data: buckets } = await supabase.storage.listBuckets();
    const bucketExists = buckets?.some(b => b.name === bucket);

    if (!bucketExists) {
        console.log(`📦 Creating bucket: ${bucket}`);
        const { error } = await supabase.storage.createBucket(bucket, {
            public: true,
            fileSizeLimit: 52428800, // 50MB
            allowedMimeTypes: ['video/mp4', 'video/webm', 'audio/mpeg', 'image/jpeg', 'image/png'],
        });

        if (error) {
            console.warn(`⚠️ Bucket creation warning: ${error.message}`);
        }
    }

    // Read file
    const fileBuffer = fs.readFileSync(filePath);
    const fileName = path.basename(filePath);
    const contentType = getContentType(fileName);

    // Upload file
    const { data, error } = await supabase.storage
        .from(bucket)
        .upload(storagePath, fileBuffer, {
            contentType,
            upsert: true, // Overwrite if exists
        });

    if (error) {
        throw new Error(`Upload failed: ${error.message}`);
    }

    // Get public URL
    const { data: urlData } = supabase.storage
        .from(bucket)
        .getPublicUrl(storagePath);

    return urlData.publicUrl;
}

/**
 * Upload multiple files in batch
 * @param {Array<Object>} files - Array of {filePath, path} objects
 * @param {string} bucket - Bucket name
 * @returns {Promise<Array<Object>>} - Array of {path, url} objects
 */
export async function uploadBatch(files, bucket = 'studyreps-videos') {
    const results = [];

    for (const file of files) {
        try {
            const url = await uploadToSupabase({
                filePath: file.filePath,
                bucket,
                path: file.path,
            });
            results.push({ path: file.path, url, success: true });
        } catch (error) {
            results.push({ path: file.path, error: error.message, success: false });
        }
    }

    return results;
}

/**
 * Delete a file from Supabase Storage
 * @param {string} path - Path to file in bucket
 * @param {string} bucket - Bucket name
 */
export async function deleteFromSupabase(path, bucket = 'studyreps-videos') {
    const { error } = await supabase.storage
        .from(bucket)
        .remove([path]);

    if (error) {
        throw new Error(`Delete failed: ${error.message}`);
    }
}

/**
 * List all files in a folder
 * @param {string} folder - Folder path
 * @param {string} bucket - Bucket name
 */
export async function listFiles(folder, bucket = 'studyreps-videos') {
    const { data, error } = await supabase.storage
        .from(bucket)
        .list(folder);

    if (error) {
        throw new Error(`List failed: ${error.message}`);
    }

    return data;
}

/**
 * Get content type from filename
 */
function getContentType(filename) {
    const ext = path.extname(filename).toLowerCase();
    const types = {
        '.mp4': 'video/mp4',
        '.webm': 'video/webm',
        '.mp3': 'audio/mpeg',
        '.wav': 'audio/wav',
        '.jpg': 'image/jpeg',
        '.jpeg': 'image/jpeg',
        '.png': 'image/png',
    };
    return types[ext] || 'application/octet-stream';
}

/**
 * Generate a signed URL for private files
 * @param {string} path - File path
 * @param {number} expiresIn - Expiration in seconds
 */
export async function getSignedUrl(path, expiresIn = 3600, bucket = 'studyreps-videos') {
    const { data, error } = await supabase.storage
        .from(bucket)
        .createSignedUrl(path, expiresIn);

    if (error) {
        throw new Error(`Signed URL failed: ${error.message}`);
    }

    return data.signedUrl;
}

// Test function
if (process.argv.includes('--test')) {
    console.log('Testing Supabase Uploader...\n');

    if (!process.env.SUPABASE_URL || !process.env.SUPABASE_SERVICE_KEY) {
        console.log('❌ Missing Supabase credentials.');
        console.log('Set SUPABASE_URL and SUPABASE_SERVICE_KEY in .env file.');
    } else {
        console.log('✅ Supabase credentials found.');

        try {
            const files = await listFiles('');
            console.log(`📂 Files in bucket: ${files.length}`);
        } catch (error) {
            console.log(`⚠️ Could not list files: ${error.message}`);
        }
    }
}
