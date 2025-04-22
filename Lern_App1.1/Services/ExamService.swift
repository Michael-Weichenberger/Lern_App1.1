import Foundation
import Combine
import CoreData

class ExamService {
    
    private let persistentContainer: NSPersistentContainer
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    // Exam erstellen und in Core Data speichern
    func createExam(title: String, subject: Subject, date: Date, startTime: Date, endTime: Date,
                   location: String, importance: ExamImportance, topics: [Topic], description: String? = nil) -> AnyPublisher<Exam, Error> {
        
        return Future<Exam, Error> { promise in
            // Core Data-Objekt für Exam erstellen
            let exam = ExamEntity(context: self.context)
            exam.id = UUID()
            exam.title = title
            exam.date = date
            exam.startTime = startTime
            exam.endTime = endTime
            exam.location = location
            exam.importance = importance.rawValue
            exam.preparationStatus = PreparationStatus.notStarted.rawValue
            exam.subject = subject.name
            exam.topics = topics.map { $0.name }.joined(separator: ", ")
            exam.examDescription = description
            exam.reminderTimes = [86400, 3600] as NSObject // Reminder für 1 Tag und 1 Stunde vorher
            
            do {
                try self.context.save()
                let mappedExam = Exam(
                    id: exam.id ?? UUID(),
                    title: exam.title ?? "",
                    date: exam.date ?? Date(),
                    startTime: exam.startTime ?? Date(),
                    endTime: exam.endTime ?? Date(),
                    location: exam.location ?? "",
                    importance: ExamImportance(rawValue: exam.importance ?? "") ?? .medium,
                    preparationStatus: PreparationStatus(rawValue: exam.preparationStatus ?? "") ?? .notStarted,
                    subject: subject, // <- kommt aus Parameter
                    topics: topics,   // <- kommt aus Parameter
                    description: exam.examDescription,
                    reminderTimes: exam.reminderTimes as? [TimeInterval] ?? []
                )

                promise(.success(mappedExam))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    // Status einer Prüfung aktualisieren
    func updateExamStatus(_ exam: ExamEntity, status: PreparationStatus) -> AnyPublisher<ExamEntity, Error> {
        return Future<ExamEntity, Error> { promise in
            exam.preparationStatus = status.rawValue
            do {
                try self.context.save()
                promise(.success(exam)) // Rückgabe des aktualisierten Exam
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    // Alle anstehenden Prüfungen abrufen
    func getUpcomingExams() -> AnyPublisher<[ExamEntity], Error> {
        return Future<[ExamEntity], Error> { promise in
            let fetchRequest: NSFetchRequest<ExamEntity> = ExamEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "date >= %@", Date() as CVarArg) // Nur zukünftige Prüfungen
            
            do {
                let exams = try self.context.fetch(fetchRequest)
                promise(.success(exams))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    // Prüfung löschen
    func deleteExam(_ exam: ExamEntity) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            self.context.delete(exam)
            do {
                try self.context.save()
                promise(.success(())) // Erfolgreiches Löschen
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}
