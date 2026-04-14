import SwiftUI

struct ApplicationsView: View {
    @Environment(ProgressStore.self) private var progressStore

    private let lessons = SampleContent.applicationsLessons

    private var completedLessons: Int {
        progressStore.completedCount(in: lessons.map(\.id))
    }

    private var savedLessons: Int {
        lessons.filter { progressStore.isSaved($0.id) }.count
    }

    private var nextLesson: Lesson? {
        lessons.first { !progressStore.isCompleted($0.id) } ?? lessons.first
    }

    private var progressValue: Double {
        guard !lessons.isEmpty else { return 0 }
        return Double(completedLessons) / Double(lessons.count)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SectionCard(title: "Why This Tab Exists", eyebrow: "Concrete Mental Models") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your other lessons explain what neural networks are. This section explains what they look like inside a real computer: arrays of weights, normalized inputs, matrix multiplies, model files, and deployment constraints.")
                                .font(AppTheme.bodyFont)
                                .foregroundStyle(AppTheme.mutedInk)
                                .lineSpacing(3)

                            Text("The goal is to make phrases like \"run a model\" and \"the cat class scored highest\" feel literal instead of mystical.")
                                .font(AppTheme.bodyFont)
                                .foregroundStyle(AppTheme.mutedInk)
                                .lineSpacing(3)
                        }
                    }

                    if let nextLesson {
                        NavigationLink(value: nextLesson) {
                            SectionCard(title: "Continue Learning", eyebrow: "Recommended Next Step") {
                                HStack(spacing: 14) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(nextLesson.title)
                                            .font(AppTheme.cardTitleFont)
                                            .foregroundStyle(AppTheme.ink)
                                        Text(nextLesson.summary)
                                            .font(AppTheme.bodyFont)
                                            .foregroundStyle(AppTheme.mutedInk)
                                            .lineSpacing(3)
                                    }

                                    Spacer()

                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 28, weight: .semibold))
                                        .foregroundStyle(AppTheme.accentWarm)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    SectionCard(title: "Section Progress", eyebrow: "Applications Track") {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("You have finished \(completedLessons) of \(lessons.count) lessons.")
                                    .font(AppTheme.bodyFont)
                                    .foregroundStyle(AppTheme.mutedInk)
                                Spacer()
                                Text("\(Int(progressValue * 100))%")
                                    .font(AppTheme.captionFont.weight(.semibold))
                                    .foregroundStyle(AppTheme.accentWarm)
                            }

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(AppTheme.surfaceStrong)
                                        .frame(height: 10)

                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [AppTheme.accentWarm, AppTheme.accent],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geo.size.width * progressValue, height: 10)
                                        .animation(.easeInOut(duration: 0.3), value: progressValue)
                                }
                            }
                            .frame(height: 10)
                        }
                    }

                    SectionCard(title: "Lesson Roadmap", eyebrow: "\(lessons.count) Lessons") {
                        VStack(alignment: .leading, spacing: 14) {
                            ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                                NavigationLink(value: lesson) {
                                    HStack(alignment: .top, spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(progressStore.isCompleted(lesson.id) ? AppTheme.positive.opacity(0.18) : AppTheme.accentWarm.opacity(0.16))
                                                .frame(width: 34, height: 34)

                                            if progressStore.isCompleted(lesson.id) {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundStyle(AppTheme.positive)
                                            } else {
                                                Text("\(index + 1)")
                                                    .font(AppTheme.captionFont.weight(.bold))
                                                    .foregroundStyle(AppTheme.accentWarm)
                                            }
                                        }

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(lesson.title)
                                                .font(AppTheme.bodyFont.weight(.semibold))
                                                .foregroundStyle(AppTheme.ink)
                                            Text(lesson.summary)
                                                .font(AppTheme.captionFont)
                                                .foregroundStyle(AppTheme.mutedInk)
                                                .lineSpacing(2)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(AppTheme.mutedInk)
                                            .padding(.top, 8)
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                if lesson.id != lessons.last?.id {
                                    Divider()
                                        .foregroundStyle(AppTheme.surfaceStrong)
                                }
                            }
                        }
                    }
                }
                .padding(AppTheme.screenPadding)
            }
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .navigationTitle("Applications")
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(for: Lesson.self) { lesson in
                LessonDetailView(lesson: lesson)
            }
        }
    }
}

#Preview {
    ApplicationsView()
        .environment(ProgressStore())
}
