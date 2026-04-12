import SwiftUI

@main
struct NuelearnNDApp: App {
    @State private var progressStore = ProgressStore()
    @AppStorage("hasSeenLaunchExperience") private var hasSeenLaunchExperience = false
    @State private var showsLaunchExperience = true

    private var launchMode: LaunchExperienceView.Mode {
        hasSeenLaunchExperience ? .returning : .firstLaunch
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if progressStore.hasCompletedOnboarding {
                        RootTabView()
                    } else {
                        OnboardingView()
                    }
                }
                .environment(progressStore)

                if showsLaunchExperience {
                    LaunchExperienceView(mode: launchMode)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .task {
                await runLaunchExperience()
            }
        }
    }

    @MainActor
    private func runLaunchExperience() async {
        guard showsLaunchExperience else { return }

        let isFirstLaunchExperience = !hasSeenLaunchExperience
        if isFirstLaunchExperience {
            hasSeenLaunchExperience = true
        }

        let delay = isFirstLaunchExperience ? 2.5 : 0.8

        do {
            try await Task.sleep(for: .seconds(delay))
        } catch {
            return
        }

        withAnimation(.easeOut(duration: 0.45)) {
            showsLaunchExperience = false
        }
    }
}
