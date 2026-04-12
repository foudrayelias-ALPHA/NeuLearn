import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @Environment(ProgressStore.self) private var progressStore
    @State private var currentSectionIndex = 0
    @State private var showChallenge = false
    @State private var challengeCompleted = false

    private var tint: Color {
        switch lesson.level {
        case .beginner: AppTheme.positive
        case .intermediate: AppTheme.accent
        case .advanced: AppTheme.accentWarm
        }
    }

    private var isOnLastSection: Bool {
        currentSectionIndex >= lesson.sections.count - 1
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(lesson.level.displayName.uppercased())
                                .font(AppTheme.captionFont)
                                .tracking(1.2)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(tint.opacity(0.12), in: Capsule())
                                .foregroundStyle(tint)

                            Spacer()

                            Button {
                                progressStore.toggleSaved(lesson.id)
                            } label: {
                                Image(systemName: progressStore.isSaved(lesson.id) ? "bookmark.fill" : "bookmark")
                                    .font(.title3)
                                    .foregroundStyle(progressStore.isSaved(lesson.id) ? AppTheme.accentWarm : AppTheme.mutedInk)
                            }
                        }

                        Text(lesson.title)
                            .font(AppTheme.heroTitleFont)
                            .foregroundStyle(AppTheme.ink)

                        Text(lesson.summary)
                            .font(AppTheme.bodyFont)
                            .foregroundStyle(AppTheme.mutedInk)
                            .lineSpacing(3)
                    }

                    // Section navigation pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(lesson.sections.enumerated()), id: \.element.id) { index, section in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        currentSectionIndex = index
                                        showChallenge = false
                                    }
                                } label: {
                                    Text(section.title)
                                        .font(AppTheme.captionFont)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule().fill(index == currentSectionIndex && !showChallenge ? tint : AppTheme.surfaceStrong.opacity(0.6))
                                        )
                                        .foregroundStyle(index == currentSectionIndex && !showChallenge ? .white : AppTheme.ink)
                                }
                                .buttonStyle(.plain)
                            }

                            // Challenge pill
                            if lesson.challenge != nil {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        showChallenge = true
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: challengeCompleted ? "checkmark.seal.fill" : "questionmark.diamond.fill")
                                            .font(.system(size: 10))
                                        Text("Challenge")
                                    }
                                    .font(AppTheme.captionFont)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule().fill(showChallenge ? AppTheme.accentWarm : AppTheme.surfaceStrong.opacity(0.6))
                                    )
                                    .foregroundStyle(showChallenge ? .white : (challengeCompleted ? AppTheme.positive : AppTheme.ink))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    if showChallenge, let challenge = lesson.challenge {
                        // Challenge view
                        ChallengeView(challenge: challenge, tint: tint) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                challengeCompleted = true
                                progressStore.markCompleted(lesson.id)
                                showChallenge = false
                                if !lesson.sections.isEmpty {
                                    currentSectionIndex = lesson.sections.count - 1
                                }
                            }
                        }
                        .id("challenge")
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    } else if lesson.sections.indices.contains(currentSectionIndex) {
                        let section = lesson.sections[currentSectionIndex]

                        VStack(alignment: .leading, spacing: 18) {
                            // Section text content
                            VStack(alignment: .leading, spacing: 14) {
                                Text(section.title)
                                    .font(AppTheme.cardTitleFont)
                                    .foregroundStyle(AppTheme.ink)

                                Text(section.body)
                                    .font(AppTheme.bodyFont)
                                    .foregroundStyle(AppTheme.ink.opacity(0.85))
                                    .lineSpacing(4)
                            }
                            .padding(18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                                    .fill(AppTheme.surface.opacity(0.96))
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                                    .stroke(AppTheme.ink.opacity(0.06), lineWidth: 1)
                            }
                            .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 6)

                            // Interactive component (if this section has one)
                            if let interactive = section.interactive {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "hand.tap.fill")
                                            .font(.caption)
                                            .foregroundStyle(tint)
                                        Text("Try it yourself")
                                            .font(AppTheme.captionFont)
                                            .tracking(1.0)
                                            .foregroundStyle(tint)
                                    }

                                    InteractiveComponentView(component: interactive)
                                }
                                .padding(18)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                                        .fill(AppTheme.surface.opacity(0.96))
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                                        .stroke(tint.opacity(0.15), lineWidth: 1.5)
                                }
                                .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 6)
                            }
                        }
                        .id("section-\(currentSectionIndex)")
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }

                    // Progress indicator
                    let totalSteps = lesson.sections.count + (lesson.challenge != nil ? 1 : 0)
                    let currentProgress = showChallenge ? lesson.sections.count : currentSectionIndex
                    HStack(spacing: 6) {
                        ForEach(0..<totalSteps, id: \.self) { index in
                            Capsule()
                                .fill(index <= currentProgress ? tint : AppTheme.surfaceStrong)
                                .frame(height: 4)
                        }
                    }

                    // Navigation buttons
                    HStack(spacing: 12) {
                        if currentSectionIndex > 0 || showChallenge {
                            Button {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    if showChallenge {
                                        showChallenge = false
                                        currentSectionIndex = lesson.sections.count - 1
                                    } else {
                                        currentSectionIndex -= 1
                                    }
                                }
                            } label: {
                                Label("Previous", systemImage: "chevron.left")
                                    .font(AppTheme.bodyFont.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(AppTheme.surfaceStrong.opacity(0.5), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .foregroundStyle(AppTheme.ink)
                            }
                        }

                        if !showChallenge {
                            if isOnLastSection {
                                if lesson.challenge != nil && !challengeCompleted {
                                    // Go to challenge
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            showChallenge = true
                                        }
                                    } label: {
                                        Label("Take the Challenge", systemImage: "questionmark.diamond")
                                            .font(AppTheme.bodyFont.weight(.semibold))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(AppTheme.accentWarm, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                            .foregroundStyle(.white)
                                    }
                                } else {
                                    // Mark complete
                                    Button {
                                        progressStore.markCompleted(lesson.id)
                                    } label: {
                                        Label(
                                            progressStore.isCompleted(lesson.id) ? "Completed" : "Mark Complete",
                                            systemImage: progressStore.isCompleted(lesson.id) ? "checkmark.circle.fill" : "checkmark.circle"
                                        )
                                        .font(AppTheme.bodyFont.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            progressStore.isCompleted(lesson.id) ? AppTheme.positive.opacity(0.15) : AppTheme.positive,
                                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        )
                                        .foregroundStyle(progressStore.isCompleted(lesson.id) ? AppTheme.positive : .white)
                                    }
                                }
                            } else {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        currentSectionIndex += 1
                                    }
                                } label: {
                                    Label("Next", systemImage: "chevron.right")
                                        .font(AppTheme.bodyFont.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(tint, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                }
                .padding(AppTheme.screenPadding)
            }
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .navigationTitle(lesson.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                progressStore.markViewed(lesson.id)
                challengeCompleted = progressStore.isCompleted(lesson.id)
            }
        }
    }
}

#Preview {
    NavigationStack {
        LessonDetailView(lesson: SampleContent.lessonNeuron)
    }
    .environment(ProgressStore())
}
