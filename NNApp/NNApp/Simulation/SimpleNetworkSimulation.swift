import Foundation

struct SimpleNetworkSimulation {
    // Network shape: 3 inputs → 3 hidden1 → 3 hidden2 → 1 output (fully connected)

    static let inputCount = 3
    static let hidden1Count = 3
    static let hidden2Count = 3

    struct TrainingStepSnapshot {
        let inputs: [Double]
        let targetOutput: Double
        let learningRate: Double
        let epochBeforeUpdate: Int
        let epochAfterUpdate: Int

        // Weights before update (flattened row-major)
        let weightsInputToHidden1Before: [Double]   // inputCount * hidden1Count
        let weightsHidden1ToHidden2Before: [Double]  // hidden1Count * hidden2Count
        let weightsHidden2ToOutputBefore: [Double]   // hidden2Count

        // Forward pass
        let hidden1Raw: [Double]
        let hidden1Activations: [Double]
        let hidden2Raw: [Double]
        let hidden2Activations: [Double]
        let outputRaw: Double
        let output: Double
        let loss: Double
        let outputError: Double

        // Gradients
        let outputGradient: Double
        let hidden2Gradients: [Double]
        let hidden1Gradients: [Double]

        // Weight deltas
        let hidden2ToOutputDeltas: [Double]
        let hidden1ToHidden2Deltas: [Double]
        let inputToHidden1Deltas: [Double]

        // Weights after update
        let weightsInputToHidden1After: [Double]
        let weightsHidden1ToHidden2After: [Double]
        let weightsHidden2ToOutputAfter: [Double]
    }

    var inputs: [Double]
    var targetOutput: Double
    var weightsInputToHidden1: [Double]    // 3*3 = 9
    var weightsHidden1ToHidden2: [Double]  // 3*3 = 9
    var weightsHidden2ToOutput: [Double]   // 3
    var epoch: Int
    var learningRate: Double = 0.5

    static let demo = SimpleNetworkSimulation(
        inputs: [0.2, 0.7, 0.5],
        targetOutput: 0.9,
        weightsInputToHidden1: [0.4, -0.2, 0.3, 0.1, 0.5, -0.3, -0.1, 0.2, 0.4],
        weightsHidden1ToHidden2: [0.3, -0.1, 0.2, 0.5, 0.1, -0.4, -0.2, 0.3, 0.1],
        weightsHidden2ToOutput: [0.5, 0.3, -0.2],
        epoch: 0
    )

    private static let initialWeightsIH1: [Double] = [0.4, -0.2, 0.3, 0.1, 0.5, -0.3, -0.1, 0.2, 0.4]
    private static let initialWeightsH1H2: [Double] = [0.3, -0.1, 0.2, 0.5, 0.1, -0.4, -0.2, 0.3, 0.1]
    private static let initialWeightsH2O: [Double] = [0.5, 0.3, -0.2]

    // MARK: - Forward helpers

    private func computeHidden1Raw() -> [Double] {
        var result = [Double](repeating: 0, count: Self.hidden1Count)
        for j in 0..<Self.hidden1Count {
            for i in 0..<Self.inputCount {
                result[j] += inputs[i] * weightsInputToHidden1[i * Self.hidden1Count + j]
            }
        }
        return result
    }

    private func computeLayerRaw(prevAct: [Double], weights: [Double], prevCount: Int, nextCount: Int) -> [Double] {
        var result = [Double](repeating: 0, count: nextCount)
        for j in 0..<nextCount {
            for i in 0..<prevCount {
                result[j] += prevAct[i] * weights[i * nextCount + j]
            }
        }
        return result
    }

    var hidden1Raw: [Double] { computeHidden1Raw() }
    var hidden1Activations: [Double] { hidden1Raw.map { sigmoid($0) } }

    var hidden2Raw: [Double] {
        computeLayerRaw(prevAct: hidden1Activations, weights: weightsHidden1ToHidden2, prevCount: Self.hidden1Count, nextCount: Self.hidden2Count)
    }
    var hidden2Activations: [Double] { hidden2Raw.map { sigmoid($0) } }

    var outputRaw: Double {
        zip(hidden2Activations, weightsHidden2ToOutput).map(*).reduce(0, +)
    }

    var output: Double { sigmoid(outputRaw) }

    var loss: Double {
        let diff = targetOutput - output
        return 0.5 * diff * diff
    }

    // MARK: - Full step

    func previewStep() -> TrainingStepSnapshot {
        // Forward
        let h1Raw = computeHidden1Raw()
        let h1Act = h1Raw.map(sigmoid)
        let h2Raw = computeLayerRaw(prevAct: h1Act, weights: weightsHidden1ToHidden2, prevCount: Self.hidden1Count, nextCount: Self.hidden2Count)
        let h2Act = h2Raw.map(sigmoid)
        let oRaw = zip(h2Act, weightsHidden2ToOutput).map(*).reduce(0, +)
        let o = sigmoid(oRaw)
        let oError = o - targetOutput
        let oLoss = 0.5 * oError * oError

        // Backprop
        let oGrad = oError * sigmoidDerivative(oRaw)

        // hidden2 → output deltas
        let h2oGrads = h2Act.map { oGrad * $0 }
        let h2oDeltas = h2oGrads.map { -learningRate * $0 }
        let wH2OAfter = zip(weightsHidden2ToOutput, h2oDeltas).map(+)

        // hidden2 gradients
        var h2Grads = [Double](repeating: 0, count: Self.hidden2Count)
        for j in 0..<Self.hidden2Count {
            h2Grads[j] = oGrad * weightsHidden2ToOutput[j] * sigmoidDerivative(h2Raw[j])
        }

        // hidden1 → hidden2 deltas
        var h1h2Grads = [Double](repeating: 0, count: Self.hidden1Count * Self.hidden2Count)
        for i in 0..<Self.hidden1Count {
            for j in 0..<Self.hidden2Count {
                h1h2Grads[i * Self.hidden2Count + j] = h2Grads[j] * h1Act[i]
            }
        }
        let h1h2Deltas = h1h2Grads.map { -learningRate * $0 }
        let wH1H2After = zip(weightsHidden1ToHidden2, h1h2Deltas).map(+)

        // hidden1 gradients
        var h1Grads = [Double](repeating: 0, count: Self.hidden1Count)
        for i in 0..<Self.hidden1Count {
            var sum = 0.0
            for j in 0..<Self.hidden2Count {
                sum += h2Grads[j] * weightsHidden1ToHidden2[i * Self.hidden2Count + j]
            }
            h1Grads[i] = sum * sigmoidDerivative(h1Raw[i])
        }

        // input → hidden1 deltas
        var ih1Grads = [Double](repeating: 0, count: Self.inputCount * Self.hidden1Count)
        for i in 0..<Self.inputCount {
            for j in 0..<Self.hidden1Count {
                ih1Grads[i * Self.hidden1Count + j] = h1Grads[j] * inputs[i]
            }
        }
        let ih1Deltas = ih1Grads.map { -learningRate * $0 }
        let wIH1After = zip(weightsInputToHidden1, ih1Deltas).map(+)

        return TrainingStepSnapshot(
            inputs: inputs,
            targetOutput: targetOutput,
            learningRate: learningRate,
            epochBeforeUpdate: epoch,
            epochAfterUpdate: epoch + 1,
            weightsInputToHidden1Before: weightsInputToHidden1,
            weightsHidden1ToHidden2Before: weightsHidden1ToHidden2,
            weightsHidden2ToOutputBefore: weightsHidden2ToOutput,
            hidden1Raw: h1Raw,
            hidden1Activations: h1Act,
            hidden2Raw: h2Raw,
            hidden2Activations: h2Act,
            outputRaw: oRaw,
            output: o,
            loss: oLoss,
            outputError: oError,
            outputGradient: oGrad,
            hidden2Gradients: h2Grads,
            hidden1Gradients: h1Grads,
            hidden2ToOutputDeltas: h2oDeltas,
            hidden1ToHidden2Deltas: h1h2Deltas,
            inputToHidden1Deltas: ih1Deltas,
            weightsInputToHidden1After: wIH1After,
            weightsHidden1ToHidden2After: wH1H2After,
            weightsHidden2ToOutputAfter: wH2OAfter
        )
    }

    mutating func trainStep() -> TrainingStepSnapshot {
        let snapshot = previewStep()
        weightsInputToHidden1 = snapshot.weightsInputToHidden1After
        weightsHidden1ToHidden2 = snapshot.weightsHidden1ToHidden2After
        weightsHidden2ToOutput = snapshot.weightsHidden2ToOutputAfter
        epoch += 1
        return snapshot
    }

    mutating func reset() {
        weightsInputToHidden1 = Self.initialWeightsIH1
        weightsHidden1ToHidden2 = Self.initialWeightsH1H2
        weightsHidden2ToOutput = Self.initialWeightsH2O
        epoch = 0
    }

    func sigmoid(_ value: Double) -> Double {
        1.0 / (1.0 + exp(-value))
    }

    func sigmoidDerivative(_ value: Double) -> Double {
        let s = sigmoid(value)
        return s * (1 - s)
    }
}
