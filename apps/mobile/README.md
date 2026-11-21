# Flutter Android – Offline-Task-MVP (unverified)

This is a first vertical slice: text entry, persistent local SQLite tasks, completion toggle, and task list. No network, microphone, cloud account, or personal test data are required.

Prerequisites: Flutter SDK with Android toolchain. From `apps/mobile`, run `flutter pub get`, `flutter analyze`, `flutter test`, then `flutter build apk --debug`. Android platform scaffolding must first be generated with `flutter create --platforms=android .` if the `android/` directory is absent. Do not claim the APK is ready until these commands pass.

Limitations: no scheduler integration, speech recognition, notifications, encryption, migration tests, or Android device acceptance yet. Text input is the deliberate offline fallback. This MVP is independent from the Python backend and uses its own SQLite schema; schema convergence/synchronization is still to be designed.
