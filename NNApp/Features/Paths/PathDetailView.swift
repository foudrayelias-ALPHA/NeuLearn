import SwiftUI

struct PathDetailView: View {
    let path: LearningPath
    @Environment(ProgressStore.self) private var progressStore

    private var lessons: [Lesson] {
        path.lessonIDs.compactMap { SampleContent.lesson(for: $0) }
    }

    private var tint: Color {
        switch path.level {
        case .beginner: AppTheme.positive
        case .intermediate: AppTheme.accent
        case .advanced: AppTheme.accentWarm
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text(path.level.displayName.uppercased())
                        .font(AppTheme.captionFont)
                        .tracking(1.2)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(tint.opacity(0.12), in: Capsule())
                        .foregroundStyle(tint)

                    Text(path.title)
                        .font(AppTheme.heroTitleFont)
                        .foregroundStyle(AppTheme.ink)

                    Text(path.summary)
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.mutedInk)
                        .lineSpacing(3)
                }

                // Progress
                let completed = progressStore.completedCount(in: path.lessonIDs)
                HStack(spacing: 12) {
                    MetricPill(title: "Lessons", value: "\(path.lessonCount)", tint: tint)
                    MetricPill(title: "Completed", value: "\(completed)", tint: AppTheme.positive)
                }

                // Lesson list
                VStack(spacing: 12) {
                    ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                        NavigationLink(value: lesson) {
                            PathLessonRow(
                                lesson: lesson,
                                index: index + 1,
                                isCompleted: progressStore.isCompleted(lesson.id),
                                tint: tint
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(AppTheme.screenPadding)
        }
        .scrollContentBackground(.hidden)
        .background(AppBackground())
        .navigationTitle(path.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationDestination(for: Lesson.self) { lesson in
            LessonDetailView(lesson: lesson)
        }
    }
}

private struct PathLessonRow: View {
    let lesson: Lesson
    let index: Int
    let isCompleted: Bool
    let tint: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isCompleted ? AppTheme.positive : tint.opacity(0.12))
                    .frame(width: 36, height: 36)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(index)")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(tint)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(lesson.title)
                    .font(AppTheme.bodyFont.weight(.semibold))
                    .foregroundStyle(AppTheme.ink)

                Text(lesson.summary)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.mutedInk)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppTheme.mutedInk)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppTheme.surface.opacity(0.96))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isCompleted ? AppTheme.positive.opacity(0.2) : AppTheme.ink.opacity(0.06), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    NavigationStack {
        PathDetailView(path: SampleContent.paths[0])
    }
    .environment(ProgressStore())
}
