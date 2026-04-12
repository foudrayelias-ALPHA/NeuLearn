import SwiftUI

// MARK: - Neuron Explorer

struct NeuronExplorerView: View {
    @State private var weight1: Double = 0.5
    @State private var weight2: Double = 0.3
    @State private var input1: Double = 0.6
    @State private var input2: Double = 0.4
    @State private var bias: Double = 0.0

    private var weightedSum: Double {
        input1 * weight1 + input2 * weight2 + bias
    }

    private var sigmoidOutput: Double {
        1.0 / (1.0 + exp(-weightedSum))
    }

    var body: some View {
        VStack(spacing: 16) {
            // Visual neuron diagram
            HStack(spacing: 0) {
                // Inputs
                VStack(spacing: 20) {
                    NeuronNodeBubble(value: input1, label: "In 1", color: AppTheme.nodeInput)
                    NeuronNodeBubble(value: input2, label: "In 2", color: AppTheme.nodeInput)
                }

                // Arrows with weights
                VStack(spacing: 12) {
                    WeightArrow(value: weight1)
                    WeightArrow(value: weight2)
                }
                .frame(width: 60)

                // Neuron body
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.nodeHidden.opacity(0.15 + sigmoidOutput * 0.65))
                            .frame(width: 70, height: 70)
                            .overlay {
                                Circle().stroke(AppTheme.nodeHidden.opacity(0.5), lineWidth: 2)
                            }

                        VStack(spacing: 2) {
                            Text("\u{03A3}")
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundStyle(AppTheme.nodeHidden)
                            Text(weightedSum, format: .number.precision(.fractionLength(2)))
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundStyle(AppTheme.ink)
                        }
                    }

                    if bias != 0 {
                        Text("b: \(bias, format: .number.precision(.fractionLength(1)))")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(AppTheme.mutedInk)
                    }
                }

                // Arrow to output
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundStyle(AppTheme.mutedInk)
                    .padding(.horizontal, 8)

                // Output
                NeuronNodeBubble(value: sigmoidOutput, label: "Out", color: AppTheme.nodeOutput)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppTheme.background.opacity(0.6))
            )

            // Sliders
            VStack(spacing: 12) {
                InteractiveSlider(label: "Input 1", value: $input1, range: 0...1, tint: AppTheme.nodeInput)
                InteractiveSlider(label: "Input 2", value: $input2, range: 0...1, tint: AppTheme.nodeInput)
                InteractiveSlider(label: "Weight 1", value: $weight1, range: -2...2, tint: AppTheme.accent)
                InteractiveSlider(label: "Weight 2", value: $weight2, range: -2...2, tint: AppTheme.accent)
                InteractiveSlider(label: "Bias", value: $bias, range: -2...2, tint: AppTheme.accentWarm)
            }
        }
    }
}

// MARK: - Activation Playground

struct ActivationPlaygroundView: View {
    @State private var inputValue: Double = 0.0
    @State private var selectedFunction = 0

    private let functions = ["Sigmoid", "ReLU", "Tanh"]

    private func activate(_ x: Double, function: Int) -> Double {
        switch function {
        case 0: return 1.0 / (1.0 + exp(-x))
        case 1: return max(0, x)
        case 2: return tanh(x)
        default: return x
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Function selector
            HStack(spacing: 8) {
                ForEach(0..<functions.count, id: \.self) { index in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedFunction = index }
                    } label: {
                        Text(functions[index])
                            .font(AppTheme.captionFont)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(index == selectedFunction ? AppTheme.accent : AppTheme.surfaceStrong.opacity(0.6))
                            )
                            .foregroundStyle(index == selectedFunction ? .white : AppTheme.ink)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Graph
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let midY = h / 2
                let midX = w / 2

                // Grid lines
                let gridColor = AppTheme.surfaceStrong
                context.stroke(Path { p in p.move(to: CGPoint(x: 0, y: midY)); p.addLine(to: CGPoint(x: w, y: midY)) }, with: .color(gridColor), lineWidth: 1)
                context.stroke(Path { p in p.move(to: CGPoint(x: midX, y: 0)); p.addLine(to: CGPoint(x: midX, y: h)) }, with: .color(gridColor), lineWidth: 1)

                // Draw all three curves faintly
                for fn in 0..<3 {
                    let isCurrent = fn == selectedFunction
                    var path = Path()
                    let steps = 80
                    for i in 0...steps {
                        let x = Double(i) / Double(steps) * 8.0 - 4.0
                        let y = activate(x, function: fn)
                        let px = (x + 4.0) / 8.0 * w
                        let py = midY - y * (h * 0.35)
                        if i == 0 { path.move(to: CGPoint(x: px, y: py)) }
                        else { path.addLine(to: CGPoint(x: px, y: py)) }
                    }
                    let color: Color = fn == 0 ? .blue : fn == 1 ? .orange : .purple
                    context.stroke(path, with: .color(color.opacity(isCurrent ? 1 : 0.15)), lineWidth: isCurrent ? 3 : 1.5)
                }

                // Input marker
                let markerX = (inputValue + 4.0) / 8.0 * w
                let markerY = midY - activate(inputValue, function: selectedFunction) * (h * 0.35)
                context.fill(Circle().path(in: CGRect(x: markerX - 7, y: markerY - 7, width: 14, height: 14)), with: .color(AppTheme.accentWarm))
                context.stroke(Circle().path(in: CGRect(x: markerX - 7, y: markerY - 7, width: 14, height: 14)), with: .color(.white), lineWidth: 2)
            }
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppTheme.background.opacity(0.6))
            )

            // Readout
            HStack(spacing: 20) {
                VStack(spacing: 2) {
                    Text("INPUT")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.mutedInk)
                    Text(inputValue, format: .number.precision(.fractionLength(2)))
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundStyle(AppTheme.ink)
                }
                Image(systemName: "arrow.right")
                    .foregroundStyle(AppTheme.mutedInk)
                VStack(spacing: 2) {
                    Text(functions[selectedFunction].uppercased())
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.mutedInk)
                    Text(activate(inputValue, function: selectedFunction), format: .number.precision(.fractionLength(3)))
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundStyle(AppTheme.accent)
                }
            }

            InteractiveSlider(label: "Input value", value: $inputValue, range: -4...4, tint: AppTheme.accentWarm)
        }
    }
}

// MARK: - Loss Visualizer

struct LossVisualizerView: View {
    @State private var prediction: Double = 0.3
    private let target: Double = 0.8

    private var loss: Double {
        0.5 * pow(target - prediction, 2)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Visual bar comparing prediction and target
            GeometryReader { geo in
                let w = geo.size.width
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(AppTheme.surfaceStrong.opacity(0.5))

                    // Target marker
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(AppTheme.positive.opacity(0.3))
                        .frame(width: 4)
                        .offset(x: w * target - 2)

                    // Prediction fill
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(
                            loss < 0.01 ? AppTheme.positive.opacity(0.6) :
                            loss < 0.05 ? AppTheme.accentWarm.opacity(0.5) :
                            AppTheme.negative.opacity(0.4)
                        )
                        .frame(width: max(4, w * prediction))

                    // Error bracket
                    let predX = w * prediction
                    let targetX = w * target
                    let minX = min(predX, targetX)
                    let gapW = abs(targetX - predX)
                    if gapW > 2 {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(AppTheme.negative.opacity(0.25))
                            .frame(width: gapW, height: 10)
                            .offset(x: minX, y: 0)
                    }
                }
                .frame(height: 32)
            }
            .frame(height: 32)

            // Metrics
            HStack(spacing: 12) {
                MetricPill(title: "Prediction", value: prediction.formatted(.number.precision(.fractionLength(2))), tint: AppTheme.accent)
                MetricPill(title: "Target", value: target.formatted(.number.precision(.fractionLength(1))), tint: AppTheme.positive)
                MetricPill(title: "Loss", value: loss.formatted(.number.precision(.fractionLength(4))), tint: AppTheme.negative)
            }

            InteractiveSlider(label: "Drag prediction toward target", value: $prediction, range: 0...1, tint: loss < 0.01 ? AppTheme.positive : AppTheme.accent)
        }
    }
}

// MARK: - Gradient Step Visualizer

struct GradientStepView: View {
    @State private var weightPosition: Double = -1.5
    @State private var stepsTaken: Int = 0
    private let learningRate: Double = 0.3

    private func lossAt(_ x: Double) -> Double {
        pow(x - 1.0, 2) + 0.5 * sin(x * 2) + 1
    }

    private func gradientAt(_ x: Double) -> Double {
        2 * (x - 1.0) + cos(x * 2)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Loss landscape
            Canvas { context, size in
                let w = size.width
                let h = size.height

                // Draw loss curve
                var path = Path()
                let steps = 100
                var maxLoss = 0.0
                for i in 0...steps {
                    let x = Double(i) / Double(steps) * 6.0 - 2.0
                    maxLoss = max(maxLoss, lossAt(x))
                }
                for i in 0...steps {
                    let x = Double(i) / Double(steps) * 6.0 - 2.0
                    let y = lossAt(x)
                    let px = Double(i) / Double(steps) * w
                    let py = h - (y / (maxLoss + 0.5)) * h * 0.85 - 10
                    if i == 0 { path.move(to: CGPoint(x: px, y: py)) }
                    else { path.addLine(to: CGPoint(x: px, y: py)) }
                }

                // Fill under curve
                var fillPath = path
                fillPath.addLine(to: CGPoint(x: w, y: h))
                fillPath.addLine(to: CGPoint(x: 0, y: h))
                fillPath.closeSubpath()
                context.fill(fillPath, with: .color(AppTheme.accent.opacity(0.08)))
                context.stroke(path, with: .color(AppTheme.accent), lineWidth: 2.5)

                // Current position ball
                let normX = (weightPosition + 2.0) / 6.0
                let ballX = normX * w
                let ballY = h - (lossAt(weightPosition) / (maxLoss + 0.5)) * h * 0.85 - 10
                context.fill(Circle().path(in: CGRect(x: ballX - 9, y: ballY - 9, width: 18, height: 18)), with: .color(AppTheme.accentWarm))
                context.stroke(Circle().path(in: CGRect(x: ballX - 9, y: ballY - 9, width: 18, height: 18)), with: .color(.white), lineWidth: 2.5)

                // Gradient arrow
                let grad = gradientAt(weightPosition)
                let arrowDir = -grad
                let arrowLen = min(abs(arrowDir) * 15, 40.0)
                let arrowEnd = ballX + (arrowDir > 0 ? arrowLen : -arrowLen)
                var arrowPath = Path()
                arrowPath.move(to: CGPoint(x: ballX, y: ballY + 20))
                arrowPath.addLine(to: CGPoint(x: arrowEnd, y: ballY + 20))
                context.stroke(arrowPath, with: .color(AppTheme.positive), lineWidth: 2)

                // Arrowhead
                let headDir: Double = arrowDir > 0 ? 1 : -1
                var head = Path()
                head.move(to: CGPoint(x: arrowEnd, y: ballY + 20))
                head.addLine(to: CGPoint(x: arrowEnd - headDir * 6, y: ballY + 16))
                head.addLine(to: CGPoint(x: arrowEnd - headDir * 6, y: ballY + 24))
                head.closeSubpath()
                context.fill(head, with: .color(AppTheme.positive))
            }
            .frame(height: 180)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppTheme.background.opacity(0.6))
            )

            HStack(spacing: 12) {
                MetricPill(title: "Loss", value: lossAt(weightPosition).formatted(.number.precision(.fractionLength(2))), tint: AppTheme.negative)
                MetricPill(title: "Gradient", value: gradientAt(weightPosition).formatted(.number.precision(.fractionLength(2))), tint: AppTheme.accent)
                MetricPill(title: "Steps", value: "\(stepsTaken)", tint: AppTheme.positive)
            }

            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        weightPosition -= learningRate * gradientAt(weightPosition)
                        stepsTaken += 1
                    }
                } label: {
                    Label("Step Downhill", systemImage: "arrow.down.right")
                        .font(AppTheme.bodyFont.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.positive.opacity(0.15), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .foregroundStyle(AppTheme.positive)
                }

                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        weightPosition = Double.random(in: -1.5...3.5)
                        stepsTaken = 0
                    }
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(AppTheme.bodyFont.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.surfaceStrong.opacity(0.5), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .foregroundStyle(AppTheme.ink)
                }
            }
        }
    }
}

// MARK: - Forward Pass Stepper

struct ForwardPassStepperView: View {
    @State private var currentStep = 0
    private let inputValues: [Double] = [0.6, 0.4]
    private let weights1: [Double] = [0.5, 0.8]
    private let weights2: [Double] = [0.7, 0.3]
    private let bias: Double = 0.1

    private var hiddenRaw: [Double] {
        zip(inputValues, weights1).map(*)
    }
    private var hiddenAct: [Double] {
        hiddenRaw.map { 1.0 / (1.0 + exp(-($0 + bias))) }
    }
    private var outputRaw: Double {
        zip(hiddenAct, weights2).map(*).reduce(0, +)
    }
    private var outputAct: Double {
        1.0 / (1.0 + exp(-outputRaw))
    }

    private let stepLabels = [
        "Inputs ready",
        "Multiply by weights",
        "Add bias & activate",
        "Hidden to output",
        "Final output"
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Step indicator
            HStack(spacing: 4) {
                ForEach(0..<stepLabels.count, id: \.self) { i in
                    Capsule()
                        .fill(i <= currentStep ? AppTheme.accent : AppTheme.surfaceStrong)
                        .frame(height: 4)
                }
            }

            Text(stepLabels[currentStep])
                .font(AppTheme.bodyFont.weight(.semibold))
                .foregroundStyle(AppTheme.ink)

            // Network state
            HStack(spacing: 12) {
                // Inputs
                VStack(spacing: 8) {
                    Text("INPUT").font(.system(size: 9, weight: .bold, design: .rounded)).foregroundStyle(AppTheme.mutedInk)
                    ForEach(inputValues.indices, id: \.self) { i in
                        StepNode(
                            value: inputValues[i],
                            color: AppTheme.nodeInput,
                            active: currentStep >= 0,
                            pulsing: currentStep == 0
                        )
                    }
                }

                // Arrows
                VStack(spacing: 14) {
                    ForEach(weights1.indices, id: \.self) { i in
                        HStack(spacing: 2) {
                            Rectangle().fill(currentStep >= 1 ? AppTheme.accent : AppTheme.surfaceStrong).frame(width: 20, height: 2)
                            Text(weights1[i], format: .number.precision(.fractionLength(1)))
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(currentStep >= 1 ? AppTheme.accent : AppTheme.mutedInk)
                        }
                    }
                }

                // Hidden
                VStack(spacing: 8) {
                    Text("HIDDEN").font(.system(size: 9, weight: .bold, design: .rounded)).foregroundStyle(AppTheme.mutedInk)
                    ForEach(hiddenAct.indices, id: \.self) { i in
                        StepNode(
                            value: currentStep >= 2 ? hiddenAct[i] : (currentStep >= 1 ? hiddenRaw[i] : 0),
                            color: AppTheme.nodeHidden,
                            active: currentStep >= 1,
                            pulsing: currentStep == 2
                        )
                    }
                }

                // Arrow to output
                HStack(spacing: 2) {
                    Rectangle().fill(currentStep >= 3 ? AppTheme.accent : AppTheme.surfaceStrong).frame(width: 20, height: 2)
                }

                // Output
                VStack(spacing: 8) {
                    Text("OUTPUT").font(.system(size: 9, weight: .bold, design: .rounded)).foregroundStyle(AppTheme.mutedInk)
                    StepNode(
                        value: currentStep >= 4 ? outputAct : (currentStep >= 3 ? outputRaw : 0),
                        color: AppTheme.nodeOutput,
                        active: currentStep >= 3,
                        pulsing: currentStep == 4
                    )
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppTheme.background.opacity(0.6))
            )

            // Controls
            HStack(spacing: 12) {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = max(0, currentStep - 1)
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .frame(width: 44, height: 44)
                        .background(AppTheme.surfaceStrong.opacity(0.5), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .foregroundStyle(AppTheme.ink)
                }
                .disabled(currentStep == 0)
                .opacity(currentStep == 0 ? 0.4 : 1)

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = min(stepLabels.count - 1, currentStep + 1)
                    }
                } label: {
                    HStack {
                        Text(currentStep < stepLabels.count - 1 ? "Next Step" : "Complete")
                        Image(systemName: currentStep < stepLabels.count - 1 ? "chevron.right" : "checkmark")
                    }
                    .font(AppTheme.bodyFont.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .foregroundStyle(.white)
                }
                .disabled(currentStep >= stepLabels.count - 1)
                .opacity(currentStep >= stepLabels.count - 1 ? 0.6 : 1)
            }
        }
    }
}

// MARK: - Learning Rate Explorer

struct LearningRateExplorerView: View {
    @State private var learningRate: Double = 0.5
    @State private var position: Double = -1.5
    @State private var history: [Double] = [-1.5]
    @State private var isRunning = false
    @State private var timer: Timer?

    private func lossAt(_ x: Double) -> Double {
        pow(x - 1.2, 2) + 0.3
    }

    private func gradientAt(_ x: Double) -> Double {
        2 * (x - 1.2)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Loss landscape with path history
            Canvas { context, size in
                let w = size.width
                let h = size.height

                func toScreen(_ x: Double) -> (Double, Double) {
                    let normX = (x + 3.0) / 7.0
                    let y = lossAt(x)
                    let maxY = 20.0
                    return (normX * w, h - (y / maxY) * h * 0.8 - 15)
                }

                // Draw loss curve
                var curve = Path()
                let steps = 100
                for i in 0...steps {
                    let x = Double(i) / Double(steps) * 7.0 - 3.0
                    let (px, py) = toScreen(x)
                    if i == 0 { curve.move(to: CGPoint(x: px, y: py)) }
                    else { curve.addLine(to: CGPoint(x: px, y: py)) }
                }
                context.stroke(curve, with: .color(AppTheme.accent.opacity(0.6)), lineWidth: 2)

                // Draw history path
                if history.count > 1 {
                    var histPath = Path()
                    for (i, pos) in history.enumerated() {
                        let (px, py) = toScreen(pos)
                        if i == 0 { histPath.move(to: CGPoint(x: px, y: py)) }
                        else { histPath.addLine(to: CGPoint(x: px, y: py)) }
                    }
                    context.stroke(histPath, with: .color(AppTheme.accentWarm.opacity(0.4)), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))

                    // Draw dots for each step
                    for (i, pos) in history.enumerated() {
                        let (px, py) = toScreen(pos)
                        let opacity = Double(i + 1) / Double(history.count)
                        let r: Double = i == history.count - 1 ? 8 : 4
                        context.fill(Circle().path(in: CGRect(x: px - r, y: py - r, width: r * 2, height: r * 2)), with: .color(AppTheme.accentWarm.opacity(opacity)))
                    }
                }

                // Current position
                let (cx, cy) = toScreen(position)
                context.fill(Circle().path(in: CGRect(x: cx - 9, y: cy - 9, width: 18, height: 18)), with: .color(AppTheme.accentWarm))
                context.stroke(Circle().path(in: CGRect(x: cx - 9, y: cy - 9, width: 18, height: 18)), with: .color(.white), lineWidth: 2.5)
            }
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppTheme.background.opacity(0.6))
            )

            HStack(spacing: 12) {
                MetricPill(title: "Loss", value: lossAt(position).formatted(.number.precision(.fractionLength(2))), tint: AppTheme.negative)
                MetricPill(title: "LR", value: learningRate.formatted(.number.precision(.fractionLength(2))), tint: AppTheme.accent)
                MetricPill(title: "Steps", value: "\(history.count - 1)", tint: AppTheme.positive)
            }

            InteractiveSlider(label: "Learning rate", value: $learningRate, range: 0.01...3.0, tint: AppTheme.accent)

            HStack(spacing: 12) {
                Button {
                    if isRunning { stopRunning() } else { startRunning() }
                } label: {
                    Label(isRunning ? "Pause" : "Train", systemImage: isRunning ? "pause.fill" : "play.fill")
                        .font(AppTheme.bodyFont.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.positive.opacity(0.15), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .foregroundStyle(AppTheme.positive)
                }

                Button {
                    stopRunning()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        position = -1.5
                        history = [-1.5]
                    }
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(AppTheme.bodyFont.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.surfaceStrong.opacity(0.5), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .foregroundStyle(AppTheme.ink)
                }
            }
        }
        .onDisappear { stopRunning() }
    }

    private func startRunning() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                let grad = gradientAt(position)
                position -= learningRate * grad
                position = max(-3, min(4, position))
                history.append(position)
                if history.count > 50 { history.removeFirst() }
            }
        }
    }

    private func stopRunning() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Shared Components

private struct NeuronNodeBubble: View {
    let value: Double
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15 + abs(value) * 0.5))
                    .frame(width: 48, height: 48)
                    .overlay { Circle().stroke(color.opacity(0.4), lineWidth: 1.5) }
                Text(value, format: .number.precision(.fractionLength(2)))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(AppTheme.ink)
            }
            Text(label)
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.mutedInk)
        }
    }
}

private struct WeightArrow: View {
    let value: Double
    var body: some View {
        HStack(spacing: 2) {
            Rectangle()
                .fill(value >= 0 ? AppTheme.positive.opacity(0.5) : AppTheme.negative.opacity(0.5))
                .frame(height: max(1.5, abs(value) * 2.5))
                .frame(maxWidth: .infinity)
            Text(value, format: .number.precision(.fractionLength(1)))
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(AppTheme.mutedInk)
        }
    }
}

private struct StepNode: View {
    let value: Double
    let color: Color
    let active: Bool
    let pulsing: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(active ? color.opacity(0.15 + abs(value) * 0.5) : AppTheme.surfaceStrong.opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay { Circle().stroke(active ? color.opacity(0.4) : AppTheme.surfaceStrong, lineWidth: 1.5) }
                .scaleEffect(pulsing ? 1.08 : 1.0)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pulsing)
            if active {
                Text(value, format: .number.precision(.fractionLength(2)))
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(AppTheme.ink)
            } else {
                Text("?")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.mutedInk)
            }
        }
    }
}

struct InteractiveSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                Text(value, format: .number.precision(.fractionLength(2)))
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(AppTheme.mutedInk)
            }
            Slider(value: $value, in: range)
                .tint(tint)
        }
    }
}

// MARK: - Router

struct InteractiveComponentView: View {
    let component: InteractiveComponent

    var body: some View {
        Group {
            switch component {
            case .neuronExplorer:
                NeuronExplorerView()
            case .activationPlayground:
                ActivationPlaygroundView()
            case .lossVisualizer:
                LossVisualizerView()
            case .gradientStep:
                GradientStepView()
            case .forwardPassStepper:
                ForwardPassStepperView()
            case .learningRateExplorer:
                LearningRateExplorerView()
            }
        }
        .padding(4)
    }
}
