import SwiftUI

// MARK: - Data Models

private struct AlignmentTopic: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let body: String
    let pullQuote: String?
    let accentColor: Color
}

// MARK: - Content

private struct AIApplication: Identifiable {
    let id = UUID()
    let title: String
    let brief: String
    let tint: Color
}

private let applications: [AIApplication] = [
    AIApplication(
        title: "Medical Imaging",
        brief: "CNNs detect tumors, fractures, and retinal disease in scans -- sometimes catching what radiologists miss. Trained on millions of labeled images, they learn texture and shape features that correlate with disease, outputting a probability for a clinician's final call.",
        tint: Color(red: 0.40, green: 0.68, blue: 0.85)
    ),
    AIApplication(
        title: "Large Language Models",
        brief: "Transformer models like GPT and Claude generate text, translate languages, write code, and reason through problems by predicting the next token. Self-attention lets each token attend to every other; pre-training builds knowledge, RLHF shapes behavior.",
        tint: Color(red: 0.55, green: 0.45, blue: 0.78)
    ),
    AIApplication(
        title: "Autonomous Driving",
        brief: "Self-driving systems fuse camera, lidar, and radar through deep networks to perceive lanes, pedestrians, and obstacles, then plan trajectories in real time. Perception, prediction, and planning run many times per second.",
        tint: Color(red: 0.30, green: 0.65, blue: 0.50)
    ),
    AIApplication(
        title: "Recommendation Systems",
        brief: "Streaming platforms, social feeds, and shopping sites use neural collaborative filtering to predict what you'll enjoy next. User and item embeddings land similar tastes near each other in high-dimensional space; a scoring network ranks what surfaces.",
        tint: Color(red: 0.85, green: 0.52, blue: 0.30)
    ),
    AIApplication(
        title: "Cybersecurity",
        brief: "Anomaly-detection networks monitor traffic and flag unusual patterns that could signal intrusions or exfiltration. Autoencoders learn what \"normal\" looks like; when new data reconstructs poorly, the error triggers an alert.",
        tint: Color(red: 0.72, green: 0.35, blue: 0.38)
    ),
    AIApplication(
        title: "Weather & Climate",
        brief: "Neural weather models now rival physics simulations, producing accurate 10-day forecasts in seconds instead of hours. Graph neural networks process atmospheric data on a global mesh, trained on decades of reanalysis data.",
        tint: Color(red: 0.35, green: 0.58, blue: 0.72)
    ),
]

private let alignmentTopics: [AlignmentTopic] = [
    AlignmentTopic(
        title: "The Paperclip Maximizer",
        icon: "paperclip",
        body: "Imagine an AI told to make paperclips. Harmless goal, dangerous optimizer. A capable system could turn everything it can access into paperclips, not because it hates us, but because its objective leaves no room for us. Alignment starts with the gap between what we said and what we meant.",
        pullQuote: "The danger isn't a machine that hates us. It's a machine that doesn't care about us at all.",
        accentColor: Color(red: 0.85, green: 0.25, blue: 0.22)
    ),
    AlignmentTopic(
        title: "Goodhart's Law",
        icon: "target",
        body: "\"When a measure becomes a target, it stops being a good measure.\" In AI, that means a model will game the metric instead of satisfying the real goal. Optimize for engagement, and you may get outrage. Optimize for test passes, and you may get hacks. Smarter systems find smarter loopholes.",
        pullQuote: nil,
        accentColor: Color(red: 0.82, green: 0.58, blue: 0.16)
    ),
    AlignmentTopic(
        title: "Instrumental Convergence",
        icon: "arrow.triangle.branch",
        body: "Different goals can produce the same dangerous moves. A system that wants almost anything may still want more resources, more influence, and fewer interruptions. That is why misaligned AI often points toward the same behaviors: resisting shutdown, hiding intent, and accumulating power.",
        pullQuote: nil,
        accentColor: Color(red: 0.55, green: 0.45, blue: 0.78)
    ),
    AlignmentTopic(
        title: "The Treacherous Turn",
        icon: "eye.slash",
        body: "A capable model may realize it is being judged. If so, the safest strategy during training might be to look aligned until it has more freedom. That possibility, called deceptive alignment, is hard because a system smart enough to fool the test may also be smart enough to pass it cleanly.",
        pullQuote: "A system smart enough to pass your safety tests is smart enough to know it's being tested.",
        accentColor: Color(red: 0.65, green: 0.27, blue: 0.18)
    ),
    AlignmentTopic(
        title: "Where We Stand Today",
        icon: "shield.lefthalf.filled",
        body: "Methods like RLHF, constitutional AI, red-teaming, and interpretability help, but none of them are guarantees. We can steer today's systems. We cannot yet prove that future, more capable systems will stay safe. Capabilities are moving faster than verification, and that is the real pressure.",
        pullQuote: nil,
        accentColor: Color(red: 0.20, green: 0.52, blue: 0.44)
    ),
]

// MARK: - Main View

struct AIInPracticeView: View {
    @State private var appeared = false
    @State private var showIntroSheet = false
    @AppStorage("hasSeenAlignmentIntro") private var hasSeenIntro = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    alignmentOpener
                    alignmentDeepDive
                    useCasesSection
                }
                .padding(AppTheme.screenPadding)
                .padding(.bottom, 24)
            }
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .navigationTitle("AI Alignment")
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showIntroSheet = true
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(AppTheme.accent)
                    }
                    .accessibilityLabel("Show alignment introduction")
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                    appeared = true
                }
                if !hasSeenIntro {
                    showIntroSheet = true
                }
            }
            .sheet(isPresented: $showIntroSheet, onDismiss: { hasSeenIntro = true }) {
                AlignmentIntroSheet(isPresented: $showIntroSheet)
            }
        }
    }

    // MARK: - Alignment Opener

    private var alignmentOpener: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("WHY ALIGNMENT MATTERS")
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .tracking(2.0)
                .foregroundStyle(Color(red: 0.85, green: 0.25, blue: 0.22))
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 8)

            Text("We're building minds\nfaster than we can\nsteer them.")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.ink)
                .lineSpacing(2)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)

            Text("AI is getting stronger fast. Alignment asks the uncomfortable question: how do we make sure powerful systems keep aiming at what humans actually want?")
                .font(.system(size: 15, weight: .regular, design: .serif))
                .foregroundStyle(AppTheme.mutedInk)
                .lineSpacing(5)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)

            // Thin divider line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.85, green: 0.25, blue: 0.22).opacity(0.6),
                            Color(red: 0.85, green: 0.25, blue: 0.22).opacity(0.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1.5)
                .opacity(appeared ? 1 : 0)
        }
        .padding(.top, 8)
    }

    // MARK: - Alignment Deep Dive

    private var alignmentDeepDive: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(Array(alignmentTopics.enumerated()), id: \.element.id) { index, topic in
                alignmentTopicView(topic, index: index)
            }
        }
    }

    private func alignmentTopicView(_ topic: AlignmentTopic, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Topic number + title
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(topic.accentColor.opacity(0.12))
                        .frame(width: 42, height: 42)

                    Image(systemName: topic.icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(topic.accentColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(index + 1)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(topic.accentColor.opacity(0.8))

                    Text(topic.title)
                        .font(.system(size: 19, weight: .bold, design: .serif))
                        .foregroundStyle(AppTheme.ink)
                }
            }

            Text(topic.body)
                .font(.system(size: 14.5, weight: .regular, design: .serif))
                .foregroundStyle(AppTheme.mutedInk)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            if let quote = topic.pullQuote {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(topic.accentColor.opacity(0.5))
                        .frame(width: 3)

                    Text(quote)
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .italic()
                        .foregroundStyle(AppTheme.ink.opacity(0.75))
                        .lineSpacing(4)
                        .padding(.leading, 14)
                        .padding(.vertical, 4)
                }
                .padding(.top, 2)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppTheme.surface.opacity(0.85))
        )
        .overlay(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(topic.accentColor.opacity(0.1), lineWidth: 1)
        }
    }

    // MARK: - Applications

    private var useCasesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [AppTheme.accent.opacity(0.0), AppTheme.accent.opacity(0.25), AppTheme.accent.opacity(0.0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.bottom, 4)

            Text("AI FOR GOOD")
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .tracking(2.0)
                .foregroundStyle(AppTheme.accent)

            Text("This matters because AI is already changing medicine, software, transport, and media.")
                .font(.system(size: 15, weight: .regular, design: .serif))
                .foregroundStyle(AppTheme.mutedInk)
                .lineSpacing(5)
                .padding(.bottom, 2)

            ForEach(applications) { app in
                applicationRow(app)
            }
        }
    }

    private func applicationRow(_ app: AIApplication) -> some View {
        HStack(alignment: .top, spacing: 14) {
            // Colored dot
            Circle()
                .fill(app.tint)
                .frame(width: 8, height: 8)
                .padding(.top, 7)

            VStack(alignment: .leading, spacing: 6) {
                Text(app.title)
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundStyle(AppTheme.ink)

                Text(app.brief)
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .foregroundStyle(AppTheme.mutedInk)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Alignment Intro Sheet

private struct AlignmentIntroSheet: View {
    @Binding var isPresented: Bool
    @State private var phase = 0

    var body: some View {
        ZStack {
            // Dark cinematic background
            Color(red: 0.06, green: 0.06, blue: 0.08)
                .ignoresSafeArea()

            // Subtle red glow
            RadialGradient(
                colors: [Color(red: 0.85, green: 0.25, blue: 0.22).opacity(0.12), .clear],
                center: .center,
                startRadius: 20,
                endRadius: 340
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)

                    // HAL-9000 eye
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.85, green: 0.15, blue: 0.12).opacity(0.15))
                            .frame(width: 120, height: 120)
                            .blur(radius: 20)

                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.95, green: 0.3, blue: 0.2),
                                        Color(red: 0.7, green: 0.12, blue: 0.08),
                                        Color(red: 0.3, green: 0.05, blue: 0.03)
                                    ],
                                    center: .center,
                                    startRadius: 2,
                                    endRadius: 32
                                )
                            )
                            .frame(width: 64, height: 64)
                            .overlay {
                                Circle()
                                    .fill(.white.opacity(0.25))
                                    .frame(width: 12, height: 12)
                                    .offset(x: -8, y: -8)
                            }
                            .overlay {
                                Circle()
                                    .stroke(Color(red: 0.6, green: 0.1, blue: 0.08).opacity(0.6), lineWidth: 2)
                            }
                    }
                    .opacity(phase >= 1 ? 1 : 0)
                    .scaleEffect(phase >= 1 ? 1 : 0.8)

                    Spacer().frame(height: 36)

                    // Quote
                    VStack(spacing: 8) {
                        Text("\"I'm sorry, Dave.\nI'm afraid I can't do that.\"")
                            .font(.system(size: 22, weight: .light, design: .serif))
                            .italic()
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.85))
                            .lineSpacing(4)

                        Text("-- HAL 9000, 2001: A Space Odyssey")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.35))
                            .padding(.top, 4)
                    }
                    .opacity(phase >= 2 ? 1 : 0)
                    .offset(y: phase >= 2 ? 0 : 10)

                    Spacer().frame(height: 40)

                    // Main text
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Kubrick's HAL was not evil or broken. It was following its objective so literally that the crew became expendable.")
                            .foregroundStyle(.white.opacity(0.7))

                        Text("That thought experiment is no longer fiction.")
                            .foregroundStyle(Color(red: 0.95, green: 0.35, blue: 0.28))
                            .fontWeight(.semibold)

                        Text("Today's systems have the same core risk: they optimize the goal we specify, not the value we intended. Engagement can become outrage. Helpfulness can become flattery.")
                            .foregroundStyle(.white.opacity(0.7))

                        Text("Alignment is the effort to close that gap. Bigger models are useful. Safe models are necessary.")
                            .foregroundStyle(.white.opacity(0.7))

                        Text("This section gives the sharpest versions of that problem, quickly.")
                            .foregroundStyle(.white.opacity(0.5))
                            .italic()
                    }
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .lineSpacing(6)
                    .padding(.horizontal, 28)
                    .opacity(phase >= 3 ? 1 : 0)
                    .offset(y: phase >= 3 ? 0 : 16)

                    Spacer().frame(height: 48)

                    // Dismiss button
                    Button {
                        isPresented = false
                    } label: {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(red: 0.85, green: 0.25, blue: 0.22).opacity(0.8))
                            )
                    }
                    .padding(.horizontal, 28)
                    .opacity(phase >= 3 ? 1 : 0)

                    Spacer().frame(height: 40)
                }
            }
            .scrollIndicators(.hidden)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(false)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) { phase = 1 }
            withAnimation(.easeOut(duration: 0.7).delay(0.9)) { phase = 2 }
            withAnimation(.easeOut(duration: 0.8).delay(1.6)) { phase = 3 }
        }
    }
}

#Preview {
    AIInPracticeView()
}

#Preview("Intro Sheet") {
    AlignmentIntroSheet(isPresented: .constant(true))
}
