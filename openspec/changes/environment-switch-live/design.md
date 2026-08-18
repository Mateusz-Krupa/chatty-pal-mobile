# Design — environment-switch-live

`ChatView` gains two `@AppStorage` properties mirroring the settings keys (`appEnvironment`, `localWebBaseURL`) and `onChange` handlers that rebuild the engine:

```swift
private func rebuildEngine() {
    engine = ChatEngine(
        persona: .main(language: LanguageConfig.all[langCode] ?? LanguageConfig.default, level: level),
        store: LocalChatStore(languageCode: langCode, level: level),
        dependencies: .live   // re-reads AppEnvironment.webBaseURL at init
    )
}
```

- `ChatEngine.init` already reloads persisted messages, so conversation history survives.
- In-flight tasks of the old engine die with it (weak-self tasks).
- Voice state resets to idle — acceptable for a deliberate environment switch.
