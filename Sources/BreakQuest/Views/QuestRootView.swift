import SwiftUI

// MARK: - Root

struct QuestRootView: View {
    @EnvironmentObject private var store: QuestStore

    var body: some View {
        ZStack {
            if store.appPhase == .breakGame {
                BreakMiniGameView()
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.85).combined(with: .opacity),
                        removal:   .opacity
                    ))
            } else {
                FocusTimerView()
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.45), value: store.appPhase == .breakGame)
        .overlay(lootToast)
    }

    @ViewBuilder
    private var lootToast: some View {
        if let loot = store.newLoot {
            VStack {
                Spacer()
                HStack(spacing: 10) {
                    Text(loot.emoji).font(.system(size: 28))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Loot Found!").font(.system(size: 12, weight: .bold, design: .rounded)).foregroundStyle(.yellow)
                        Text(loot.name).font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundStyle(.white)
                    }
                    Spacer()
                    Button { store.dismissLoot() } label: {
                        Image(systemName: "xmark").foregroundStyle(.white.opacity(0.5))
                    }
                }
                .padding(16)
                .background(Color(red: 0.15, green: 0.1, blue: 0.25))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.4), radius: 12, y: 6)
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

// MARK: - Focus Timer

struct FocusTimerView: View {
    @EnvironmentObject private var store: QuestStore

    var body: some View {
        ZStack {
            background
            VStack(spacing: 0) {
                Spacer()
                // Hero
                VStack(spacing: 6) {
                    Text("🧙").font(.system(size: 64))
                    Text(store.phase == "work" && store.isRunning ? "Adventuring…" : "At the inn 🏠")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                }

                Spacer().frame(height: 28)

                // Ring timer
                timerRing

                Spacer().frame(height: 28)

                // Sessions + inventory teaser
                HStack(spacing: 20) {
                    Label("\(store.sessionsToday) sessions", systemImage: "flame.fill")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.orange)
                    Label("\(store.inventory.count) items", systemImage: "bag.fill")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.yellow)
                }

                Spacer().frame(height: 28)

                // Controls
                HStack(spacing: 16) {
                    if store.isRunning {
                        questButton(label: "Rest", icon: "pause.fill", color: .orange) { store.pauseFocus() }
                    } else if store.phase == "idle" {
                        questButton(label: "Embark", icon: "play.fill", color: .indigo) { store.startFocus() }
                    } else {
                        questButton(label: "Resume", icon: "play.fill", color: .indigo) { store.startFocus() }
                        questButton(label: "Camp", icon: "arrow.counterclockwise", color: .gray.opacity(0.5)) { store.resetAll() }
                    }
                }

                Spacer()

                // Inventory
                if !store.inventory.isEmpty {
                    inventoryRow
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                }
            }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [Color(red: 0.08, green: 0.06, blue: 0.20), Color(red: 0.03, green: 0.04, blue: 0.12)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var timerRing: some View {
        ZStack {
            Circle().stroke(.white.opacity(0.1), lineWidth: 7)
            Circle()
                .trim(from: 0, to: store.timerProgress)
                .stroke(Color.indigo, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: store.timerProgress)
            VStack(spacing: 2) {
                Text(store.timerDisplay)
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                Text(phaseLabel)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .frame(width: 170, height: 170)
    }

    private var phaseLabel: String {
        switch store.phase {
        case "work":  return "FOCUS QUEST"
        case "break": return "BREAK"
        default:      return "READY"
        }
    }

    private func questButton(label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .frame(minWidth: 130)
                .padding(.vertical, 14)
                .background(color)
                .foregroundStyle(.white)
                .clipShape(Capsule())
        }
    }

    private var inventoryRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🎒 Inventory")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(store.inventory.reversed()) { item in
                        VStack(spacing: 2) {
                            Text(item.emoji).font(.system(size: 24))
                            Text(item.name)
                                .font(.system(size: 9, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.55))
                        }
                        .frame(width: 52)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.07))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }
}

// MARK: - Break Mini-Game (Breathing)

struct BreakMiniGameView: View {
    @EnvironmentObject private var store: QuestStore

    private var circleScale: CGFloat {
        switch store.breathPhase {
        case .inhale: return CGFloat(0.5 + 0.5 * store.breathProgress)
        case .hold:   return 1.0
        case .exhale: return CGFloat(1.0 - 0.5 * store.breathProgress)
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.12, blue: 0.20), Color(red: 0.02, green: 0.06, blue: 0.14)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text("🌿 Break Quest")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text("Complete 2 breath cycles to earn loot")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 4)

                Spacer().frame(height: 40)

                // Breathing circle
                ZStack {
                    Circle()
                        .fill(Color.teal.opacity(0.12))
                        .frame(width: 220, height: 220)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.teal.opacity(0.55), Color.teal.opacity(0.1)],
                                center: .center, startRadius: 0, endRadius: 90
                            )
                        )
                        .frame(width: 180, height: 180)
                        .scaleEffect(circleScale)
                        .animation(.easeInOut(duration: 0.1), value: circleScale)

                    VStack(spacing: 6) {
                        Text(store.breathPhase.label)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        if store.breathCycles > 0 {
                            Text("Cycle \(store.breathCycles) ✓")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.teal)
                        }
                    }
                }

                Spacer().frame(height: 32)

                // Timer remaining
                Text("Break ends in \(store.timerDisplay)")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.55))

                // Hero room
                Spacer().frame(height: 40)
                heroRoom

                Spacer()
            }
        }
    }

    private var heroRoom: some View {
        VStack(spacing: 4) {
            HStack(spacing: 16) {
                // Random props from inventory
                ForEach(store.inventory.prefix(5)) { item in
                    Text(item.emoji).font(.system(size: 22))
                }
                if store.inventory.isEmpty {
                    Text("🏚️").font(.system(size: 28))
                }
            }
            HStack(spacing: 0) {
                Text("🧙").font(.system(size: 36))
                Text(" explores the room…")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .padding(16)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 40)
    }
}
