# Flutter Run Without Debugger Rule

Always run the Flutter application **without a debugger** on target devices:

1. **Commands to use**:
   - For real devices / wireless ADB: Use `flutter run --release -d <device_id>` or build and install directly:
     ```bash
     flutter build apk --release
     adb install -r build/app/outputs/flutter-apk/app-release.apk
     adb shell am start -n com.example.jstack_assignment/.MainActivity
     ```
   - Never use standard debug mode (`flutter run` without `--release`) on physical devices over wireless ADB, as the Dart VM Service / observatory port forwarding blocks and causes connection failures.

2. **IDE Configurations**:
   - Always ensure `.vscode/launch.json` has `"noDebug": true` and `"flutterMode": "release"`.
