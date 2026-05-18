#!/bin/bash
set -e

echo "Cloning Flutter..."
git clone https://github.com/flutter/flutter.git -b stable --depth=1

echo "Adding Flutter to PATH..."
export PATH="$PATH:`pwd`/flutter/bin"

echo "Checking Flutter version..."
flutter --version

echo "Getting dependencies..."
flutter pub get

echo "Building Flutter Web..."
flutter build web --release --no-wasm-dry-run

echo "Build complete! Output in build/web"
