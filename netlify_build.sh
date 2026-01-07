#!/bin/bash
set -e

echo "📦 Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

flutter --version
flutter doctor

echo "🌐 Enabling Flutter Web..."
flutter config --enable-web

echo "📦 Getting dependencies..."
flutter pub get

echo "🏗 Building Flutter Web..."
flutter build web --release
