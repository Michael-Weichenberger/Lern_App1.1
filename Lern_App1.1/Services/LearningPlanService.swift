import Foundation
import Combine

class LearningPlanService {
    func generateLearningPlan(for subject: Subject, exam: Exam? = nil, startDate: Date, endDate: Date) -> AnyPublisher<LearningPlan, Error> {
        // In a real app, this would use AI algorithms to generate a personalized learning plan
        // For this demo, we'll simulate plan generation with a Future publisher
        
        return Future<LearningPlan, Error> { promise in
            // Simulate processing time
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
                // Create sample learning sessions
                var sessions: [LearningSession] = []
                
                // Calculate number of days between start and end
                let calendar = Calendar.current
                let components = calendar.dateComponents([.day], from: startDate, to: endDate)
                let numberOfDays = components.day ?? 7
                
                // Create a session every other day
                for day in 0..<numberOfDays {
                    if day % 2 == 0 { // Every other day
                        let sessionDate = calendar.date(byAdding: .day, value: day, to: startDate)!
                        
                        // Alternate between afternoon and evening sessions
                        let hour = day % 4 == 0 ? 16 : 18
                        let sessionTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: sessionDate)!
                        
                        // Alternate between 30 and 45 minute sessions
                        let duration = day % 4 == 0 ? 30.0 * 60.0 : 45.0 * 60.0
                        
                        // Get some topics from the subject
                        let topics = subject.topics.isEmpty ? 
                            [Topic(id: UUID(), name: "Allgemein", subject: subject)] : 
                            Array(subject.topics.prefix(2))
                        
                        // Create sample exercises
                        let exercises: [Exercise] = [
                            Exercise(
                                id: UUID(),
                                title: "Übung 1",
                                description: "Einfache Übungsaufgabe",
                                difficulty: .easy,
                                topic: topics.first!,
                                type: .multipleChoice
                            ),
                            Exercise(
                                id: UUID(),
                                title: "Übung 2",
                                description: "Mittelschwere Übungsaufgabe",
                                difficulty: .medium,
                                topic: topics.first!,
                                type: .freeText
                            )
                        ]
                        
                        let session = LearningSession(
                            id: UUID(),
                            date: sessionTime,
                            duration: duration,
                            topics: topics,
                            exercises: exercises,
                            isCompleted: false
                        )
                        
                        sessions.append(session)
                    }
                }
                
                // Create the learning plan
                let learningPlan = LearningPlan(
                    id: UUID(),
                    subject: subject,
                    exam: exam,
                    startDate: startDate,
                    endDate: endDate,
                    sessions: sessions,
                    adaptationHistory: []
                )
                
                promise(.success(learningPlan))
            }
        }.eraseToAnyPublisher()
    }
    
    func adaptLearningPlan(_ plan: LearningPlan, based performance: SessionPerformance) -> AnyPublisher<LearningPlan, Error> {
        // In a real app, this would use AI algorithms to adapt the learning plan based on performance
        // For this demo, we'll simulate plan adaptation with a Future publisher
        
        return Future<LearningPlan, Error> { promise in
            // Simulate processing time
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                // Create a copy of the plan (since it's a struct)
                var adaptedPlan = plan
                
                // Create an adaptation record
                let adaptation = LearningPlanAdaptation(
                    id: UUID(),
                    date: Date(),
                    reason: .performance,
                    description: "Anpassung basierend auf Leistung. Schwierigkeitsgrad angepasst und zusätzliche Übungen hinzugefügt."
                )
                
                // Add the adaptation to the history
                var adaptationHistory = plan.adaptationHistory
                adaptationHistory.append(adaptation)
                
                // In a real app, we would modify the sessions based on performance
                // For this demo, we'll just update the adaptation history
                adaptedPlan = LearningPlan(
                    id: plan.id,
                    subject: plan.subject,
                    exam: plan.exam,
                    startDate: plan.startDate,
                    endDate: plan.endDate,
                    sessions: plan.sessions,
                    adaptationHistory: adaptationHistory
                )
                
                promise(.success(adaptedPlan))
            }
        }.eraseToAnyPublisher()
    }
}
