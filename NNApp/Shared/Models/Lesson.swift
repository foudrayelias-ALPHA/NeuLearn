import Foundation

enum LearnerLevel: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"

    var displayName: String {
        switch self {
        case .beginner: "I'm new to this"
        case .intermediate: "I know the basics"
        case .advanced: "I want deep dives"
        }
    }

    var description: String {
        switch self {
        case .beginner: "Start with intuition-first lessons. Lots of visuals, minimal jargon."
        case .intermediate: "Explore training, loss curves, and how design choices affect behavior."
        case .advanced: "Architecture comparisons, backpropagation details, and dense explanations."
        }
    }

    var shortLabel: String {
        switch self {
        case .beginner: "Beginner"
        case .intermediate: "Inter"
        case .advanced: "Advanced"
        }
    }

    var icon: String {
        switch self {
        case .beginner: "sparkles"
        case .intermediate: "arrow.triangle.branch"
        case .advanced: "cube.transparent"
        }
    }

    var nextLevel: LearnerLevel? {
        switch self {
        case .beginner: .intermediate
        case .intermediate: .advanced
        case .advanced: nil
        }
    }

    var previousLevel: LearnerLevel? {
        switch self {
        case .beginner: nil
        case .intermediate: .beginner
        case .advanced: .intermediate
        }
    }

    var rank: Int {
        switch self {
        case .beginner: 0
        case .intermediate: 1
        case .advanced: 2
        }
    }
}

enum LearningInterest: String, CaseIterable, Codable {
    case foundations = "foundations"
    case training = "training"
    case architectures = "architectures"
    case realWorldAI = "realWorldAI"

    var title: String {
        switch self {
        case .foundations: "Core Concepts"
        case .training: "How Models Learn"
        case .architectures: "Model Architectures"
        case .realWorldAI: "Real-World AI"
        }
    }

    var description: String {
        switch self {
        case .foundations: "Build intuition for neurons, weights, activations, and forward passes."
        case .training: "Focus on loss, gradient descent, backpropagation, and tuning."
        case .architectures: "Compare feedforward networks, CNNs, transformers, and design tradeoffs."
        case .realWorldAI: "Start from AI products you know, then trace back to the neural network ideas behind them."
        }
    }

    var icon: String {
        switch self {
        case .foundations: "square.stack.3d.up"
        case .training: "figure.run"
        case .architectures: "building.columns"
        case .realWorldAI: "sparkles.rectangle.stack"
        }
    }
}

enum LearningGoal: String, CaseIterable, Codable {
    case intuition = "intuition"
    case mechanics = "mechanics"
    case applications = "applications"

    var title: String {
        switch self {
        case .intuition: "Build Intuition"
        case .mechanics: "Understand the Mechanics"
        case .applications: "Connect It to AI Products"
        }
    }

    var description: String {
        switch self {
        case .intuition: "Prefer visuals and mental models before the math."
        case .mechanics: "Want to understand training steps and what each part is doing."
        case .applications: "Care most about how neural networks show up in real systems."
        }
    }

    var icon: String {
        switch self {
        case .intuition: "eye"
        case .mechanics: "gearshape.2"
        case .applications: "bolt.badge.a"
        }
    }
}

struct PersonalizedPlan: Codable, Hashable {
    let title: String
    let summary: String
    let level: LearnerLevel
    let interest: LearningInterest
    let goal: LearningGoal
    let lessonIDs: [UUID]

    var lessonCount: Int { lessonIDs.count }
}

struct Lesson: Identifiable, Hashable {
    let id: UUID
    let title: String
    let summary: String
    let level: LearnerLevel
    let sections: [LessonSection]
    let challenge: LessonChallenge?

    init(id: UUID = UUID(), title: String, summary: String, level: LearnerLevel = .beginner, sections: [LessonSection], challenge: LessonChallenge? = nil) {
        self.id = id
        self.title = title
        self.summary = summary
        self.level = level
        self.sections = sections
        self.challenge = challenge
    }
}

struct LessonSection: Identifiable, Hashable {
    let id: UUID
    let title: String
    let body: String
    let interactive: InteractiveComponent?

    init(id: UUID = UUID(), title: String, body: String, interactive: InteractiveComponent? = nil) {
        self.id = id
        self.title = title
        self.body = body
        self.interactive = interactive
    }
}

// MARK: - Interactive Components (inline in lessons)

enum InteractiveComponent: Hashable {
    case neuronExplorer
    case activationPlayground
    case lossVisualizer
    case gradientStep
    case forwardPassStepper
    case learningRateExplorer
}

// MARK: - Challenges (end of lesson)

struct LessonChallenge: Identifiable, Hashable {
    let id: UUID
    let prompt: String
    let type: ChallengeType

    init(id: UUID = UUID(), prompt: String, type: ChallengeType) {
        self.id = id
        self.prompt = prompt
        self.type = type
    }
}

enum ChallengeType: Hashable {
    case sliderTarget(label: String, target: Double, tolerance: Double, minVal: Double, maxVal: Double, unit: String)
    case multipleChoice(options: [ChallengeOption])
    case ordering(items: [String], correctOrder: [Int])
    case predictOutput(inputs: [Double], weights: [Double], bias: Double, activationName: String, correctAnswer: Double, tolerance: Double)
}

struct ChallengeOption: Hashable, Identifiable {
    let id: UUID
    let text: String
    let isCorrect: Bool
    let explanation: String

    init(id: UUID = UUID(), text: String, isCorrect: Bool, explanation: String) {
        self.id = id
        self.text = text
        self.isCorrect = isCorrect
        self.explanation = explanation
    }
}

struct TopicSummary: Identifiable, Hashable {
    let id: UUID
    let title: String
    let summary: String
    let lessonID: UUID?

    init(id: UUID = UUID(), title: String, summary: String, lessonID: UUID? = nil) {
        self.id = id
        self.title = title
        self.summary = summary
        self.lessonID = lessonID
    }
}

struct LearningPath: Identifiable, Hashable {
    let id: UUID
    let title: String
    let summary: String
    let level: LearnerLevel
    let lessonIDs: [UUID]

    var lessonCount: Int { lessonIDs.count }

    init(id: UUID = UUID(), title: String, summary: String, level: LearnerLevel = .beginner, lessonIDs: [UUID]) {
        self.id = id
        self.title = title
        self.summary = summary
        self.level = level
        self.lessonIDs = lessonIDs
    }
}

struct TopicCategory: Identifiable, Hashable {
    let id: UUID
    let name: String
    let topics: [TopicSummary]

    init(id: UUID = UUID(), name: String, topics: [TopicSummary]) {
        self.id = id
        self.name = name
        self.topics = topics
    }
}

struct GlossaryTerm: Identifiable, Hashable {
    let id: UUID
    let term: String
    let definition: String

    init(id: UUID = UUID(), term: String, definition: String) {
        self.id = id
        self.term = term
        self.definition = definition
    }
}

struct TopicTreeNode: Identifiable, Hashable {
    let id: UUID
    let label: String
    let icon: String
    let summary: String
    let children: [TopicTreeNode]
    let lessonID: UUID?

    var isLeaf: Bool { children.isEmpty }

    init(id: UUID = UUID(), label: String, icon: String = "circle.fill", summary: String = "", children: [TopicTreeNode] = [], lessonID: UUID? = nil) {
        self.id = id
        self.label = label
        self.icon = icon
        self.summary = summary
        self.children = children
        self.lessonID = lessonID
    }
}
