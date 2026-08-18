import SwiftUI

struct PlaceholderView: View {
    let title: String

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.title2.weight(.semibold))
            Text("Placeholder page")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ChattyTheme.appBackground)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsSheet: View {
    @AppStorage("langCode") private var langCode: String = "de"
    @AppStorage("level") private var level: String = "B1"
    @AppStorage("appEnvironment") private var appEnvironment: String = AppEnvironmentMode.production.rawValue
    @AppStorage("localWebBaseURL") private var localWebBaseURL: String = AppEnvironment.defaultLocalWebBaseURL
    @AppStorage("localCMSAPIBaseURL") private var localCMSAPIBaseURL: String = AppEnvironment.defaultLocalCMSAPIBaseURL
    @AppStorage("voiceTranscriptionMode") private var voiceTranscriptionMode: String = VoiceTranscriptionMode.local.rawValue

    var body: some View {
        NavigationStack {
            Form {
                Section("Server") {
                    Picker("Environment", selection: $appEnvironment) {
                        ForEach(AppEnvironmentMode.allCases) { mode in
                            Text(mode.title).tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)

                    if appEnvironment == AppEnvironmentMode.local.rawValue {
                        TextField("Web URL", text: $localWebBaseURL)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                        TextField("CMS API URL", text: $localCMSAPIBaseURL)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                        Text("On a real iPhone, use your Mac's LAN IP, for example http://192.168.1.20:3000 and http://192.168.1.20:1337/api.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        LabeledContent("Web", value: AppEnvironment.productionWebBaseURL.absoluteString)
                        LabeledContent("CMS", value: AppEnvironment.productionCMSAPIBaseURL.absoluteString)
                    }
                }

                Section("Voice input") {
                    Picker("Transcription", selection: $voiceTranscriptionMode) {
                        ForEach(VoiceTranscriptionMode.allCases) { mode in
                            Text(mode.title).tag(mode.rawValue)
                        }
                    }
                    Text("On-device is instant but weaker on accented speech. Cloud Whisper is more accurate but adds 1-3s.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Practice") {
                    Picker("Language", selection: $langCode) {
                        ForEach(LanguageConfig.sorted) { language in
                            Text(language.language).tag(language.code)
                        }
                    }

                    Picker("Level", selection: $level) {
                        ForEach(LanguageConfig.levels, id: \.self) { lvl in
                            Text(lvl).tag(lvl)
                        }
                    }
                }

                Section("Current persona") {
                    let l = LanguageConfig.all[langCode] ?? LanguageConfig.default
                    LabeledContent("Voice", value: l.voice)
                    LabeledContent("Country", value: l.country)
                    LabeledContent("Speech locale", value: l.speechLocale)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

