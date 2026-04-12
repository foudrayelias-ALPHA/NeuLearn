import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: Tab = .home
    @State private var homeSelectionCount = 0

    private enum Tab {
        case home
        case explore
        case aiInPractice
        case visualLab
        case library
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(homeSelectionCount: homeSelectionCount)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(Tab.home)

            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "safari")
                }
                .tag(Tab.explore)

            AIInPracticeView()
                .tabItem {
                    Label("AI Alignment", systemImage: "brain.head.profile")
                }
                .tag(Tab.aiInPractice)

            VisualLabView()
                .tabItem {
                    Label("Visual Lab", systemImage: "point.3.connected.trianglepath.dotted")
                }
                .tag(Tab.visualLab)

            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
                .tag(Tab.library)
        }
        .tint(AppTheme.accent)
        .toolbarBackground(.hidden, for: .tabBar)
        .onChange(of: selectedTab) { _, newValue in
            guard newValue == .home else { return }
            homeSelectionCount += 1
        }
        .onAppear {
            // Tab bar
            let tabAppearance = UITabBarAppearance()
            tabAppearance.configureWithTransparentBackground()
            tabAppearance.backgroundColor = UIColor(AppTheme.surface)
            
            let normalAttrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor(AppTheme.mutedInk)
            ]
            let selectedAttrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor(AppTheme.accent)
            ]
            
            tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs
            tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs
            tabAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppTheme.mutedInk)
            tabAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppTheme.accent)
            
            UITabBar.appearance().standardAppearance = tabAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance

            // Navigation bar — ensure titles are readable against light backgrounds
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithOpaqueBackground()
            navAppearance.backgroundColor = UIColor(AppTheme.surface)
            navAppearance.largeTitleTextAttributes = [
                .foregroundColor: UIColor(AppTheme.ink)
            ]
            navAppearance.titleTextAttributes = [
                .foregroundColor: UIColor(AppTheme.ink)
            ]

            let scrollEdgeNavAppearance = UINavigationBarAppearance()
            scrollEdgeNavAppearance.configureWithTransparentBackground()
            scrollEdgeNavAppearance.largeTitleTextAttributes = [
                .foregroundColor: UIColor(AppTheme.ink)
            ]
            scrollEdgeNavAppearance.titleTextAttributes = [
                .foregroundColor: UIColor(AppTheme.ink)
            ]

            UINavigationBar.appearance().standardAppearance = navAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = scrollEdgeNavAppearance
            UINavigationBar.appearance().compactAppearance = navAppearance
        }
    }
}

#Preview {
    RootTabView()
        .environment(ProgressStore())
}
