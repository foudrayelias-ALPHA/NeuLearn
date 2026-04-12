import Foundation
import Observation

@Observable
final class ProgressStore {
    var hasCompletedOnboarding: Bool {
        didSet { save() }
    }
    var selectedLevel: LearnerLevel {
        didSet { save() }
    }
    var selectedInterest: LearningInterest? {
        didSet { save() }
    }
    var selectedGoal: LearningGoal? {
        didSet { save() }
    }
    var personalizedPlan: PersonalizedPlan? {
        didSet { save() }
    }
    var completedLessonIDs: Set<UUID> {
        didSet { save() }
    }
    var savedLessonIDs: Set<UUID> {
        didSet { save() }
    }
    var lastViewedLessonID: UUID? {
        didSet { save() }
    }

    private let defaults = UserDefaults.standard

    init() {
        self.hasCompletedOnboarding = defaults.bool(forKey: "hasCompletedOnboarding")
        self.selectedLevel = LearnerLevel(rawValue: defaults.string(forKey: "selectedLevel") ?? "") ?? .beginner
        self.selectedInterest = LearningInterest(rawValue: defaults.string(forKey: "selectedInterest") ?? "")
        self.selectedGoal = LearningGoal(rawValue: defaults.string(forKey: "selectedGoal") ?? "")

        if let planData = defaults.data(forKey: "personalizedPlan"),
           let decoded = try? JSONDecoder().decode(PersonalizedPlan.self, from: planData) {
            self.personalizedPlan = decoded
        } else {
            self.personalizedPlan = nil
        }

        if let completedData = defaults.data(forKey: "completedLessonIDs"),
           let decoded = try? JSONDecoder().decode(Set<UUID>.self, from: completedData) {
            self.completedLessonIDs = decoded
        } else {
            self.completedLessonIDs = []
        }

        if let savedData = defaults.data(forKey: "savedLessonIDs"),
           let decoded = try? JSONDecoder().decode(Set<UUID>.self, from: savedData) {
            self.savedLessonIDs = decoded
        } else {
            self.savedLessonIDs = []
        }

        if let uuidString = defaults.string(forKey: "lastViewedLessonID") {
            self.lastViewedLessonID = UUID(uuidString: uuidString)
        } else {
            self.lastViewedLessonID = nil
        }
    }

    func markCompleted(_ lessonID: UUID) {
        let inserted = completedLessonIDs.insert(lessonID).inserted
        lastViewedLessonID = lessonID
        if inserted {
            updateLevelProgression()
            refreshPersonalizedPlan()
        }
    }

    func markViewed(_ lessonID: UUID) {
        lastViewedLessonID = lessonID
    }

    func toggleSaved(_ lessonID: UUID) {
        if savedLessonIDs.contains(lessonID) {
            savedLessonIDs.remove(lessonID)
        } else {
            savedLessonIDs.insert(lessonID)
        }
    }

    func isCompleted(_ lessonID: UUID) -> Bool {
        completedLessonIDs.contains(lessonID)
    }

    func isSaved(_ lessonID: UUID) -> Bool {
        savedLessonIDs.contains(lessonID)
    }

    func completedCount(in lessonIDs: [UUID]) -> Int {
        lessonIDs.filter { completedLessonIDs.contains($0) }.count
    }

    func completedCount(for level: LearnerLevel) -> Int {
        completedCount(in: lessonIDs(for: level))
    }

    func totalLessonCount(for level: LearnerLevel) -> Int {
        lessonIDs(for: level).count
    }

    func isLevelUnlocked(_ level: LearnerLevel) -> Bool {
        if level.rank <= selectedLevel.rank {
            return true
        }

        guard let previousLevel = level.previousLevel else { return true }
        return hasCompletedLevel(previousLevel)
    }

    func hasCompletedLevel(_ level: LearnerLevel) -> Bool {
        let lessonIDs = lessonIDs(for: level)
        guard !lessonIDs.isEmpty else { return false }
        return completedCount(in: lessonIDs) == lessonIDs.count
    }

    var nextLevelToUnlock: LearnerLevel? {
        LearnerLevel.allCases.first { !isLevelUnlocked($0) }
    }

    var progressTowardNextLevel: Double {
        guard let nextLevel = nextLevelToUnlock,
              let prerequisiteLevel = nextLevel.previousLevel else {
            return 1
        }

        let requiredLessonIDs = lessonIDs(for: prerequisiteLevel)
        guard !requiredLessonIDs.isEmpty else { return 0 }
        return Double(completedCount(in: requiredLessonIDs)) / Double(requiredLessonIDs.count)
    }

    var lessonsNeededForNextLevel: Int {
        guard let nextLevel = nextLevelToUnlock,
              let prerequisiteLevel = nextLevel.previousLevel else {
            return 0
        }

        return max(lessonIDs(for: prerequisiteLevel).count - completedCount(for: prerequisiteLevel), 0)
    }

    func createPersonalizedPlan(level: LearnerLevel, interest: LearningInterest, goal: LearningGoal) {
        selectedLevel = level
        selectedInterest = interest
        selectedGoal = goal
        refreshPersonalizedPlan()
    }

    var recommendedNextLesson: Lesson? {
        if let personalizedPlan {
            let planLessons = personalizedPlan.lessonIDs.compactMap(SampleContent.lesson(for:))
            return planLessons.first { !completedLessonIDs.contains($0.id) } ?? planLessons.first
        }

        let lessons = SampleContent.lessons.filter { $0.level == selectedLevel }
        return lessons.first { !completedLessonIDs.contains($0.id) } ?? lessons.first
    }

    var currentPlanSequenceNumber: Int {
        guard let selectedInterest, let selectedGoal else { return 1 }
        let fullSequence = SampleContent.personalizedLessonSequence(
            level: selectedLevel,
            interest: selectedInterest,
            goal: selectedGoal
        )
        guard !fullSequence.isEmpty else { return 1 }

        let completedCount = fullSequence.filter { completedLessonIDs.contains($0) }.count
        let totalSequences = max(Int(ceil(Double(fullSequence.count) / 5.0)), 1)
        return min((completedCount / 5) + 1, totalSequences)
    }

    var totalPlanSequenceCount: Int {
        guard let selectedInterest, let selectedGoal else { return 1 }
        let fullSequence = SampleContent.personalizedLessonSequence(
            level: selectedLevel,
            interest: selectedInterest,
            goal: selectedGoal
        )
        return max(Int(ceil(Double(fullSequence.count) / 5.0)), 1)
    }

    private func lessonIDs(for level: LearnerLevel) -> [UUID] {
        SampleContent.lessons
            .filter { $0.level == level }
            .map(\.id)
    }

    private func updateLevelProgression() {
        let highestUnlockedLevel = LearnerLevel.allCases.last(where: isLevelUnlocked) ?? .beginner

        guard highestUnlockedLevel != selectedLevel else { return }

        selectedLevel = highestUnlockedLevel
    }

    private func refreshPersonalizedPlan() {
        guard let selectedInterest, let selectedGoal else { return }

        personalizedPlan = SampleContent.makePersonalizedPlan(
            level: selectedLevel,
            interest: selectedInterest,
            goal: selectedGoal,
            completedLessonIDs: completedLessonIDs
        )
    }

    private func save() {
        defaults.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        defaults.set(selectedLevel.rawValue, forKey: "selectedLevel")
        defaults.set(selectedInterest?.rawValue, forKey: "selectedInterest")
        defaults.set(selectedGoal?.rawValue, forKey: "selectedGoal")
        if let data = try? JSONEncoder().encode(personalizedPlan) {
            defaults.set(data, forKey: "personalizedPlan")
        } else {
            defaults.removeObject(forKey: "personalizedPlan")
        }
        if let data = try? JSONEncoder().encode(completedLessonIDs) {
            defaults.set(data, forKey: "completedLessonIDs")
        }
        if let data = try? JSONEncoder().encode(savedLessonIDs) {
            defaults.set(data, forKey: "savedLessonIDs")
        }
        if let id = lastViewedLessonID {
            defaults.set(id.uuidString, forKey: "lastViewedLessonID")
        }
    }
}
