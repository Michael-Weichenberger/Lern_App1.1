import Foundation
import SwiftUICore
import Combine

class SubjectsViewModel: ObservableObject {
    @Published var subjects: [Subject] = []
    @Published var activeSubjects: [Subject] = []
    @Published var selectedSubject: Subject?
    @Published var topics: [Topic] = []
    
    private let subjectService: SubjectService
    private var cancellables = Set<AnyCancellable>()
    
    init(subjectService: SubjectService = SubjectService()) {
        self.subjectService = subjectService
        loadSampleData()
        setupBindings()
    }
    
    private func setupBindings() {
        $subjects
            .map { subjects in
                subjects.filter { $0.isActive }
            }
            .assign(to: &$activeSubjects)
        
        $selectedSubject
            .compactMap { $0 }
            .sink { [weak self] subject in
                self?.loadTopicsForSubject(subject)
            }
            .store(in: &cancellables)
    }
    
    func addSubject(name: String, color: Color, symbol: String) {
        let newSubject = Subject(id: UUID(), name: name, color: color, symbol: symbol)
        
        subjectService.saveSubject(newSubject)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error saving subject: \(error)")
                }
            }, receiveValue: { [weak self] subject in
                self?.subjects.append(subject)
                self?.subjects.sort { $0.name < $1.name }
            })
            .store(in: &cancellables)
    }
    
    func updateSubject(_ subject: Subject, isActive: Bool) {
        if let index = subjects.firstIndex(where: { $0.id == subject.id }) {
            // In a real implementation, we would create a new subject with updated values
            // Since Subject is a struct, we can't modify it directly
            var updatedSubject = subject
            // This is a simplification for the demo
            
            subjects[index] = updatedSubject
        }
    }
    
    func deleteSubject(_ subject: Subject) {
        subjects.removeAll { $0.id == subject.id }
    }
    
    func addTopic(name: String, to subject: Subject, parentTopic: Topic? = nil) {
        let newTopic = Topic(id: UUID(), name: name, subject: subject, parentTopicId: parentTopic?.id)
        
        subjectService.saveTopic(newTopic)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error saving topic: \(error)")
                }
            }, receiveValue: { [weak self] topic in
                self?.topics.append(topic)
                self?.topics.sort { $0.name < $1.name }
            })
            .store(in: &cancellables)
    }
    
    func deleteTopic(_ topic: Topic) {
        topics.removeAll { $0.id == topic.id }
    }
    
    private func loadTopicsForSubject(_ subject: Subject) {
        subjectService.getTopicsForSubject(subject)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error loading topics: \(error)")
                }
            }, receiveValue: { [weak self] topics in
                self?.topics = topics
            })
            .store(in: &cancellables)
    }
    
    // Sample data for preview and testing
    private func loadSampleData() {
        let mathSubject = Subject(id: UUID(), name: "Mathematik", color: .blue, symbol: "function")
        let germanSubject = Subject(id: UUID(), name: "Deutsch", color: .red, symbol: "text.book.closed")
        let englishSubject = Subject(id: UUID(), name: "Englisch", color: .purple, symbol: "globe")
        let biologySubject = Subject(id: UUID(), name: "Biologie", color: .green, symbol: "leaf")
        let physicsSubject = Subject(id: UUID(), name: "Physik", color: .orange, symbol: "atom")
        let historySubject = Subject(id: UUID(), name: "Geschichte", color: .brown, symbol: "clock")
        let artSubject = Subject(id: UUID(), name: "Kunst", color: .pink, symbol: "paintbrush", isActive: false)
        
        subjects = [mathSubject, germanSubject, englishSubject, biologySubject, physicsSubject, historySubject, artSubject]
        selectedSubject = mathSubject
        
        // Sample topics for Math
        topics = [
            Topic(id: UUID(), name: "Algebra", subject: mathSubject),
            Topic(id: UUID(), name: "Geometrie", subject: mathSubject),
            Topic(id: UUID(), name: "Analysis", subject: mathSubject),
            Topic(id: UUID(), name: "Stochastik", subject: mathSubject)
        ]
    }
}
