import Foundation

struct Subject: Identifiable {
    let id: UUID
    let name: String
    let color: Color
    let symbol: String
    var isActive: Bool = true
    var topics: [Topic] = []
    var curriculumReference: String?
}

struct Topic: Identifiable {
    let id: UUID
    let name: String
    let subject: Subject?
    var parentTopicId: UUID?
    var subtopics: [UUID] = []
}

struct Exam: Identifiable {
    let id: UUID
    let title: String
    let date: Date
    let startTime: Date
    let endTime: Date
    let location: String
    let importance: ExamImportance
    let preparationStatus: PreparationStatus
    let subject: Subject?
    let topics: [Topic]
    let description: String?
    let reminderTimes: [TimeInterval]
}

enum ExamImportance: String, CaseIterable, Identifiable {
    case low = "Niedrig"
    case medium = "Mittel"
    case high = "Hoch"
    
    var id: String { self.rawValue }
}

enum PreparationStatus: String, CaseIterable, Identifiable {
    case notStarted = "Nicht begonnen"
    case inProgress = "In Bearbeitung"
    case almostDone = "Fast fertig"
    case ready = "Bereit"
    
    var id: String { self.rawValue }
}

struct LearningPlan: Identifiable {
    let id: UUID
    let subject: Subject
    let exam: Exam?
    let startDate: Date
    let endDate: Date
    var sessions: [LearningSession]
    var adaptationHistory: [LearningPlanAdaptation]
}

struct LearningSession: Identifiable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let topics: [Topic]
    let exercises: [Exercise]
    var isCompleted: Bool = false
    var performance: SessionPerformance?
}

struct Exercise: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let difficulty: ExerciseDifficulty
    let topic: Topic
    let type: ExerciseType
}

enum ExerciseDifficulty: String, CaseIterable, Identifiable {
    case easy = "Leicht"
    case medium = "Mittel"
    case hard = "Schwer"
    
    var id: String { self.rawValue }
}

enum ExerciseType: String, CaseIterable, Identifiable {
    case multipleChoice = "Multiple Choice"
    case freeText = "Freitext"
    case matching = "Zuordnung"
    case calculation = "Berechnung"
    
    var id: String { self.rawValue }
}

struct SessionPerformance {
    let correctAnswers: Int
    let totalQuestions: Int
    let timeSpent: TimeInterval
    let difficulty: ExerciseDifficulty
    let feedback: String?
}

struct LearningPlanAdaptation: Identifiable {
    let id: UUID
    let date: Date
    let reason: AdaptationReason
    let description: String
}

enum AdaptationReason: String {
    case performance = "Leistungsänderung"
    case timeConstraint = "Zeitliche Einschränkung"
    case topicDifficulty = "Themenschwierigkeit"
    case userFeedback = "Benutzer-Feedback"
    case learningBehavior = "Lernverhalten"
}

struct ScannedDocument: Identifiable {
    let id: UUID
    let title: String
    let recognizedText: String
    let dateScanned: Date
    let subject: Subject?
    let topics: [Topic]
    let curriculumReference: String?
    var image: UIImage?
}

struct LearningPreferences: Codable {
    var visualLearner: Double = 0.5
    var auditoryLearner: Double = 0.5
    var kinestheticLearner: Double = 0.5
    var morningLearner: Double = 0.5
    var eveningLearner: Double = 0.5
    var preferredSessionLength: TimeInterval = 30 * 60 // 30 minutes
}

struct User {
    let id: UUID
    var name: String
    var age: Int
    var learningPreferences: LearningPreferences
    var subjects: [Subject]
    var exams: [Exam]
    var documents: [ScannedDocument]
    var learningPlans: [LearningPlan]
}

// Erweiterung für SwiftUI Color
import SwiftUI

extension Color: Identifiable {
    public var id: String {
        if let colorName = self.assetName {
            return colorName
        }
        return UUID().uuidString // Fallback (nicht ideal)
    }

    // Hilfsfunktion, um den Asset-Namen zu extrahieren
    var assetName: String? {
        Mirror(reflecting: self).children
            .first { $0.label == "name" }?
            .value as? String
    }
}
