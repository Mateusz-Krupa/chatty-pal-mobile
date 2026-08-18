# Proposal — environment-switch-live

## Why

Switching Environment (Production/Local) or the local Web URL in Settings changes `UserDefaults`, but the live `ChatEngine` and its services (`BotService`, `TeacherService`, `PollySpeechService`, `WhisperTranscriber`) captured `AppEnvironment.webBaseURL` at app launch and keep hitting the old origin until the app is force-quit. On a real device this makes the toggle look broken ("it still hits the same URL").

## What changes

`ChatView` observes `appEnvironment` and `localWebBaseURL` and rebuilds the `ChatEngine` with fresh `.live` dependencies when either changes. Messages survive the rebuild (reloaded from the persisted `LocalChatStore`).

## Impact

Single file: `ChatView.swift`. No behavior change for anything else.
