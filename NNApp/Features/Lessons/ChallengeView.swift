import SwiftUI

struct ChallengeView: View {
    let challenge: LessonChallenge
    let tint: Color
    let onComplete: () -> Void

    @State private var solved = false
    @State private var showResult = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: solved ? "checkmark.seal.fill" : "questionmark.diamond.fill")
                    .font(.title3)
                    .foregroundStyle(solved ? AppTheme.positive : tint)
                    .symbolEffect(.bounce, value: solved)
                Text(solved ? "Challenge Complete" : "Challenge")
                    .font(AppTheme.cardTitleFont)
                    .foregroundStyle(AppTheme.ink)
            }

            Text(challenge.prompt)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.ink.opacity(0.85))
                .lineSpacing(3)

            // Challenge content based on type
            switch challenge.type {
            case .sliderTarget(let label, let target, let tolerance, let minVal, let maxVal, let unit):
                SliderTargetChallenge(
                    label: label, target: target, tolerance: tolerance,
                    minVal: minVal, maxVal: maxVal, unit: unit,
                    solved: $solved, showResult: $showResult
                )

            case .multipleChoice(let options):
                MultipleChoiceChallenge(
                    options: options, tint: tint,
                    solved: $solved, showResult: $showResult
                )

            case .ordering(let items, let correctOrder):
                OrderingChallenge(
                    items: items, correctOrder: correctOrder, tint: tint,
                    solved: $solved, showResult: $showResult
                )

            case .predictOutput(let inputs, let weights, let bias, let activationName, let correctAnswer, let tolerance):
                PredictOutputChallenge(
                    inputs: inputs, weights: weights, bias: bias,
                    activationName: activationName, correctAnswer: correctAnswer,
                    tolerance: tolerance,
                    solved: $solved, showResult: $showResult
                )
            }

            if solved {
                Button {
                    onComplete()
                } label: {
                    Label("Continue", systemImage: "arrow.right")
                        .font(AppTheme.bodyFont.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.positive, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                .fill(solved ? AppTheme.positive.opacity(0.06) : AppTheme.surface.opacity(0.96))
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                .stroke(solved ? AppTheme.positive.opacity(0.25) : tint.opacity(0.15), lineWidth: 1.5)
        }
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Slider Target Challenge

private struct SliderTargetChallenge: View {
    let label: String
    let target: Double
    let tolerance: Double
    let minVal: Double
    let maxVal: Double
    let unit: String

    @Binding var solved: Bool
    @Binding var showResult: Bool
    @State private var userValue: Double = 0
    @State private var hasChecked = false
    @State private var isCorrect = false

    var body: some View {
        VStack(spacing: 14) {
            // Visual target indicator
            GeometryReader { geo in
                let w = geo.size.width
                let range = maxVal - minVal
                let targetNorm = (target - minVal) / range
                let userNorm = (userValue - minVal) / range

                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(AppTheme.surfaceStrong.opacity(0.4))

                    // Target zone
                    let tolNorm = tolerance / range
                    let zoneStart = max(0, targetNorm - tolNorm)
                    let zoneWidth = min(1, tolNorm * 2)
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(AppTheme.positive.opacity(0.2))
                        .frame(width: w * zoneWidth)
                        .offset(x: w * zoneStart)

                    // User value indicator
                    Circle()
                        .fill(isCorrect && hasChecked ? AppTheme.positive : AppTheme.accentWarm)
                        .frame(width: 16, height: 16)
                        .offset(x: max(0, min(w - 16, w * userNorm - 8)))
                }
                .frame(height: 24)
            }
            .frame(height: 24)

            HStack {
                Text(label)
                    .font(AppTheme.bodyFont.weight(.medium))
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                Text("\(userValue, format: .number.precision(.fractionLength(3)))\(unit.isEmpty ? "" : " \(unit)")")
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundStyle(isCorrect && hasChecked ? AppTheme.positive : AppTheme.ink)
            }

            Slider(value: $userValue, in: minVal...maxVal)
                .tint(isCorrect && hasChecked ? AppTheme.positive : AppTheme.accent)
                .disabled(solved)

            if !solved {
                Button {
                    hasChecked = true
                    isCorrect = abs(userValue - target) <= tolerance
                    if isCorrect {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            solved = true
                            showResult = true
                        }
                    }
                } label: {
                    Text(hasChecked && !isCorrect ? "Try Again" : "Check Answer")
                        .font(AppTheme.bodyFont.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .foregroundStyle(.white)
                }
            }

            if hasChecked && !isCorrect {
                Text("Not quite \u{2014} try adjusting the slider closer to the answer.")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.accentWarm)
            }
        }
    }
}

// MARK: - Multiple Choice Challenge

private struct MultipleChoiceChallenge: View {
    let options: [ChallengeOption]
    let tint: Color

    @Binding var solved: Bool
    @Binding var showResult: Bool
    @State private var selectedID: UUID?
    @State private var hasChecked = false

    private var selectedOption: ChallengeOption? {
        options.first { $0.id == selectedID }
    }

    var body: some View {
        VStack(spacing: 10) {
            ForEach(options) { option in
                Button {
                    if !solved {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedID = option.id
                            hasChecked = false
                        }
                    }
                } label: {
                    HStack(spacing: 12) {
                        // Selection indicator
                        ZStack {
                            Circle()
                                .stroke(borderColor(for: option), lineWidth: 2)
                                .frame(width: 24, height: 24)
                            if selectedID == option.id {
                                Circle()
                                    .fill(fillColor(for: option))
                                    .frame(width: 14, height: 14)
                            }
                            if hasChecked && option.isCorrect {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }

                        Text(option.text)
                            .font(AppTheme.bodyFont)
                            .foregroundStyle(AppTheme.ink)
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(bgColor(for: option))
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(borderColor(for: option), lineWidth: selectedID == option.id ? 2 : 1)
                    }
                }
                .buttonStyle(.plain)
                .disabled(solved)
            }

            // Explanation
            if hasChecked, let selected = selectedOption {
                Text(selected.explanation)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(selected.isCorrect ? AppTheme.positive : AppTheme.accentWarm)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(selected.isCorrect ? AppTheme.positive.opacity(0.08) : AppTheme.accentWarm.opacity(0.08))
                    )
            }

            if !solved && selectedID != nil {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        hasChecked = true
                        if selectedOption?.isCorrect == true {
                            solved = true
                            showResult = true
                        }
                    }
                } label: {
                    Text(hasChecked && selectedOption?.isCorrect != true ? "Try Again" : "Check Answer")
                        .font(AppTheme.bodyFont.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private func borderColor(for option: ChallengeOption) -> Color {
        guard hasChecked else {
            return selectedID == option.id ? tint : AppTheme.ink.opacity(0.1)
        }
        if option.isCorrect { return AppTheme.positive }
        if selectedID == option.id { return AppTheme.negative }
        return AppTheme.ink.opacity(0.06)
    }

    private func fillColor(for option: ChallengeOption) -> Color {
        guard hasChecked else { return tint }
        if option.isCorrect { return AppTheme.positive }
        if selectedID == option.id { return AppTheme.negative }
        return tint
    }

    private func bgColor(for option: ChallengeOption) -> Color {
        guard hasChecked else {
            return selectedID == option.id ? tint.opacity(0.06) : AppTheme.background.opacity(0.3)
        }
        if option.isCorrect { return AppTheme.positive.opacity(0.06) }
        if selectedID == option.id && !option.isCorrect { return AppTheme.negative.opacity(0.06) }
        return AppTheme.background.opacity(0.3)
    }
}

// MARK: - Ordering Challenge

private struct OrderingChallenge: View {
    let items: [String]
    let correctOrder: [Int]
    let tint: Color

    @Binding var solved: Bool
    @Binding var showResult: Bool
    @State private var userOrder: [Int] = []
    @State private var hasChecked = false
    @State private var isCorrect = false

    private var availableIndices: [Int] {
        Array(0..<items.count).filter { !userOrder.contains($0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Tap items in the correct order:")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.mutedInk)

            // Current ordering
            if !userOrder.isEmpty {
                VStack(spacing: 6) {
                    ForEach(userOrder.indices, id: \.self) { position in
                        HStack(spacing: 10) {
                            Text("\(position + 1)")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(width: 26, height: 26)
                                .background(orderColor(position: position), in: Circle())

                            Text(items[userOrder[position]])
                                .font(AppTheme.bodyFont)
                                .foregroundStyle(AppTheme.ink)

                            Spacer()

                            if !solved {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        userOrder.remove(at: position)
                                        hasChecked = false
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.body)
                                        .foregroundStyle(AppTheme.mutedInk)
                                }
                            }
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(orderBgColor(position: position))
                        )
                    }
                }
            }

            // Available items to tap
            if !availableIndices.isEmpty && !solved {
                FlowLayout(spacing: 8) {
                    ForEach(availableIndices, id: \.self) { index in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                userOrder.append(index)
                                hasChecked = false
                            }
                        } label: {
                            Text(items[index])
                                .font(AppTheme.bodyFont)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(tint.opacity(0.08))
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(tint.opacity(0.2), lineWidth: 1)
                                }
                                .foregroundStyle(AppTheme.ink)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if userOrder.count == items.count && !solved {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        hasChecked = true
                        isCorrect = userOrder == correctOrder
                        if isCorrect {
                            solved = true
                            showResult = true
                        }
                    }
                } label: {
                    Text(hasChecked && !isCorrect ? "Not quite \u{2014} try rearranging" : "Check Order")
                        .font(AppTheme.bodyFont.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .foregroundStyle(.white)
                }
            }

            if hasChecked && !isCorrect && !solved {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        userOrder = []
                        hasChecked = false
                    }
                } label: {
                    Text("Start Over")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.mutedInk)
                }
            }
        }
    }

    private func orderColor(position: Int) -> Color {
        guard hasChecked else { return tint }
        if position < correctOrder.count && userOrder[position] == correctOrder[position] {
            return AppTheme.positive
        }
        return AppTheme.negative
    }

    private func orderBgColor(position: Int) -> Color {
        guard hasChecked else { return AppTheme.background.opacity(0.4) }
        if position < correctOrder.count && userOrder[position] == correctOrder[position] {
            return AppTheme.positive.opacity(0.06)
        }
        return AppTheme.negative.opacity(0.06)
    }
}

// MARK: - Predict Output Challenge

private struct PredictOutputChallenge: View {
    let inputs: [Double]
    let weights: [Double]
    let bias: Double
    let activationName: String
    let correctAnswer: Double
    let tolerance: Double

    @Binding var solved: Bool
    @Binding var showResult: Bool
    @State private var userGuessText = ""
    @State private var hasChecked = false
    @State private var isCorrect = false

    private var weightedSum: Double {
        zip(inputs, weights).map(*).reduce(0, +) + bias
    }

    private var parsedGuess: Double? {
        Double(userGuessText.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    var body: some View {
        VStack(spacing: 14) {
            // Show the computation
            VStack(alignment: .leading, spacing: 6) {
                ForEach(inputs.indices, id: \.self) { i in
                    HStack(spacing: 4) {
                        Text("input[\(i)]")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(AppTheme.nodeInput)
                        Text("=")
                            .foregroundStyle(AppTheme.mutedInk)
                        Text("\(inputs[i], format: .number.precision(.fractionLength(1)))")
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        Text("\u{00D7}")
                            .foregroundStyle(AppTheme.mutedInk)
                        Text("w[\(i)]")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(AppTheme.accent)
                        Text("=")
                            .foregroundStyle(AppTheme.mutedInk)
                        Text("\(weights[i], format: .number.precision(.fractionLength(1)))")
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    }
                    .font(.system(size: 13))
                }
                if bias != 0 {
                    Text("bias = \(bias, format: .number.precision(.fractionLength(1)))")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(AppTheme.accentWarm)
                }
                if !activationName.isEmpty {
                    Text("activation = \(activationName)")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(AppTheme.mutedInk)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppTheme.background.opacity(0.5))
            )

            HStack {
                Text("Your prediction")
                    .font(AppTheme.bodyFont.weight(.medium))
                Spacer()
                Text(parsedGuess ?? 0, format: .number.precision(.fractionLength(3)))
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundStyle(isCorrect && hasChecked ? AppTheme.positive : AppTheme.ink)
            }

            TextField("Enter a number", text: $userGuessText)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .textFieldStyle(.plain)
                .keyboardType(.decimalPad)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppTheme.background.opacity(0.5))
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke((hasChecked && !isCorrect && parsedGuess != nil ? AppTheme.accentWarm : AppTheme.surfaceStrong.opacity(0.6)), lineWidth: 1)
                }
                .disabled(solved)

            if !solved {
                Button {
                    hasChecked = true
                    guard let guess = parsedGuess else {
                        isCorrect = false
                        return
                    }
                    isCorrect = abs(guess - correctAnswer) <= tolerance
                    if isCorrect {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            solved = true
                            showResult = true
                        }
                    }
                } label: {
                    Text(hasChecked && !isCorrect ? "Try Again" : "Check Prediction")
                        .font(AppTheme.bodyFont.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .foregroundStyle(.white)
                }
            }

            if hasChecked && !isCorrect {
                Text(feedbackText)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.accentWarm)
            }
        }
    }

    private var feedbackText: String {
        if parsedGuess == nil {
            return "Enter a numeric answer to check your prediction."
        }
        if activationName.isEmpty {
            return "Compute the weighted sum from the inputs, weights, and bias."
        }
        return "Compute the weighted sum, then apply \(activationName). You're close!"
    }
}

// MARK: - Flow Layout (for ordering challenge chips)

struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, offset) in result.offsets.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + offset.x, y: bounds.minY + offset.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (offsets: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var offsets: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            offsets.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }

        return (offsets, CGSize(width: maxX, height: currentY + lineHeight))
    }
}
