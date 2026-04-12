import SwiftUI

// MARK: - Data Models

private struct AIUseCase: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let domain: String
    let description: String
    let howItWorks: String
    let tint: Color
}

private struct AlignmentPrinciple: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let summary: String
    let detail: String
    let urgency: AlignmentUrgency
}

private enum AlignmentUrgency: String {
    case critical, important, foundational

    var tint: Color {
        switch self {
        case .critical: Color(red: 0.85, green: 0.25, blue: 0.22)
        case .important: Color(red: 0.82, green: 0.58, blue: 0.16)
        case .foundational: Color(red: 0.20, green: 0.52, blue: 0.44)
        }
    }

    var label: String {
        switch self {
        case .critical: "CRITICAL"
        case .important: "IMPORTANT"
        case .foundational: "FOUNDATIONAL"
        }
    }
}

// MARK: - Content

private let realWorldUseCases: [AIUseCase] = [
    AIUseCase(
        icon: "waveform.and.magnifyingglass",
        title: "Medical Imaging",
        domain: "Healthcare",
        description: "Convolutional neural networks detect tumors, fractures, and retinal disease in X-rays, MRIs, and fundus photographs -- sometimes catching patterns radiologists miss.",
        howItWorks: "A CNN trained on millions of labeled scans learns to recognize texture and shape features that correlate with disease. The network outputs a probability, and a clinician makes the final call.",
        tint: Color(red: 0.40, green: 0.68, blue: 0.85)
    ),
    AIUseCase(
        icon: "text.bubble",
        title: "Large Language Models",
        domain: "Natural Language",
        description: "Transformer-based models like GPT and Claude generate coherent text, translate languages, write code, and reason through complex problems by predicting the next token in a sequence.",
        howItWorks: "Self-attention layers let each token attend to every other token. Pre-training on vast text corpora builds general knowledge; fine-tuning and RLHF shape behavior and safety.",
        tint: Color(red: 0.55, green: 0.45, blue: 0.78)
    ),
    AIUseCase(
        icon: "car.fill",
        title: "Autonomous Driving",
        domain: "Robotics",
        description: "Self-driving systems fuse camera, lidar, and radar data through deep neural networks to perceive lanes, pedestrians, and obstacles, then plan safe trajectories in real time.",
        howItWorks: "Perception networks segment the scene; prediction networks forecast what other agents will do; a planner chooses a safe path. The whole pipeline runs many times per second.",
        tint: Color(red: 0.30, green: 0.65, blue: 0.50)
    ),
    AIUseCase(
        icon: "music.note.list",
        title: "Recommendation Systems",
        domain: "Consumer Tech",
        description: "Streaming platforms, social feeds, and shopping sites use neural collaborative filtering and embeddings to predict what you will enjoy next based on behavior patterns.",
        howItWorks: "User and item embeddings are learned so that similar tastes land near each other in a high-dimensional space. A scoring network ranks candidates and the top results surface.",
        tint: Color(red: 0.85, green: 0.52, blue: 0.30)
    ),
    AIUseCase(
        icon: "bolt.shield",
        title: "Cybersecurity",
        domain: "Security",
        description: "Anomaly-detection networks monitor network traffic, flagging unusual patterns that could signal intrusions, malware, or data exfiltration -- far faster than manual log review.",
        howItWorks: "Autoencoders learn what normal traffic looks like. When new data reconstructs poorly, the high reconstruction error triggers an alert for human analysts to investigate.",
        tint: Color(red: 0.72, green: 0.35, blue: 0.38)
    ),
    AIUseCase(
        icon: "cloud.sun.rain",
        title: "Weather & Climate",
        domain: "Earth Science",
        description: "Neural weather models now rival traditional physics simulations, producing accurate 10-day forecasts in seconds rather than hours on supercomputers.",
        howItWorks: "Graph neural networks process atmospheric data on a mesh of points around the globe. Trained on decades of reanalysis data, they learn the dynamics of pressure, wind, and moisture.",
        tint: Color(red: 0.35, green: 0.58, blue: 0.72)
    ),
]

private let alignmentPrinciples: [AlignmentPrinciple] = [
    AlignmentPrinciple(
        icon: "target",
        title: "Value Alignment",
        summary: "Systems should pursue goals that reflect human values.",
        detail: "The core challenge: how do you formally specify what humans actually want? Reward hacking, Goodhart's law, and the difficulty of encoding nuanced preferences mean that a misspecified objective can lead a powerful optimizer to behave in harmful ways, even without malice.",
        urgency: .critical
    ),
    AlignmentPrinciple(
        icon: "eye.trianglebadge.exclamationmark",
        title: "Interpretability",
        summary: "We need to understand what models are actually doing inside.",
        detail: "Mechanistic interpretability aims to reverse-engineer the computations inside neural networks -- finding circuits, features, and representations. If we can read the model's reasoning, we can spot deception, bias, or dangerous capabilities before deployment.",
        urgency: .critical
    ),
    AlignmentPrinciple(
        icon: "person.2.badge.gearshape",
        title: "RLHF & Constitutional AI",
        summary: "Training models to follow principles via human feedback.",
        detail: "Reinforcement Learning from Human Feedback trains a reward model on human preferences, then optimizes the AI to score well. Constitutional AI extends this by having the model critique its own outputs against a set of principles, reducing the need for constant human labeling.",
        urgency: .important
    ),
    AlignmentPrinciple(
        icon: "exclamationmark.triangle",
        title: "Robustness & Red-Teaming",
        summary: "Proactively finding failure modes before they cause harm.",
        detail: "Red teams try to elicit harmful behavior through adversarial prompts, jailbreaks, and edge cases. Robust models should degrade gracefully, refuse dangerous requests, and flag uncertainty rather than confabulating confidently.",
        urgency: .important
    ),
    AlignmentPrinciple(
        icon: "lock.shield",
        title: "Containment & Control",
        summary: "Keeping AI systems within intended boundaries.",
        detail: "As models become more capable, the ability to monitor, pause, and correct them becomes essential. This includes sandboxing, capability limitations, human-in-the-loop approvals for high-stakes actions, and killswitches that the system cannot circumvent.",
        urgency: .critical
    ),
    AlignmentPrinciple(
        icon: "scalemass",
        title: "Governance & Policy",
        summary: "Society-level coordination on safe AI development.",
        detail: "Technical alignment alone is not enough. We need international agreements, compute governance, mandatory safety evaluations, whistleblower protections, and open research norms so that competitive pressure does not erode safety standards.",
        urgency: .foundational
    ),
    AlignmentPrinciple(
        icon: "arrow.trianglehead.branch",
        title: "Scalable Oversight",
        summary: "Supervising systems smarter than the supervisor.",
        detail: "Debate, recursive reward modeling, and iterated amplification are research programs for maintaining human oversight even when AI systems can solve problems humans cannot directly check. The goal: never lose the ability to verify.",
        urgency: .foundational
    ),
]

// MARK: - Main View

struct AIInPracticeView: View {
    @State private var selectedUseCase: AIUseCase?
    @State private var expandedAlignmentID: UUID?
    @State private var showAlignmentFirst = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    heroSection

                    toggleBar

                    if showAlignmentFirst {
                        alignmentSection
                        useCasesSection
                    } else {
                        useCasesSection
                        alignmentSection
                    }

                    callToActionSection
                }
                .padding(AppTheme.screenPadding)
            }
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .navigationTitle("AI in Practice")
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("REAL WORLD")
                    .font(AppTheme.captionFont)
                    .tracking(1.2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.55, green: 0.45, blue: 0.78).opacity(0.12), in: Capsule())
                    .foregroundStyle(Color(red: 0.55, green: 0.45, blue: 0.78))

                Spacer()

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 22))
                    .foregroundStyle(AppTheme.accent.opacity(0.4))
            }

            Text("How Neural Networks Shape the World")
                .font(AppTheme.heroTitleFont)
                .foregroundStyle(AppTheme.ink)

            Text("From hospital scans to climate forecasts, neural networks are already embedded in critical systems. Understanding how they work -- and how to keep them safe -- matters for everyone.")
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.mutedInk)
                .lineSpacing(3)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.55, green: 0.45, blue: 0.78), Color(red: 0.55, green: 0.45, blue: 0.78).opacity(0.15)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 104, height: 4)
                .clipShape(Capsule())
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.surface, Color(red: 0.55, green: 0.45, blue: 0.78).opacity(0.10)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(Color(red: 0.55, green: 0.45, blue: 0.78).opacity(0.15), lineWidth: 1)

                Circle()
                    .fill(Color(red: 0.55, green: 0.45, blue: 0.78).opacity(0.08))
                    .frame(width: 180, height: 180)
                    .offset(x: 48, y: -56)
            }
        )
    }

    // MARK: - Toggle

    private var toggleBar: some View {
        HStack(spacing: 0) {
            toggleButton(title: "Applications", isActive: !showAlignmentFirst) {
                withAnimation(.easeInOut(duration: 0.25)) { showAlignmentFirst = false }
            }
            toggleButton(title: "Alignment", isActive: showAlignmentFirst) {
                withAnimation(.easeInOut(duration: 0.25)) { showAlignmentFirst = true }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.surfaceStrong.opacity(0.6))
        )
    }

    private func toggleButton(title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(isActive ? AppTheme.ink : AppTheme.mutedInk)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isActive ? AppTheme.surface : .clear)
                        .shadow(color: isActive ? .black.opacity(0.06) : .clear, radius: 4, y: 2)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Use Cases

    private var useCasesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(AppTheme.accentWarm)
                Text("AI in the Wild")
                    .font(AppTheme.cardTitleFont)
                    .foregroundStyle(AppTheme.ink)
            }
            .padding(.top, 4)

            ForEach(realWorldUseCases) { useCase in
                useCaseCard(useCase)
            }
        }
    }

    private func useCaseCard(_ useCase: AIUseCase) -> some View {
        let isExpanded = selectedUseCase?.id == useCase.id

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    selectedUseCase = isExpanded ? nil : useCase
                }
            } label: {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(useCase.tint.opacity(0.12))
                            .frame(width: 48, height: 48)

                        Image(systemName: useCase.icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(useCase.tint)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(useCase.domain.uppercased())
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .tracking(0.8)
                            .foregroundStyle(useCase.tint)

                        Text(useCase.title)
                            .font(AppTheme.cardTitleFont)
                            .foregroundStyle(AppTheme.ink)

                        Text(useCase.description)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(AppTheme.mutedInk)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppTheme.mutedInk.opacity(0.5))
                        .padding(.top, 4)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .background(useCase.tint.opacity(0.2))
                        .padding(.vertical, 8)

                    HStack(spacing: 6) {
                        Image(systemName: "gearshape.2")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(useCase.tint)
                        Text("How It Works")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(useCase.tint)
                    }

                    Text(useCase.howItWorks)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(AppTheme.mutedInk)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.leading, 62)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                .fill(AppTheme.surface.opacity(0.96))
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                .stroke(isExpanded ? useCase.tint.opacity(0.2) : AppTheme.ink.opacity(0.06), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 6)
    }

    // MARK: - Alignment Section

    private var alignmentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "shield.checkerboard")
                        .foregroundStyle(Color(red: 0.85, green: 0.25, blue: 0.22))
                    Text("AI Alignment")
                        .font(AppTheme.cardTitleFont)
                        .foregroundStyle(AppTheme.ink)
                }

                Text("Building AI that does what we actually want -- and stays that way as it grows more capable -- is one of the defining challenges of our time.")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(AppTheme.mutedInk)
                    .lineSpacing(2)
            }
            .padding(.top, 4)

            ForEach(alignmentPrinciples) { principle in
                alignmentCard(principle)
            }
        }
    }

    private func alignmentCard(_ principle: AlignmentPrinciple) -> some View {
        let isExpanded = expandedAlignmentID == principle.id

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    expandedAlignmentID = isExpanded ? nil : principle.id
                }
            } label: {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(principle.urgency.tint.opacity(0.12))
                            .frame(width: 44, height: 44)

                        Image(systemName: principle.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(principle.urgency.tint)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(principle.urgency.label)
                                .font(.system(size: 9, weight: .heavy, design: .rounded))
                                .tracking(0.6)
                                .foregroundStyle(principle.urgency.tint)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(principle.urgency.tint.opacity(0.10), in: Capsule())
                        }

                        Text(principle.title)
                            .font(AppTheme.cardTitleFont)
                            .foregroundStyle(AppTheme.ink)

                        Text(principle.summary)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(AppTheme.mutedInk)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppTheme.mutedInk.opacity(0.5))
                        .padding(.top, 4)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .background(principle.urgency.tint.opacity(0.2))
                        .padding(.vertical, 8)

                    Text(principle.detail)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(AppTheme.mutedInk)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.leading, 58)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                .fill(AppTheme.surface.opacity(0.96))
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                .stroke(isExpanded ? principle.urgency.tint.opacity(0.2) : AppTheme.ink.opacity(0.06), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 6)
    }

    // MARK: - Call to Action

    private var callToActionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "hand.raised.fingers.spread")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppTheme.accent)

                Text("What You Can Do")
                    .font(AppTheme.cardTitleFont)
                    .foregroundStyle(AppTheme.ink)
            }

            VStack(alignment: .leading, spacing: 12) {
                actionRow(
                    number: "1",
                    text: "Learn the fundamentals. Understanding how neural networks learn gives you the vocabulary to evaluate AI claims critically."
                )
                actionRow(
                    number: "2",
                    text: "Support alignment research. Organizations like Anthropic, MIRI, ARC, and Redwood Research are working on technical safety -- their work needs funding and talented people."
                )
                actionRow(
                    number: "3",
                    text: "Demand transparency. Push for interpretability standards, safety evaluations, and public reporting of model capabilities and limitations."
                )
                actionRow(
                    number: "4",
                    text: "Advocate for governance. Engage with policy discussions about compute thresholds, deployment standards, and international coordination on frontier AI."
                )
                actionRow(
                    number: "5",
                    text: "Stay skeptical. Hype and doomerism both obscure the real, nuanced challenges. Calibrate your beliefs to the evidence."
                )
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.surface, AppTheme.accent.opacity(0.06)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                    .stroke(AppTheme.accent.opacity(0.12), lineWidth: 1)
            }
        )
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 6)
        .padding(.bottom, 20)
    }

    private func actionRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(AppTheme.accent, in: Circle())

            Text(text)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.mutedInk)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    AIInPracticeView()
}
