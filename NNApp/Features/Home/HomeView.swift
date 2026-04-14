import SwiftUI

struct HomeView: View {
    @Environment(ProgressStore.self) private var progressStore
    @State private var showCredits = false
    @State private var showRecommendPrompt = false
    @State private var currentFunFactIndex = Int.random(in: 0..<funFacts.count)
    let homeSelectionCount: Int

    private static let funFacts: [FunFact] = [
        FunFact(
            title: "Word vectors capture analogies",
            body: "In many embedding spaces, the direction from man to woman is similar to the direction from king to queen. The model learned a geometric pattern from language usage alone."
        ),
        FunFact(
            title: "Tiny weight changes add up",
            body: "A neural network usually learns through many small updates. Gradient descent rarely finds a good solution in one leap; it improves through accumulated nudges."
        ),
        FunFact(
            title: "More layers are not always better",
            body: "A deeper network can model richer patterns, but it can also become harder to train or overfit. Architecture only helps when it matches the problem and data."
        ),
        FunFact(
            title: "Dropout is controlled forgetfulness",
            body: "During training, dropout temporarily turns off random neurons so the network cannot rely on any single shortcut. That often improves generalization."
        ),
        FunFact(
            title: "Convolutions reuse the same detector",
            body: "A convolutional filter scans across an image with shared weights, so one learned edge detector can recognize similar structure in many locations."
        ),
        FunFact(
            title: "Attention compares everything to everything",
            body: "Transformer attention scores how strongly each token should look at the others. That is why context can shift the meaning of the same word in different sentences."
        )
    ]

    private var hasStartedLearning: Bool {
        !progressStore.completedLessonIDs.isEmpty || progressStore.lastViewedLessonID != nil
    }

    private var activePlan: PersonalizedPlan? {
        progressStore.personalizedPlan
    }

    private var planLessons: [Lesson] {
        guard let activePlan else { return [] }
        return activePlan.lessonIDs.compactMap(SampleContent.lesson(for:))
    }

    private var completedPlanLessons: Int {
        guard let activePlan else { return 0 }
        return progressStore.completedCount(in: activePlan.lessonIDs)
    }

    private var planProgress: Double {
        guard let activePlan, activePlan.lessonCount > 0 else { return 0 }
        return Double(completedPlanLessons) / Double(activePlan.lessonCount)
    }

    private var nextPlanLesson: Lesson? {
        planLessons.first { !progressStore.isCompleted($0.id) } ?? planLessons.first
    }

    private var currentFunFact: FunFact {
        Self.funFacts[currentFunFactIndex]
    }

    private var currentLevelCompletedLessons: Int {
        progressStore.completedCount(for: progressStore.selectedLevel)
    }

    private var currentLevelLessonTotal: Int {
        progressStore.totalLessonCount(for: progressStore.selectedLevel)
    }

    private var planSequenceLabel: String {
        let totalSequences = progressStore.totalPlanSequenceCount
        guard totalSequences > 1 else { return "Your Sequence" }
        return "Sequence \(progressStore.currentPlanSequenceNumber) of \(totalSequences)"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    if let activePlan, let nextPlanLesson {
                        NavigationLink(value: nextPlanLesson) {
                            personalizedPlanHero(plan: activePlan, nextLesson: nextPlanLesson)
                        }
                        .buttonStyle(.plain)

                        SectionCard(title: "Plan Steps", eyebrow: planSequenceLabel) {
                            VStack(spacing: 10) {
                                ForEach(Array(planLessons.enumerated()), id: \.element.id) { index, lesson in
                                    NavigationLink(value: lesson) {
                                        HStack(spacing: 12) {
                                            Image(systemName: progressStore.isCompleted(lesson.id) ? "checkmark.circle.fill" : "\(index + 1).circle.fill")
                                                .font(.body)
                                                .foregroundStyle(progressStore.isCompleted(lesson.id) ? AppTheme.positive : AppTheme.accent)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(lesson.title)
                                                    .font(AppTheme.bodyFont.weight(.semibold))
                                                    .foregroundStyle(AppTheme.ink)
                                                Text(lesson.summary)
                                                    .font(AppTheme.captionFont)
                                                    .foregroundStyle(AppTheme.mutedInk)
                                                    .lineLimit(1)
                                            }

                                            Spacer()

                                            if lesson.id == nextPlanLesson.id && !progressStore.isCompleted(lesson.id) {
                                                Text("Next")
                                                    .font(AppTheme.captionFont)
                                                    .foregroundStyle(AppTheme.accent)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(AppTheme.accent.opacity(0.12), in: Capsule())
                                            }

                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundStyle(AppTheme.mutedInk)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    } else if let heroLesson = progressStore.recommendedNextLesson {
                        NavigationLink(value: heroLesson) {
                            HeroCard(
                                eyebrow: hasStartedLearning ? "Resume Learning" : "Start Learning",
                                title: hasStartedLearning
                                    ? "Continue: \(heroLesson.title)"
                                    : "Build intuition for how neural networks learn",
                                subtitle: hasStartedLearning
                                    ? heroLesson.summary
                                    : "Start with your first lesson to explore inputs, predictions, and training step by step.",
                                accent: AppTheme.accent
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    HStack(spacing: 12) {
                        MetricPill(title: "Completed", value: "\(progressStore.completedLessonIDs.count)/\(SampleContent.lessons.count)", tint: AppTheme.positive)
                        MetricPill(title: "Saved", value: "\(progressStore.savedLessonIDs.count)", tint: AppTheme.accentWarm)
                            .fixedSize(horizontal: true, vertical: false)
                        MetricPill(title: "Level", value: progressStore.selectedLevel.shortLabel, tint: AppTheme.accent)
                    }

                    SectionCard(title: "Skill Progression", eyebrow: "Level Track") {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(progressStore.selectedLevel.displayName)
                                        .font(AppTheme.cardTitleFont)
                                        .foregroundStyle(AppTheme.ink)
                                    Text("\(currentLevelCompletedLessons)/\(currentLevelLessonTotal) \(progressStore.selectedLevel.shortLabel.lowercased()) lessons completed")
                                        .font(AppTheme.captionFont)
                                        .foregroundStyle(AppTheme.mutedInk)
                                }

                                Spacer()

                                if let nextLevel = progressStore.nextLevelToUnlock {
                                    Text("Next: \(nextLevel.shortLabel)")
                                        .font(AppTheme.captionFont.weight(.semibold))
                                        .foregroundStyle(AppTheme.accent)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(AppTheme.accent.opacity(0.12), in: Capsule())
                                } else {
                                    Text("Top level")
                                        .font(AppTheme.captionFont.weight(.semibold))
                                        .foregroundStyle(AppTheme.positive)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(AppTheme.positive.opacity(0.12), in: Capsule())
                                }
                            }

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(AppTheme.surfaceStrong)
                                        .frame(height: 8)

                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [AppTheme.accent, AppTheme.accentWarm],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geo.size.width * progressStore.progressTowardNextLevel, height: 8)
                                        .animation(.easeInOut(duration: 0.3), value: progressStore.progressTowardNextLevel)
                                }
                            }
                            .frame(height: 8)

                            Text(nextLevelSummary)
                                .font(AppTheme.bodyFont)
                                .foregroundStyle(AppTheme.mutedInk)
                                .lineSpacing(3)
                        }
                    }

                    if !progressStore.completedLessonIDs.isEmpty {
                        let recentlyCompleted = SampleContent.lessons.filter { progressStore.isCompleted($0.id) }.suffix(3)
                        SectionCard(title: "Recently Completed", eyebrow: "Progress") {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(Array(recentlyCompleted)) { lesson in
                                    HStack(spacing: 10) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(AppTheme.positive)
                                            .font(.body)
                                        Text(lesson.title)
                                            .font(AppTheme.bodyFont)
                                            .foregroundStyle(AppTheme.ink)
                                    }
                                }
                            }
                        }
                    }

                    SectionCard(title: currentFunFact.title, eyebrow: "Fun Fact") {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(currentFunFact.body)
                                .font(AppTheme.bodyFont)
                                .foregroundStyle(AppTheme.mutedInk)
                                .lineSpacing(3)

                            HStack(spacing: 10) {
                                Label("Refreshes when you return to Home", systemImage: "shuffle")
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.accent)

                                Spacer()

                                Text("Fact \(currentFunFactIndex + 1)")
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.mutedInk)
                            }
                        }
                    }

                    HStack(spacing: 14) {
                        Button {
                            showCredits = true
                        } label: {
                            Text("App Information")
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.mutedInk.opacity(0.45))
                        }

                        Button {
                            showRecommendPrompt = true
                        } label: {
                            Image(systemName: "square.and.arrow.up.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(AppTheme.accent.opacity(0.85))
                        }
                        .accessibilityLabel("Recommend app")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 24)
                }
                .padding(AppTheme.screenPadding)
            }
            .sheet(isPresented: $showCredits) {
                CreditsView()
            }
            .navigationTitle("NueLearnND")
            .navigationDestination(for: Lesson.self) { lesson in
                LessonDetailView(lesson: lesson)
            }
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert("Recommend NueLearnND", isPresented: $showRecommendPrompt) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Like the app? Recommend it to a friend.")
            }
        }
        .onChange(of: homeSelectionCount) { _, _ in
            withAnimation(.easeInOut(duration: 0.25)) {
                selectNextFunFact()
            }
        }
    }

    private func personalizedPlanHero(plan: PersonalizedPlan, nextLesson: Lesson) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("YOUR PLAN")
                        .font(AppTheme.captionFont)
                        .tracking(1.2)
                        .foregroundStyle(AppTheme.accent)

                    Text(plan.title)
                        .font(AppTheme.heroTitleFont)
                        .foregroundStyle(AppTheme.ink)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(completedPlanLessons)/\(plan.lessonCount)")
                        .font(AppTheme.numberFont)
                        .foregroundStyle(AppTheme.ink)
                    Text("completed")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.mutedInk)
                }
            }

            Text(plan.summary)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.mutedInk)
                .lineSpacing(3)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Plan progress")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.mutedInk)
                    Spacer()
                    Text("\(Int(planProgress * 100))%")
                        .font(AppTheme.captionFont.weight(.semibold))
                        .foregroundStyle(AppTheme.accent)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppTheme.surfaceStrong)
                            .frame(height: 10)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.accent, AppTheme.positive],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * planProgress, height: 10)
                            .animation(.easeInOut(duration: 0.3), value: planProgress)
                    }
                }
                .frame(height: 10)
            }

            HStack(spacing: 10) {
                planPill(text: plan.interest.title, tint: AppTheme.accent)
                planPill(text: plan.goal.title, tint: AppTheme.accentWarm)
                if progressStore.totalPlanSequenceCount > 1 {
                    planPill(text: "Seq \(progressStore.currentPlanSequenceNumber)/\(progressStore.totalPlanSequenceCount)", tint: AppTheme.positive)
                }
            }

            HStack {
                Spacer()
                HStack(spacing: 10) {
                    Text(hasStartedLearning ? "Continue: \(nextLesson.title)" : "Start: \(nextLesson.title)")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [AppTheme.accent, AppTheme.accent.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: Capsule()
                )
                .shadow(color: AppTheme.accent.opacity(0.4), radius: 12, y: 6)
                Spacer()
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.surface, AppTheme.accent.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(AppTheme.accent.opacity(0.16), lineWidth: 1)

                Circle()
                    .fill(AppTheme.accent.opacity(0.08))
                    .frame(width: 180, height: 180)
                    .offset(x: 52, y: -54)
            }
        )
    }

    private func planPill(text: String, tint: Color) -> some View {
        Text(text)
            .font(AppTheme.captionFont)
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.12), in: Capsule())
    }

    private var nextLevelSummary: String {
        if let nextLevel = progressStore.nextLevelToUnlock,
           let prerequisiteLevel = nextLevel.previousLevel {
            let completed = progressStore.completedCount(for: prerequisiteLevel)
            let total = progressStore.totalLessonCount(for: prerequisiteLevel)
            return "Finish \(progressStore.lessonsNeededForNextLevel) more \(prerequisiteLevel.shortLabel.lowercased()) lesson\(progressStore.lessonsNeededForNextLevel == 1 ? "" : "s") to unlock \(nextLevel.shortLabel.lowercased()) content. You're at \(completed) of \(total)."
        }

        return "You've unlocked every skill tier. Revisit saved lessons or jump into advanced topics whenever you want."
    }

    private func selectNextFunFact() {
        guard Self.funFacts.count > 1 else { return }

        var nextIndex = currentFunFactIndex
        while nextIndex == currentFunFactIndex {
            nextIndex = Int.random(in: 0..<Self.funFacts.count)
        }

        currentFunFactIndex = nextIndex
    }
}

private struct FunFact {
    let title: String
    let body: String
}

#Preview {
    HomeView(homeSelectionCount: 0)
        .environment(ProgressStore())
}
