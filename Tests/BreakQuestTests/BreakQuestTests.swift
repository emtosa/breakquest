import Testing
@testable import BreakQuest

@Suite("BreathPhase")
struct BreathPhaseTests {
    @Test("sequence has 3 phases")
    func sequenceCount() {
        #expect(BreathPhase.sequence.count == 3)
    }

    @Test("each phase has non-empty label")
    func labels() {
        for phase in BreathPhase.sequence {
            #expect(!phase.label.isEmpty)
        }
    }

    @Test("total durations are positive")
    func durations() {
        for phase in BreathPhase.sequence {
            #expect(phase.totalDuration > 0)
        }
    }
}

@Suite("LootItem")
struct LootItemTests {
    @Test("pool has 10 items")
    func poolSize() {
        #expect(LootItem.pool.count == 10)
    }

    @Test("all items have unique emoji")
    func uniqueEmoji() {
        let emojis = Set(LootItem.pool.map { $0.emoji })
        #expect(emojis.count == LootItem.pool.count)
    }
}

@Suite("QuestStore")
@MainActor
struct QuestStoreTests {
    @Test("starts idle")
    func initialState() {
        let store = QuestStore()
        #expect(store.appPhase == .idle)
        #expect(!store.isRunning)
    }

    @Test("startFocus transitions to focus phase")
    func startFocus() {
        let store = QuestStore()
        store.startFocus()
        #expect(store.appPhase == .focus)
        #expect(store.isRunning)
        #expect(store.phase == "work")
    }

    @Test("resetAll returns to idle")
    func reset() {
        let store = QuestStore()
        store.startFocus()
        store.resetAll()
        #expect(store.appPhase == .idle)
        #expect(!store.isRunning)
    }
}
