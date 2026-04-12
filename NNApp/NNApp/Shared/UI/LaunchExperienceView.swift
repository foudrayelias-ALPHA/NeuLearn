import SwiftUI

struct LaunchExperienceView: View {
    enum Mode {
        case firstLaunch
        case returning

        var title: String {
            switch self {
            case .firstLaunch:
                return "Watching a network learn"
            case .returning:
                return "Warming up the lab"
            }
        }

        var subtitle: String {
            switch self {
            case .firstLaunch:
                return "Inputs move forward, error flows back, and each pass nudges the weights into shape."
            case .returning:
                return "A quick training pulse before you jump back in."
            }
        }

        var eyebrow: String {
            switch self {
            case .firstLaunch:
                return "First Open"
            case .returning:
                return "Loading"
            }
        }
    }

    let mode: Mode

    @State private var startDate = Date()

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 28) {
                VStack(spacing: 14) {
                    Text(mode.eyebrow.uppercased())
                        .font(AppTheme.captionFont)
                        .tracking(1.4)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(AppTheme.accent.opacity(0.12), in: Capsule())
                        .foregroundStyle(AppTheme.accent)

                    Text(mode.title)
                        .font(AppTheme.heroTitleFont)
                        .foregroundStyle(AppTheme.ink)
                        .multilineTextAlignment(.center)

                    Text(mode.subtitle)
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.mutedInk)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .frame(maxWidth: 460)
                }

                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
                    let elapsed = context.date.timeIntervalSince(startDate)

                    VStack(spacing: 18) {
                        LaunchTrainingCard(progress: elapsed, mode: mode)
                            .frame(maxWidth: 620)

                        HStack(spacing: 12) {
                            LaunchMetricPill(
                                title: "Epoch",
                                value: "\(Int((elapsed * 2.8).rounded(.down)) + 1)",
                                tint: AppTheme.accent
                            )
                            LaunchMetricPill(
                                title: "Loss",
                                value: lossString(for: elapsed),
                                tint: AppTheme.negative
                            )
                            LaunchMetricPill(
                                title: "Flow",
                                value: flowString(for: elapsed),
                                tint: AppTheme.positive
                            )
                        }
                    }
                }

                Text(mode == .firstLaunch ? "Preparing your first walkthrough..." : "Preparing your workspace...")
                    .font(AppTheme.captionFont)
                    .tracking(0.6)
                    .foregroundStyle(AppTheme.mutedInk)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            startDate = Date()
        }
    }

    private func lossString(for elapsed: Double) -> String {
        let value = max(0.08, 0.94 - elapsed * (mode == .firstLaunch ? 0.11 : 0.24) + sin(elapsed * 2.0) * 0.04)
        return value.formatted(.number.precision(.fractionLength(2)))
    }

    private func flowString(for elapsed: Double) -> String {
        let value = 0.28 + abs(sin(elapsed * 1.7)) * 0.57
        return value.formatted(.number.precision(.fractionLength(2)))
    }
}

private struct LaunchTrainingCard: View {
    let progress: Double
    let mode: LaunchExperienceView.Mode

    private let inputValues: [Double] = [0.15, 0.82, 0.46]
    private let hiddenBase: [Double] = [0.34, 0.67, 0.51]

    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local)
            let inputNodes = nodePositions(count: 3, x: frame.width * 0.18, height: frame.height)
            let hiddenNodes = nodePositions(count: 3, x: frame.width * 0.50, height: frame.height)
            let outputNodes = nodePositions(count: 1, x: frame.width * 0.82, height: frame.height)
            let leftConnections = buildConnections(from: inputNodes, to: hiddenNodes, scale: 0.75)
            let rightConnections = buildConnections(from: hiddenNodes, to: outputNodes, scale: 0.92)

            ZStack {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.surface.opacity(0.98), AppTheme.background.opacity(0.84)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(AppTheme.ink.opacity(0.08), lineWidth: 1)

                Circle()
                    .fill(AppTheme.accent.opacity(0.08))
                    .frame(width: 240, height: 240)
                    .offset(x: frame.width * 0.24, y: -frame.height * 0.20)
                    .blur(radius: 4)

                Circle()
                    .fill(AppTheme.accentWarm.opacity(0.10))
                    .frame(width: 210, height: 210)
                    .offset(x: -frame.width * 0.28, y: frame.height * 0.16)
                    .blur(radius: 6)

                ForEach(leftConnections.indices, id: \.self) { index in
                    connectionView(for: leftConnections[index], at: index, hue: .forward)
                }

                ForEach(rightConnections.indices, id: \.self) { index in
                    connectionView(for: rightConnections[index], at: index + leftConnections.count, hue: .backward)
                }

                ForEach(inputNodes.indices, id: \.self) { index in
                    launchNode(
                        at: inputNodes[index],
                        value: inputValues[index],
                        tint: AppTheme.nodeInput,
                        phase: progress * 1.4 + Double(index) * 0.35
                    )
                }

                ForEach(hiddenNodes.indices, id: \.self) { index in
                    launchNode(
                        at: hiddenNodes[index],
                        value: hiddenActivation(for: index),
                        tint: AppTheme.nodeHidden,
                        phase: progress * 1.8 + Double(index) * 0.42
                    )
                }

                launchNode(
                    at: outputNodes[0],
                    value: outputValue,
                    tint: AppTheme.nodeOutput,
                    phase: progress * 2.0
                )

                columnLabel("Inputs", x: inputNodes[0].x, y: frame.height - 18)
                columnLabel("Hidden", x: hiddenNodes[0].x, y: frame.height - 18)
                columnLabel("Output", x: outputNodes[0].x, y: frame.height - 18)
            }
            .padding(20)
        }
        .frame(height: 320)
        .shadow(color: .black.opacity(0.06), radius: 18, x: 0, y: 10)
    }

    private func hiddenActivation(for index: Int) -> Double {
        let wave = sin(progress * 1.5 + Double(index) * 0.8) * 0.12
        return max(0.18, min(0.94, hiddenBase[index] + wave))
    }

    private var outputValue: Double {
        let value = 0.42 + sin(progress * 1.2) * 0.11 + cos(progress * 0.9) * 0.05
        return max(0.10, min(0.96, value))
    }

    private func nodePositions(count: Int, x: CGFloat, height: CGFloat) -> [CGPoint] {
        let topInset = height * 0.22
        let bottomInset = height * 0.30
        let usableHeight = height - topInset - bottomInset

        return (0..<count).map { index in
            let fraction = count == 1 ? 0.5 : CGFloat(index) / CGFloat(count - 1)
            return CGPoint(x: x, y: topInset + usableHeight * fraction)
        }
    }

    private func buildConnections(from source: [CGPoint], to destination: [CGPoint], scale: Double) -> [LaunchConnection] {
        source.enumerated().flatMap { sourceIndex, start in
            destination.enumerated().map { destinationIndex, end in
                LaunchConnection(
                    start: start,
                    end: end,
                    weight: dynamicWeight(seed: sourceIndex * 5 + destinationIndex, scale: scale)
                )
            }
        }
    }

    private func dynamicWeight(seed: Int, scale: Double) -> Double {
        let speed = mode == .firstLaunch ? 1.05 : 1.8
        return sin(progress * speed + Double(seed) * 0.72) * scale
    }

    private func launchNode(at point: CGPoint, value: Double, tint: Color, phase: Double) -> some View {
        let pulse = 0.22 + (sin(phase) + 1) * 0.18

        return ZStack {
            Circle()
                .fill(tint.opacity(0.10 + pulse))
                .frame(width: 62, height: 62)
                .overlay {
                    Circle()
                        .stroke(tint.opacity(0.45 + pulse * 0.3), lineWidth: 1.5)
                }
                .shadow(color: tint.opacity(0.18), radius: 14, x: 0, y: 6)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [tint.opacity(0.78), tint.opacity(0.26)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, height: 48)

            Text(value.formatted(.number.precision(.fractionLength(2))))
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(AppTheme.ink)
        }
        .position(point)
    }

    private func connectionView(for connection: LaunchConnection, at index: Int, hue: LaunchConnectionHue) -> some View {
        let intensity = max(0.12, min(1.0, abs(connection.weight)))
        let lineWidth = 2.0 + intensity * 6.0
        let pulse = pulseProgress(for: index, reverse: hue == .backward)
        let pulsePoint = point(between: connection.start, and: connection.end, progress: pulse)

        return ZStack {
            Path { path in
                path.move(to: connection.start)
                path.addLine(to: connection.end)
            }
            .stroke(hue.gradient.opacity(0.22), style: StrokeStyle(lineWidth: lineWidth + 4, lineCap: .round))

            Path { path in
                path.move(to: connection.start)
                path.addLine(to: connection.end)
            }
            .stroke(hue.gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

            Circle()
                .fill(hue.pulseColor)
                .frame(width: 12 + intensity * 4, height: 12 + intensity * 4)
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.7), lineWidth: 1)
                }
                .shadow(color: hue.pulseColor.opacity(0.35), radius: 10, x: 0, y: 0)
                .position(pulsePoint)
        }
    }

    private func pulseProgress(for index: Int, reverse: Bool) -> Double {
        let cycle = mode == .firstLaunch ? 2.8 : 1.7
        let phase = (progress / cycle) + Double(index) * 0.11
        let raw = phase - floor(phase)
        return reverse ? 1.0 - raw : raw
    }

    private func point(between start: CGPoint, and end: CGPoint, progress: Double) -> CGPoint {
        CGPoint(
            x: start.x + (end.x - start.x) * progress,
            y: start.y + (end.y - start.y) * progress
        )
    }

    private func columnLabel(_ title: String, x: CGFloat, y: CGFloat) -> some View {
        Text(title.uppercased())
            .font(AppTheme.captionFont)
            .tracking(1.1)
            .foregroundStyle(AppTheme.mutedInk)
            .position(x: x, y: y)
    }
}

private struct LaunchMetricPill: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(AppTheme.captionFont)
                .tracking(1.0)
                .foregroundStyle(AppTheme.mutedInk)

            Text(value)
                .font(AppTheme.numberFont)
                .foregroundStyle(AppTheme.ink)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(tint.opacity(0.10))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(tint.opacity(0.18), lineWidth: 1)
        }
    }
}

private struct LaunchConnection {
    let start: CGPoint
    let end: CGPoint
    let weight: Double
}

private enum LaunchConnectionHue {
    case forward
    case backward

    var gradient: LinearGradient {
        switch self {
        case .forward:
            return LinearGradient(
                colors: [AppTheme.accent.opacity(0.55), AppTheme.positive],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .backward:
            return LinearGradient(
                colors: [AppTheme.accentWarm, AppTheme.negative.opacity(0.72)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    var pulseColor: Color {
        switch self {
        case .forward:
            return AppTheme.positive
        case .backward:
            return AppTheme.accentWarm
        }
    }
}

#Preview("First Launch") {
    LaunchExperienceView(mode: .firstLaunch)
}

#Preview("Returning") {
    LaunchExperienceView(mode: .returning)
}
