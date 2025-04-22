import Foundation
import Combine
import SwiftUI

class DocumentScannerViewModel: ObservableObject {
    @Published var scannedDocuments: [ScannedDocument] = []
    @Published var isScanning: Bool = false
    @Published var currentDocument: ScannedDocument?
    @Published var availableSubjects: [Subject] = []
    @Published var availableTopics: [Topic] = []
    
    private let documentService: DocumentScannerService
    private var cancellables = Set<AnyCancellable>()
    
    init(documentService: DocumentScannerService = DocumentScannerService()) {
        self.documentService = documentService
        loadSampleData()
    }
    
    func processImage(_ image: UIImage) {
        isScanning = true
        
        documentService.performOCR(on: image)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isScanning = false
                if case .failure(let error) = completion {
                    print("OCR Error: \(error)")
                }
            }, receiveValue: { [weak self] recognizedText in
                self?.createDocument(from: recognizedText, image: image)
            })
            .store(in: &cancellables)
    }
    
    private func createDocument(from recognizedText: String, image: UIImage) {
        // Analyze text to determine subject and topics
        let (title, subject, topics, curriculumReference) = documentService.analyzeContent(recognizedText)
        
        let newDocument = ScannedDocument(
            id: UUID(),
            title: title,
            recognizedText: recognizedText,
            dateScanned: Date(),
            subject: subject,
            topics: topics,
            curriculumReference: curriculumReference,
            image: image
        )
        
        scannedDocuments.append(newDocument)
        currentDocument = newDocument
    }
    
    func updateDocument(_ document: ScannedDocument, subject: Subject?, topics: [Topic]) {
        if let index = scannedDocuments.firstIndex(where: { $0.id == document.id }) {
            var updatedDocument = document
            // In a real implementation, we would create a new document with updated values
            // Since ScannedDocument is a struct, we can't modify it directly
            scannedDocuments[index] = updatedDocument
        }
    }
    
    func deleteDocuments(at offsets: IndexSet) {
        scannedDocuments.remove(atOffsets: offsets)
    }
    
    // Sample data for preview and testing
    private func loadSampleData() {
        let mathSubject = Subject(id: UUID(), name: "Mathematik", color: .blue, symbol: "function")
        let germanSubject = Subject(id: UUID(), name: "Deutsch", color: .red, symbol: "text.book.closed")
        
        availableSubjects = [mathSubject, germanSubject]
        
        let algebraTopic = Topic(id: UUID(), name: "Algebra", subject: mathSubject)
        let geometryTopic = Topic(id: UUID(), name: "Geometrie", subject: mathSubject)
        let linearEquationsTopic = Topic(id: UUID(), name: "Lineare Gleichungen", subject: mathSubject, parentTopicId: algebraTopic.id)
        
        availableTopics = [algebraTopic, geometryTopic, linearEquationsTopic]
        
        // Sample document
        let sampleText = """
        Mathematik Arbeitsblatt
        
        Lineare Gleichungen
        
        1. Löse die folgenden Gleichungen:
           a) 2x + 3 = 7
           b) 5x - 2 = 8
           c) 3x + 4 = 2x - 1
        
        2. Stelle die Gleichung der Geraden auf, die durch die Punkte (1,3) und (4,9) verläuft.
        
        3. Bestimme den Schnittpunkt der Geraden y = 2x + 1 und y = -x + 7.
        """
        
        let sampleDocument = ScannedDocument(
            id: UUID(),
            title: "Mathematik Arbeitsblatt",
            recognizedText: sampleText,
            dateScanned: Date(),
            subject: mathSubject,
            topics: [algebraTopic, linearEquationsTopic],
            curriculumReference: "KMK Bildungsstandards Mathematik, Leitidee Zahl"
        )
        
        scannedDocuments = [sampleDocument]
    }
}
