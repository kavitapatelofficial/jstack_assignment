# Flutter Run Without Debugger Rule

Always run the Flutter application **without a debugger** on target devices:

1. **For Debug Build without Debugger**:
   - Build debug APK and install directly via ADB without attaching debugger:
     ```bash
     flutter build apk --debug
     adb install -r build/app/outputs/flutter-apk/app-debug.apk
     adb shell am start -n com.example.jstack_assignment/.MainActivity
     ```
   - In VS Code / IDE: Use configuration `"jWallet Lite (Debug - Without Debugger)"` (`"flutterMode": "debug"`, `"noDebug": true`).

2. **For Release Build without Debugger**:
   - Use `flutter run --release -d <device_id>` or:
     ```bash
     flutter build apk --release
     adb install -r build/app/outputs/flutter-apk/app-release.apk
     adb shell am start -n com.example.jstack_assignment/.MainActivity
     ```

3. **Why avoid standard debug attach over wireless ADB**:
   - On physical devices (especially Vivo / OriginOS / Android 12) connected over wireless ADB, logcat reader drops packets, causing `Error waiting for a debug connection: The log reader stopped unexpectedly`. Running debug without debugger avoids this completely.
