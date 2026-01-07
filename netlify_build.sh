#!/bin/bash
set -e

echo "📦 Setting up Flutter..."

# Use cached Flutter if available
if [ ! -d "flutter" ]; then
  echo "⬇️ Cloning Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable
else
  echo "✅ Flutter SDK already exists, reusing cache"
fi

export PATH="$PATH:`pwd`/flutter/bin"

flutter --version

echo "🌐 Enabling Flutter Web..."
flutter config --enable-web

echo "📦 Getting dependencies..."
flutter pub get

echo "🏗 Building Flutter Web..."
flutter build web --release
