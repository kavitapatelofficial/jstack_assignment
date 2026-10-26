.PHONY: run run-debug test analyze

# Run in Release mode (No VM debugger, maximum performance, crisp typography)
run:
	adb reverse tcp:3000 tcp:3000 2>/dev/null || true
	flutter run --release

# Run in Debug mode without attaching the debugger
run-debug:
	adb reverse tcp:3000 tcp:3000 2>/dev/null || true
	flutter build apk --debug
	adb install -r build/app/outputs/flutter-apk/app-debug.apk
	adb shell am start -n com.example.jstack_assignment/.MainActivity

test:
	flutter test

analyze:
	flutter analyze
