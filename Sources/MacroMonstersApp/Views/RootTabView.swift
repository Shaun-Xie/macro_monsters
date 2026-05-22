import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Today", systemImage: "chart.pie.fill")
                }

            FoodLogView()
                .tabItem {
                    Label("Log", systemImage: "plus.circle.fill")
                }

            BaseContainerView()
                .tabItem {
                    Label("Base", systemImage: "square.grid.3x3.fill")
                }

            UpgradeStoreView()
                .tabItem {
                    Label("Upgrade", systemImage: "hammer.fill")
                }
        }
    }
}
