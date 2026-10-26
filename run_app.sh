#!/bin/bash
# ==============================================================================
# Script to run jWallet Lite permanently without Dart VM debugger attached
# Usage:
#   ./run_app.sh          -> Runs in Release mode (Fastest, zero debugger, sharp text)
#   ./run_app.sh debug    -> Builds & launches Debug APK directly (No debugger attached)
# ==============================================================================

set -e

# Automatically map mock backend port to device
echo "🔗 Configuring port forwarding (tcp:3000 -> tcp:3000)..."
adb reverse tcp:3000 tcp:3000 2>/dev/null || true

MODE="${1:-release}"

if [ "$MODE" = "debug" ]; then
    echo "⚡ Building & Installing Debug APK (without attaching debugger)..."
    flutter build apk --debug
    adb install -r build/app/outputs/flutter-apk/app-debug.apk
    echo "🚀 Starting App directly on device..."
    adb shell am start -n com.example.jstack_assignment/.MainActivity
    echo "✅ jWallet Lite is now running on your phone without debugger!"
else
    echo "🚀 Running jWallet Lite in Release mode (No VM Service debugger)..."
    flutter run --release
fi
