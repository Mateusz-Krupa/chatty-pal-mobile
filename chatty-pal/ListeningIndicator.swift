import SwiftUI

struct ListeningIndicator: View {
    let transcript: String
    let level: Float

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(transcript.isEmpty ? "Listening..." : transcript)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.red.opacity(0.15))
                Capsule()
                    .fill(Color.red)
                    .frame(width: max(4, CGFloat(level) * 150))
            }
            .frame(height: 4)
        }
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
