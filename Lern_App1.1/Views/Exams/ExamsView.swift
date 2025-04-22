//
//  ExamsView.swift
//  Lern_App1.1
//
//  Created by Kasi Weichenberger on 13.04.25.
//

import SwiftUI

struct ExamsView: View {
    @StateObject private var viewModel = ExamsViewModel()
    @State private var showingAddExam = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter-Optionen
                VStack(spacing: 12) {
                    // Zeitraum-Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ExamsViewModel.TimeFrame.allCases) { timeFrame in
                                Button(action: {
                                    viewModel.selectedTimeFrame = timeFrame
                                }) {
                                    Text(timeFrame.rawValue)
                                        .font(.subheadline)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(viewModel.selectedTimeFrame == timeFrame ? Color.blue : Color(.systemGray6))
                                        .foregroundColor(viewModel.selectedTimeFrame == timeFrame ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Fächer-Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            Button(action: {
                                viewModel.selectedSubject = nil
                            }) {
                                Text("Alle Fächer")
                                    .font(.subheadline)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(viewModel.selectedSubject == nil ? Color.blue : Color(.systemGray6))
                                    .foregroundColor(viewModel.selectedSubject == nil ? .white : .primary)
                                    .cornerRadius(20)
                            }
                            
                            // Hier würden die Fächer aus dem ViewModel angezeigt werden
                            // In einer echten App würde man ForEach über viewModel.subjects verwenden
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .background(Color(.systemBackground))
                
                // Prüfungsliste
                if viewModel.filteredExams.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(viewModel.filteredExams) { exam in
                            NavigationLink(destination: ExamDetailView(exam: exam)) {
                                examRow(for: exam)
                            }
                        }
                        .onDelete { indexSet in
                            // Hier würde man die Prüfungen löschen
                            // In einer echten App würde man viewModel.deleteExam aufrufen
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Prüfungen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddExam = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExam) {
                ExamFormView()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            Text("Keine Prüfungen")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Du hast noch keine Prüfungen hinzugefügt. Tippe auf das Plus-Symbol, um eine neue Prüfung zu erstellen.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                showingAddExam = true
            }) {
                Text("Prüfung hinzufügen")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
    
    private func examRow(for exam: Exam) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(exam.subject?.color ?? Color.gray)
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
        .padding(.vertical, 4)
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

struct ExamDetailView: View {
    let exam: Exam
    @State private var preparationStatus: PreparationStatus
    
    init(exam: Exam) {
        self.exam = exam
        self._preparationStatus = State(initialValue: exam.preparationStatus)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        if let subject = exam.subject {
                            Circle()
                                .fill(subject.color)
                                .frame(width: 16, height: 16)
                            
                            Text(subject.name)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(exam.importance.rawValue)
                            .font(.subheadline)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(importanceColor(for: exam.importance).opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    Text(exam.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        
                        Text(exam.date, style: .date)
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        
                        Text("\(exam.startTime, style: .time) - \(exam.endTime, style: .time)")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "mappin")
                            .foregroundColor(.secondary)
                        
                        Text(exam.location)
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Vorbereitungsstatus
                VStack(alignment: .leading, spacing: 12) {
                    Text("Vorbereitungsstatus")
                        .font(.headline)
                    
                    Picker("Status", selection: $preparationStatus) {
                        ForEach(PreparationStatus.allCases) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Button(action: {
                        // Status aktualisieren
                        // In einer echten App würde man viewModel.updateExam aufrufen
                    }) {
                        Text("Status aktualisieren")
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
                
                // Themen
                VStack(alignment: .leading, spacing: 12) {
                    Text("Prüfungsthemen")
                        .font(.headline)
                    
                    if exam.topics.isEmpty {
                        Text("Keine Themen angegeben")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(exam.topics) { topic in
                            HStack {
                                Circle()
                                    .fill(topic.subject?.color ?? Color.gray)
                                    .frame(width: 8, height: 8)
                                
                                Text(topic.name)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Beschreibung
                if let description = exam.description {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Beschreibung")
                            .font(.headline)
                        
                        Text(description)
                            .font(.body)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                // Lernplan erstellen
                VStack(alignment: .leading, spacing: 12) {
                    Text("Lernplan")
                        .font(.headline)
                    
                    Button(action: {
                        // Lernplan erstellen
                        // In einer echten App würde man zur Lernplanerstellung navigieren
                    }) {
                        Text("Lernplan für diese Prüfung erstellen")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Prüfungsdetails")
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

struct ExamFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var subjectsViewModel = SubjectsViewModel()
    
    @State private var title = ""
    @State private var date = Date()
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(90 * 60) // 90 Minuten später
    @State private var location = ""
    @State private var importance = ExamImportance.medium
    @State private var selectedSubject: Subject?
    @State private var selectedTopics: [Topic] = []
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Allgemeine Informationen")) {
                    TextField("Titel", text: $title)
                    
                    DatePicker("Datum", selection: $date, displayedComponents: .date)
                    
                    DatePicker("Startzeit", selection: $startTime, displayedComponents: .hourAndMinute)
                    
                    DatePicker("Endzeit", selection: $endTime, displayedComponents: .hourAndMinute)
                    
                    TextField("Ort", text: $location)
                }
                
                Section(header: Text("Wichtigkeit")) {
                    Picker("Wichtigkeit", selection: $importance) {
                        ForEach(ExamImportance.allCases) { importance in
                            Text(importance.rawValue).tag(importance)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Fach")) {
                    // Hier würde man ein Picker für die Fächer anzeigen
                    // In einer echten App würde man ForEach über subjectsViewModel.subjects verwenden
                    Text("Fach auswählen")
                }
                
                Section(header: Text("Themen")) {
                    // Hier würde man ein MultiPicker für die Themen anzeigen
                    // In einer echten App würde man ForEach über die Themen des ausgewählten Fachs verwenden
                    Text("Themen auswählen")
                }
                
                Section(header: Text("Beschreibung")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Neue Prüfung")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        // Hier würde man die Prüfung speichern
                        // In einer echten App würde man viewModel.addExam aufrufen
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.isEmpty || location.isEmpty)
                }
            }
        }
    }
}


#Preview {
    ExamsView()
}
