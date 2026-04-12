import SwiftUI

struct OnboardingView: View {
    @Environment(ProgressStore.self) private var progressStore
    @State private var phase: OnboardingPhase = .welcome
    @State private var selectedLevel: LearnerLevel?
    @State private var selectedInterest: LearningInterest?
    @State private var selectedGoal: LearningGoal?

    private enum OnboardingPhase: Int, CaseIterable {
        case welcome
        case level
        case interest
        case goal
        case ready

        var stepIndex: Int {
            switch self {
            case .welcome: 0
            case .level: 1
            case .interest: 2
            case .goal: 3
            case .ready: 4
            }
        }
    }

    private var generatedPlan: PersonalizedPlan? {
        guard let selectedLevel, let selectedInterest, let selectedGoal else { return nil }
        return SampleContent.makePersonalizedPlan(level: selectedLevel, interest: selectedInterest, goal: selectedGoal)
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                if phase != .welcome {
                    onboardingProgress
                        .padding(.bottom, 28)
                }

                switch phase {
                case .welcome:
                    welcomeContent
                case .level:
                    levelContent
                case .interest:
                    interestContent
                case .goal:
                    goalContent
                case .ready:
                    readyContent
                }
            }
            .padding(AppTheme.screenPadding)
        }
    }

    private var onboardingProgress: some View {
        HStack(spacing: 8) {
            ForEach(1..<OnboardingPhase.allCases.count, id: \.self) { index in
                Capsule()
                    .fill(index <= phase.stepIndex ? AppTheme.accent : AppTheme.surfaceStrong)
                    .frame(height: 5)
            }
        }
    }

    private var welcomeContent: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    VStack(spacing: 18) {
                        Image(systemName: "point.3.connected.trianglepath.dotted")
                            .font(.system(size: 56, weight: .light))
                            .foregroundStyle(AppTheme.accent)
                            .padding(.top, 24)

                        Text("Why Neural Networks Matter")
                            .font(AppTheme.heroTitleFont)
                            .foregroundStyle(AppTheme.ink)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Large language models, image generation, voice assistants, and modern recommendation systems all run on neural networks.")
                            .font(AppTheme.bodyFont)
                            .foregroundStyle(AppTheme.mutedInk)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    SectionCard(title: "What You're About To Understand", eyebrow: "Motivation") {
                        VStack(alignment: .leading, spacing: 12) {
                            onboardingBullet(text: "Why tools like ChatGPT and other LLMs are possible at all")
                            onboardingBullet(text: "How models turn inputs into predictions, language, and images")
                            onboardingBullet(text: "What learning inside a neural network actually looks like")
                        }
                    }

                    SectionCard(title: "Then We'll Personalize It", eyebrow: "Your Plan") {
                        VStack(alignment: .leading, spacing: 12) {
                            onboardingBullet(text: "A recommended lesson sequence based on your starting point")
                            onboardingBullet(text: "A focused theme tied to your main interest")
                            onboardingBullet(text: "A clear progress bar on Home so you always know what's next")
                        }
                    }
                }
                .padding(.bottom, 24)
            }

            Button {
                withAnimation(.easeInOut(duration: 0.35)) {
                    phase = .level
                }
            } label: {
                Text("Build My Plan")
                    .font(AppTheme.bodyFont.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .foregroundStyle(.white)
            }
        }
    }

    private var levelContent: some View {
        questionLayout(
            eyebrow: "Question 1",
            title: "What’s your current level?",
            subtitle: "Pick the description that feels closest to where you are right now."
        ) {
            VStack(spacing: 12) {
                ForEach(LearnerLevel.allCases, id: \.self) { level in
                    LevelOptionCard(level: level, isSelected: selectedLevel == level) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedLevel = level
                        }
                    }
                }
            }
        } action: {
            Button {
                withAnimation(.easeInOut(duration: 0.35)) {
                    phase = .interest
                }
            } label: {
                Text("Continue")
                    .font(AppTheme.bodyFont.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(selectedLevel != nil ? AppTheme.accent : AppTheme.surfaceStrong)
                    )
                    .foregroundStyle(selectedLevel != nil ? .white : AppTheme.mutedInk)
            }
            .disabled(selectedLevel == nil)
        }
    }

    private var interestContent: some View {
        questionLayout(
            eyebrow: "Question 2",
            title: "What are you most interested in?",
            subtitle: "This becomes the main thread running through your personalized plan."
        ) {
            VStack(spacing: 12) {
                ForEach(LearningInterest.allCases, id: \.self) { interest in
                    ChoiceCard(
                        title: interest.title,
                        subtitle: interest.description,
                        icon: interest.icon,
                        isSelected: selectedInterest == interest,
                        tint: AppTheme.accent
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedInterest = interest
                        }
                    }
                }
            }
        } action: {
            Button {
                withAnimation(.easeInOut(duration: 0.35)) {
                    phase = .goal
                }
            } label: {
                Text("Continue")
                    .font(AppTheme.bodyFont.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(selectedInterest != nil ? AppTheme.accent : AppTheme.surfaceStrong)
                    )
                    .foregroundStyle(selectedInterest != nil ? .white : AppTheme.mutedInk)
            }
            .disabled(selectedInterest == nil)
        }
    }

    private var goalContent: some View {
        questionLayout(
            eyebrow: "Question 3",
            title: "How do you want to learn?",
            subtitle: "Choose the angle that should shape the explanations and lesson order."
        ) {
            VStack(spacing: 12) {
                ForEach(LearningGoal.allCases, id: \.self) { goal in
                    ChoiceCard(
                        title: goal.title,
                        subtitle: goal.description,
                        icon: goal.icon,
                        isSelected: selectedGoal == goal,
                        tint: AppTheme.accentWarm
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedGoal = goal
                        }
                    }
                }
            }
        } action: {
            Button {
                guard let selectedLevel, let selectedInterest, let selectedGoal else { return }
                progressStore.createPersonalizedPlan(level: selectedLevel, interest: selectedInterest, goal: selectedGoal)
                withAnimation(.easeInOut(duration: 0.35)) {
                    phase = .ready
                }
            } label: {
                Text("Create My Plan")
                    .font(AppTheme.bodyFont.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(selectedGoal != nil ? AppTheme.positive : AppTheme.surfaceStrong)
                    )
                    .foregroundStyle(selectedGoal != nil ? .white : AppTheme.mutedInk)
            }
            .disabled(selectedGoal == nil)
        }
    }

    private var readyContent: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 14) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 46, weight: .light))
                    .foregroundStyle(AppTheme.positive)

                Text("Your plan is ready")
                    .font(AppTheme.titleFont)
                    .foregroundStyle(AppTheme.ink)
            }

            if let generatedPlan {
                SectionCard(title: generatedPlan.title, eyebrow: "Personalized Plan") {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(generatedPlan.summary)
                            .font(AppTheme.bodyFont)
                            .foregroundStyle(AppTheme.mutedInk)
                            .lineSpacing(3)

                        HStack(spacing: 10) {
                            planTag(text: generatedPlan.level.shortLabel, tint: AppTheme.positive)
                            planTag(text: generatedPlan.interest.title, tint: AppTheme.accent)
                            planTag(text: generatedPlan.goal.title, tint: AppTheme.accentWarm)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(generatedPlan.lessonIDs.prefix(3).enumerated()), id: \.offset) { index, lessonID in
                                if let lesson = SampleContent.lesson(for: lessonID) {
                                    HStack(spacing: 10) {
                                        Text("\(index + 1)")
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                            .foregroundStyle(AppTheme.accent)
                                            .frame(width: 24, height: 24)
                                            .background(AppTheme.accent.opacity(0.12), in: Circle())

                                        Text(lesson.title)
                                            .font(AppTheme.bodyFont)
                                            .foregroundStyle(AppTheme.ink)
                                    }
                                }
                            }
                        }

                        Text("You’ll start with the first 5 lessons, and the next sequence will appear automatically as you finish them.")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.mutedInk)
                    }
                }
            }

            Spacer()

            Button {
                progressStore.hasCompletedOnboarding = true
            } label: {
                Text("Go To Home")
                    .font(AppTheme.bodyFont.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.positive, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .foregroundStyle(.white)
            }
        }
    }

    private func questionLayout<Content: View, Action: View>(
        eyebrow: String,
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content,
        @ViewBuilder action: () -> Action
    ) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(eyebrow.uppercased())
                    .font(AppTheme.captionFont)
                    .tracking(1.2)
                    .foregroundStyle(AppTheme.accent)

                Text(title)
                    .font(AppTheme.titleFont)
                    .foregroundStyle(AppTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(subtitle)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            content()

            Spacer()

            action()
        }
    }

    private func onboardingBullet(text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppTheme.positive)

            Text(text)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func planTag(text: String, tint: Color) -> some View {
        Text(text)
            .font(AppTheme.captionFont)
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.12), in: Capsule())
    }
}

private struct ChoiceCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let tint: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : tint)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(isSelected ? tint : tint.opacity(0.12)))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTheme.cardTitleFont)
                        .foregroundStyle(AppTheme.ink)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(subtitle)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(tint)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppTheme.surface.opacity(0.96))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? tint : AppTheme.ink.opacity(0.06), lineWidth: isSelected ? 2 : 1)
            }
            .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

private struct LevelOptionCard: View {
    let level: LearnerLevel
    let isSelected: Bool
    let onTap: () -> Void

    private var tint: Color {
        switch level {
        case .beginner: AppTheme.positive
        case .intermediate: AppTheme.accent
        case .advanced: AppTheme.accentWarm
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: level.icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : tint)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(isSelected ? tint : tint.opacity(0.12)))

                VStack(alignment: .leading, spacing: 3) {
                    Text(level.displayName)
                        .font(AppTheme.cardTitleFont)
                        .foregroundStyle(AppTheme.ink)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(level.description)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(tint)
                        .font(.title3)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppTheme.surface.opacity(0.96))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? tint : AppTheme.ink.opacity(0.06), lineWidth: isSelected ? 2 : 1)
            }
            .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingView()
        .environment(ProgressStore())
}
