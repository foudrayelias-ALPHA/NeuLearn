import SwiftUI

// MARK: - Phase Model

private enum LabPhase: String, CaseIterable, Identifiable {
    case forward
    case loss
    case backprop
    case update

    var id: String { rawValue }

    var title: String {
        switch self {
        case .forward: "Send Signal"
        case .loss: "Measure Error"
        case .backprop: "Find Blame"
        case .update: "Adjust Weights"
        }
    }

    var technicalName: String {
        switch self {
        case .forward: "Forward Pass"
        case .loss: "Loss Function"
        case .backprop: "Backpropagation"
        case .update: "Gradient Descent"
        }
    }

    var symbol: String {
        switch self {
        case .forward: "arrow.right.circle.fill"
        case .loss: "target"
        case .backprop: "arrow.uturn.backward.circle.fill"
        case .update: "wrench.and.screwdriver.fill"
        }
    }

    var tint: Color {
        switch self {
        case .forward: LabColors.signal
        case .loss: LabColors.error
        case .backprop: LabColors.blame
        case .update: LabColors.growth
        }
    }

    var stepNumber: Int {
        switch self {
        case .forward: 1
        case .loss: 2
        case .backprop: 3
        case .update: 4
        }
    }
}

// MARK: - Color Palette

private enum LabColors {
    static let signal = Color(red: 0.45, green: 0.72, blue: 0.95)
    static let error = Color(red: 0.95, green: 0.55, blue: 0.30)
    static let blame = Color(red: 0.92, green: 0.40, blue: 0.42)
    static let growth = Color(red: 0.38, green: 0.82, blue: 0.62)
    static let input = Color(red: 0.88, green: 0.65, blue: 0.32)
    static let hidden1 = Color(red: 0.40, green: 0.60, blue: 0.85)
    static let hidden2 = Color(red: 0.58, green: 0.45, blue: 0.82)
    static let output = Color(red: 0.30, green: 0.72, blue: 0.58)
    static let dimText = Color.white.opacity(0.40)
    static let bodyText = Color.white.opacity(0.70)
    static let brightText = Color.white.opacity(0.92)
    static let bg = Color(red: 0.06, green: 0.07, blue: 0.10)
    static let bgLight = Color(red: 0.10, green: 0.11, blue: 0.15)
    static let card = Color.white.opacity(0.04)
    static let cardBorder = Color.white.opacity(0.07)
}

// MARK: - Main View

struct VisualLabView: View {
    @AppStorage("hasSeenVisualLabOverview") private var hasSeenVisualLabOverview = false
    @State private var simulation = SimpleNetworkSimulation.demo
    @State private var isTraining = false
    @State private var trainingTimer: Timer?
    @State private var activePhase: LabPhase = .forward
    @State private var focusedStep: SimpleNetworkSimulation.TrainingStepSnapshot?
    @State private var phaseSequenceToken = 0
    @State private var lossHistory: [Double] = []
    @State private var hasStarted = false
    @State private var showingOverview = false

    private var inspectedStep: SimpleNetworkSimulation.TrainingStepSnapshot {
        focusedStep ?? simulation.previewStep()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        networkCanvas

                        phaseTimeline
                            .padding(.top, 16)

                        explainerCard
                            .padding(.top, 12)

                        snapshotSummary
                            .padding(.top, 16)

                        if hasStarted {
                            weightsOverview
                                .padding(.top, 20)
                        }

                        if lossHistory.count > 1 {
                            lossChart
                                .padding(.top, 20)
                        }

                        Spacer().frame(height: 16)
                    }
                }

                bottomDock
            }
            .background(labBackground)
            .navigationTitle("Visual Lab")
            .toolbarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingOverview = true
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(LabColors.signal)
                    }
                    .accessibilityLabel("Show visual lab overview")
                }
            }
            .onAppear {
                guard !hasSeenVisualLabOverview, !showingOverview else { return }
                showingOverview = true
            }
            .onChange(of: simulation.inputs) { _, _ in resetFocus() }
            .onChange(of: simulation.targetOutput) { _, _ in resetFocus() }
            .onChange(of: simulation.learningRate) { _, _ in resetFocus() }
            .onDisappear { stopTraining() }
            .fullScreenCover(isPresented: $showingOverview, onDismiss: {
                hasSeenVisualLabOverview = true
            }) {
                visualLabOverviewSheet
            }
        }
    }

    // MARK: - Background

    private var labBackground: some View {
        LinearGradient(
            colors: [LabColors.bgLight, LabColors.bg],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Network Canvas

    private var networkCanvas: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                drawBackground(ctx: ctx, size: size)

                let inp = inputPositions(size)
                let h1 = hidden1Positions(size)
                let h2 = hidden2Positions(size)
                let out = outputPosition(size)
                let wires = allWires(inp: inp, h1: h1, h2: h2, out: out)

                for w in wires { drawWire(ctx: ctx, w: w, time: time) }

                if activePhase == .loss {
                    drawErrorPulse(ctx: ctx, center: out, time: time)
                    drawTargetMarker(ctx: ctx, near: out, target: inspectedStep.targetOutput)
                }

                // Layer labels
                drawLabel(ctx: ctx, text: "Inputs", at: CGPoint(x: inp[0].x, y: 20), color: LabColors.input, size: 10)
                drawLabel(ctx: ctx, text: "Hidden 1", at: CGPoint(x: h1[0].x, y: 20), color: LabColors.hidden1, size: 10)
                drawLabel(ctx: ctx, text: "Hidden 2", at: CGPoint(x: h2[0].x, y: 20), color: LabColors.hidden2, size: 10)
                drawLabel(ctx: ctx, text: "Output", at: CGPoint(x: out.x, y: 20), color: LabColors.output, size: 10)

                // Input nodes
                for (i, pos) in inp.enumerated() {
                    drawNode(ctx: ctx, center: pos, name: "In\(i+1)", value: inspectedStep.inputs[i], color: LabColors.input, radius: 20)
                }
                // Hidden layer 1
                for (i, pos) in h1.enumerated() {
                    drawNode(ctx: ctx, center: pos, name: "H1.\(i+1)", value: inspectedStep.hidden1Activations[i], color: LabColors.hidden1, radius: 18)
                }
                // Hidden layer 2
                for (i, pos) in h2.enumerated() {
                    drawNode(ctx: ctx, center: pos, name: "H2.\(i+1)", value: inspectedStep.hidden2Activations[i], color: LabColors.hidden2, radius: 18)
                }
                // Output node
                drawNode(ctx: ctx, center: out, name: "Out", value: inspectedStep.output, color: LabColors.output, radius: 24)
            }
        }
        .frame(height: 340)
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 24, bottomTrailingRadius: 24))
    }

    // MARK: - Node Positions

    private func inputPositions(_ size: CGSize) -> [CGPoint] {
        let x = size.width * 0.08
        return [
            CGPoint(x: x, y: size.height * 0.22),
            CGPoint(x: x, y: size.height * 0.50),
            CGPoint(x: x, y: size.height * 0.78)
        ]
    }

    private func hidden1Positions(_ size: CGSize) -> [CGPoint] {
        let x = size.width * 0.34
        return [
            CGPoint(x: x, y: size.height * 0.22),
            CGPoint(x: x, y: size.height * 0.50),
            CGPoint(x: x, y: size.height * 0.78)
        ]
    }

    private func hidden2Positions(_ size: CGSize) -> [CGPoint] {
        let x = size.width * 0.60
        return [
            CGPoint(x: x, y: size.height * 0.22),
            CGPoint(x: x, y: size.height * 0.50),
            CGPoint(x: x, y: size.height * 0.78)
        ]
    }

    private func outputPosition(_ size: CGSize) -> CGPoint {
        CGPoint(x: size.width * 0.87, y: size.height * 0.50)
    }

    // MARK: - Wires

    private struct Wire {
        let from: CGPoint, to: CGPoint
        let weightBefore: Double, weightAfter: Double, delta: Double
        enum Layer { case inputToH1, h1ToH2, h2ToOutput }
        let layer: Layer
    }

    private func allWires(inp: [CGPoint], h1: [CGPoint], h2: [CGPoint], out: CGPoint) -> [Wire] {
        var wires: [Wire] = []

        // Input → Hidden1 (fully connected: 3×3 = 9)
        for i in 0..<SimpleNetworkSimulation.inputCount {
            for j in 0..<SimpleNetworkSimulation.hidden1Count {
                let idx = i * SimpleNetworkSimulation.hidden1Count + j
                wires.append(Wire(
                    from: inp[i], to: h1[j],
                    weightBefore: inspectedStep.weightsInputToHidden1Before[idx],
                    weightAfter: inspectedStep.weightsInputToHidden1After[idx],
                    delta: inspectedStep.inputToHidden1Deltas[idx],
                    layer: .inputToH1
                ))
            }
        }

        // Hidden1 → Hidden2 (fully connected: 3×3 = 9)
        for i in 0..<SimpleNetworkSimulation.hidden1Count {
            for j in 0..<SimpleNetworkSimulation.hidden2Count {
                let idx = i * SimpleNetworkSimulation.hidden2Count + j
                wires.append(Wire(
                    from: h1[i], to: h2[j],
                    weightBefore: inspectedStep.weightsHidden1ToHidden2Before[idx],
                    weightAfter: inspectedStep.weightsHidden1ToHidden2After[idx],
                    delta: inspectedStep.hidden1ToHidden2Deltas[idx],
                    layer: .h1ToH2
                ))
            }
        }

        // Hidden2 → Output (fully connected: 3×1 = 3)
        for i in 0..<SimpleNetworkSimulation.hidden2Count {
            wires.append(Wire(
                from: h2[i], to: out,
                weightBefore: inspectedStep.weightsHidden2ToOutputBefore[i],
                weightAfter: inspectedStep.weightsHidden2ToOutputAfter[i],
                delta: inspectedStep.hidden2ToOutputDeltas[i],
                layer: .h2ToOutput
            ))
        }

        return wires
    }

    // MARK: - Phase Timeline

    private var phaseTimeline: some View {
        HStack(spacing: 4) {
            ForEach(LabPhase.allCases) { phase in
                let isActive = phase == activePhase

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) { activePhase = phase }
                } label: {
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(isActive ? phase.tint.opacity(0.2) : LabColors.card)
                                .frame(width: 36, height: 36)

                            Image(systemName: phase.symbol)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(isActive ? phase.tint : LabColors.dimText)
                        }

                        Text(phase.title)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(isActive ? phase.tint : LabColors.dimText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(isActive ? phase.tint.opacity(0.08) : .clear)
                    )
                    .overlay {
                        if isActive {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(phase.tint.opacity(0.3), lineWidth: 1)
                        }
                    }
                }
                .buttonStyle(.plain)

                if phase != .update {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(LabColors.dimText.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Explainer Card

    private var explainerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: activePhase.symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(activePhase.tint)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Step \(activePhase.stepNumber): \(activePhase.title)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(LabColors.brightText)
                    Text(activePhase.technicalName)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(activePhase.tint.opacity(0.7))
                }
            }

            Text(friendlyExplanation)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(LabColors.bodyText)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(activePhase.tint.opacity(0.06))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(activePhase.tint.opacity(0.12), lineWidth: 1)
        }
        .padding(.horizontal, 16)
    }

    private var friendlyExplanation: String {
        switch activePhase {
        case .forward:
            "Each input multiplies through 21 weighted connections across two hidden layers. Every neuron receives signals from all neurons in the previous layer, squashes them with sigmoid, and passes the result forward to produce the output."
        case .loss:
            "How wrong is the guess? We compare the output to what we wanted (the target). The bigger the gap, the bigger the loss number. This error signal is what drives the network to improve."
        case .backprop:
            "Now we work backwards through both hidden layers. Starting from the error, we figure out how much each of the 21 weights contributed to the mistake. Weights that pushed the output the wrong way get more blame."
        case .update:
            "Time to fix things. All 21 weights get nudged in the direction that would reduce the error. Green means a weight got stronger, red means it got weaker. After this, the network is slightly smarter."
        }
    }

    // MARK: - Overview Sheet

    private var visualLabOverviewSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("What Visual Lab Is")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(LabColors.brightText)

                    Text("A live sandbox for watching a neural network (3 inputs → 3 hidden → 3 hidden → 1 output) make a prediction, measure its mistake, and update all 21 weights.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(LabColors.bodyText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 12) {
                    overviewRow(
                        number: "1",
                        title: "Set the inputs",
                        detail: "Use the bottom dock to change the three inputs, the target value, and the learning rate."
                    )
                    overviewRow(
                        number: "2",
                        title: "Run the network",
                        detail: "Tap Step for a single training cycle or Auto to keep training continuously."
                    )
                    overviewRow(
                        number: "3",
                        title: "Read the feedback",
                        detail: "Follow the four phases, then watch loss drop and weights shift as the model learns."
                    )
                }

                Spacer()

                Button {
                    hasSeenVisualLabOverview = true
                    showingOverview = false
                } label: {
                    Text("Start Exploring")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(LabColors.signal, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .foregroundStyle(.white)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(labBackground)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        hasSeenVisualLabOverview = true
                        showingOverview = false
                    }
                    .foregroundStyle(LabColors.signal)
                }
            }
        }
    }

    private func overviewRow(number: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(LabColors.bg)
                .frame(width: 28, height: 28)
                .background(LabColors.signal, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(LabColors.brightText)
                Text(detail)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(LabColors.bodyText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Snapshot Summary

    private var snapshotSummary: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                summaryCell(
                    icon: "number",
                    label: "Training Step",
                    value: "\(simulation.epoch)",
                    tint: LabColors.signal
                )
                summaryCell(
                    icon: "brain",
                    label: "Network's Guess",
                    value: fmt(inspectedStep.output),
                    tint: LabColors.output
                )
            }
            HStack(spacing: 8) {
                summaryCell(
                    icon: "target",
                    label: "We Wanted",
                    value: fmt(inspectedStep.targetOutput),
                    tint: LabColors.error
                )
                summaryCell(
                    icon: "exclamationmark.triangle",
                    label: "How Wrong (Loss)",
                    value: fmt(inspectedStep.loss),
                    tint: inspectedStep.loss < 0.01 ? LabColors.growth : LabColors.blame
                )
            }

            phaseSpecificDetails
        }
        .padding(.horizontal, 16)
    }

    private func summaryCell(icon: String, label: String, value: String, tint: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(LabColors.dimText)
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundStyle(LabColors.brightText)
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(LabColors.card)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(tint.opacity(0.1), lineWidth: 0.5)
        }
    }

    private var phaseSpecificDetails: some View {
        let rows: [[(String, String, Color)]] = {
            switch activePhase {
            case .forward:
                return [
                    [("H1 activations", inspectedStep.hidden1Activations.map { fmt($0) }.joined(separator: " "), LabColors.hidden1)],
                    [("H2 activations", inspectedStep.hidden2Activations.map { fmt($0) }.joined(separator: " "), LabColors.hidden2)]
                ]
            case .loss:
                return [
                    [("Raw error", signedFmt(inspectedStep.outputError), LabColors.blame),
                     ("Squared loss", fmt(inspectedStep.loss), LabColors.error)],
                    [("Prediction", fmt(inspectedStep.output), LabColors.output),
                     ("Target", fmt(inspectedStep.targetOutput), LabColors.error)]
                ]
            case .backprop:
                return [
                    [("Output gradient", signedFmt(inspectedStep.outputGradient), LabColors.blame)],
                    [("H2 blame", inspectedStep.hidden2Gradients.map { signedFmt($0) }.joined(separator: " "), LabColors.blame)],
                    [("H1 blame", inspectedStep.hidden1Gradients.map { signedFmt($0) }.joined(separator: " "), LabColors.blame)]
                ]
            case .update:
                return [
                    [("Total weights", "21", LabColors.signal),
                     ("Learning rate", fmt(simulation.learningRate), LabColors.growth)],
                    [("Epoch", "\(simulation.epoch)", LabColors.signal)]
                ]
            }
        }()

        return VStack(spacing: 8) {
            ForEach(0..<rows.count, id: \.self) { i in
                detailRow(items: rows[i])
            }
        }
    }

    private func detailRow(items: [(String, String, Color)]) -> some View {
        HStack(spacing: 8) {
            ForEach(items, id: \.0) { label, value, tint in
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(LabColors.dimText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    Text(value)
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundStyle(tint.opacity(0.85))
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(LabColors.card)
                )
            }
        }
    }

    // MARK: - Weights Overview

    private var weightsOverview: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(LabColors.growth)
                Text("Weight Dashboard")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(LabColors.brightText)
                Spacer()
                Text("21 connections")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(LabColors.dimText)
            }
            .padding(.horizontal, 16)

            Text("Every neuron connects to every neuron in the next layer. The network learns by adjusting all 21 weights to reduce error.")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(LabColors.dimText)
                .padding(.horizontal, 16)

            // Layer-by-layer weight summary
            weightLayerSummary(
                title: "Input → Hidden 1",
                weights: activePhase == .update ? inspectedStep.weightsInputToHidden1After : inspectedStep.weightsInputToHidden1Before,
                deltas: inspectedStep.inputToHidden1Deltas,
                tint: LabColors.hidden1,
                count: 9
            )

            weightLayerSummary(
                title: "Hidden 1 → Hidden 2",
                weights: activePhase == .update ? inspectedStep.weightsHidden1ToHidden2After : inspectedStep.weightsHidden1ToHidden2Before,
                deltas: inspectedStep.hidden1ToHidden2Deltas,
                tint: LabColors.hidden2,
                count: 9
            )

            weightLayerSummary(
                title: "Hidden 2 → Output",
                weights: activePhase == .update ? inspectedStep.weightsHidden2ToOutputAfter : inspectedStep.weightsHidden2ToOutputBefore,
                deltas: inspectedStep.hidden2ToOutputDeltas,
                tint: LabColors.output,
                count: 3
            )
        }
    }

    private func weightLayerSummary(title: String, weights: [Double], deltas: [Double], tint: Color, count: Int) -> some View {
        let showChange = activePhase == .update || activePhase == .backprop
        let avgWeight = weights.reduce(0, +) / Double(count)
        let avgDelta = deltas.reduce(0, +) / Double(count)

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(tint)
                Spacer()
                Text("\(count) weights")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(LabColors.dimText)
            }

            // Weight bar visualization
            HStack(spacing: 2) {
                ForEach(0..<count, id: \.self) { i in
                    let w = weights[i]
                    let barHeight = max(4, CGFloat(abs(w)) * 30)
                    let color = showChange ? (deltas[i] >= 0 ? LabColors.growth : LabColors.blame) : tint

                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color.opacity(0.6))
                            .frame(height: barHeight)
                        Text(fmt2(w))
                            .font(.system(size: 7, weight: .medium, design: .monospaced))
                            .foregroundStyle(LabColors.dimText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 50)

            if showChange {
                HStack(spacing: 4) {
                    Image(systemName: avgDelta >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 9, weight: .bold))
                    Text("avg Δ \(signedFmt(avgDelta))")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                }
                .foregroundStyle(avgDelta >= 0 ? LabColors.growth : LabColors.blame)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(LabColors.card)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(tint.opacity(0.1), lineWidth: 0.5)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Loss Chart

    private var lossChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "chart.line.downtrend.xyaxis")
                    .foregroundStyle(LabColors.error)
                Text("Error Over Time")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(LabColors.brightText)
                Spacer()
                Text(fmt(lossHistory.last ?? 0))
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(LabColors.error.opacity(0.8))
            }

            Text("Watch this number drop as the network learns. When it gets close to zero, the network has figured out the pattern.")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(LabColors.dimText)

            Canvas { context, size in
                let count = lossHistory.count
                let step = size.width / CGFloat(max(count - 1, 1))
                let maxLoss = max(lossHistory.max() ?? 0.1, 0.01)

                var fill = Path()
                var stroke = Path()
                for (i, loss) in lossHistory.enumerated() {
                    let x = CGFloat(i) * step
                    let y = size.height - CGFloat(loss / maxLoss) * (size.height * 0.85)
                    if i == 0 {
                        stroke.move(to: CGPoint(x: x, y: y))
                        fill.move(to: CGPoint(x: 0, y: size.height))
                        fill.addLine(to: CGPoint(x: x, y: y))
                    } else {
                        stroke.addLine(to: CGPoint(x: x, y: y))
                        fill.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                fill.addLine(to: CGPoint(x: CGFloat(count - 1) * step, y: size.height))
                fill.closeSubpath()

                context.fill(fill, with: .linearGradient(
                    Gradient(colors: [LabColors.error.opacity(0.15), .clear]),
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: 0, y: size.height)
                ))
                context.stroke(stroke, with: .color(LabColors.error.opacity(0.8)), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
            .frame(height: 70)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(LabColors.card)
            )
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Bottom Dock

    @State private var dockExpanded = false

    private var bottomDock: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 0.5)

            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    Button { performTrainingStep() } label: {
                        Label("Step", systemImage: "forward.frame.fill")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(LabColors.signal.opacity(0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .foregroundStyle(LabColors.signal)
                    }
                    .disabled(isTraining)

                    Button {
                        if isTraining { stopTraining() } else { startTraining() }
                    } label: {
                        Label(isTraining ? "Pause" : "Auto", systemImage: isTraining ? "pause.fill" : "play.fill")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(LabColors.growth.opacity(0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .foregroundStyle(LabColors.growth)
                    }

                    Button {
                        stopTraining()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            simulation.reset()
                            focusedStep = nil
                            activePhase = .forward
                            lossHistory.removeAll()
                            hasStarted = false
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 13, weight: .bold))
                            .frame(width: 44)
                            .padding(.vertical, 12)
                            .background(LabColors.blame.opacity(0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .foregroundStyle(LabColors.blame.opacity(0.8))
                    }
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) { dockExpanded.toggle() }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Inputs & Settings")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                        Spacer()
                        ForEach(0..<3, id: \.self) { i in
                            dockPill("In\(i+1)", fmt2(simulation.inputs[i]), LabColors.input)
                        }
                        Image(systemName: dockExpanded ? "chevron.down" : "chevron.up")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(LabColors.bodyText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(LabColors.card)
                    )
                }
                .buttonStyle(.plain)

                if dockExpanded {
                    VStack(spacing: 8) {
                        ForEach(simulation.inputs.indices, id: \.self) { i in
                            dockSlider(
                                label: "Input \(i + 1)",
                                value: Binding(
                                    get: { simulation.inputs[i] },
                                    set: { simulation.inputs[i] = $0; resetFocus() }
                                ),
                                range: 0...1,
                                tint: LabColors.input
                            )
                        }

                        dockSlider(
                            label: "Target",
                            value: Binding(
                                get: { simulation.targetOutput },
                                set: { simulation.targetOutput = $0; resetFocus() }
                            ),
                            range: 0...1,
                            tint: LabColors.error
                        )

                        dockSlider(
                            label: "Learn Speed",
                            value: Binding(
                                get: { simulation.learningRate },
                                set: { simulation.learningRate = $0; resetFocus() }
                            ),
                            range: 0.01...2.0,
                            tint: LabColors.growth
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 8)
        }
        .background(
            LabColors.bg
                .overlay(Color.white.opacity(0.03))
        )
    }

    private func dockPill(_ label: String, _ value: String, _ tint: Color) -> some View {
        HStack(spacing: 3) {
            Text(label)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(LabColors.dimText)
            Text(value)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(tint.opacity(0.8))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(tint.opacity(0.08), in: Capsule())
    }

    private func dockSlider(label: String, value: Binding<Double>, range: ClosedRange<Double>, tint: Color) -> some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(LabColors.bodyText)
                .frame(width: 80, alignment: .leading)
            Slider(value: value, in: range)
                .tint(tint)
            Text(fmt2(value.wrappedValue))
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(tint.opacity(0.8))
                .frame(width: 32, alignment: .trailing)
        }
    }

    private func fmt2(_ v: Double) -> String {
        v.formatted(.number.precision(.fractionLength(2)))
    }

    // MARK: - Canvas Drawing Helpers

    private func drawBackground(ctx: GraphicsContext, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        ctx.fill(Path(rect), with: .linearGradient(
            Gradient(colors: [
                Color(red: 0.07, green: 0.09, blue: 0.14),
                Color(red: 0.04, green: 0.05, blue: 0.08)
            ]),
            startPoint: .zero,
            endPoint: CGPoint(x: size.width, y: size.height)
        ))

        let spacing: CGFloat = 36
        for x in stride(from: 0, through: size.width, by: spacing) {
            var p = Path()
            p.move(to: CGPoint(x: x, y: 0))
            p.addLine(to: CGPoint(x: x, y: size.height))
            ctx.stroke(p, with: .color(Color.white.opacity(0.015)), lineWidth: 0.5)
        }
        for y in stride(from: 0, through: size.height, by: spacing) {
            var p = Path()
            p.move(to: CGPoint(x: 0, y: y))
            p.addLine(to: CGPoint(x: size.width, y: y))
            ctx.stroke(p, with: .color(Color.white.opacity(0.015)), lineWidth: 0.5)
        }
    }

    private func drawWire(ctx: GraphicsContext, w: Wire, time: Double) {
        let weight = activePhase == .update ? w.weightAfter : w.weightBefore
        let thickness = max(1.0, min(4.0, 1.0 + abs(weight) * 3))
        let path = bezier(from: w.from, to: w.to)

        let color: Color
        switch activePhase {
        case .forward: color = weight >= 0 ? LabColors.signal : LabColors.error
        case .loss: color = LabColors.error
        case .backprop: color = LabColors.blame
        case .update: color = w.delta >= 0 ? LabColors.growth : LabColors.blame
        }

        let wireOpacity = activePhase == .loss ? 0.08 : 0.3
        ctx.stroke(path, with: .color(color.opacity(wireOpacity)), style: StrokeStyle(lineWidth: thickness, lineCap: .round))

        // Single particle per wire (21 wires = keep it lightweight)
        let baseT = fmod(time * 0.4, 1.0)
        let t: CGFloat = activePhase == .backprop ? CGFloat(1.0 - baseT) : CGFloat(baseT)
        let pt = bezierPoint(from: w.from, to: w.to, t: t)
        let r: CGFloat = 3
        let pr = CGRect(x: pt.x - r, y: pt.y - r, width: r * 2, height: r * 2)
        let pOpacity = activePhase == .loss ? 0.1 : 0.6
        ctx.fill(Ellipse().path(in: pr), with: .color(color.opacity(pOpacity)))
    }

    private func drawErrorPulse(ctx: GraphicsContext, center: CGPoint, time: Double) {
        for i in 0..<4 {
            let phase = fmod(time * 0.5 + Double(i) * 0.25, 1.0)
            let r = 24 + CGFloat(phase) * 60
            let opacity = 0.3 * (1.0 - phase)
            let rect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
            ctx.stroke(Ellipse().path(in: rect), with: .color(LabColors.error.opacity(opacity)), lineWidth: 1.5)
        }
    }

    private func drawTargetMarker(ctx: GraphicsContext, near output: CGPoint, target: Double) {
        let pos = CGPoint(x: output.x + 45, y: output.y)
        let r: CGFloat = 14
        let rect = CGRect(x: pos.x - r, y: pos.y - r, width: r * 2, height: r * 2)
        ctx.fill(Ellipse().path(in: rect), with: .color(LabColors.error.opacity(0.1)))
        ctx.stroke(Ellipse().path(in: rect), with: .color(LabColors.error.opacity(0.5)), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))

        let goalLabel = Text("Goal")
            .font(.system(size: 8, weight: .bold, design: .rounded))
            .foregroundColor(LabColors.error.opacity(0.7))
        ctx.draw(ctx.resolve(goalLabel), at: CGPoint(x: pos.x, y: pos.y - 9))

        let valLabel = Text(fmt(target))
            .font(.system(size: 10, weight: .semibold, design: .monospaced))
            .foregroundColor(LabColors.error)
        ctx.draw(ctx.resolve(valLabel), at: CGPoint(x: pos.x, y: pos.y + 5))

        var beam = Path()
        beam.move(to: output)
        beam.addLine(to: pos)
        ctx.stroke(beam, with: .color(LabColors.error.opacity(0.25)), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
    }

    private func drawNode(ctx: GraphicsContext, center: CGPoint, name: String, value: Double, color: Color, radius: CGFloat) {
        let intensity = max(0.3, min(1.0, abs(value) * 1.3))

        // Glow
        let gr = radius + 10
        ctx.fill(Ellipse().path(in: CGRect(x: center.x - gr, y: center.y - gr, width: gr * 2, height: gr * 2)),
                 with: .color(color.opacity(0.06 * intensity)))

        // Circle
        let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        ctx.fill(Ellipse().path(in: rect), with: .color(color.opacity(0.15 + intensity * 0.25)))
        ctx.stroke(Ellipse().path(in: rect), with: .color(color.opacity(0.55)), lineWidth: 1.2)

        // Inner fill showing activation
        let ir = radius * CGFloat(intensity) * 0.6
        ctx.fill(Ellipse().path(in: CGRect(x: center.x - ir, y: center.y - ir, width: ir * 2, height: ir * 2)),
                 with: .color(color.opacity(0.2)))

        // Name
        let nameText = Text(name)
            .font(.system(size: 8, weight: .bold, design: .rounded))
            .foregroundColor(Color.white.opacity(0.5))
        ctx.draw(ctx.resolve(nameText), at: CGPoint(x: center.x, y: center.y - 8))

        // Value
        let valText = Text(value.formatted(.number.precision(.fractionLength(2))))
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(Color.white.opacity(0.88))
        ctx.draw(ctx.resolve(valText), at: CGPoint(x: center.x, y: center.y + 6))
    }

    private func drawLabel(ctx: GraphicsContext, text: String, at point: CGPoint, color: Color, size: CGFloat) {
        let t = Text(text)
            .font(.system(size: size, weight: .bold, design: .rounded))
            .foregroundColor(color.opacity(0.45))
        ctx.draw(ctx.resolve(t), at: point)
    }

    // MARK: - Bezier

    private func bezier(from: CGPoint, to: CGPoint) -> Path {
        let dx = to.x - from.x
        let c = dx * 0.4
        var p = Path()
        p.move(to: from)
        p.addCurve(to: to, control1: CGPoint(x: from.x + c, y: from.y), control2: CGPoint(x: to.x - c, y: to.y))
        return p
    }

    private func bezierPoint(from: CGPoint, to: CGPoint, t: CGFloat) -> CGPoint {
        let dx = to.x - from.x
        let c = dx * 0.4
        let p0 = from, p1 = CGPoint(x: from.x + c, y: from.y), p2 = CGPoint(x: to.x - c, y: to.y), p3 = to
        let u = 1 - t
        return CGPoint(
            x: u*u*u*p0.x + 3*u*u*t*p1.x + 3*u*t*t*p2.x + t*t*t*p3.x,
            y: u*u*u*p0.y + 3*u*u*t*p1.y + 3*u*t*t*p2.y + t*t*t*p3.y
        )
    }

    // MARK: - Actions

    private func performTrainingStep() {
        hasStarted = true
        withAnimation(.easeInOut(duration: 0.35)) {
            focusedStep = simulation.trainStep()
        }
        lossHistory.append(inspectedStep.loss)
        if lossHistory.count > 50 { lossHistory.removeFirst() }
        playPhaseSequence()
    }

    private func startTraining() {
        isTraining = true
        performTrainingStep()
        trainingTimer = Timer.scheduledTimer(withTimeInterval: 2.4, repeats: true) { _ in
            performTrainingStep()
        }
    }

    private func stopTraining() {
        isTraining = false
        phaseSequenceToken += 1
        trainingTimer?.invalidate()
        trainingTimer = nil
    }

    private func playPhaseSequence() {
        phaseSequenceToken += 1
        let token = phaseSequenceToken
        let steps: [(Double, LabPhase)] = [
            (0.0, .forward), (0.55, .loss), (1.10, .backprop), (1.65, .update)
        ]
        for (delay, phase) in steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard token == phaseSequenceToken else { return }
                withAnimation(.easeInOut(duration: 0.3)) { activePhase = phase }
            }
        }
    }

    private func resetFocus() {
        focusedStep = nil
        phaseSequenceToken += 1
        if !isTraining { activePhase = .forward }
    }

    // MARK: - Formatters

    private func fmt(_ v: Double) -> String {
        v.formatted(.number.precision(.fractionLength(3)))
    }

    private func signedFmt(_ v: Double) -> String {
        v.formatted(.number.precision(.fractionLength(3)).sign(strategy: .always()))
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

#Preview {
    VisualLabView()
}
