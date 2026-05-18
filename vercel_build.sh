#!/bin/bash
set -e

echo "--- Step 1: Creating .env file from Vercel environment variables ---"
cat > .env << EOF
SUPABASE_URL=${SUPABASE_URL}
SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
GEMINI_API_KEY=${GEMINI_API_KEY}
ELEVENLABS_API_KEY=${ELEVENLABS_API_KEY}
EOF
echo ".env file created successfully"

echo "--- Step 2: Cloning Flutter (stable, shallow) ---"
git clone https://github.com/flutter/flutter.git -b stable --depth=1

echo "--- Step 3: Adding Flutter to PATH ---"
export PATH="$PATH:`pwd`/flutter/bin"

echo "--- Step 4: Flutter version ---"
flutter --version

echo "--- Step 5: Getting dependencies ---"
flutter pub get

echo "--- Step 6: Building Flutter Web ---"
flutter build web --release --no-wasm-dry-run

echo "--- Build complete! Output in build/web ---"
