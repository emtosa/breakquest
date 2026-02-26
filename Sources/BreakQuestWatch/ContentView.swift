import SwiftUI

struct ContentView: View {
    @AppStorage("bq_loot_count") private var lootCount: Int = 0
    @AppStorage("bq_sessions") private var sessions: Int = 0
    @State private var breathScale: CGFloat = 1.0
    @State private var phase: String = "Breathe"

    var body: some View {
        VStack(spacing: 6) {
            Text("🧙 Break Quest")
                .font(.headline)
            Circle()
                .fill(.blue.opacity(0.3))
                .frame(width: 50, height: 50)
                .scaleEffect(breathScale)
                .overlay(Text(phase).font(.caption2))
                .onAppear {
                    withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        breathScale = 1.4
                    }
                }
            HStack {
                Label("\(sessions)", systemImage: "timer")
                Label("\(lootCount)", systemImage: "crown.fill")
                    .foregroundStyle(.yellow)
            }
            .font(.caption)
        }
        .padding()
    }
}

#Preview { ContentView() }
