import Foundation
import Combine

// MARK: - App Phase

enum AppPhase {
    case focus     // Pomodoro work session
    case breakGame // Mini-game during break
    case idle
}

// MARK: - Breath Phase

enum BreathPhase: Equatable {
    case inhale(total: Double)
    case hold(total: Double)
    case exhale(total: Double)

    var label: String {
        switch self {
        case .inhale: return "Breathe in…"
        case .hold:   return "Hold…"
        case .exhale: return "Breathe out…"
        }
    }

    var totalDuration: Double {
        switch self {
        case .inhale(let t), .hold(let t), .exhale(let t): return t
        }
    }

    static let sequence: [BreathPhase] = [
        .inhale(total: 4), .hold(total: 2), .exhale(total: 4)
    ]
}

// MARK: - Loot Item

struct LootItem: Identifiable, Codable {
    let id:    UUID
    let emoji: String
    let name:  String

    static let pool: [LootItem] = [
        LootItem(id: UUID(), emoji: "🗡️", name: "Iron Dagger"),
        LootItem(id: UUID(), emoji: "⚔️", name: "Twin Swords"),
        LootItem(id: UUID(), emoji: "🛡️", name: "Round Shield"),
        LootItem(id: UUID(), emoji: "👑", name: "Golden Crown"),
        LootItem(id: UUID(), emoji: "💎", name: "Blue Gem"),
        LootItem(id: UUID(), emoji: "🪄", name: "Magic Wand"),
        LootItem(id: UUID(), emoji: "🏺", name: "Ancient Urn"),
        LootItem(id: UUID(), emoji: "🔮", name: "Crystal Ball"),
        LootItem(id: UUID(), emoji: "🪙", name: "Gold Coin"),
        LootItem(id: UUID(), emoji: "🧿", name: "Nazar Amulet")
    ]
}

// MARK: - Settings

struct QuestSettings: Codable, Equatable {
    var workMinutes:  Int = 25
    var breakMinutes: Int = 5
}

// MARK: - QuestStore

@MainActor
final class QuestStore: ObservableObject {

    @Published private(set) var appPhase:       AppPhase    = .idle
    @Published private(set) var phase:          String      = "idle"  // "work" | "break" | "idle"
    @Published private(set) var secondsLeft:    Int         = 0
    @Published private(set) var isRunning:      Bool        = false
    @Published private(set) var inventory:      [LootItem]  = []
    @Published private(set) var sessionsToday:  Int         = 0
    @Published private(set) var breathProgress: Double      = 0      // 0–1 within current breath phase
    @Published private(set) var breathPhase:    BreathPhase = BreathPhase.sequence[0]
    @Published private(set) var breathCycles:   Int         = 0      // completed full cycles
    @Published private(set) var newLoot:        LootItem?   = nil
    @Published              var settings:       QuestSettings = QuestSettings()

    private var mainTimer:    AnyCancellable?
    private var breathTimer:  AnyCancellable?
    private var breathIndex   = 0
    private var breathElapsed: Double = 0
    private let defaults = UserDefaults.standard

    init() {
        load()
        secondsLeft = settings.workMinutes * 60
    }

    // MARK: - Computed

    var timerDisplay: String {
        let m = secondsLeft / 60; let s = secondsLeft % 60
        return String(format: "%02d:%02d", m, s)
    }

    var timerProgress: Double {
        let total = phase == "break" ? settings.breakMinutes * 60 : settings.workMinutes * 60
        guard total > 0 else { return 0 }
        return Double(total - secondsLeft) / Double(total)
    }

    // MARK: - Timer control

    func startFocus() {
        guard !isRunning else { return }
        phase       = "work"
        appPhase    = .focus
        secondsLeft = settings.workMinutes * 60
        isRunning   = true
        startMainTimer()
    }

    func pauseFocus() {
        isRunning = false
        mainTimer?.cancel()
        mainTimer = nil
    }

    func resetAll() {
        pauseFocus()
        stopBreath()
        phase    = "idle"
        appPhase = .idle
        secondsLeft = settings.workMinutes * 60
    }

    // MARK: - Internal

    private func startMainTimer() {
        mainTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.mainTick() }
    }

    private func mainTick() {
        guard secondsLeft > 0 else { advanceMainPhase(); return }
        secondsLeft -= 1
    }

    private func advanceMainPhase() {
        pauseFocus()
        if phase == "work" {
            sessionsToday += 1
            persist()
            phase       = "break"
            appPhase    = .breakGame
            secondsLeft = settings.breakMinutes * 60
            isRunning   = true
            startMainTimer()
            startBreath()
        } else {
            stopBreath()
            awardLoot()
            phase    = "idle"
            appPhase = .idle
            secondsLeft = settings.workMinutes * 60
        }
    }

    // MARK: - Breath mini-game

    private func startBreath() {
        breathIndex   = 0
        breathElapsed = 0
        breathCycles  = 0
        breathPhase   = BreathPhase.sequence[0]
        breathProgress = 0
        breathTimer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.breathTick() }
    }

    private func breathTick() {
        breathElapsed += 0.05
        let total = BreathPhase.sequence[breathIndex].totalDuration
        breathProgress = min(1.0, breathElapsed / total)

        if breathElapsed >= total {
            breathElapsed = 0
            breathIndex = (breathIndex + 1) % BreathPhase.sequence.count
            breathPhase = BreathPhase.sequence[breathIndex]
            if breathIndex == 0 { breathCycles += 1 }
            breathProgress = 0
        }
    }

    private func stopBreath() {
        breathTimer?.cancel()
        breathTimer = nil
    }

    // MARK: - Loot

    private func awardLoot() {
        guard breathCycles >= 2 else { return }    // Only award after 2 full breath cycles
        let item = LootItem.pool.randomElement()!
        inventory.append(item)
        newLoot = item
        persist()
        Task {
            try? await Task.sleep(for: .seconds(3))
            self.newLoot = nil
        }
    }

    func dismissLoot() { newLoot = nil }

    // MARK: - Persistence

    private func persist() {
        defaults.set(sessionsToday, forKey: "bq_sessionsToday")
        if let data = try? JSONEncoder().encode(inventory) {
            defaults.set(data, forKey: "bq_inventory")
        }
    }

    private func load() {
        sessionsToday = defaults.integer(forKey: "bq_sessionsToday")
        if let data = defaults.data(forKey: "bq_inventory"),
           let items = try? JSONDecoder().decode([LootItem].self, from: data) {
            inventory = items
        }
        if let data = defaults.data(forKey: "bq_settings"),
           let s = try? JSONDecoder().decode(QuestSettings.self, from: data) {
            settings = s
        }
    }
}
