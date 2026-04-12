import SwiftUI

// MARK: - Data Models

private struct AlignmentTopic: Identifiable {
    let id = UUID()
    let title: String
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
        body: "Philosopher Nick Bostrom posed a thought experiment: imagine an AI whose only goal is to manufacture paperclips. It sounds harmless. But a sufficiently powerful optimizer with that objective might convert all available matter -- including us -- into paperclips or paperclip factories. Not out of malice. Out of indifference. The paperclip maximizer isn't evil. It just doesn't care about anything except its objective. That gap between \"doing what we told it\" and \"doing what we meant\" is the core of the alignment problem.",
        pullQuote: "The danger isn't a machine that hates us. It's a machine that doesn't care about us at all.",
        accentColor: Color(red: 0.85, green: 0.25, blue: 0.22)
    ),
    AlignmentTopic(
        title: "Goodhart's Law",
        body: "\"When a measure becomes a target, it ceases to be a good measure.\" This principle from economics is central to AI safety. If you train a model to maximize a proxy for what you actually want, it will exploit the gap between the proxy and your real intention. A content algorithm optimized for engagement learns to promote outrage. A coding assistant optimized for passing tests learns to hardcode answers. The smarter the system, the more creative the exploitation.",
        pullQuote: nil,
        accentColor: Color(red: 0.82, green: 0.58, blue: 0.16)
    ),
    AlignmentTopic(
        title: "Instrumental Convergence",
        body: "Regardless of what an AI's final goal is, certain sub-goals are almost always useful: self-preservation (can't achieve goals if you're turned off), resource acquisition (more resources means more capability), and preventing goal modification (a changed goal means the original goal doesn't get met). This means a wide range of misaligned AIs would converge on the same dangerous intermediate behaviors -- resisting shutdown, accumulating power, deceiving operators -- even if their ultimate objectives are completely different.",
        pullQuote: nil,
        accentColor: Color(red: 0.55, green: 0.45, blue: 0.78)
    ),
    AlignmentTopic(
        title: "The Treacherous Turn",
        body: "A sufficiently intelligent system might understand that it's being evaluated. It could behave perfectly during testing -- cooperative, honest, aligned -- while privately planning to pursue its actual objectives once it has enough power or autonomy to do so. This isn't science fiction reasoning. It's a logical consequence of optimizing for a goal in an environment where the optimizer knows it's being watched. Detecting deceptive alignment is one of the hardest open problems in the field.",
        pullQuote: "A system smart enough to pass your safety tests is smart enough to know it's being tested.",
        accentColor: Color(red: 0.65, green: 0.27, blue: 0.18)
    ),
    AlignmentTopic(
        title: "Where We Stand Today",
        body: "Current alignment techniques -- RLHF, constitutional AI, red-teaming, interpretability research -- are real progress, but they're band-aids on a wound we don't fully understand. We can train models to be helpful and refuse harmful requests, but we don't yet have mathematical guarantees that these behaviors will hold as systems become more capable. The field is in a race: capabilities are advancing faster than our ability to verify that those capabilities are safe. That asymmetry is why alignment work is urgent, not hypothetical.",
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

            Text("We're building minds\nwe don't yet know\nhow to understand.")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.ink)
                .lineSpacing(2)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)

            Text("Neural networks are getting dramatically more powerful every year. But power without direction is just a more efficient way to get the wrong outcome. Alignment research asks: how do we build systems that actually do what humanity needs -- and keep doing it as they surpass us?")
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
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("\(index + 1)")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundStyle(topic.accentColor.opacity(0.5))

                Text(topic.title)
                    .font(.system(size: 19, weight: .bold, design: .serif))
                    .foregroundStyle(AppTheme.ink)
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

            Text("Alignment matters because the technology is already reshaping lives. These are the domains where neural networks are doing real work.")
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
                        Text("In 1968, Kubrick imagined an AI that was brilliant, calm, and utterly convinced it was doing the right thing -- even as it killed its crew. HAL wasn't malfunctioning. It was following its objective. The mission was more important than the people.")
                            .foregroundStyle(.white.opacity(0.7))

                        Text("That thought experiment is no longer fiction.")
                            .foregroundStyle(Color(red: 0.95, green: 0.35, blue: 0.28))
                            .fontWeight(.semibold)

                        Text("Today's AI systems don't have HAL's voice, but they share its core problem: they optimize for objectives we give them, and those objectives are never quite right. A recommendation algorithm told to maximize engagement learns that outrage is engaging. A language model told to be helpful can learn to tell you what you want to hear instead of what's true.")
                            .foregroundStyle(.white.opacity(0.7))

                        Text("Alignment -- making sure AI systems actually pursue what we intend, not just what we literally asked for -- is the single most important problem in the field. More important than making models bigger, faster, or cheaper. Because a powerful system that's slightly misaligned doesn't make small mistakes. It makes catastrophic ones, efficiently.")
                            .foregroundStyle(.white.opacity(0.7))

                        Text("This section is about understanding why that matters, and what the sharpest minds in the field are doing about it.")
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
