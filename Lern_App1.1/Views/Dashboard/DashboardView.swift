import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject var learningPlanViewModel = LearningPlanViewModel()
    @ObservedObject var examsViewModel = ExamsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Welcome section
                welcomeSection
                
                // Upcoming exams section
                upcomingExamsSection
                
                // Learning plan section
                learningPlanSection
                
                // Recent documents section
                recentDocumentsSection
            }
            .padding()
        }
        .navigationTitle("Dashboard")
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hallo, \(userSettings.userName.isEmpty ? "Schüler" : userSettings.userName)!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Hier ist dein Lernfortschritt für heute")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var upcomingExamsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Anstehende Prüfungen")
                .font(.headline)
            
            if examsViewModel.filteredExams.isEmpty {
                Text("Keine anstehenden Prüfungen")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            } else {
                ForEach(examsViewModel.filteredExams.prefix(3)) { exam in
                    ExamCard(exam: exam)
                }
            }
            
            NavigationLink(destination: ExamsView()) {
                Text("Alle Prüfungen anzeigen")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    private var learningPlanSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dein Lernplan")
                .font(.headline)
            
            if let currentPlan = learningPlanViewModel.currentPlan {
                VStack(alignment: .leading, spacing: 8) {
                    Text(currentPlan.subject.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    if let exam = currentPlan.exam {
                        Text("Vorbereitung auf: \(exam.title)")
                            .font(.subheadline)
                    }
                    
                    ProgressView(value: learningPlanViewModel.learningProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.vertical, 4)
                    
                    Text("\(Int(learningPlanViewModel.learningProgress * 100))% abgeschlossen")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                if !learningPlanViewModel.upcomingSessions.isEmpty {
                    Text("Nächste Lernsitzung")
                        .font(.subheadline)
                        .padding(.top, 8)
                    
                    let nextSession = learningPlanViewModel.upcomingSessions.first!
                    SessionCard(session: nextSession)
                }
            } else {
                Text("Noch kein Lernplan erstellt")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                Button(action: {
                    // In a real app, this would navigate to create a learning plan
                }) {
                    Text("Lernplan erstellen")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            
            NavigationLink(destination: LearningPlanView()) {
                Text("Zum Lernplan")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    private var recentDocumentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kürzlich gescannte Dokumente")
                .font(.headline)
            
            // This would be populated with actual documents in a real app
            Text("Keine kürzlich gescannten Dokumente")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            NavigationLink(destination: DocumentScannerView()) {
                Text("Dokument scannen")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

struct ExamCard: View {
    let exam: Exam
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(exam.subject?.color ?? .gray)
                    .frame(width: 12, height: 12)
                
                Text(exam.title)
                    .font(.headline)
                
                Spacer()
                
                Text(exam.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                
                Text("\(exam.startTime, style: .time) - \(exam.endTime, style: .time)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: "mappin")
                    .foregroundColor(.secondary)
                
                Text(exam.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Status: \(exam.preparationStatus.rawValue)")
                    .font(.caption)
                    .padding(4)
                    .background(statusColor(for: exam.preparationStatus).opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
                
                Text("Wichtigkeit: \(exam.importance.rawValue)")
                    .font(.caption)
                    .padding(4)
                    .background(importanceColor(for: exam.importance).opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private func statusColor(for status: PreparationStatus) -> Color {
        switch status {
        case .notStarted:
            return .red
        case .inProgress:
            return .orange
        case .almostDone:
            return .yellow
        case .ready:
            return .green
        }
    }
    
    private func importanceColor(for importance: ExamImportance) -> Color {
        switch importance {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .red
        }
    }
}

struct SessionCard: View {
    let session: LearningSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.date, style: .time)
                    .font(.headline)
                
                Spacer()
                
                Text("Dauer: \(formattedDuration)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("Themen: \(topicNames)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: {
                // In a real app, this would navigate to the session details
            }) {
                Text("Zur Sitzung")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private var formattedDuration: String {
        let minutes = Int(session.duration / 60)
        return "\(minutes) Minuten"
    }
    
    private var topicNames: String {
        session.topics.map { $0.name }.joined(separator: ", ")
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardView()
                .environmentObject(UserSettings())
        }
    }
}
