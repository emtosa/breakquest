import XCTest
import SwiftUI
@testable import BreakQuest

@MainActor
final class ScreenshotTests: XCTestCase {

    let outputDir: URL = {
        if let dir = ProcessInfo.processInfo.environment["SCREENSHOTS_DIR"] {
            return URL(fileURLWithPath: dir)
        }
        return URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("AppStore/screenshots/en-US")
    }()

    let sizes: [(CGFloat, CGFloat)] = [(1320, 2868), (1284, 2778), (2064, 2752)]

    func testGenerateScreenshots() throws {
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        for (w, h) in sizes {
            let label = "\(Int(w))x\(Int(h))"
            save(MenuShot(w: w, h: h), w: w, h: h,      name: "01-menu-\(label)")
            save(FocusShot(w: w, h: h), w: w, h: h,     name: "02-focus-\(label)")
            save(BreathShot(w: w, h: h), w: w, h: h,    name: "03-breathe-\(label)")
            save(LootShot(w: w, h: h), w: w, h: h,      name: "04-loot-\(label)")
        }
    }

    private func save(_ view: some View, w: CGFloat = 0, h: CGFloat = 0, name: String) {
        let renderer = ImageRenderer(content: view)
        if w > 0 && h > 0 { renderer.proposedSize = .init(width: w, height: h) }
        renderer.scale = 1.0
        guard let uiImage = renderer.uiImage,
              let data = uiImage.jpegData(compressionQuality: 0.92) else { XCTFail("Render failed: \(name)"); return }
        let url = outputDir.appendingPathComponent("\(name).jpg")
        try? data.write(to: url)
        print("📸 \(url.lastPathComponent)")
    }
}

private struct MenuShot: View {
    let w, h: CGFloat
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red:0.04,green:0.07,blue:0.2), Color(red:0.08,green:0.18,blue:0.35)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: h * 0.04) {
                Spacer()
                Text("🧙").font(.system(size: h * 0.1))
                Text("Break Quest").font(.system(size: h * 0.046, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                Text("Breathe on break. Earn loot. Repeat.").font(.system(size: h * 0.022, design: .rounded)).foregroundStyle(.white.opacity(0.6))
                Spacer()
                Text("BEGIN QUEST").font(.system(size: h * 0.025, weight: .heavy, design: .rounded))
                    .frame(width: w * 0.6, height: h * 0.07)
                    .background(Color.blue).foregroundStyle(.white).clipShape(Capsule())
                Spacer()
            }
        }
    }
}

private struct FocusShot: View {
    let w, h: CGFloat
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red:0.04,green:0.07,blue:0.2), Color(red:0.08,green:0.18,blue:0.35)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                Text("🧙").font(.system(size: h*0.06))
                Text("FOCUS").font(.system(size: h*0.016, weight:.heavy, design:.rounded)).foregroundStyle(.white.opacity(0.5)).padding(.bottom, h*0.02)
                ZStack {
                    Circle().strokeBorder(Color.white.opacity(0.1), lineWidth: 8)
                    Circle().trim(from:0, to:0.72).stroke(Color.blue, style: StrokeStyle(lineWidth:8, lineCap:.round)).rotationEffect(.degrees(-90))
                    Text("17:58").font(.system(size: h*0.06, weight:.heavy, design:.monospaced)).foregroundStyle(.white)
                }
                .frame(width: w*0.55, height: w*0.55)
                Text("Break in 18 min").font(.system(size: h*0.022, design:.rounded)).foregroundStyle(.white.opacity(0.55)).padding(.top, h*0.02)
                Text("🏺 Loot chest awaits…").font(.system(size: h*0.025, weight:.semibold, design:.rounded)).foregroundStyle(.yellow.opacity(0.8)).padding(.top, h*0.01)
                Spacer()
            }
        }
    }
}

private struct BreathShot: View {
    let w, h: CGFloat
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red:0.04,green:0.07,blue:0.2), Color(red:0.08,green:0.18,blue:0.35)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: h*0.03) {
                Spacer()
                Text("BREAK TIME").font(.system(size: h*0.018, weight:.heavy, design:.rounded)).foregroundStyle(.white.opacity(0.5))
                Text("🫁 Breathe In…").font(.system(size: h*0.042, weight:.heavy, design:.rounded)).foregroundStyle(.white)
                Circle().fill(Color.blue.opacity(0.35)).frame(width: w*0.55, height: w*0.55)
                    .overlay(Text("4s").font(.system(size: h*0.06, weight:.heavy, design:.rounded)).foregroundStyle(.white))
                Text("Cycle 1 of 2 — loot after 2 cycles!").font(.system(size: h*0.02, design:.rounded)).foregroundStyle(.white.opacity(0.5))
                Spacer()
            }
        }
    }
}

private struct LootShot: View {
    let w, h: CGFloat
    let items = ["🗡️","⚔️","🛡️","👑","💎","🪄","🏺","🔮","🪙","🧿"]
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red:0.04,green:0.07,blue:0.2), Color(red:0.08,green:0.18,blue:0.35)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: h*0.025) {
                Spacer()
                Text("🎁 Loot Earned!").font(.system(size: h*0.042, weight:.heavy, design:.rounded)).foregroundStyle(.yellow)
                Text("You earned: 🏺 Ancient Urn").font(.system(size: h*0.025, design:.rounded)).foregroundStyle(.white)
                Text("Inventory").font(.system(size: h*0.022, weight:.semibold, design:.rounded)).foregroundStyle(.white.opacity(0.6))
                LazyVGrid(columns: Array(repeating: .init(.fixed(w*0.12)), count: 5), spacing: h*0.02) {
                    ForEach(items.prefix(7), id:\.self) { item in
                        Text(item).font(.system(size: h*0.05))
                    }
                }
                Spacer()
            }
        }
    }
}
