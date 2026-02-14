# StudyReps Automated Content Pipeline

This tool automatically converts PDF content into video content for your app.

## Pipeline Overview

```
PDF Text → Gemini (Script) → TTS (Audio) → Remotion (Video) → Supabase (Upload)
```

## Setup

```bash
cd tools/content-pipeline
npm install
```

## Required API Keys

Create a `.env` file:

```env
GEMINI_API_KEY=your_gemini_key
GOOGLE_TTS_API_KEY=your_google_tts_key  # Optional: for Google TTS
ELEVENLABS_API_KEY=your_elevenlabs_key  # Optional: for ElevenLabs
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_KEY=your_service_key
```

## Usage

```bash
# Generate content for a single topic
npm run generate -- --topic "Newton's First Law" --content "A body continues..."

# Generate from JSON config
npm run generate -- --config topics.json

# Generate entire chapter from PDF text
npm run generate-chapter -- --input force_chapter.txt
```

## Files

- `src/pipeline.js` - Main orchestrator
- `src/gemini-script.js` - Script generation with Gemini
- `src/audio-generator.js` - TTS audio generation
- `src/video-generator.js` - Remotion video rendering
- `src/uploader.js` - Supabase upload

