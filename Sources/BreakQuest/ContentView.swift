import SwiftUI

struct ContentView: View {
    @StateObject private var store = QuestStore()

    var body: some View {
        QuestRootView()
            .environmentObject(store)
    }
}
