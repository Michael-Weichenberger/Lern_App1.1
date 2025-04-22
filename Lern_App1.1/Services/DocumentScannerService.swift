import Foundation
import Combine
import Vision
import UIKit

class DocumentScannerService {
    
    // OCR mit Vision Framework für echtes OCR
    func performOCR(on image: UIImage) -> AnyPublisher<String, Error> {
        // Erstellen einer VNImageRequestHandler-Instanz mit dem Bild
        guard let cgImage = image.cgImage else {
            return Fail(error: NSError(domain: "Invalid Image", code: -1, userInfo: nil))
                .eraseToAnyPublisher()
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Perform the OCR Request und erzeuge eine Future Publisher
        return Future<String, Error> { promise in
            // Erstellen einer OCR-Anfrage
            let ocrRequest = VNRecognizeTextRequest { request, error in
                // Fehlerbehandlung
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                // Überprüfen, ob OCR-Ergebnisse vorhanden sind
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    promise(.failure(NSError(domain: "No OCR Result", code: -1, userInfo: nil)))
                    return
                }
                
                // Text aus den OCR-Ergebnissen extrahieren
                let recognizedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")
                
                // Gib das Ergebnis über promise zurück
                promise(.success(recognizedText))
            }
            
            // OCR-Anfrage ausführen
            do {
                try requestHandler.perform([ocrRequest])
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    // Inhaltsanalyse mit einfachem Keyword-Matching
    func analyzeContent(_ text: String) -> (title: String, subject: Subject?, topics: [Topic], curriculumReference: String?) {
        // Titel aus dem Text extrahieren
        let title = text.split(separator: "\n").first?.trimmingCharacters(in: .whitespaces) ?? "Unbenanntes Dokument"
        
        var subject: Subject?
        var topics: [Topic] = []
        var curriculumReference: String?
        
        // Keyword-basierte Themenanalyse für Mathematik
        if text.lowercased().contains("mathematik") {
            subject = Subject(id: UUID(), name: "Mathematik", color: .blue, symbol: "function")
            curriculumReference = "KMK Bildungsstandards Mathematik, Leitidee Zahl"
            
            // Erkennen von Algebra und Linearen Gleichungen
            if text.lowercased().contains("algebra") || text.lowercased().contains("gleichung") {
                let algebraTopic = Topic(id: UUID(), name: "Algebra", subject: subject)
                topics.append(algebraTopic)
                
                if text.lowercased().contains("linear") {
                    let linearEquationsTopic = Topic(id: UUID(), name: "Lineare Gleichungen", subject: subject, parentTopicId: algebraTopic.id)
                    topics.append(linearEquationsTopic)
                }
            }
            
            // Geometrie und Dreiecke
            if text.lowercased().contains("geometrie") || text.lowercased().contains("dreieck") {
                topics.append(Topic(id: UUID(), name: "Geometrie", subject: subject))
            }
        } else if text.lowercased().contains("deutsch") {
            subject = Subject(id: UUID(), name: "Deutsch", color: .red, symbol: "text.book.closed")
            curriculumReference = "KMK Bildungsstandards Deutsch, Kompetenzbereich Lesen"
        }
        
        return (title, subject, topics, curriculumReference)
    }
}
