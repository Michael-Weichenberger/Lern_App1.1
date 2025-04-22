import Foundation
import CoreData
import Combine

class ExamsViewModel: ObservableObject {
    @Published var exams: [Exam] = []
    @Published var upcomingExams: [Exam] = []
    @Published var filteredExams: [Exam] = []
    @Published var selectedSubject: Subject?
    @Published var selectedTimeFrame: TimeFrame = .all

    private let examService: ExamService
    private var cancellables = Set<AnyCancellable>()

    enum TimeFrame: String, CaseIterable, Identifiable {
        case today = "Heute"
        case thisWeek = "Diese Woche"
        case thisMonth = "Diesen Monat"
        case all = "Alle"

        var id: String { self.rawValue }
    }

    init(examService: ExamService = ExamService(persistentContainer: PersistenceController.shared.container)) {
        self.examService = examService
        setupBindings()
    }

    // MARK: - Bindings

    private func setupBindings() {
        Publishers.CombineLatest($exams, $selectedTimeFrame)
            .map { [weak self] exams, timeFrame in
                self?.filterExams(exams, by: timeFrame) ?? []
            }
            .assign(to: &$upcomingExams)

        Publishers.CombineLatest($upcomingExams, $selectedSubject)
            .map { exams, subject in
                if let subject = subject {
                    return exams.filter { $0.subject?.id == subject.id }
                } else {
                    return exams
                }
            }
            .assign(to: &$filteredExams)
    }

    // MARK: - Filterfunktion

    private func filterExams(_ exams: [Exam], by timeFrame: TimeFrame) -> [Exam] {
        let now = Date()
        let calendar = Calendar.current
        let filteredExams = exams.filter { $0.date > now }

        switch timeFrame {
        case .today:
            return filteredExams.filter { calendar.isDateInToday($0.date) }
        case .thisWeek:
            let endOfWeek = calendar.date(byAdding: .day, value: 7, to: now)!
            return filteredExams.filter { $0.date <= endOfWeek }
        case .thisMonth:
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: now)!
            return filteredExams.filter { $0.date <= endOfMonth }
        case .all:
            return filteredExams
        }
    }

    // MARK: - Prüfungen hinzufügen

    func addExam(title: String, subject: Subject, date: Date, startTime: Date, endTime: Date,
                 location: String, importance: ExamImportance, topics: [Topic], description: String? = nil) {

        examService.createExam(title: title, subject: subject, date: date, startTime: startTime, endTime: endTime,
                               location: location, importance: importance, topics: topics, description: description)
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Error creating exam: \(error)")
            }
        }, receiveValue: { [weak self] exam in
            self?.exams.append(exam)
            self?.exams.sort { $0.date < $1.date }
        })
        .store(in: &cancellables)
    }

    // MARK: - Prüfung aktualisieren

    func updateExam(_ exam: Exam, preparationStatus: PreparationStatus) {
        if let index = exams.firstIndex(where: { $0.id == exam.id }) {
            print("Updated exam \(exam.title) status to \(preparationStatus.rawValue)")
        }
    }

    // MARK: - Prüfung löschen

    func deleteExam(_ exam: Exam) {
        exams.removeAll { $0.id == exam.id }
    }

    // MARK: - Beispieldaten

    func loadSampleData() {
        let mathSubject = Subject(id: UUID(), name: "Mathematik", color: .blue, symbol: "function")
        let germanSubject = Subject(id: UUID(), name: "Deutsch", color: .red, symbol: "text.book.closed")
        let biologySubject = Subject(id: UUID(), name: "Biologie", color: .green, symbol: "leaf")

        let now = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: now)!
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: now)!

        let mathExam = Exam(
            id: UUID(),
            title: "Klassenarbeit Algebra",
            date: tomorrow,
            startTime: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: tomorrow)!,
            endTime: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: tomorrow)!,
            location: "Raum 203",
            importance: .high,
            preparationStatus: .inProgress,
            subject: mathSubject,
            topics: [
                Topic(id: UUID(), name: "Algebra", subject: mathSubject),
                Topic(id: UUID(), name: "Lineare Gleichungen", subject: mathSubject)
            ],
            description: "Klassenarbeit über lineare und quadratische Gleichungen. Taschenrechner erlaubt, aber keine Formelsammlung.",
            reminderTimes: [86400, 43200, 3600]
        )

        let germanExam = Exam(
            id: UUID(),
            title: "Aufsatz Textanalyse",
            date: nextWeek,
            startTime: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: nextWeek)!,
            endTime: Calendar.current.date(bySettingHour: 11, minute: 30, second: 0, of: nextWeek)!,
            location: "Raum 105",
            importance: .medium,
            preparationStatus: .almostDone,
            subject: germanSubject,
            topics: [
                Topic(id: UUID(), name: "Textanalyse", subject: germanSubject),
                Topic(id: UUID(), name: "Charakterisierung", subject: germanSubject)
            ],
            description: "Aufsatz zu einer Kurzgeschichte. Wörterbuch erlaubt.",
            reminderTimes: [86400, 3600]
        )

        let biologyExam = Exam(
            id: UUID(),
            title: "Test Zellbiologie",
            date: nextMonth,
            startTime: Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: nextMonth)!,
            endTime: Calendar.current.date(bySettingHour: 14, minute: 45, second: 0, of: nextMonth)!,
            location: "Biologieraum",
            importance: .low,
            preparationStatus: .notStarted,
            subject: biologySubject,
            topics: [
                Topic(id: UUID(), name: "Zellbiologie", subject: biologySubject),
                Topic(id: UUID(), name: "Zellaufbau", subject: biologySubject)
            ],
            description: "Kurzer Test über Grundlagen der Zellbiologie.",
            reminderTimes: [86400]
        )

        exams = [mathExam, germanExam, biologyExam]
    }

    // MARK: - PersistenceController für Vorschau

    class PersistenceController {
        static let shared = PersistenceController()

        let container: NSPersistentContainer

        init() {
            container = NSPersistentContainer(name: "DeinModelName")
            container.loadPersistentStores { description, error in
                if let error = error {
                    fatalError("Core Data Store konnte nicht geladen werden: \(error)")
                }
            }
        }
    }
}
