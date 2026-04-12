import SwiftUI

struct PathsView: View {
    @Environment(ProgressStore.self) private var progressStore
    private let paths = SampleContent.paths

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ForEach(Array(paths.enumerated()), id: \.element.id) { index, path in
                        let isUnlocked = progressStore.isLevelUnlocked(path.level)

                        Group {
                            if isUnlocked {
                                NavigationLink(value: path) {
                                    PathCard(
                                        path: path,
                                        index: index + 1,
                                        completedCount: progressStore.completedCount(in: path.lessonIDs),
                                        isUnlocked: isUnlocked
                                    )
                                }
                                .buttonStyle(.plain)
                            } else {
                                PathCard(
                                    path: path,
                                    index: index + 1,
                                    completedCount: progressStore.completedCount(in: path.lessonIDs),
                                    isUnlocked: isUnlocked
                                )
                            }
                        }
                    }
                }
                .padding(AppTheme.screenPadding)
            }
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .navigationTitle("Paths")
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(for: LearningPath.self) { path in
                PathDetailView(path: path)
            }
        }
    }
}

private struct PathCard: View {
    let path: LearningPath
    let index: Int
    let completedCount: Int
    let isUnlocked: Bool

    private var tint: Color {
        switch path.level {
        case .beginner: AppTheme.positive
        case .intermediate: AppTheme.accentWarm
        case .advanced: AppTheme.accent
        }
    }

    private var progress: Double {
        guard path.lessonCount > 0 else { return 0 }
        return Double(completedCount) / Double(path.lessonCount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(index)")
                    .font(AppTheme.numberFont)
                    .foregroundStyle(tint)
                    .frame(width: 32, height: 32)
                    .background(tint.opacity(0.12), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(path.title)
                        .font(AppTheme.cardTitleFont)
                        .foregroundStyle(AppTheme.ink)
                    Text("\(completedCount)/\(path.lessonCount) lessons")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(tint)
                }

                Spacer()

                Image(systemName: isUnlocked ? "chevron.right" : "lock.fill")
                    .font(.caption)
                    .foregroundStyle(isUnlocked ? AppTheme.mutedInk : AppTheme.accentWarm)
            }

            Text(path.summary)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.mutedInk)
                .lineSpacing(2)

            if !isUnlocked, let prerequisiteLevel = path.level.previousLevel {
                Text("Complete all \(prerequisiteLevel.shortLabel.lowercased()) lessons to unlock this path.")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.accentWarm)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.surfaceStrong)
                        .frame(height: 6)
                    Capsule()
                        .fill(tint.opacity(0.6))
                        .frame(width: geo.size.width * (isUnlocked ? progress : 0), height: 6)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 6)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                .fill(AppTheme.surface.opacity(0.96))
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                .stroke((isUnlocked ? tint : AppTheme.accentWarm).opacity(0.12), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 6)
        .opacity(isUnlocked ? 1 : 0.8)
    }
}

#Preview {
    PathsView()
        .environment(ProgressStore())
}
