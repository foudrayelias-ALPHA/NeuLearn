import Foundation

struct SimpleNetworkSimulation {
    struct TrainingStepSnapshot {
        let inputs: [Double]
        let targetOutput: Double
        let learningRate: Double
        let epochBeforeUpdate: Int
        let epochAfterUpdate: Int
        let weightsInputToHiddenBefore: [Double]
        let weightsHiddenToOutputBefore: [Double]
        let hiddenRaw: [Double]
        let hiddenActivations: [Double]
        let outputRaw: Double
        let output: Double
        let loss: Double
        let outputError: Double
        let outputGradient: Double
        let hiddenGradients: [Double]
        let hiddenToOutputGradients: [Double]
        let inputToHiddenGradients: [Double]
        let hiddenToOutputDeltas: [Double]
        let inputToHiddenDeltas: [Double]
        let weightsInputToHiddenAfter: [Double]
        let weightsHiddenToOutputAfter: [Double]
    }

    var inputs: [Double]
    var targetOutput: Double
    var weightsInputToHidden: [Double]
    var weightsHiddenToOutput: [Double]
    var epoch: Int
    var learningRate: Double = 0.5

    static let demo = SimpleNetworkSimulation(
        inputs: [0.2, 0.7],
        targetOutput: 0.9,
        weightsInputToHidden: [0.4, -0.2],
        weightsHiddenToOutput: [0.5, 0.3],
        epoch: 0
    )

    var hiddenRaw: [Double] {
        zip(inputs, weightsInputToHidden).map(*)
    }

    var hiddenActivations: [Double] {
        hiddenRaw.map { sigmoid($0) }
    }

    var outputRaw: Double {
        zip(hiddenActivations, weightsHiddenToOutput)
            .map(*)
            .reduce(0, +)
    }

    var output: Double {
        sigmoid(outputRaw)
    }

    var loss: Double {
        let diff = targetOutput - output
        return 0.5 * diff * diff
    }

    func previewStep() -> TrainingStepSnapshot {
        let hiddenRaw = zip(inputs, weightsInputToHidden).map(*)
        let hiddenActivations = hiddenRaw.map(sigmoid)
        let outputRaw = zip(hiddenActivations, weightsHiddenToOutput)
            .map(*)
            .reduce(0, +)
        let output = sigmoid(outputRaw)
        let outputError = output - targetOutput
        let loss = 0.5 * outputError * outputError
        let outputGradient = outputError * sigmoidDerivative(outputRaw)

        let hiddenToOutputGradients = hiddenActivations.map { outputGradient * $0 }
        let hiddenToOutputDeltas = hiddenToOutputGradients.map { -learningRate * $0 }
        let weightsHiddenToOutputAfter = zip(weightsHiddenToOutput, hiddenToOutputDeltas).map(+)

        let hiddenGradients = hiddenRaw.indices.map { index in
            outputGradient * weightsHiddenToOutput[index] * sigmoidDerivative(hiddenRaw[index])
        }
        let inputToHiddenGradients = hiddenRaw.indices.map { index in
            hiddenGradients[index] * inputs[index]
        }
        let inputToHiddenDeltas = inputToHiddenGradients.map { -learningRate * $0 }
        let weightsInputToHiddenAfter = zip(weightsInputToHidden, inputToHiddenDeltas).map(+)

        return TrainingStepSnapshot(
            inputs: inputs,
            targetOutput: targetOutput,
            learningRate: learningRate,
            epochBeforeUpdate: epoch,
            epochAfterUpdate: epoch + 1,
            weightsInputToHiddenBefore: weightsInputToHidden,
            weightsHiddenToOutputBefore: weightsHiddenToOutput,
            hiddenRaw: hiddenRaw,
            hiddenActivations: hiddenActivations,
            outputRaw: outputRaw,
            output: output,
            loss: loss,
            outputError: outputError,
            outputGradient: outputGradient,
            hiddenGradients: hiddenGradients,
            hiddenToOutputGradients: hiddenToOutputGradients,
            inputToHiddenGradients: inputToHiddenGradients,
            hiddenToOutputDeltas: hiddenToOutputDeltas,
            inputToHiddenDeltas: inputToHiddenDeltas,
            weightsInputToHiddenAfter: weightsInputToHiddenAfter,
            weightsHiddenToOutputAfter: weightsHiddenToOutputAfter
        )
    }

    /// Perform one gradient descent step using backpropagation.
    mutating func trainStep() -> TrainingStepSnapshot {
        let snapshot = previewStep()
        weightsHiddenToOutput = snapshot.weightsHiddenToOutputAfter
        weightsInputToHidden = snapshot.weightsInputToHiddenAfter
        epoch += 1
        return snapshot
    }

    mutating func reset() {
        weightsInputToHidden = [0.4, -0.2]
        weightsHiddenToOutput = [0.5, 0.3]
        epoch = 0
    }

    private func sigmoid(_ value: Double) -> Double {
        1.0 / (1.0 + exp(-value))
    }

    private func sigmoidDerivative(_ value: Double) -> Double {
        let s = sigmoid(value)
        return s * (1 - s)
    }
}
