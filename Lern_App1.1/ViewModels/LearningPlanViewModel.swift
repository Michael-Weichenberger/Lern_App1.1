import Foundation
import Combine

class LearningPlanViewModel: ObservableObject {
    @Published var learningPlans: [LearningPlan] = []
    @Published var currentPlan: LearningPlan?
    @Published var upcomingSessions: [LearningSession] = []
    @Published var completedSessions: [LearningSession] = []
    @Published var learningProgress: Double = 0.0
    
    private let learningService: LearningPlanService
    private var cancellables = Set<AnyCancellable>()
    
    init(learningService: LearningPlanService = LearningPlanService()) {
        self.learningService = learningService
        loadSampleData()
        setupBindings()
    }
    
    private func setupBindings() {
        $currentPlan
            .compactMap { $0 }
            .sink { [weak self] plan in
                self?.updateSessionLists(for: plan)
                self?.calculateProgress(for: plan)
            }
            .store(in: &cancellables)
    }
    
    func createLearningPlan(for subject: Subject, exam: Exam? = nil, startDate: Date = Date(), endDate: Date? = nil) {
        let targetEndDate = endDate ?? (exam?.date ?? Calendar.current.date(byAdding: .day, value: 14, to: startDate)!)
        
        learningService.generateLearningPlan(for: subject, exam: exam, startDate: startDate, endDate: targetEndDate)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error creating learning plan: \(error)")
                }
            }, receiveValue: { [weak self] plan in
                self?.learningPlans.append(plan)
                self?.currentPlan = plan
            })
            .store(in: &cancellables)
    }
    
    func completeSession(_ session: LearningSession, performance: SessionPerformance) {
        guard let planIndex = learningPlans.firstIndex(where: { plan in
            plan.sessions.contains(where: { $0.id == session.id })
        }) else { return }
        
        // In a real implementation, we would update the session in the plan
        // and potentially adapt the learning plan based on performance
        
        // For now, we'll just update our lists
        if let sessionIndex = upcomingSessions.firstIndex(where: { $0.id == session.id }) {
            upcomingSessions.remove(at: sessionIndex)
            
            // Create a completed session (in a real app, we'd modify the original)
            var completedSession = session
            // Since LearningSession is a struct, we can't modify it directly
            // This is a simplification for the demo
            completedSessions.append(completedSession)
            
            // Recalculate progress
            if let currentPlan = currentPlan {
                calculateProgress(for: currentPlan)
            }
            
            // Adapt the learning plan based on performance
            adaptLearningPlan(based: performance)
        }
    }
    
    func adaptLearningPlan(based on: SessionPerformance) {
        guard let currentPlan = currentPlan else { return }
        
        learningService.adaptLearningPlan(currentPlan, based: on)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error adapting learning plan: \(error)")
                }
            }, receiveValue: { [weak self] adaptedPlan in
                if let index = self?.learningPlans.firstIndex(where: { $0.id == currentPlan.id }) {
                    self?.learningPlans[index] = adaptedPlan
                    self?.currentPlan = adaptedPlan
                }
            })
            .store(in: &cancellables)
    }
    
    private func updateSessionLists(for plan: LearningPlan) {
        let now = Date()
        
        upcomingSessions = plan.sessions.filter { session in
            !session.isCompleted && session.date > now
        }.sorted { $0.date < $1.date }
        
        completedSessions = plan.sessions.filter { session in
            session.isCompleted || session.date < now
        }.sorted { $0.date > $1.date }
    }
    
    private func calculateProgress(for plan: LearningPlan) {
        let totalSessions = plan.sessions.count
        let completedCount = plan.sessions.filter { $0.isCompleted }.count
        
        if totalSessions > 0 {
            learningProgress = Double(completedCount) / Double(totalSessions)
        } else {
            learningProgress = 0
        }
    }
    
    // Sample data for preview and testing
    private func loadSampleData() {
        let mathSubject = Subject(id: UUID(), name: "Mathematik", color: .blue, symbol: "function")
        
        let algebraTopic = Topic(id: UUID(), name: "Algebra", subject: mathSubject)
        let linearEquationsTopic = Topic(id: UUID(), name: "Lineare Gleichungen", subject: mathSubject, parentTopicId: algebraTopic.id)
        
        let now = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: now)!
        
        let mathExam = Exam(
            id: UUID(),
            title: "Klassenarbeit Algebra",
            date: nextWeek,
            startTime: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: nextWeek)!,
            endTime: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: nextWeek)!,
            location: "Raum 203",
            importance: .high,
            preparationStatus: .inProgress,
            subject: mathSubject,
            topics: [algebraTopic, linearEquationsTopic],
            description: "Klassenarbeit über lineare und quadratische Gleichungen. Taschenrechner erlaubt, aber keine Formelsammlung.",
            reminderTimes: [86400, 43200, 3600] // 1 day, 12 hours, 1 hour before
        )
        
        // Create sample learning sessions
        var sessions: [LearningSession] = []
        
        // Past completed session
        let yesterdaySession = LearningSession(
            id: UUID(),
            date: Calendar.current.date(byAdding: .day, value: -1, to: now)!,
            duration: 30 * 60, // 30 minutes
            topics: [algebraTopic],
            exercises: [],
            isCompleted: true,
            performance: SessionPerformance(
                correctAnswers: 8,
                totalQuestions: 10,
                timeSpent: 25 * 60,
                difficulty: .medium,
                feedback: "Gut gemacht, aber noch Schwierigkeiten bei quadratischen Gleichungen."
            )
        )
        sessions.append(yesterdaySession)
        
        // Today's session
        let todaySession = LearningSession(
            id: UUID(),
            date: Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: now)!,
            duration: 45 * 60, // 45 minutes
            topics: [linearEquationsTopic],
            exercises: [],
            isCompleted: false
        )
        sessions.append(todaySession)
        
        // Tomorrow's session
        let tomorrowSession = LearningSession(
            id: UUID(),
            date: Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: tomorrow)!,
            duration: 30 * 60, // 30 minutes
            topics: [algebraTopic, linearEquationsTopic],
            exercises: [],
            isCompleted: false
        )
        sessions.append(tomorrowSession)
        
        // Create sample learning plan
        let samplePlan = LearningPlan(
            id: UUID(),
            subject: mathSubject,
            exam: mathExam,
            startDate: Calendar.current.date(byAdding: .day, value: -2, to: now)!,
            endDate: nextWeek,
            sessions: sessions,
            adaptationHistory: [
                LearningPlanAdaptation(
                    id: UUID(),
                    date: Calendar.current.date(byAdding: .day, value: -1, to: now)!,
                    reason: .performance,
                    description: "Anpassung basierend auf Leistung in der letzten Sitzung. Mehr Übungen zu quadratischen Gleichungen hinzugefügt."
                )
            ]
        )
        
        learningPlans = [samplePlan]
        currentPlan = samplePlan
    }
}
