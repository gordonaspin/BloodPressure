import SwiftUI

@main
struct BloodPressureApp: App {
    @StateObject private var healthStore = HealthStore()

    var body: some Scene {
        WindowGroup {
            TabView {
                DataEntryView()
                    .tabItem {
                        Label("Data", systemImage: "heart.text.square")
                    }
                HistoricalDataView()
                    .tabItem {
                        Label("History", systemImage: "chart.bar")
                    }
            }
            .environmentObject(healthStore)
        }
    }
}
