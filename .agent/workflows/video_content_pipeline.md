---
description: How to add new video content to the StudyReps feed via Supabase
---

# Video Content Pipeline

This workflow describes how to add new educational videos (e.g., generated from NotebookLM) to the StudyReps app without modifying the code. The app is configured to fetch content dynamically from the Supabase database.

## Prerequisites
- Access to the Supabase Project Dashboard
- A video file (MP4) to upload (e.g., output from NotebookLM video overview)

## Step 1: Upload Video to Storage
1. Go to **Supabase Dashboard** > **Storage**.
2. Create a bucket named `educational_videos` (if not exists) and ensure it's Public.
3. Upload your `.mp4` video file.
4. Click **Get Public URL** and copy the link.
   - Example: `https://xyz.supabase.co/storage/v1/object/public/educational_videos/force_intro.mp4`

## Step 2: Add Metadata to Database
1. Go to **Supabase Dashboard** > **Table Editor**.
2. Open the `educational_content` table.
3. Click **Insert Row**.
4. Fill in the fields:
   - **title**: "What is Force? — Introduction"
   - **subject**: "Physics"
   - **video_url**: Paste the Public URL from Step 1.
   - **difficulty_level**: 1 (Beginner) to 5 (Advanced).
   - **creator_name**: "StudyReps AI" or your name.
   - **topic_id**: `force_intro` (unique identifier for topic clustering).
   - **question**: (Optional) JSON object for the interactive gate.
     ```json
     {
       "id": "q1",
       "prompt": "What is the unit of Force?",
       "type": "multiple_choice",
       "options": ["Newton", "Joule", "Watt"],
       "correctAnswer": "Newton",
       "explanation": "Force is measured in Newtons."
     }
     ```
5. Click **Save**.

## Step 3: Verify in App
1. Open the StudyReps app.
2. Pull down to refresh the feed (or restart the app).
3. The new video will appear in the feed automatically, prioritizing new content!

## Troubleshooting
- **Video not loading?** Ensure the Storage bucket is Public.
- **Not appearing?** Check if `educational_content` table has Row Level Security (RLS) policies allowing `SELECT` for anon/authenticated users.
