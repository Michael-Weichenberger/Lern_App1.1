import SwiftUI
import Vision

struct DocumentScannerView: View {
    @StateObject private var viewModel = DocumentScannerViewModel()
    @State private var showCamera = false
    @State private var showScannedDocument = false
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.scannedDocuments.isEmpty {
                    emptyStateView
                } else {
                    documentListView
                }
                
                Spacer()
                
                Button(action: {
                    showCamera = true
                }) {
                    HStack {
                        Image(systemName: "doc.text.viewfinder")
                        Text("Dokument scannen")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding()
                }
            }
            .navigationTitle("Dokumente scannen")
            .sheet(isPresented: $showCamera) {
                CameraView(onImageCaptured: { image in
                    viewModel.processImage(image)
                    showCamera = false
                    showScannedDocument = true
                })
            }
            .sheet(isPresented: $showScannedDocument) {
                if let latestDocument = viewModel.scannedDocuments.last {
                    ScannedDocumentView(document: latestDocument)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            Text("Keine Dokumente")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Scanne deine Schuldokumente, um sie zu digitalisieren und mit deinem Lernplan zu verknüpfen.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
    
    private var documentListView: some View {
        List {
            ForEach(viewModel.scannedDocuments) { document in
                NavigationLink(destination: ScannedDocumentView(document: document)) {
                    DocumentRow(document: document)
                }
            }
            .onDelete { indexSet in
                viewModel.deleteDocuments(at: indexSet)
            }
        }
    }
}

struct DocumentRow: View {
    let document: ScannedDocument
    
    var body: some View {
        HStack {
            Image(systemName: "doc.text")
                .foregroundColor(document.subject?.color ?? .gray)
            
            VStack(alignment: .leading) {
                Text(document.title)
                    .font(.headline)
                
                if let subject = document.subject {
                    Text(subject.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(document.dateScanned, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct CameraView: View {
    var onImageCaptured: (UIImage) -> Void
    
    // In a real app, this would use AVFoundation to access the camera
    // For this demo, we'll simulate camera capture with a placeholder
    
    var body: some View {
        VStack {
            Text("Kamera-Simulation")
                .font(.title)
                .padding()
            
            Image(systemName: "camera.viewfinder")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .padding()
            
            Text("In einer echten App würde hier die Kamera-Vorschau angezeigt werden.")
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                // Simulate capturing an image
                let simulatedImage = UIImage(systemName: "doc.text") ?? UIImage()
                onImageCaptured(simulatedImage)
            }) {
                Text("Foto aufnehmen")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding()
            }
        }
    }
}

struct ScannedDocumentView: View {
    let document: ScannedDocument
    @State private var selectedSubject: Subject?
    @State private var selectedTopics: [Topic] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(document.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Gescannt am \(document.dateScanned, style: .date)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                
                Text("Erkannter Text:")
                    .font(.headline)
                
                Text(document.recognizedText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Divider()
                
                Text("Fach zuordnen:")
                    .font(.headline)
                
                // Subject picker would go here
                Text("Fach: \(document.subject?.name ?? "Nicht zugeordnet")")
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Text("Themen zuordnen:")
                    .font(.headline)
                
                // Topics picker would go here
                Text("Themen: \(document.topics.map { $0.name }.joined(separator: ", "))")
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Divider()
                
                Text("Lehrplanbezug:")
                    .font(.headline)
                
                if let curriculumReference = document.curriculumReference {
                    Text(curriculumReference)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                } else {
                    Text("Kein Lehrplanbezug gefunden")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Dokument Details")
    }
}




struct DocumentScannerView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentScannerView()
    }
}
