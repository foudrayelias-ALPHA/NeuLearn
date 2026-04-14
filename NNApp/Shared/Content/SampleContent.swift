import Foundation

// swiftlint:disable type_body_length file_length
enum SampleContent {

    // MARK: - Lessons

    static let existingLessons: [Lesson] = [
        lessonNeuron, lessonWeightsBias, lessonActivation,
        lessonForwardPass, lessonLoss, lessonGradientDescent, lessonBackprop,
        lessonOverfitting, lessonLearningRate,
        lessonFeedforward, lessonCNN, lessonTransformers,
    ]

    static let applicationsLessons: [Lesson] = [
        lessonWeightsReally,
        lessonSignals,
        lessonNumbersInNumbersOut,
        lessonComputersDoTheMath,
        lessonTrainingToDeployment,
        lessonWhatNetworkLearned,
        lessonLimitsOfNumbers,
    ]

    static var lessons: [Lesson] {
        existingLessons + applicationsLessons + generatedExploreLessons
    }

    static func lesson(for id: UUID) -> Lesson? {
        lessons.first { $0.id == id }
    }

    static func lesson(for node: TopicTreeNode) -> Lesson? {
        if let lessonID = node.lessonID {
            return lesson(for: lessonID)
        }

        return generatedExploreLessonsByTitle[node.label]
    }

    // MARK: Beginner

    static let lessonWeightsReally = Lesson(
        id: UUID(uuidString: "A0000002-0000-0000-0000-000000000001")!,
        title: "What Are Weights, Really?",
        summary: "See a trained model as stored numbers, not magic.",
        level: .beginner,
        sections: [
            LessonSection(title: "Weights are values", body: "A weight is just a floating-point number. In code, weights usually live inside arrays, vectors, or matrices. A neuron does not store a rule like \"look for whiskers\" in plain English. It stores many numeric values that push outputs up or down during the forward pass."),
            LessonSection(title: "A model is a file of numbers", body: "After training, those weights are written to disk. A model file is often a very large collection of numbers plus a little metadata describing shapes and names. When someone says they downloaded a model checkpoint, they usually mean they downloaded learned weights that can be loaded back into memory for inference."),
            LessonSection(title: "Architecture vs. weights", body: "The architecture is the structure: how many layers, what kinds of operations, and how tensors flow. The weights are the learned recipe inside that structure. Same architecture, different weights, completely different behavior. Think of the architecture as the kitchen and the weights as the ingredients and proportions that make a specific dish.")
        ],
        challenge: LessonChallenge(
            prompt: "Which statement is most accurate?",
            type: .multipleChoice(options: [
                ChallengeOption(text: "Weights are English rules hidden inside each neuron.", isCorrect: false, explanation: "Weights are not text instructions. They are numeric parameters."),
                ChallengeOption(text: "Weights are learned floating-point values stored in arrays or matrices.", isCorrect: true, explanation: "Correct. That is the concrete representation used by neural networks."),
                ChallengeOption(text: "Weights exist only while training and disappear during inference.", isCorrect: false, explanation: "Inference depends on the saved weights."),
                ChallengeOption(text: "Weights are the same thing as the architecture.", isCorrect: false, explanation: "Architecture describes structure. Weights are the learned parameter values.")
            ])
        )
    )

    static let lessonSignals = Lesson(
        id: UUID(uuidString: "A0000002-0000-0000-0000-000000000007")!,
        title: "What Are Signals?",
        summary: "How information actually travels through a network.",
        level: .beginner,
        sections: [
            LessonSection(title: "A signal is a number in motion", body: "In neural networks, a signal is just a number being passed from one part of the network to the next. One neuron produces an output value, and that value becomes part of the next neuron's input. There is no hidden substance moving through the model. The signal is the value itself."),
            LessonSection(title: "Weights shape signals", body: "A raw signal does not stay unchanged. Each receiving neuron multiplies incoming signals by weights, adds them together, and often applies an activation function. That means the same incoming signal can be amplified, weakened, flipped, or ignored depending on the learned weights."),
            LessonSection(title: "From layer to layer", body: "As signals move through deeper layers, they become transformed representations of the original input. Early signals may reflect simple measurements like brightness or token identity. Later signals may encode more abstract combinations such as edges, shapes, or context. The network's entire forward pass is a chain of signal transformations.")
        ],
        challenge: LessonChallenge(
            prompt: "Which description of a neural-network signal is best?",
            type: .multipleChoice(options: [
                ChallengeOption(text: "A signal is a special kind of energy stored inside each layer.", isCorrect: false, explanation: "Signals are not a separate physical substance inside the model."),
                ChallengeOption(text: "A signal is a numeric value passed forward and transformed by weights and activations.", isCorrect: true, explanation: "Correct. Signals are just values moving through the computation."),
                ChallengeOption(text: "A signal is another name for the model's architecture.", isCorrect: false, explanation: "Architecture is the structure of the network, not the values flowing through it."),
                ChallengeOption(text: "Signals only exist during training, not inference.", isCorrect: false, explanation: "Inference is also a forward pass, so signals still move through the network.")
            ])
        )
    )

    static let lessonNumbersInNumbersOut = Lesson(
        id: UUID(uuidString: "A0000002-0000-0000-0000-000000000002")!,
        title: "Numbers In, Numbers Out",
        summary: "How images, text, and audio become machine-readable values.",
        level: .beginner,
        sections: [
            LessonSection(title: "Inputs become numbers", body: "Computers only manipulate numbers. An image becomes pixel values. Text becomes token IDs. Audio becomes sampled amplitudes over time. Before a neural network sees anything, that thing has already been converted into a numerical representation."),
            LessonSection(title: "Outputs are numbers too", body: "The output of a model is also numeric. A classifier might produce one score per label. A language model produces one score for every possible next token. An embedding model produces a vector of values that place similar meanings near each other in space."),
            LessonSection(title: "What a prediction really means", body: "When we say a network recognized a cat, we usually mean the score tied to the cat label ended up higher than the other labels. The system did not attach the human concept of catness. It computed numbers, and we interpreted the highest one using a label map.")
        ],
        challenge: LessonChallenge(
            prompt: "If a classifier outputs [0.12 dog, 0.81 cat, 0.07 bird], what does the model predict?",
            type: .multipleChoice(options: [
                ChallengeOption(text: "Dog, because it appears first in the list.", isCorrect: false, explanation: "Order does not matter here. The largest score matters."),
                ChallengeOption(text: "Cat, because that label has the highest output value.", isCorrect: true, explanation: "Correct. The prediction is the label attached to the highest score."),
                ChallengeOption(text: "Bird, because small numbers are more confident.", isCorrect: false, explanation: "Confidence is not encoded by choosing the smallest score."),
                ChallengeOption(text: "Nothing. Outputs are only used during training.", isCorrect: false, explanation: "Outputs are what inference produces at runtime.")
            ])
        )
    )

    static let lessonComputersDoTheMath = Lesson(
        id: UUID(uuidString: "A0000002-0000-0000-0000-000000000003")!,
        title: "How Computers Do the Math",
        summary: "Why matrix multiplication and parallel hardware dominate deep learning.",
        level: .intermediate,
        sections: [
            LessonSection(title: "Matrix multiply everywhere", body: "Under the hood, many neural network layers reduce to matrix multiplication plus simple element-wise operations. A batch of inputs is multiplied by a matrix of weights, biases are added, and then an activation or normalization step follows. That pattern appears again and again."),
            LessonSection(title: "Why GPUs matter", body: "GPUs are valuable because they can perform huge numbers of similar multiply-add operations in parallel. Neural network workloads contain exactly that kind of repetitive arithmetic. Instead of a few large CPU cores doing general work, GPUs use many smaller cores to push through massive arrays of numbers efficiently."),
            LessonSection(title: "Precision is a tradeoff", body: "Float32 stores more precision than Float16, but it also uses more memory and bandwidth. Smaller formats often run faster and let more model weights fit on a device. The tradeoff is that less precision can introduce rounding error, so engineers pick formats that are small enough to be fast but accurate enough to preserve model quality.")
        ],
        challenge: LessonChallenge(
            prompt: "Why are GPUs especially useful for neural networks?",
            type: .multipleChoice(options: [
                ChallengeOption(text: "They are better at storing text prompts in memory.", isCorrect: false, explanation: "Prompt storage is not the main reason."),
                ChallengeOption(text: "They can run many similar multiply-add operations in parallel.", isCorrect: true, explanation: "Correct. Deep learning relies heavily on parallel numerical operations."),
                ChallengeOption(text: "They remove the need for weights entirely.", isCorrect: false, explanation: "Hardware does not replace model parameters."),
                ChallengeOption(text: "They always make models perfectly accurate.", isCorrect: false, explanation: "Faster hardware does not guarantee better predictions.")
            ])
        )
    )

    static let lessonTrainingToDeployment = Lesson(
        id: UUID(uuidString: "A0000002-0000-0000-0000-000000000004")!,
        title: "From Training to Deployment",
        summary: "What changes when a model stops learning and starts serving predictions.",
        level: .intermediate,
        sections: [
            LessonSection(title: "Training produces weights", body: "Training repeatedly adjusts weights to reduce loss on data. By the end, the main artifact you keep is the learned parameter set. That is the expensive part of the process: searching for a useful arrangement of numbers."),
            LessonSection(title: "Inference loads and runs", body: "Deployment means putting those learned weights somewhere useful, such as a phone, browser, server, or edge device. Running the model usually means loading weights into memory, preparing an input tensor, and executing forward passes to produce outputs."),
            LessonSection(title: "Size matters", body: "Large models can be enormous because every parameter consumes storage. Quantization shrinks weights into smaller numeric formats so the model needs less memory and can often run faster. That is one of the main ways engineers make a trained model practical on limited hardware.")
        ],
        challenge: LessonChallenge(
            prompt: "Put these steps in the correct order:",
            type: .ordering(
                items: ["Run inference on new input", "Train the model", "Save learned weights", "Load weights onto a device"],
                correctOrder: [1, 2, 3, 0]
            )
        )
    )

    static let lessonWhatNetworkLearned = Lesson(
        id: UUID(uuidString: "A0000002-0000-0000-0000-000000000005")!,
        title: "What the Network Actually Learned",
        summary: "How simple patterns become layered internal representations.",
        level: .intermediate,
        sections: [
            LessonSection(title: "Layers build up features", body: "In many vision models, early layers respond to simple patterns such as edges, contrast changes, or basic textures. Later layers combine those lower-level signals into larger shapes or object parts. Deeper layers often represent more abstract combinations of earlier features."),
            LessonSection(title: "Neurons respond to patterns", body: "A neuron does not usually store a perfect human-readable concept. Instead, it becomes sensitive to some pattern in the data. Researchers sometimes inspect which inputs maximize a neuron's activation to get hints about what kinds of features it reacts to."),
            LessonSection(title: "Shortcut learning is real", body: "Networks can sometimes solve tasks for the wrong reason. If a wolf photo dataset often includes snow in the background, the model may learn to rely on snow more than the animal itself. That is why strong benchmark scores do not always mean a model truly learned the intended concept.")
        ],
        challenge: LessonChallenge(
            prompt: "A model classifies wolves mostly by the snowy background in many training photos. What is this an example of?",
            type: .multipleChoice(options: [
                ChallengeOption(text: "Good generalization from the true concept.", isCorrect: false, explanation: "The model is not using the intended concept."),
                ChallengeOption(text: "Shortcut learning based on a spurious correlation.", isCorrect: true, explanation: "Correct. The model found an easy proxy instead of the real signal."),
                ChallengeOption(text: "Quantization error during deployment.", isCorrect: false, explanation: "This is about learned behavior, not numeric compression."),
                ChallengeOption(text: "Backpropagation failing to compute gradients.", isCorrect: false, explanation: "The issue is the data pattern the model exploited.")
            ])
        )
    )

    static let lessonLimitsOfNumbers = Lesson(
        id: UUID(uuidString: "A0000002-0000-0000-0000-000000000006")!,
        title: "The Limits of Numbers",
        summary: "Why bigger models still have practical blind spots.",
        level: .beginner,
        sections: [
            LessonSection(title: "Pattern matching is not everything", body: "Neural networks can become extremely good pattern matchers without being reliable reasoners. They may struggle with careful counting, unfamiliar combinations, or tasks that look different from their training data even when the underlying idea is simple for a person."),
            LessonSection(title: "More parameters are not magic", body: "Adding parameters often increases capacity, but it does not guarantee understanding. A larger model may store more patterns, require more data, and cost more to run while still failing in cases that need abstraction, planning, or robust out-of-distribution behavior."),
            LessonSection(title: "Generalization is the real goal", body: "Memorization means recalling seen examples. Generalization means applying learned structure to new examples. Practical machine learning is mostly about pushing models toward the second one while knowing they will never become perfect just by scaling numbers upward.")
        ],
        challenge: LessonChallenge(
            prompt: "Which statement is the best takeaway?",
            type: .multipleChoice(options: [
                ChallengeOption(text: "If a model has more parameters, it will automatically reason better.", isCorrect: false, explanation: "Scale can help, but it does not guarantee robust reasoning."),
                ChallengeOption(text: "Generalization matters more than memorizing training examples.", isCorrect: true, explanation: "Correct. Real-world usefulness depends on handling new cases well."),
                ChallengeOption(text: "Neural networks fail only because GPUs are too slow.", isCorrect: false, explanation: "Many limits are conceptual, not just computational."),
                ChallengeOption(text: "Once trained, a model can no longer make mistakes on novel inputs.", isCorrect: false, explanation: "Novel situations are often where models are most fragile.")
            ])
        )
    )

    static let lessonNeuron = Lesson(
        id: UUID(uuidString: "A0000001-0000-0000-0000-000000000001")!,
        title: "What is a neuron?",
        summary: "A first mental model for inputs, weights, and output.",
        level: .beginner,
        sections: [
            LessonSection(title: "Intuition", body: "Think of a neuron as a tiny decision-maker. It receives several numbers as input, decides how important each one is, adds them up, and produces a single output number.\n\nImagine you're deciding whether to go outside. You consider the temperature, whether it's raining, and how much free time you have. Each factor matters a different amount to you -- that's exactly what a neuron does with its inputs."),
            LessonSection(title: "How it works", body: "A neuron multiplies each input by a weight, sums the results, and passes the total through an activation function.\n\nFor example, with two inputs (0.5 and 0.8) and weights (0.4 and 0.6):\n\nWeighted sum = (0.5 \u{00D7} 0.4) + (0.8 \u{00D7} 0.6) = 0.20 + 0.48 = 0.68\n\nThe activation function then transforms 0.68 into the neuron's output, deciding how strongly this neuron \"fires.\"", interactive: .neuronExplorer),
            LessonSection(title: "Why it matters", body: "A single neuron can only make simple decisions -- like drawing a straight line between two groups. But when you connect many neurons together in layers, the network can learn to recognize complex patterns.\n\nEvery deep learning model, from image classifiers to language models, is built from this same basic unit."),
        ],
        challenge: LessonChallenge(
            prompt: "A neuron receives inputs [0.5, 0.8] with weights [0.4, 0.6]. What is the weighted sum before any activation function is applied?",
            type: .predictOutput(inputs: [0.5, 0.8], weights: [0.4, 0.6], bias: 0.0, activationName: "", correctAnswer: 0.68, tolerance: 0.05)
        )
    )

    static let lessonWeightsBias = Lesson(
        id: UUID(uuidString: "A0000001-0000-0000-0000-000000000002")!,
        title: "Weights and bias",
        summary: "How a neuron decides how much each input matters.",
        level: .beginner,
        sections: [
            LessonSection(title: "Weights", body: "Each connection between neurons has a weight -- a number that controls how much influence one neuron's output has on the next.\n\nA large positive weight means \"pay close attention to this input.\" A weight near zero means \"mostly ignore this.\" A negative weight means \"this input pushes the output in the opposite direction.\""),
            LessonSection(title: "Bias", body: "Bias is an extra number added to the weighted sum before the activation function. It shifts the neuron's threshold for firing.\n\nWithout bias, a neuron with all-zero inputs would always output the same thing. Bias lets the neuron have a baseline preference, making the model more flexible.", interactive: .neuronExplorer),
            LessonSection(title: "Learning", body: "During training, the network adjusts weights and biases to reduce prediction errors. This is the core of learning: finding the combination of weights and biases that makes the network's output match the desired result as closely as possible."),
        ],
        challenge: LessonChallenge(
            prompt: "What does a negative weight do to an input signal?",
            type: .multipleChoice(options: [
                ChallengeOption(text: "Amplifies the input and makes the signal stronger overall", isCorrect: false, explanation: "A positive weight amplifies. A negative weight inverts the signal."),
                ChallengeOption(text: "Reverses the input's direction", isCorrect: true, explanation: "Correct! A negative weight flips the effect: positive inputs push the output down, and vice versa."),
                ChallengeOption(text: "Zeroes out the input so the neuron ignores it entirely", isCorrect: false, explanation: "A weight of exactly zero would ignore the input. Negative weights still pass information, just inverted."),
                ChallengeOption(text: "Has no effect on the output", isCorrect: false, explanation: "Every non-zero weight affects the output. Negative weights invert the signal direction."),
            ])
        )
    )

    static let lessonActivation = Lesson(
        id: UUID(uuidString: "A0000001-0000-0000-0000-000000000003")!,
        title: "Activation functions",
        summary: "Why neurons need a non-linear step.",
        level: .beginner,
        sections: [
            LessonSection(title: "The problem", body: "If neurons only multiplied and added, stacking layers wouldn't help -- the entire network would collapse into one simple linear function. No matter how many layers you add, you'd only ever be able to draw straight lines through your data."),
            LessonSection(title: "The solution", body: "Activation functions introduce non-linearity. After computing the weighted sum, the neuron passes it through a function that bends, squashes, or clips the output.\n\nCommon activation functions:\n\n\u{2022} Sigmoid: squashes values to between 0 and 1\n\u{2022} ReLU: outputs zero for negative values, passes positive values through unchanged\n\u{2022} Tanh: squashes values to between -1 and 1", interactive: .activationPlayground),
            LessonSection(title: "Why it matters", body: "Non-linearity is what gives neural networks their power. It allows them to learn curved boundaries, complex patterns, and subtle relationships in data that no linear model could capture."),
        ],
        challenge: LessonChallenge(
            prompt: "A network uses only linear functions (no activation). You stack 100 layers. What can it learn?",
            type: .multipleChoice(options: [
                ChallengeOption(text: "Complex curves and patterns, since more layers means more power", isCorrect: false, explanation: "Without non-linearity, stacking layers is like multiplying matrices. It always collapses to a single linear transformation, no matter how deep."),
                ChallengeOption(text: "Only straight-line relationships", isCorrect: true, explanation: "Correct! Without activation functions, any number of stacked linear layers is mathematically equivalent to a single linear layer. That's why non-linearity is essential."),
                ChallengeOption(text: "Nothing at all, because the network can't even run without activation functions", isCorrect: false, explanation: "The network can still compute, it just can't learn anything beyond linear relationships. Activation functions unlock complexity, they don't enable computation."),
                ChallengeOption(text: "It depends on how many neurons each layer has", isCorrect: false, explanation: "Width doesn't help either. More neurons in a linear layer still produce a linear output. Non-linearity is the missing ingredient."),
            ])
        )
    )

    // MARK: Intermediate

    static let lessonForwardPass = Lesson(
        id: UUID(uuidString: "A0000001-0000-0000-0000-000000000004")!,
        title: "Forward pass",
        summary: "How values flow through a network to produce a prediction.",
        level: .intermediate,
        sections: [
            LessonSection(title: "The flow", body: "A forward pass is the process of feeding input data through the network, layer by layer, until it produces an output.\n\nAt each layer, every neuron computes its weighted sum of inputs, adds its bias, and applies its activation function. The results become the inputs for the next layer."),
            LessonSection(title: "Step by step", body: "1. Input values enter the first layer\n2. Each neuron computes: output = activation(weights \u{00B7} inputs + bias)\n3. Those outputs become inputs to the next layer\n4. Repeat until the final layer produces the prediction\n\nThe entire process is deterministic -- the same inputs with the same weights always produce the same output.", interactive: .forwardPassStepper),
            LessonSection(title: "In practice", body: "When you use the Visual Lab and adjust the input sliders, you're watching the forward pass happen in real time. Each node updates instantly because the computation flows strictly forward through the network."),
        ],
        challenge: LessonChallenge(
            prompt: "In a forward pass, which direction does data flow?",
            type: .multipleChoice(options: [
                ChallengeOption(text: "Output to input, since the network needs to check its answer first", isCorrect: false, explanation: "Backward flow is backpropagation, used during training to compute gradients."),
                ChallengeOption(text: "Input to output, one layer at a time", isCorrect: true, explanation: "Correct! The forward pass computes outputs layer by layer from input to output."),
                ChallengeOption(text: "All layers compute simultaneously in parallel", isCorrect: false, explanation: "Each layer depends on the previous layer's output, so they must compute in sequence."),
                ChallengeOption(text: "Randomly between layers depending on the architecture", isCorrect: false, explanation: "The forward pass is strictly ordered: input layer first, output layer last."),
            ])
        )
    )

    static let lessonLoss = Lesson(
        id: UUID(uuidString: "A0000001-0000-0000-0000-000000000005")!,
        title: "Loss and error",
        summary: "Measuring how wrong the network's predictions are.",
        level: .intermediate,
        sections: [
            LessonSection(title: "What is loss?", body: "Loss is a single number that measures how far the network's prediction is from the correct answer. A loss of zero means a perfect prediction. Higher loss means the network is more wrong.\n\nThe goal of training is to minimize loss across all training examples.", interactive: .lossVisualizer),
            LessonSection(title: "Common loss functions", body: "\u{2022} Mean Squared Error (MSE): averages the squared differences between predictions and targets. Used for regression problems.\n\n\u{2022} Cross-Entropy Loss: measures how different two probability distributions are. Used for classification problems.\n\nThe choice of loss function tells the network what \"being wrong\" means for your specific problem."),
            LessonSection(title: "Why it matters", body: "Loss is the signal that drives learning. Without a way to measure error, the network would have no direction to improve. Every training step asks: \"which way should I adjust the weights to make this number smaller?\""),
        ],
        challenge: LessonChallenge(
            prompt: "Two models predict tomorrow's temperature (actual: 72°F). Model A predicts 75°F every day. Model B predicts 60°F half the time and 84°F the other half. Which has lower MSE loss?",
            type: .multipleChoice(options: [
                ChallengeOption(text: "Model A — it's consistently close", isCorrect: true, explanation: "Correct! Model A's error is always 3, so MSE = 9. Model B's errors are 12 and 12, so MSE = 144. Squaring punishes large errors disproportionately — being consistently close beats wild swings, even if the average error looks similar."),
                ChallengeOption(text: "Model B — the errors cancel out on average", isCorrect: false, explanation: "MSE squares the errors before averaging, so large errors are penalized heavily. Model B's big misses (±12) produce much higher loss than Model A's small ones (±3)."),
                ChallengeOption(text: "They're the same — both average out to 72°F", isCorrect: false, explanation: "Loss measures prediction quality, not averages. MSE squares each error, so Model B's large deviations are punished far more than Model A's consistent small ones."),
                ChallengeOption(text: "Not enough information to tell", isCorrect: false, explanation: "We have everything we need! Model A: MSE = (75-72)² = 9. Model B: MSE = ((60-72)² + (84-72)²)/2 = 144. Model A wins easily."),
            ])
        )
    )

    static let lessonGradientDescent = Lesson(
        id: UUID(uuidString: "A0000001-0000-0000-0000-000000000006")!,
        title: "Gradient descent",
        summary: "How the network finds better weights step by step.",
        level: .intermediate,
        sections: [
            LessonSection(title: "The idea", body: "Imagine you're standing on a hilly landscape in thick fog. You can't see the lowest point, but you can feel which direction slopes downward under your feet. Gradient descent works the same way: it measures the slope of the loss with respect to each weight, then takes a small step downhill.", interactive: .gradientStep),
            LessonSection(title: "The gradient", body: "The gradient is a vector of partial derivatives -- it tells you, for each weight, how much the loss would change if you nudged that weight slightly.\n\nA large gradient means the loss is very sensitive to that weight. A gradient near zero means changing that weight wouldn't help much."),
            LessonSection(title: "The update", body: "Each training step:\n\n1. Compute the loss\n2. Compute the gradient of the loss with respect to every weight\n3. Update each weight: new_weight = old_weight - learning_rate \u{00D7} gradient\n\nThe learning rate controls how big each step is. Too large and you overshoot; too small and training takes forever."),
        ],
        challenge: LessonChallenge(
            prompt: "If a weight is 0.5, the gradient is 0.2, and the learning rate is 0.1, what is the new weight after one update?",
            type: .sliderTarget(label: "New weight", target: 0.48, tolerance: 0.02, minVal: 0.0, maxVal: 1.0, unit: "")
        )
    )

    static let lessonBackprop = Lesson(
        id: UUID(uuidString: "A0000001-0000-0000-0000-000000000007")!,
        title: "Backpropagation",
        summary: "Tracing error backward to assign responsibility to each weight.",
        level: .intermediate,
        sections: [
            LessonSection(title: "The challenge", body: "In a multi-layer network, how do you know which weights in the early layers contributed to the final error? The output layer's error is clear, but what about the hidden layers?\n\nBackpropagation solves this by working backward through the network, using the chain rule of calculus."),
            LessonSection(title: "How it works", body: "1. Run a forward pass to compute the output\n2. Compute the loss\n3. Starting from the output layer, calculate how much each weight contributed to the error\n4. Propagate these error signals backward through each layer\n5. Each weight gets a gradient telling it which direction to change\n\nThe chain rule lets you decompose the total error into contributions from each connection."),
            LessonSection(title: "In the Visual Lab", body: "When you press 'Step' in the Visual Lab, backpropagation runs behind the scenes. The weights update because the algorithm traced the error backward and computed exactly how each weight should change to reduce the loss."),
        ],
        challenge: LessonChallenge(
            prompt: "Put these backpropagation steps in the correct order:",
            type: .ordering(
                items: ["Compute the loss", "Run a forward pass", "Calculate output layer gradients", "Propagate gradients to hidden layers", "Update all weights"],
                correctOrder: [1, 0, 2, 3, 4]
            )
        )
    )

    // MARK: Advanced

    static let lessonOverfitting = Lesson(
        id: UUID(uuidString: "A0000001-0000-0000-0000-000000000008")!,
        title: "Overfitting and underfitting",
        summary: "When models memorize instead of learning.",
        level: .advanced,
        sections: [
            LessonSection(title: "Underfitting", body: "A model underfits when it's too simple to capture the patterns in the data. It performs poorly on both training data and new data.\n\nCauses: too few neurons or layers, insufficient training time, or overly aggressive regularization."),
            LessonSection(title: "Overfitting", body: "A model overfits when it memorizes the training data -- including its noise and quirks -- instead of learning the underlying pattern. It performs well on training data but poorly on new, unseen data.\n\nCauses: too many parameters relative to training data, training for too long, or no regularization."),
            LessonSection(title: "Finding the balance", body: "The goal is generalization: a model that captures real patterns without memorizing noise.\n\nTechniques to prevent overfitting:\n\u{2022} Regularization (L1, L2)\n\u{2022} Dropout: randomly disabling neurons during training\n\u{2022} Early stopping: halt training when validation performance stops improving\n\u{2022} More training data"),
        ],
        challenge: LessonChallenge(
            prompt: "A model scores 99% accuracy on training data but 52% on test data. What is this?",
            type: .multipleChoice(options: [
                ChallengeOption(text: "Underfitting", isCorrect: false, explanation: "Underfitting would show poor performance on both training AND test data."),
                ChallengeOption(text: "Overfitting", isCorrect: true, explanation: "Correct! The huge gap between training accuracy (99%) and test accuracy (52%) is the classic sign of overfitting -- the model memorized the training data."),
                ChallengeOption(text: "Good generalization", isCorrect: false, explanation: "Good generalization means similar performance on training and test data. A 47% gap is the opposite."),
                ChallengeOption(text: "The model needs more training time", isCorrect: false, explanation: "More training would likely make overfitting worse, not better. The model already performs near-perfectly on training data."),
            ])
        )
    )

    static let lessonLearningRate = Lesson(
        id: UUID(uuidString: "A0000001-0000-0000-0000-000000000009")!,
        title: "Learning rate",
        summary: "How step size shapes the training process.",
        level: .advanced,
        sections: [
            LessonSection(title: "What it controls", body: "The learning rate is a multiplier applied to every gradient update. It determines how far the weights move on each training step.\n\nToo high: the model overshoots good solutions and may never converge\nToo low: the model converges very slowly and may get stuck in poor local minima", interactive: .learningRateExplorer),
            LessonSection(title: "Finding the right rate", body: "There's no universal best learning rate. Common strategies:\n\n\u{2022} Start with a moderate value (0.01 or 0.001) and observe\n\u{2022} Learning rate schedules: decrease the rate over time\n\u{2022} Warm-up: start small and gradually increase\n\u{2022} Adaptive methods: algorithms like Adam adjust the rate per-weight automatically"),
            LessonSection(title: "Try it yourself", body: "In the Visual Lab, adjust the learning rate slider and watch how training behavior changes. A high rate makes the weights swing wildly. A low rate makes them creep slowly toward the target. Finding the sweet spot is one of the most important skills in training neural networks."),
        ],
        challenge: LessonChallenge(
            prompt: "What happens when the learning rate is too high?",
            type: .multipleChoice(options: [
                ChallengeOption(text: "Training is very slow but the model stays stable and converges", isCorrect: false, explanation: "That describes a learning rate that is too LOW, not too high."),
                ChallengeOption(text: "The loss overshoots and may diverge", isCorrect: true, explanation: "Correct! A high learning rate causes the weights to jump too far on each step, overshooting the minimum and potentially making the loss increase instead of decrease."),
                ChallengeOption(text: "The model underfits because it can't hold onto patterns", isCorrect: false, explanation: "Underfitting is about model capacity, not learning rate. A high rate causes instability."),
                ChallengeOption(text: "Nothing, because modern optimizers handle any learning rate automatically", isCorrect: false, explanation: "Even adaptive optimizers have a base learning rate that can cause divergence if set too high."),
            ])
        )
    )

    static let lessonFeedforward = Lesson(
        id: UUID(uuidString: "A0000001-0000-0000-0000-00000000000A")!,
        title: "Feedforward networks",
        summary: "The simplest architecture: data flows one direction.",
        level: .advanced,
        sections: [
            LessonSection(title: "Structure", body: "A feedforward network is the most basic neural network architecture. Data enters at the input layer, passes through one or more hidden layers, and exits at the output layer. There are no loops or cycles -- information only moves forward."),
            LessonSection(title: "What they can do", body: "Despite their simplicity, feedforward networks are universal function approximators. Given enough neurons, they can theoretically learn any continuous function.\n\nIn practice, they work well for tabular data, simple classification, and regression tasks."),
            LessonSection(title: "Limitations", body: "Feedforward networks treat each input independently. They have no memory of previous inputs and no awareness of spatial structure. This is why specialized architectures like CNNs (for images) and transformers (for sequences) were developed."),
        ],
        challenge: LessonChallenge(
            prompt: "Why can't a feedforward network process a time series as well as a recurrent network?",
            type: .multipleChoice(options: [
                ChallengeOption(text: "It can't handle numerical inputs, only categorical features", isCorrect: false, explanation: "Feedforward networks handle numerical inputs just fine. The issue is about temporal relationships."),
                ChallengeOption(text: "It has no memory of previous inputs", isCorrect: true, explanation: "Correct! Feedforward networks treat every input as isolated. They have no mechanism to remember or relate to previous time steps."),
                ChallengeOption(text: "They can only do classification, not regression on sequences", isCorrect: false, explanation: "Feedforward networks can do both classification and regression."),
                ChallengeOption(text: "They're too slow to keep up with real-time sequential data", isCorrect: false, explanation: "Speed isn't the issue. It's the lack of temporal awareness."),
            ])
        )
    )

    static let lessonCNN = Lesson(
        id: UUID(uuidString: "A0000001-0000-0000-0000-00000000000B")!,
        title: "Convolutional neural networks",
        summary: "Detecting spatial patterns through learned filters.",
        level: .advanced,
        sections: [
            LessonSection(title: "The key idea", body: "CNNs exploit the spatial structure of images. Instead of connecting every neuron to every input pixel, they use small filters that slide across the image, detecting local patterns like edges, textures, and shapes."),
            LessonSection(title: "How convolution works", body: "A convolutional layer applies multiple filters to the input. Each filter is a small grid of weights that:\n\n1. Slides across the input image\n2. At each position, computes a weighted sum\n3. Produces a feature map highlighting where that pattern appears\n\nEarly layers detect simple features (edges, corners). Deeper layers combine these into complex features (eyes, wheels, letters)."),
            LessonSection(title: "Architecture patterns", body: "Typical CNN architecture:\n\n\u{2022} Convolutional layers: extract features\n\u{2022} Pooling layers: reduce spatial dimensions\n\u{2022} Fully connected layers: make final predictions\n\nFamous CNNs include LeNet, AlexNet, ResNet, and EfficientNet. They revolutionized computer vision and remain foundational today."),
        ],
        challenge: LessonChallenge(
            prompt: "Put CNN layer operations in their typical order:",
            type: .ordering(
                items: ["Convolution (detect features)", "Activation (add non-linearity)", "Pooling (reduce dimensions)", "Fully connected (classify)"],
                correctOrder: [0, 1, 2, 3]
            )
        )
    )

    static let lessonTransformers = Lesson(
        id: UUID(uuidString: "A0000001-0000-0000-0000-00000000000C")!,
        title: "Transformers",
        summary: "Attention-based architecture behind modern AI.",
        level: .advanced,
        sections: [
            LessonSection(title: "Beyond sequence order", body: "Before transformers, recurrent networks processed sequences one element at a time. Transformers process all elements simultaneously using a mechanism called attention.\n\nThis parallelism makes them much faster to train and allows them to capture long-range relationships in data."),
            LessonSection(title: "Attention mechanism", body: "The core idea: for each element in the input, compute how relevant every other element is to it.\n\nSelf-attention uses three learned projections -- Query, Key, and Value -- to compute attention scores. High scores mean strong relevance. The output is a weighted combination of values, emphasizing the most relevant information."),
            LessonSection(title: "Impact", body: "Transformers power most modern AI systems:\n\n\u{2022} GPT, Claude: language understanding and generation\n\u{2022} Vision Transformers (ViT): image recognition\n\u{2022} DALL-E, Stable Diffusion: image generation\n\nTheir flexibility and scalability make them the dominant architecture in AI research today."),
        ],
        challenge: LessonChallenge(
            prompt: "What is the main advantage of attention over processing sequences one element at a time?",
            type: .multipleChoice(options: [
                ChallengeOption(text: "It uses fewer parameters so the model trains faster overall", isCorrect: false, explanation: "Transformers typically use MORE parameters. Their advantage is in how they process relationships."),
                ChallengeOption(text: "It captures long-range relationships directly", isCorrect: true, explanation: "Correct! Attention lets every element directly interact with every other element, regardless of distance, and processes them simultaneously."),
                ChallengeOption(text: "It doesn't need training data because attention is unsupervised", isCorrect: false, explanation: "All neural network architectures need training data. Attention is about how the model processes its inputs."),
                ChallengeOption(text: "It only works with text, which makes it very specialized for language", isCorrect: false, explanation: "Transformers work with images, audio, protein sequences, and more, not just text."),
            ])
        )
    )

    // MARK: - Topics (linked to lessons)

    static let topics: [TopicSummary] = categories.flatMap(\.topics)

    static let categories: [TopicCategory] = [
        TopicCategory(name: "Foundations", topics: [
            TopicSummary(title: "What is a neuron?", summary: "A first mental model for inputs, weights, and output.", lessonID: lessonNeuron.id),
            TopicSummary(title: "Weights and bias", summary: "How a neuron decides how much each input matters, and what shifts its decision.", lessonID: lessonWeightsBias.id),
            TopicSummary(title: "Activation functions", summary: "Why neurons need a non-linear step before passing values forward.", lessonID: lessonActivation.id),
        ]),
        TopicCategory(name: "Learning Process", topics: [
            TopicSummary(title: "Forward pass", summary: "See how values move through a network and become a prediction.", lessonID: lessonForwardPass.id),
            TopicSummary(title: "Loss and error", summary: "Compare the model output to a target and understand what needs to change.", lessonID: lessonLoss.id),
            TopicSummary(title: "Gradient descent", summary: "Watch small updates move the network toward better predictions.", lessonID: lessonGradientDescent.id),
            TopicSummary(title: "Backpropagation", summary: "Trace error backward through the network to figure out which weights to adjust.", lessonID: lessonBackprop.id),
        ]),
        TopicCategory(name: "Model Behavior", topics: [
            TopicSummary(title: "Overfitting and underfitting", summary: "What happens when a model memorizes training data or fails to learn enough.", lessonID: lessonOverfitting.id),
            TopicSummary(title: "Learning rate", summary: "How the size of each update step changes training speed and stability.", lessonID: lessonLearningRate.id),
        ]),
        TopicCategory(name: "Architectures", topics: [
            TopicSummary(title: "Feedforward networks", summary: "The simplest architecture: data flows in one direction from input to output.", lessonID: lessonFeedforward.id),
            TopicSummary(title: "Convolutional neural networks", summary: "How spatial patterns in images get detected through learned filters.", lessonID: lessonCNN.id),
            TopicSummary(title: "Transformers", summary: "The attention-based architecture behind modern language and vision models.", lessonID: lessonTransformers.id),
        ]),
    ]

    // MARK: - Paths (linked to lessons)

    static let paths: [LearningPath] = [
        LearningPath(
            title: "Neural Networks from Scratch",
            summary: "Build intuition first, then layer in mechanism and terminology.",
            level: .beginner,
            lessonIDs: [lessonNeuron.id, lessonWeightsBias.id, lessonActivation.id, lessonForwardPass.id]
        ),
        LearningPath(
            title: "How Training Works",
            summary: "Focus on loss, updates, and why a model improves over time.",
            level: .intermediate,
            lessonIDs: [lessonLoss.id, lessonGradientDescent.id, lessonBackprop.id, lessonLearningRate.id]
        ),
        LearningPath(
            title: "Architecture Deep Dives",
            summary: "Richer diagrams and denser explanations for advanced topics.",
            level: .advanced,
            lessonIDs: [lessonFeedforward.id, lessonCNN.id, lessonTransformers.id, lessonOverfitting.id]
        ),
    ]

    static func makePersonalizedPlan(
        level: LearnerLevel,
        interest: LearningInterest,
        goal: LearningGoal,
        completedLessonIDs: Set<UUID> = []
    ) -> PersonalizedPlan {
        let fullSequence = personalizedLessonSequence(level: level, interest: interest, goal: goal)
        let upcomingLessonIDs = fullSequence.filter { !completedLessonIDs.contains($0) }
        let cappedLessonIDs = Array(upcomingLessonIDs.prefix(5))
        let title = personalizedPlanTitle(level: level, interest: interest, goal: goal)
        let summary = personalizedPlanSummary(level: level, interest: interest, goal: goal)

        return PersonalizedPlan(
            title: title,
            summary: summary,
            level: level,
            interest: interest,
            goal: goal,
            lessonIDs: cappedLessonIDs
        )
    }

    static func personalizedLessonSequence(level: LearnerLevel, interest: LearningInterest, goal: LearningGoal) -> [UUID] {
        var lessonIDs: [UUID] = []
        let prioritizedGroups = [
            levelLessonIDs(for: level),
            interestLessonIDs(for: interest),
            goalLessonIDs(for: goal),
            progressionLessonIDs(startingAt: level),
            lessons.map(\.id),
        ]

        for group in prioritizedGroups {
            for lessonID in group where !lessonIDs.contains(lessonID) {
                lessonIDs.append(lessonID)
            }
        }

        return lessonIDs
    }

    private static func personalizedPlanTitle(level: LearnerLevel, interest: LearningInterest, goal: LearningGoal) -> String {
        switch (level, interest, goal) {
        case (.beginner, .foundations, _):
            "Your Neural Network Starter Plan"
        case (_, .training, .mechanics):
            "How Training Actually Works"
        case (_, .architectures, _):
            "Architecture Tour"
        case (_, .realWorldAI, .applications):
            "From AI Products to Neural Networks"
        case (.advanced, _, _):
            "Deep Dive Plan"
        default:
            "\(interest.title) Plan"
        }
    }

    private static func personalizedPlanSummary(level: LearnerLevel, interest: LearningInterest, goal: LearningGoal) -> String {
        switch goal {
        case .intuition:
            "Start with visual intuition, then add just enough mechanism to make the ideas stick."
        case .mechanics:
            "Focus on the moving parts: prediction, loss, gradients, and the updates that make models learn."
        case .applications:
            "Anchor the concepts in modern AI systems so each lesson maps back to a real use case."
        }
    }

    private static func levelLessonIDs(for level: LearnerLevel) -> [UUID] {
        switch level {
        case .beginner:
            [lessonNeuron.id, lessonWeightsBias.id, lessonActivation.id, lessonForwardPass.id]
        case .intermediate:
            [lessonForwardPass.id, lessonLoss.id, lessonGradientDescent.id, lessonBackprop.id]
        case .advanced:
            [lessonBackprop.id, lessonLearningRate.id, lessonFeedforward.id, lessonTransformers.id]
        }
    }

    private static func interestLessonIDs(for interest: LearningInterest) -> [UUID] {
        switch interest {
        case .foundations:
            [lessonNeuron.id, lessonWeightsBias.id, lessonActivation.id, lessonForwardPass.id]
        case .training:
            [lessonLoss.id, lessonGradientDescent.id, lessonBackprop.id, lessonLearningRate.id]
        case .architectures:
            [lessonFeedforward.id, lessonCNN.id, lessonTransformers.id, lessonOverfitting.id]
        case .realWorldAI:
            [lessonNumbersInNumbersOut.id, lessonTrainingToDeployment.id, lessonWhatNetworkLearned.id, lessonTransformers.id]
        }
    }

    private static func goalLessonIDs(for goal: LearningGoal) -> [UUID] {
        switch goal {
        case .intuition:
            [lessonNeuron.id, lessonActivation.id, lessonForwardPass.id, lessonCNN.id]
        case .mechanics:
            [lessonLoss.id, lessonGradientDescent.id, lessonBackprop.id, lessonLearningRate.id]
        case .applications:
            [lessonWeightsReally.id, lessonSignals.id, lessonNumbersInNumbersOut.id, lessonTrainingToDeployment.id]
        }
    }

    private static func progressionLessonIDs(startingAt level: LearnerLevel) -> [UUID] {
        let orderedLevels: [LearnerLevel] = switch level {
        case .beginner:
            [.beginner, .intermediate, .advanced]
        case .intermediate:
            [.intermediate, .advanced, .beginner]
        case .advanced:
            [.advanced, .intermediate, .beginner]
        }

        return orderedLevels.flatMap { level in
            lessons.filter { $0.level == level }.map(\.id)
        }
    }

    // MARK: - Topic Tree

    static let topicTree: TopicTreeNode = TopicTreeNode(
        label: "Artificial Intelligence",
        icon: "brain",
        summary: "The broad field of making machines exhibit intelligent behavior.",
        children: [
            // ── Machine Learning ──
            TopicTreeNode(
                label: "Machine Learning",
                icon: "chart.line.uptrend.xyaxis",
                summary: "Systems that learn patterns from data instead of being explicitly programmed.",
                children: [
                    // Supervised
                    TopicTreeNode(
                        label: "Supervised Learning",
                        icon: "tag.fill",
                        summary: "Learning from labeled input-output pairs.",
                        children: [
                            TopicTreeNode(
                                label: "Regression",
                                icon: "point.topleft.down.to.point.bottomright.curvepath.fill",
                                summary: "Predicting continuous numerical values.",
                                children: [
                                    TopicTreeNode(label: "Linear Regression", icon: "line.diagonal", summary: "Fit a straight line through data points to predict outcomes."),
                                    TopicTreeNode(label: "Polynomial Regression", icon: "waveform.path", summary: "Fit curves of higher degree for non-linear relationships."),
                                    TopicTreeNode(label: "Ridge & Lasso", icon: "slider.horizontal.below.square.and.square.filled", summary: "Add penalty terms to prevent overfitting in regression."),
                                ]
                            ),
                            TopicTreeNode(
                                label: "Classification",
                                icon: "square.grid.3x3.topleft.filled",
                                summary: "Assigning inputs to discrete categories.",
                                children: [
                                    TopicTreeNode(label: "Logistic Regression", icon: "arrow.up.right.circle", summary: "Classify by modeling the probability of a binary outcome."),
                                    TopicTreeNode(label: "Decision Trees", icon: "arrow.triangle.branch", summary: "Split data with a series of yes/no questions to classify."),
                                    TopicTreeNode(label: "Random Forests", icon: "leaf.fill", summary: "Combine many decision trees for more robust predictions."),
                                    TopicTreeNode(label: "Support Vector Machines", icon: "arrow.left.and.right", summary: "Find the optimal boundary that separates classes with maximum margin."),
                                    TopicTreeNode(label: "k-Nearest Neighbors", icon: "person.3.fill", summary: "Classify by looking at the majority vote of nearby data points."),
                                    TopicTreeNode(label: "Naive Bayes", icon: "percent", summary: "Fast probabilistic classifier using Bayes' theorem with independence assumptions."),
                                ]
                            ),
                        ]
                    ),
                    // Unsupervised
                    TopicTreeNode(
                        label: "Unsupervised Learning",
                        icon: "circle.hexagongrid.fill",
                        summary: "Finding hidden structure in unlabeled data.",
                        children: [
                            TopicTreeNode(
                                label: "Clustering",
                                icon: "circle.grid.3x3.fill",
                                summary: "Grouping similar data points together.",
                                children: [
                                    TopicTreeNode(label: "K-Means", icon: "target", summary: "Partition data into k clusters by minimizing distance to centroids."),
                                    TopicTreeNode(label: "DBSCAN", icon: "aqi.medium", summary: "Density-based clustering that finds arbitrarily shaped groups."),
                                    TopicTreeNode(label: "Hierarchical Clustering", icon: "list.triangle", summary: "Build a tree of nested clusters from bottom up or top down."),
                                    TopicTreeNode(label: "Gaussian Mixtures", icon: "chart.bar.fill", summary: "Model data as a mixture of several Gaussian distributions."),
                                ]
                            ),
                            TopicTreeNode(
                                label: "Dimensionality Reduction",
                                icon: "arrow.down.right.and.arrow.up.left",
                                summary: "Compressing high-dimensional data while preserving structure.",
                                children: [
                                    TopicTreeNode(label: "PCA", icon: "arrow.up.right", summary: "Project data onto directions of maximum variance."),
                                    TopicTreeNode(label: "t-SNE", icon: "point.3.connected.trianglepath.dotted", summary: "Visualize high-dimensional data in 2D by preserving local neighborhoods."),
                                    TopicTreeNode(label: "UMAP", icon: "globe", summary: "Fast manifold-based embedding that preserves both local and global structure."),
                                ]
                            ),
                            TopicTreeNode(
                                label: "Anomaly Detection",
                                icon: "exclamationmark.triangle.fill",
                                summary: "Identifying rare or unusual data points.",
                                children: [
                                    TopicTreeNode(label: "Isolation Forest", icon: "tree.fill", summary: "Detect anomalies by randomly partitioning data and measuring isolation depth."),
                                    TopicTreeNode(label: "Autoencoders for Anomalies", icon: "arrow.uturn.left.circle", summary: "Use reconstruction error to flag data that doesn't fit learned patterns."),
                                ]
                            ),
                        ]
                    ),
                    // Reinforcement
                    TopicTreeNode(
                        label: "Reinforcement Learning",
                        icon: "gamecontroller.fill",
                        summary: "Agents learn by trial and error, maximizing cumulative reward.",
                        children: [
                            TopicTreeNode(label: "Markov Decision Processes", icon: "arrow.triangle.turn.up.right.diamond.fill", summary: "The mathematical framework underlying sequential decision-making."),
                            TopicTreeNode(label: "Q-Learning", icon: "tablecells", summary: "Learn the value of state-action pairs through exploration."),
                            TopicTreeNode(label: "Policy Gradient", icon: "arrow.up.forward", summary: "Directly optimize the policy by following the gradient of expected reward."),
                            TopicTreeNode(label: "Actor-Critic", icon: "person.and.arrow.left.and.arrow.right", summary: "Combine value estimation with policy optimization for stability."),
                            TopicTreeNode(label: "Multi-Agent RL", icon: "person.3.sequence.fill", summary: "Multiple agents learning simultaneously in shared environments."),
                        ]
                    ),
                    // Ensemble
                    TopicTreeNode(
                        label: "Ensemble Methods",
                        icon: "square.stack.3d.up.fill",
                        summary: "Combine multiple models for better predictions.",
                        children: [
                            TopicTreeNode(label: "Bagging", icon: "square.on.square", summary: "Train models on random subsets and average their predictions."),
                            TopicTreeNode(label: "Boosting", icon: "bolt.fill", summary: "Sequentially train models that correct predecessors' mistakes."),
                            TopicTreeNode(label: "XGBoost", icon: "flame.fill", summary: "Optimized gradient boosting with regularization for tabular data."),
                            TopicTreeNode(label: "Stacking", icon: "square.stack.fill", summary: "Use a meta-model to combine predictions from diverse base learners."),
                        ]
                    ),
                ]
            ),
            // ── Deep Learning ──
            TopicTreeNode(
                label: "Deep Learning",
                icon: "network",
                summary: "Neural networks with many layers that learn hierarchical representations.",
                children: [
                    TopicTreeNode(
                        label: "Neural Network Basics",
                        icon: "cpu",
                        summary: "Core building blocks every architecture shares.",
                        children: [
                            TopicTreeNode(label: "What is a Neuron?", icon: "circle.fill", summary: "A first mental model for inputs, weights, and output.", lessonID: lessonNeuron.id),
                            TopicTreeNode(label: "Weights & Bias", icon: "slider.horizontal.3", summary: "How a neuron decides how much each input matters.", lessonID: lessonWeightsBias.id),
                            TopicTreeNode(label: "Activation Functions", icon: "waveform.path.ecg", summary: "Why neurons need a non-linear step.", lessonID: lessonActivation.id),
                            TopicTreeNode(label: "Forward Pass", icon: "arrow.right", summary: "How values flow through a network to produce a prediction.", lessonID: lessonForwardPass.id),
                            TopicTreeNode(label: "Loss & Error", icon: "xmark.circle", summary: "Measuring how wrong the network's predictions are.", lessonID: lessonLoss.id),
                        ]
                    ),
                    TopicTreeNode(
                        label: "Training",
                        icon: "arrow.clockwise",
                        summary: "How networks learn from data.",
                        children: [
                            TopicTreeNode(label: "Gradient Descent", icon: "arrow.down.circle", summary: "Walk downhill on the loss landscape.", lessonID: lessonGradientDescent.id),
                            TopicTreeNode(label: "Backpropagation", icon: "arrow.uturn.backward", summary: "Trace error backward to assign blame to each weight.", lessonID: lessonBackprop.id),
                            TopicTreeNode(label: "Learning Rate", icon: "speedometer", summary: "How step size shapes training.", lessonID: lessonLearningRate.id),
                            TopicTreeNode(
                                label: "Optimizers",
                                icon: "gearshape.2.fill",
                                summary: "Algorithms that decide how to update weights.",
                                children: [
                                    TopicTreeNode(label: "SGD & Momentum", icon: "hare.fill", summary: "Stochastic updates with optional velocity for faster convergence."),
                                    TopicTreeNode(label: "Adam", icon: "dial.medium.fill", summary: "Adaptive learning rates per parameter using moment estimates."),
                                    TopicTreeNode(label: "AdaGrad & RMSProp", icon: "tuningfork", summary: "Scale updates by historical gradient magnitudes."),
                                    TopicTreeNode(label: "Learning Rate Schedules", icon: "chart.line.downtrend.xyaxis", summary: "Decay or cycle the learning rate during training."),
                                ]
                            ),
                            TopicTreeNode(
                                label: "Regularization",
                                icon: "shield.fill",
                                summary: "Techniques to prevent overfitting.",
                                children: [
                                    TopicTreeNode(label: "Overfitting & Underfitting", icon: "scale.3d", summary: "When models memorize or fail to learn.", lessonID: lessonOverfitting.id),
                                    TopicTreeNode(label: "Dropout", icon: "xmark.circle.fill", summary: "Randomly silence neurons during training to improve generalization."),
                                    TopicTreeNode(label: "L1 & L2 Penalties", icon: "minus.circle", summary: "Penalize large weights to keep the model simple."),
                                    TopicTreeNode(label: "Batch Normalization", icon: "equal.circle", summary: "Normalize layer inputs to stabilize and accelerate training."),
                                    TopicTreeNode(label: "Data Augmentation", icon: "photo.stack", summary: "Artificially expand training data with transformations."),
                                    TopicTreeNode(label: "Early Stopping", icon: "hand.raised.fill", summary: "Halt training when validation performance plateaus."),
                                ]
                            ),
                        ]
                    ),
                    TopicTreeNode(
                        label: "Architectures",
                        icon: "building.columns.fill",
                        summary: "Specialized network designs for different tasks.",
                        children: [
                            TopicTreeNode(label: "Feedforward Networks", icon: "arrow.right.circle", summary: "The simplest architecture: data flows one direction.", lessonID: lessonFeedforward.id),
                            TopicTreeNode(
                                label: "CNNs",
                                icon: "photo.fill",
                                summary: "Detect spatial patterns through learned filters.",
                                lessonID: lessonCNN.id
                            ),
                            TopicTreeNode(
                                label: "RNNs & LSTMs",
                                icon: "arrow.triangle.capsulepath",
                                summary: "Process sequences by maintaining hidden state over time.",
                                children: [
                                    TopicTreeNode(label: "Vanilla RNNs", icon: "arrow.circlepath", summary: "Recurrent units that pass hidden state from step to step."),
                                    TopicTreeNode(label: "LSTMs", icon: "lock.fill", summary: "Gated cells that learn what to remember and forget over long sequences."),
                                    TopicTreeNode(label: "GRUs", icon: "bolt.circle", summary: "Simplified gated recurrent units with fewer parameters than LSTMs."),
                                ]
                            ),
                            TopicTreeNode(
                                label: "Transformers",
                                icon: "sparkles",
                                summary: "Attention-based architecture behind modern AI.",
                                lessonID: lessonTransformers.id
                            ),
                            TopicTreeNode(
                                label: "Generative Models",
                                icon: "paintbrush.fill",
                                summary: "Networks that create new data resembling the training distribution.",
                                children: [
                                    TopicTreeNode(label: "GANs", icon: "arrow.triangle.2.circlepath", summary: "Two networks compete: a generator creates fakes, a discriminator detects them."),
                                    TopicTreeNode(label: "VAEs", icon: "waveform.circle", summary: "Encode data into a latent space, then decode to generate new samples."),
                                    TopicTreeNode(label: "Diffusion Models", icon: "cloud.fill", summary: "Learn to reverse a noise process to generate high-quality images."),
                                    TopicTreeNode(label: "Flow Models", icon: "water.waves", summary: "Use invertible transformations for exact likelihood estimation."),
                                ]
                            ),
                            TopicTreeNode(
                                label: "Graph Neural Networks",
                                icon: "point.3.connected.trianglepath.dotted",
                                summary: "Learn on graph-structured data like social networks and molecules.",
                                children: [
                                    TopicTreeNode(label: "Message Passing", icon: "envelope.fill", summary: "Nodes exchange information with neighbors to update representations."),
                                    TopicTreeNode(label: "Graph Attention", icon: "eye.fill", summary: "Use attention to weigh neighbor contributions differently."),
                                ]
                            ),
                        ]
                    ),
                ]
            ),
            // ── NLP ──
            TopicTreeNode(
                label: "Natural Language Processing",
                icon: "text.bubble.fill",
                summary: "Teaching machines to understand, generate, and reason about human language.",
                children: [
                    TopicTreeNode(label: "Tokenization", icon: "scissors", summary: "Splitting text into tokens the model can process."),
                    TopicTreeNode(
                        label: "Word Embeddings",
                        icon: "textformat.abc",
                        summary: "Represent words as dense vectors that capture meaning.",
                        children: [
                            TopicTreeNode(label: "Word2Vec", icon: "arrow.right.arrow.left", summary: "Learn word vectors by predicting surrounding context words."),
                            TopicTreeNode(label: "GloVe", icon: "globe.americas", summary: "Derive vectors from global word co-occurrence statistics."),
                            TopicTreeNode(label: "Contextual Embeddings", icon: "text.magnifyingglass", summary: "Embeddings that change based on surrounding context (BERT, ELMo)."),
                        ]
                    ),
                    TopicTreeNode(label: "Sentiment Analysis", icon: "face.smiling.fill", summary: "Classify text by emotional tone: positive, negative, neutral."),
                    TopicTreeNode(label: "Machine Translation", icon: "globe", summary: "Automatically translate text between languages."),
                    TopicTreeNode(label: "Named Entity Recognition", icon: "person.text.rectangle", summary: "Identify and classify named entities like people, places, and dates in text."),
                ]
            ),
            // ── Large Language Models ──
            TopicTreeNode(
                label: "Large Language Models",
                icon: "text.document.fill",
                summary: "Transformer-based systems trained to predict and generate language at scale.",
                children: [
                    TopicTreeNode(label: "Pre-training", icon: "arrow.clockwise.circle", summary: "Self-supervised learning on vast corpora to build general language capability."),
                    TopicTreeNode(label: "Instruction Tuning", icon: "text.badge.checkmark", summary: "Further tuning models on prompt-response pairs so they follow human instructions more reliably."),
                    TopicTreeNode(label: "Prompt Engineering", icon: "text.cursor", summary: "Designing prompts, examples, and constraints to steer model behavior without changing weights."),
                    TopicTreeNode(label: "Context Windows", icon: "rectangle.and.text.magnifyingglass", summary: "The amount of text a model can attend to at once while generating or reasoning."),
                    TopicTreeNode(label: "Retrieval-Augmented Generation", icon: "doc.text.magnifyingglass", summary: "Ground model responses in retrieved documents instead of relying only on model memory."),
                    TopicTreeNode(label: "RLHF", icon: "hand.thumbsup.fill", summary: "Align model outputs with human preferences using feedback-driven optimization."),
                ]
            ),
            // ── Computer Vision ──
            TopicTreeNode(
                label: "Computer Vision",
                icon: "eye.fill",
                summary: "Enabling machines to interpret and understand visual information.",
                children: [
                    TopicTreeNode(label: "Image Classification", icon: "photo.on.rectangle", summary: "Assign a label to an entire image (cat, dog, car...)."),
                    TopicTreeNode(label: "Object Detection", icon: "viewfinder", summary: "Locate and classify multiple objects within an image with bounding boxes."),
                    TopicTreeNode(label: "Semantic Segmentation", icon: "square.split.bottomrightquarter.fill", summary: "Label every pixel in an image with a class."),
                    TopicTreeNode(label: "Image Generation", icon: "wand.and.stars", summary: "Create photorealistic images from noise, text, or other images."),
                    TopicTreeNode(label: "Pose Estimation", icon: "figure.walk", summary: "Detect human body keypoints and skeletal structure."),
                    TopicTreeNode(label: "Optical Flow", icon: "arrow.up.and.down.and.arrow.left.and.right", summary: "Track pixel-level motion between consecutive frames."),
                    TopicTreeNode(
                        label: "Video Understanding",
                        icon: "film.fill",
                        summary: "Analyze temporal patterns across video frames.",
                        children: [
                            TopicTreeNode(label: "Action Recognition", icon: "figure.run", summary: "Classify what action is being performed in a video clip."),
                            TopicTreeNode(label: "Video Captioning", icon: "captions.bubble.fill", summary: "Generate natural language descriptions of video content."),
                        ]
                    ),
                ]
            ),
            // ── AI Ethics & Safety ──
            TopicTreeNode(
                label: "AI Ethics & Safety",
                icon: "hand.raised.fill",
                summary: "Responsible development and deployment of AI systems.",
                children: [
                    TopicTreeNode(label: "Bias & Fairness", icon: "scale.3d", summary: "Identifying and mitigating unfair biases in data and models."),
                    TopicTreeNode(label: "Interpretability", icon: "magnifyingglass", summary: "Understanding why a model makes specific predictions."),
                    TopicTreeNode(label: "AI Alignment", icon: "arrow.triangle.merge", summary: "Ensuring AI systems pursue goals that match human values."),
                    TopicTreeNode(label: "Privacy & Data", icon: "lock.shield.fill", summary: "Protecting sensitive information used in training and inference."),
                    TopicTreeNode(label: "Adversarial Robustness", icon: "shield.lefthalf.filled", summary: "Defending models against malicious inputs designed to fool them."),
                ]
            ),
            // ── Data & Feature Engineering ──
            TopicTreeNode(
                label: "Data & Feature Engineering",
                icon: "wrench.and.screwdriver.fill",
                summary: "Preparing and transforming raw data into useful model inputs.",
                children: [
                    TopicTreeNode(label: "Data Cleaning", icon: "paintbrush.pointed.fill", summary: "Handle missing values, duplicates, and inconsistencies."),
                    TopicTreeNode(label: "Feature Scaling", icon: "ruler.fill", summary: "Normalize or standardize features so models train effectively."),
                    TopicTreeNode(label: "Feature Selection", icon: "checklist", summary: "Choose the most informative features and discard noise."),
                    TopicTreeNode(label: "Encoding Categorical Data", icon: "number", summary: "Convert categories into numerical representations models can use."),
                    TopicTreeNode(label: "Train/Val/Test Splits", icon: "rectangle.split.3x1.fill", summary: "Partition data to evaluate generalization honestly."),
                    TopicTreeNode(label: "Cross-Validation", icon: "arrow.2.squarepath", summary: "Rotate through folds to get robust performance estimates."),
                ]
            ),
            // ── Evaluation & Metrics ──
            TopicTreeNode(
                label: "Evaluation & Metrics",
                icon: "chart.bar.xaxis",
                summary: "Quantifying how well a model performs.",
                children: [
                    TopicTreeNode(label: "Accuracy, Precision, Recall", icon: "target", summary: "Core classification metrics and their trade-offs."),
                    TopicTreeNode(label: "F1 Score", icon: "equal.circle.fill", summary: "Harmonic mean of precision and recall for balanced evaluation."),
                    TopicTreeNode(label: "ROC & AUC", icon: "chart.xyaxis.line", summary: "Visualize and measure classifier performance across thresholds."),
                    TopicTreeNode(label: "Confusion Matrix", icon: "square.grid.2x2.fill", summary: "See exactly where the model gets confused between classes."),
                    TopicTreeNode(label: "MSE, MAE, R-squared", icon: "number.circle", summary: "Regression metrics measuring prediction error magnitude and fit."),
                    TopicTreeNode(label: "Perplexity & BLEU", icon: "text.badge.checkmark", summary: "Specialized metrics for language model and translation quality."),
                ]
            ),
        ]
    )

    // MARK: - Glossary

    static var glossary: [GlossaryTerm] {
        let curatedTerms = [
        GlossaryTerm(term: "Neuron", definition: "A unit that takes weighted inputs, sums them, applies an activation function, and produces an output."),
        GlossaryTerm(term: "Weight", definition: "A learnable value that scales an input. Larger weights mean the network pays more attention to that input."),
        GlossaryTerm(term: "Bias", definition: "A learnable offset added before the activation function, letting the neuron shift its output threshold."),
        GlossaryTerm(term: "Activation Function", definition: "A non-linear function applied to a neuron's sum. Common examples include sigmoid, ReLU, and tanh."),
        GlossaryTerm(term: "Forward Pass", definition: "The process of computing output from input by passing values through each layer of the network."),
        GlossaryTerm(term: "Loss", definition: "A measure of how far the network's prediction is from the desired output. Training aims to minimize loss."),
        GlossaryTerm(term: "Gradient Descent", definition: "An optimization method that adjusts weights in the direction that reduces loss, guided by computed gradients."),
        GlossaryTerm(term: "Backpropagation", definition: "The algorithm that computes how much each weight contributed to the error, working backward from output to input."),
        GlossaryTerm(term: "Epoch", definition: "One complete pass through the entire training dataset. Models typically train for many epochs."),
        GlossaryTerm(term: "Learning Rate", definition: "A scalar that controls how large each weight update is. Too high causes instability; too low causes slow convergence."),
        GlossaryTerm(term: "Overfitting", definition: "When a model memorizes training data instead of learning general patterns, performing well on training data but poorly on new data."),
        GlossaryTerm(term: "Regularization", definition: "Techniques that constrain a model to prevent overfitting, such as L2 penalties, dropout, or early stopping."),
        GlossaryTerm(term: "Convolutional Layer", definition: "A layer that applies small learned filters across spatial input, detecting local patterns like edges and textures."),
        GlossaryTerm(term: "Attention", definition: "A mechanism that lets a model focus on the most relevant parts of its input when producing each output element."),
        GlossaryTerm(term: "Transformer", definition: "An architecture that uses self-attention to process all input elements in parallel, powering most modern language and vision models."),
        ]

        let canonicalDefinitions = Dictionary(
            uniqueKeysWithValues: curatedTerms.map { ($0.term.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current), $0.definition) }
        )

        let topicTerms = allNodes(in: topicTree)
            .dropFirst()
            .filter { !$0.summary.isEmpty }
            .map { node in
                let normalizedTerm = node.label.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                return GlossaryTerm(
                    term: node.label,
                    definition: canonicalDefinitions[normalizedTerm] ?? node.summary
                )
            }

        var deduplicatedTerms: [String: GlossaryTerm] = [:]

        for term in curatedTerms + topicTerms {
            let key = term.term.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            deduplicatedTerms[key] = term
        }

        return deduplicatedTerms.values.sorted {
            $0.term.localizedCaseInsensitiveCompare($1.term) == .orderedAscending
        }
    }

    static var glossaryTopicNodes: [TopicTreeNode] {
        allNodes(in: topicTree)
            .dropFirst()
            .filter { !$0.summary.isEmpty }
            .sorted { $0.label.localizedCaseInsensitiveCompare($1.label) == .orderedAscending }
    }

    private static var generatedExploreLessons: [Lesson] {
        generatedExploreLeafNodes.map(generatedLesson(for:))
    }

    private static var generatedExploreLessonsByTitle: [String: Lesson] {
        Dictionary(uniqueKeysWithValues: generatedExploreLessons.map { ($0.title, $0) })
    }

    private static var generatedExploreLeafNodes: [TopicTreeNode] {
        allLeafNodes(in: topicTree).filter { $0.lessonID == nil }
    }

    private static func allNodes(in node: TopicTreeNode) -> [TopicTreeNode] {
        [node] + node.children.flatMap(allNodes(in:))
    }

    private static func allLeafNodes(in node: TopicTreeNode) -> [TopicTreeNode] {
        if node.children.isEmpty {
            return [node]
        }

        return node.children.flatMap(allLeafNodes(in:))
    }

    private static func generatedLesson(for node: TopicTreeNode) -> Lesson {
        let category = exploreLessonCategory(for: node.label)

        return Lesson(
            id: stableLessonID(for: node.label),
            title: node.label,
            summary: node.summary,
            level: category.level,
            sections: [
                LessonSection(title: "The idea", body: category.idea(for: node)),
                LessonSection(title: "How it works", body: category.mechanism(for: node)),
                LessonSection(title: "Why it matters", body: category.importance(for: node)),
            ],
            challenge: category.challenge(for: node)
        )
    }

    private static func stableLessonID(for title: String) -> UUID {
        var upper: UInt64 = 0xCBF29CE484222325
        var lower: UInt64 = 0x9E3779B97F4A7C15

        for byte in title.utf8 {
            upper = (upper ^ UInt64(byte)) &* 0x100000001B3
            lower = (lower ^ UInt64(byte)) &* 0x100000001B3
        }

        let hex = String(format: "%016llx%016llx", upper, lower)
        let uuid = "\(hex.prefix(8))-\(hex.dropFirst(8).prefix(4))-\(hex.dropFirst(12).prefix(4))-\(hex.dropFirst(16).prefix(4))-\(hex.dropFirst(20).prefix(12))"
        return UUID(uuidString: uuid) ?? UUID()
    }

    private static func exploreLessonCategory(for title: String) -> ExploreLessonCategory {
        switch title {
        case "Linear Regression", "Polynomial Regression", "Ridge & Lasso":
            return .regression
        case "Logistic Regression", "Decision Trees", "Random Forests", "Support Vector Machines", "k-Nearest Neighbors", "Naive Bayes":
            return .classification
        case "K-Means", "DBSCAN", "Hierarchical Clustering", "Gaussian Mixtures":
            return .clustering
        case "PCA", "t-SNE", "UMAP":
            return .dimensionalityReduction
        case "Isolation Forest", "Autoencoders for Anomalies":
            return .anomalyDetection
        case "Markov Decision Processes", "Q-Learning", "Policy Gradient", "Actor-Critic", "Multi-Agent RL":
            return .reinforcementLearning
        case "Bagging", "Boosting", "XGBoost", "Stacking":
            return .ensemble
        case "SGD & Momentum", "Adam", "AdaGrad & RMSProp", "Learning Rate Schedules":
            return .optimization
        case "Dropout", "L1 & L2 Penalties", "Batch Normalization", "Data Augmentation", "Early Stopping":
            return .regularization
        case "Vanilla RNNs", "LSTMs", "GRUs":
            return .sequenceModels
        case "GANs", "VAEs", "Diffusion Models", "Flow Models":
            return .generativeModels
        case "Message Passing", "Graph Attention":
            return .graphLearning
        case "Tokenization", "Word2Vec", "GloVe", "Contextual Embeddings":
            return .languageRepresentation
        case "Pre-training", "Fine-tuning", "Instruction Tuning", "Prompt Engineering", "Context Windows", "RLHF", "Retrieval-Augmented Generation":
            return .largeLanguageModels
        case "Sentiment Analysis", "Machine Translation", "Named Entity Recognition":
            return .languageTasks
        case "Image Classification", "Object Detection", "Semantic Segmentation", "Image Generation", "Pose Estimation", "Optical Flow", "Action Recognition", "Video Captioning":
            return .visionTasks
        case "Bias & Fairness", "Interpretability", "AI Alignment", "Privacy & Data", "Adversarial Robustness":
            return .ethicsAndSafety
        case "Data Cleaning", "Feature Scaling", "Feature Selection", "Encoding Categorical Data", "Train/Val/Test Splits", "Cross-Validation":
            return .dataPipeline
        case "Accuracy, Precision, Recall", "F1 Score", "ROC & AUC", "Confusion Matrix", "MSE, MAE, R-squared", "Perplexity & BLEU":
            return .evaluation
        default:
            return .general
        }
    }

    private enum ExploreLessonCategory {
        case regression
        case classification
        case clustering
        case dimensionalityReduction
        case anomalyDetection
        case reinforcementLearning
        case ensemble
        case optimization
        case regularization
        case sequenceModels
        case generativeModels
        case graphLearning
        case languageRepresentation
        case largeLanguageModels
        case languageTasks
        case visionTasks
        case ethicsAndSafety
        case dataPipeline
        case evaluation
        case general

        var level: LearnerLevel {
            switch self {
            case .regression, .classification, .clustering, .dataPipeline, .evaluation:
                return .beginner
            case .dimensionalityReduction, .anomalyDetection, .ensemble, .languageRepresentation, .languageTasks, .visionTasks, .ethicsAndSafety:
                return .intermediate
            case .reinforcementLearning, .optimization, .regularization, .sequenceModels, .generativeModels, .graphLearning, .largeLanguageModels, .general:
                return .advanced
            }
        }

        func idea(for node: TopicTreeNode) -> String {
            switch self {
            case .regression:
                return "\(node.label) is about estimating a continuous value from inputs. \(node.summary) Like gradient descent, the goal is to turn a messy landscape into a direction you can follow: look at the inputs, measure error, and move toward a better numeric prediction."
            case .classification:
                return "\(node.label) is about drawing boundaries between categories. \(node.summary) If gradient descent teaches you to step downhill, classification teaches you what the hill represents: a decision surface separating one class from another."
            case .clustering:
                return "\(node.label) finds structure when no labels are provided. \(node.summary) Instead of walking downhill toward a known answer, the model searches for pockets of similarity and lets those pockets define the pattern."
            case .dimensionalityReduction:
                return "\(node.label) helps compress complex data into a smaller space without losing the important shape. \(node.summary) The intuition is similar to gradient descent: keep the signal that matters most, and let the rest fade into the background."
            case .anomalyDetection:
                return "\(node.label) focuses on spotting the points that do not belong. \(node.summary) In practice, the model learns what normal looks like first, then treats large deviations from that baseline as suspicious."
            case .reinforcementLearning:
                return "\(node.label) sits inside reinforcement learning, where an agent learns by acting, observing rewards, and adjusting its strategy. \(node.summary) The agent is not handed the right answer up front; it has to discover better behavior over many updates."
            case .ensemble:
                return "\(node.label) improves predictions by combining several imperfect models. \(node.summary) The intuition is that many weak signals, averaged or coordinated well, can point downhill more reliably than any single model alone."
            case .optimization:
                return "\(node.label) is an optimization tool for training neural networks. \(node.summary) It builds directly on the same lesson as gradient descent: once you know the slope, you still need a smart rule for how to step."
            case .regularization:
                return "\(node.label) is about helping a model generalize instead of memorizing. \(node.summary) Training is not just about going downhill fast; it is also about picking a path that lands in a solution that survives new data."
            case .sequenceModels:
                return "\(node.label) handles ordered data where earlier inputs affect later ones. \(node.summary) The key intuition is memory: each step carries forward context so the model can treat a sequence as a connected story instead of isolated points."
            case .generativeModels:
                return "\(node.label) learns the structure of data well enough to create new samples. \(node.summary) Instead of only predicting labels, the model learns a distribution and then samples from it in a controlled way."
            case .graphLearning:
                return "\(node.label) works on graph-structured data where relationships matter as much as individual items. \(node.summary) The model learns by passing information along edges so every node can update in context."
            case .languageRepresentation:
                return "\(node.label) helps language models turn text into machine-readable structure. \(node.summary) Before a model can learn meaning, it needs a stable representation of words, pieces of words, or context."
            case .largeLanguageModels:
                return "\(node.label) is part of the workflow behind large language models. \(node.summary) These systems still rely on the same training loop as gradient descent, but at much larger scale and with more careful control over data, objectives, and deployment."
            case .languageTasks:
                return "\(node.label) is a language task built on top of text representations and learned patterns. \(node.summary) Once language is encoded well, the model can use that representation to make a focused decision or generate a targeted output."
            case .visionTasks:
                return "\(node.label) applies machine learning to visual data. \(node.summary) The central question is how to turn pixels or frames into a structured understanding of what is present, where it is, or how it is changing."
            case .ethicsAndSafety:
                return "\(node.label) covers one of the guardrails around building and deploying AI responsibly. \(node.summary) Good optimization is not enough on its own; systems also need constraints, oversight, and clear failure analysis."
            case .dataPipeline:
                return "\(node.label) belongs to the data pipeline that shapes what the model is allowed to learn from. \(node.summary) Strong training begins long before gradient descent runs, because the data setup determines what patterns are even visible."
            case .evaluation:
                return "\(node.label) helps you measure whether a model is actually improving. \(node.summary) Gradient descent can lower a loss value, but evaluation metrics tell you whether that improvement matters for the real task."
            case .general:
                return "\(node.label) is a useful concept in the broader machine learning landscape. \(node.summary) It fits the same overall pattern as the rest of the app: define the objective clearly, understand the mechanism, and watch how the model changes as you update it."
            }
        }

        func mechanism(for node: TopicTreeNode) -> String {
            switch self {
            case .regression:
                return "The core mechanism in \(node.label) is learning a function that maps features to a number. During training, the model compares its prediction to the target value, computes an error signal, and adjusts parameters to reduce that gap. Simpler regression methods assume a smoother relationship; more flexible ones let the model bend or shrink that relationship to match the data."
            case .classification:
                return "\(node.label) turns inputs into scores for one or more classes, then uses those scores to choose a label. Different classifiers build those decisions in different ways: some learn linear boundaries, some split with rules, and some vote using nearby examples or many small models. The shared pattern is the same: represent the input, score the choices, and separate the classes as cleanly as possible."
            case .clustering:
                return "In \(node.label), the algorithm searches for groups by measuring similarity between points. Some methods assign every point to a center, some grow groups from dense regions, and some build a hierarchy of merges or splits. The main loop is always about comparing structure, updating group assumptions, and repeating until the clustering stabilizes."
            case .dimensionalityReduction:
                return "\(node.label) reduces many input dimensions into fewer coordinates. Some methods preserve variance, some preserve local neighborhoods, and some try to keep both local and global geometry intact. The mechanism is compression with purpose: keep the relationships that matter for analysis, visualization, or downstream learning."
            case .anomalyDetection:
                return "Most anomaly detectors first model normal behavior, then score how unusual a new example looks relative to that baseline. \(node.label) may isolate points quickly, reconstruct common patterns well, or estimate density and flag low-probability regions. The important mechanic is the anomaly score: the higher it climbs, the more the point resists the model's picture of normal data."
            case .reinforcementLearning:
                return "\(node.label) updates an agent from experience collected over time. The agent observes a state, chooses an action, receives a reward, and uses that feedback to improve either its value estimates, its policy, or both. Unlike supervised learning, the signal arrives through delayed consequences, so the algorithm has to connect present decisions to future rewards."
            case .ensemble:
                return "\(node.label) combines predictions from multiple models to improve robustness. Depending on the method, the models may train independently on varied data, train sequentially to fix prior mistakes, or feed their outputs into a final combiner. The mechanism works because errors from one model can be canceled or corrected by the others."
            case .optimization:
                return "\(node.label) changes how parameter updates are computed after gradients are known. Some methods add velocity, some adapt the step size per parameter, and some reshape the schedule over time. The common job is to make training smoother, faster, or more stable than plain gradient descent."
            case .regularization:
                return "\(node.label) changes training so the model is less likely to memorize noise. The technique may remove capacity temporarily, penalize large weights, normalize activations, expand the dataset, or stop training before the model starts fitting quirks too closely. In each case, the mechanism nudges learning toward simpler, more durable patterns."
            case .sequenceModels:
                return "With \(node.label), the model processes one step of a sequence while carrying a hidden state forward. Gated variants decide what to keep, forget, or expose at each step so information can survive across longer contexts. That running state is what lets sequence models connect words, frames, or events over time."
            case .generativeModels:
                return "\(node.label) learns a procedure for producing realistic samples from a latent process. Some methods decode compressed representations, some denoise step by step, some compete with a discriminator, and some rely on invertible transformations. The mechanism varies, but the objective stays consistent: match the training distribution closely enough to generate believable new data."
            case .graphLearning:
                return "\(node.label) updates node representations by aggregating information from connected neighbors. Each round of message passing mixes local structure into the node state, and later layers stack that context into richer graph-level understanding. The graph itself becomes part of the computation, not just the node features."
            case .languageRepresentation:
                return "\(node.label) builds the representation layer that language models rely on. Tokens or words are converted into vectors, and those vectors are arranged so similar meanings or useful contexts land near one another in the embedding space. Better representations make every later task easier because the model starts from a more informative input signal."
            case .largeLanguageModels:
                return "\(node.label) shapes either how a language model is trained or how it is adapted at inference time. The mechanism may involve large-scale self-supervision, task-specific updates, careful prompting, preference optimization, or retrieval from external documents. Each method changes what information the model can use and how reliably it uses it."
            case .languageTasks:
                return "For \(node.label), the model converts text into internal representations, then predicts the structure required by the task. That might be a sentiment label, a translated sentence, or tagged spans for named entities. The core mechanism is task conditioning: the same language features are reused, but the output head and training objective are tailored to the job."
            case .visionTasks:
                return "\(node.label) takes visual input and transforms it into structured predictions. Depending on the task, the model may output a single class, boxes, masks, keypoints, pixel motion, or a generated frame or image. The mechanism always starts from feature extraction, then adds the task-specific geometry needed for the final output."
            case .ethicsAndSafety:
                return "\(node.label) is implemented through process, measurement, and system design rather than a single model architecture. Teams define what failure looks like, build ways to detect it, and add interventions such as dataset checks, interpretability tools, privacy safeguards, or adversarial evaluations. The mechanism is operational discipline translated into model behavior."
            case .dataPipeline:
                return "\(node.label) sits upstream of the model and changes the shape or quality of the training signal. Data may be cleaned, normalized, filtered, encoded, or partitioned so the learner sees a clearer and more honest version of the problem. These steps do not replace learning; they make learning possible and reliable."
            case .evaluation:
                return "\(node.label) converts model behavior into a measurement you can compare. Some metrics focus on ranking mistakes, some summarize trade-offs across thresholds, and some target regression or language quality directly. The mechanism is simple but essential: map predictions and ground truth into a score that reflects what success actually means."
            case .general:
                return "The mechanism behind \(node.label) depends on the context in which it is used, but the pattern remains the same: turn observations into a measurable signal, update your assumptions, and repeat. That loop is what ties the rest of the Explore content together."
            }
        }

        func importance(for node: TopicTreeNode) -> String {
            switch self {
            case .regression:
                return "\(node.label) matters whenever the answer is a quantity rather than a category: price, temperature, demand, risk, or time. It is one of the clearest ways to see how features, loss, and parameter updates fit together in a real model."
            case .classification:
                return "\(node.label) matters because many practical systems make yes-or-no or one-of-many decisions. Understanding how classifiers separate classes gives you a direct bridge from simple models to more complex neural networks."
            case .clustering:
                return "\(node.label) matters when labels are unavailable or expensive. It helps you explore datasets, discover natural structure, and build intuition before you commit to a supervised objective."
            case .dimensionalityReduction:
                return "\(node.label) matters because modern datasets are often too large or too high-dimensional to inspect directly. Good reduction techniques make patterns visible, speed up later models, and help you spot noise or drift."
            case .anomalyDetection:
                return "\(node.label) matters in fraud detection, monitoring, security, quality control, and any workflow where rare failures are expensive. The whole point is to react before an unusual point becomes a real incident."
            case .reinforcementLearning:
                return "\(node.label) matters because many problems are sequential: robotics, games, recommendations, control systems, and agentic workflows. It expands the learning story from predicting the next answer to choosing the next action."
            case .ensemble:
                return "\(node.label) matters because strong production systems often win by combining models rather than betting on one. Ensembles reduce variance, improve calibration, and can capture complementary strengths across methods."
            case .optimization:
                return "\(node.label) matters because training quality is often limited less by architecture and more by update behavior. Better optimization lets the same model converge faster, avoid instability, and reach better solutions."
            case .regularization:
                return "\(node.label) matters because a model that only succeeds on training data is not useful. Regularization is what turns a low training loss into something closer to dependable real-world performance."
            case .sequenceModels:
                return "\(node.label) matters for language, audio, logs, time series, and any problem where order carries meaning. It introduces the idea that context can persist and shape what comes next."
            case .generativeModels:
                return "\(node.label) matters because generation is now central to modern AI products. These models create images, text, audio, and synthetic data, and they force you to think about distributions rather than only labels."
            case .graphLearning:
                return "\(node.label) matters in molecules, recommender systems, knowledge graphs, and social networks. It teaches an important modeling principle: relationships can be first-class features."
            case .languageRepresentation:
                return "\(node.label) matters because language performance depends heavily on the quality of the representation layer. If meaning is encoded poorly, every downstream model has to fight weak inputs before it can solve the task."
            case .largeLanguageModels:
                return "\(node.label) matters because modern language systems are shaped as much by training strategy and post-training control as by architecture. Understanding these steps explains why large models can be adapted, aligned, and grounded so effectively."
            case .languageTasks:
                return "\(node.label) matters because it turns abstract language modeling into something directly useful for users and products. It is where representations, objectives, and evaluation all meet a concrete business or research goal."
            case .visionTasks:
                return "\(node.label) matters because visual systems often need more than a single label. Real applications need location, motion, pose, segmentation, or generation, and each task changes what the model must preserve in its visual features."
            case .ethicsAndSafety:
                return "\(node.label) matters because a technically impressive system can still fail users, institutions, or regulators if safety is ignored. These topics define whether the model is trustworthy, contestable, and deployable."
            case .dataPipeline:
                return "\(node.label) matters because data quality controls the ceiling on model quality. Clean, well-structured inputs make every later training step more informative and every evaluation score easier to trust."
            case .evaluation:
                return "\(node.label) matters because you can only improve what you can measure honestly. Choosing the right metric prevents you from optimizing the wrong behavior and mistaking movement for progress."
            case .general:
                return "\(node.label) matters because it adds one more piece to the mental model of how AI systems are built, trained, and judged. The better these pieces connect in your head, the easier it becomes to reason about new architectures later."
            }
        }

        func challenge(for node: TopicTreeNode) -> LessonChallenge {
            LessonChallenge(
                prompt: "Which statement best describes \(node.label)?",
                type: .multipleChoice(options: [
                    ChallengeOption(text: correctStatement(for: node), isCorrect: true, explanation: "Correct. \(node.summary)"),
                    ChallengeOption(text: distractors[0], isCorrect: false, explanation: "That describes a different family of methods, not \(node.label)."),
                    ChallengeOption(text: distractors[1], isCorrect: false, explanation: "That mixes up the role of \(node.label) with another part of the pipeline."),
                    ChallengeOption(text: distractors[2], isCorrect: false, explanation: "That would point you toward the wrong mental model for \(node.label)."),
                ])
            )
        }

        private func correctStatement(for node: TopicTreeNode) -> String {
            switch self {
            case .regression:
                return "It predicts a continuous value from input features."
            case .classification:
                return "It separates inputs into discrete classes or labels."
            case .clustering:
                return "It groups unlabeled examples by similarity."
            case .dimensionalityReduction:
                return "It compresses high-dimensional data while trying to preserve important structure."
            case .anomalyDetection:
                return "It flags data points that look unusually different from normal patterns."
            case .reinforcementLearning:
                return "It improves behavior from reward signals collected over sequences of actions."
            case .ensemble:
                return "It combines multiple models to improve stability or accuracy."
            case .optimization:
                return "It changes how gradient-based updates are applied during training."
            case .regularization:
                return "It helps a model generalize instead of memorizing the training set."
            case .sequenceModels:
                return "It models ordered data by carrying context across time steps."
            case .generativeModels:
                return "It learns a data distribution well enough to produce new samples."
            case .graphLearning:
                return "It learns from nodes and their relationships in a graph."
            case .languageRepresentation:
                return "It turns text into vector representations a model can learn from."
            case .largeLanguageModels:
                return "It controls how a large language model is trained, adapted, or grounded."
            case .languageTasks:
                return "It uses text representations to solve a specific language task."
            case .visionTasks:
                return "It extracts structure or generation targets from images or video."
            case .ethicsAndSafety:
                return "It addresses reliability, fairness, privacy, or alignment in AI systems."
            case .dataPipeline:
                return "It prepares data so the model can train and be evaluated more reliably."
            case .evaluation:
                return "It measures model performance with task-relevant metrics."
            case .general:
                return node.summary
            }
        }

        private var distractors: [String] {
            switch self {
            case .regression:
                return [
                    "It discovers clusters in unlabeled data without using targets.",
                    "It computes a token-by-token representation for language models.",
                    "It measures model performance after training is complete.",
                ]
            case .classification:
                return [
                    "It compresses many dimensions into a smaller embedding space.",
                    "It creates new synthetic samples from a learned distribution.",
                    "It chooses a train/validation/test split for fair evaluation.",
                ]
            case .clustering:
                return [
                    "It predicts an exact numeric target for each example.",
                    "It updates neural network weights using adaptive gradients.",
                    "It translates text from one language to another.",
                ]
            case .dimensionalityReduction:
                return [
                    "It assigns every example to a predefined class label.",
                    "It learns by maximizing long-term reward from actions.",
                    "It detects bounding boxes and masks in images.",
                ]
            case .anomalyDetection:
                return [
                    "It improves a model by averaging many decision trees.",
                    "It turns text into subword tokens for a language model.",
                    "It estimates performance using precision and recall.",
                ]
            case .reinforcementLearning:
                return [
                    "It predicts labels from static examples with no notion of time.",
                    "It regularizes a model by penalizing large weights.",
                    "It groups similar points into clusters without rewards.",
                ]
            case .ensemble:
                return [
                    "It carries hidden state across time steps in a sequence.",
                    "It removes noise from images by reversing a diffusion process.",
                    "It calibrates the scale of raw numerical features before training.",
                ]
            case .optimization:
                return [
                    "It detects whether a training sample is an outlier.",
                    "It uses privacy constraints to protect sensitive user data.",
                    "It maps confusion counts into an evaluation table after inference.",
                ]
            case .regularization:
                return [
                    "It predicts the next token in a prompt by retrieval alone.",
                    "It finds the nearest labeled points and votes on a class.",
                    "It reduces a dataset to two dimensions for visualization only.",
                ]
            case .sequenceModels:
                return [
                    "It treats every frame or token as fully independent with no context.",
                    "It merges many separate models into a single ensemble output.",
                    "It scores model quality with a post-training metric.",
                ]
            case .generativeModels:
                return [
                    "It only chooses among a fixed set of class labels.",
                    "It identifies unfair bias and policy risk in deployed systems.",
                    "It normalizes features before the first training step.",
                ]
            case .graphLearning:
                return [
                    "It removes mislabeled rows and missing values from a dataset.",
                    "It learns solely from reward signals in an environment.",
                    "It compares false positives and false negatives with a metric.",
                ]
            case .languageRepresentation:
                return [
                    "It detects motion vectors between consecutive video frames.",
                    "It adds stochastic depth to prevent overfitting in CNNs.",
                    "It isolates rare anomalies by partitioning feature space.",
                ]
            case .largeLanguageModels:
                return [
                    "It clusters unlabeled examples based on Euclidean distance.",
                    "It chooses feature subsets before any model sees the data.",
                    "It estimates a regression target as a continuous number.",
                ]
            case .languageTasks:
                return [
                    "It updates weights with momentum after gradients are computed.",
                    "It uses graph neighborhoods to update node embeddings.",
                    "It stabilizes training by normalizing hidden activations only.",
                ]
            case .visionTasks:
                return [
                    "It ranks translation quality or language fit with a text metric.",
                    "It builds fairness audits and alignment constraints for deployment.",
                    "It decides how to split a dataset into train and validation folds.",
                ]
            case .ethicsAndSafety:
                return [
                    "It predicts the next token by carrying an RNN hidden state.",
                    "It estimates numeric targets with a linear or curved function.",
                    "It groups points into clusters based on geometric similarity.",
                ]
            case .dataPipeline:
                return [
                    "It combines many weak models into a single stronger ensemble.",
                    "It models ordered dependencies in a sequence with memory.",
                    "It generates entirely new samples from a latent distribution.",
                ]
            case .evaluation:
                return [
                    "It modifies gradients before an optimizer updates parameters.",
                    "It protects user privacy with dataset governance controls.",
                    "It constructs embeddings that capture semantic similarity in text.",
                ]
            case .general:
                return [
                    "It is only a visualization trick and never affects modeling decisions.",
                    "It is a replacement for data quality, optimization, and evaluation all at once.",
                    "It matters only during deployment and never during model development.",
                ]
            }
        }
    }
}
// swiftlint:enable type_body_length file_length
