//
//  SubjectView.swift
//  Lern_App1.1
//
//  Created by Kasi Weichenberger on 13.04.25.
//

import SwiftUI

struct SubjectsView: View {
    @StateObject private var viewModel = SubjectsViewModel()
    @State private var showingAddSubject = false
    
    var body: some View {
        NavigationView {
            List {
                // Aktive Fächer
                Section(header: Text("Aktive Fächer")) {
                    if viewModel.activeSubjects.isEmpty {
                        Text("Keine aktiven Fächer")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.activeSubjects) { subject in
                            NavigationLink(destination: SubjectDetailView(subject: subject)) {
                                subjectRow(for: subject)
                            }
                        }
                        .onDelete { indexSet in
                            // In echter App: viewModel.deleteSubject(indexSet)
                        }
                    }
                }
                
                // Inaktive Fächer
                Section(header: Text("Inaktive Fächer")) {
                    let inactiveSubjects = viewModel.subjects.filter { !$0.isActive }
                    
                    if inactiveSubjects.isEmpty {
                        Text("Keine inaktiven Fächer")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(inactiveSubjects) { subject in
                            NavigationLink(destination: SubjectDetailView(subject: subject)) {
                                subjectRow(for: subject)
                            }
                        }
                        .onDelete { indexSet in
                            // In echter App: viewModel.deleteSubject(indexSet)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Fächer")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddSubject = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSubject) {
                SubjectFormView()
            }
        }
    }
    
    private func subjectRow(for subject: Subject) -> some View {
        HStack {
            Image(systemName: subject.symbol)
                .foregroundColor(subject.color)
                .font(.title3)
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading) {
                Text(subject.name)
                    .font(.headline)
                
                if let reference = subject.curriculumReference {
                    Text(reference)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if !subject.isActive {
                Text("Inaktiv")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SubjectDetailView: View {
    let subject: Subject
    @StateObject private var viewModel = SubjectsViewModel()
    @State private var isActive: Bool
    @State private var showingAddTopic = false
    
    init(subject: Subject) {
        self.subject = subject
        self._isActive = State(initialValue: subject.isActive)
    }
    
    var body: some View {
        List {
            // Fach-Informationen
            Section(header: Text("Fach-Informationen")) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(subject.name)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Farbe")
                    Spacer()
                    Circle()
                        .fill(subject.color)
                        .frame(width: 20, height: 20)
                }
                
                HStack {
                    Text("Symbol")
                    Spacer()
                    Image(systemName: subject.symbol)
                        .foregroundColor(subject.color)
                }
                
                if let reference = subject.curriculumReference {
                    HStack {
                        Text("Lehrplanreferenz")
                        Spacer()
                        Text(reference)
                            .foregroundColor(.secondary)
                    }
                }
                
                Toggle("Aktiv", isOn: $isActive)
                    .onChange(of: isActive) { newValue in
                        // viewModel.updateSubject(subject, isActive: newValue)
                    }
            }
            
            // Themen
            Section(header: HStack {
                Text("Themen")
                Spacer()
                Button(action: {
                    showingAddTopic = true
                }) {
                    Image(systemName: "plus")
                        .font(.caption)
                }
            }) {
                if viewModel.topics.isEmpty {
                    Text("Keine Themen")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.topics) { topic in
                        topicRow(for: topic)
                    }
                    .onDelete { indexSet in
                        // viewModel.deleteTopic(indexSet)
                    }
                }
            }
            
            // Statistiken
            Section(header: Text("Statistiken")) {
                HStack {
                    Text("Anzahl Themen")
                    Spacer()
                    Text("\(viewModel.topics.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Anzahl Dokumente")
                    Spacer()
                    Text("0") // z. B. viewModel.documents.count
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Anzahl Prüfungen")
                    Spacer()
                    Text("0") // z. B. viewModel.exams.count
                        .foregroundColor(.secondary)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(subject.name)
        .sheet(isPresented: $showingAddTopic) {
            TopicFormView(subject: subject)
        }
    }
    
    private func topicRow(for topic: Topic) -> some View {
        VStack(alignment: .leading) {
            Text(topic.name)
                .font(.headline)
            
            if !topic.subtopics.isEmpty {
                Text("Unterthemen: \(topic.subtopics.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SubjectFormView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var colorSelection = 0
    @State private var symbolSelection = 0
    @State private var curriculumReference = ""
    
    let colors: [(name: String, color: Color)] = [
        ("Blau", .blue), ("Rot", .red), ("Grün", .green),
        ("Orange", .orange), ("Lila", .purple), ("Pink", .pink),
        ("Gelb", .yellow), ("Grau", .gray)
    ]
    
    let symbols = [
        "function", "text.book.closed", "globe", "leaf",
        "atom", "clock", "paintbrush", "desktopcomputer",
        "pencil", "ruler", "map", "waveform.path.ecg",
        "music.note", "hammer", "building.columns", "sportscourt"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Allgemeine Informationen")) {
                    TextField("Name", text: $name)
                    TextField("Lehrplanreferenz (optional)", text: $curriculumReference)
                }
                
                Section(header: Text("Farbe")) {
                    Picker("Farbe", selection: $colorSelection) {
                        ForEach(0..<colors.count, id: \.self) { index in
                            HStack {
                                Circle().fill(colors[index].color).frame(width: 20, height: 20)
                                Text(colors[index].name)
                            }.tag(index)
                        }
                    }.pickerStyle(WheelPickerStyle())
                }
                
                Section(header: Text("Symbol")) {
                    Picker("Symbol", selection: $symbolSelection) {
                        ForEach(0..<symbols.count, id: \.self) { index in
                            HStack {
                                Image(systemName: symbols[index])
                                    .foregroundColor(colors[colorSelection].color)
                                Text(symbols[index])
                            }.tag(index)
                        }
                    }.pickerStyle(WheelPickerStyle())
                }
                
                Section(header: Text("Vorschau")) {
                    HStack {
                        Image(systemName: symbols[symbolSelection])
                            .foregroundColor(colors[colorSelection].color)
                            .font(.title)
                            .frame(width: 40, height: 40)
                        Text(name.isEmpty ? "Fachname" : name)
                            .font(.headline)
                    }.padding()
                }
            }
            .navigationTitle("Neues Fach")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        // viewModel.addSubject(name, color, symbol, reference)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct TopicFormView: View {
    @Environment(\.presentationMode) var presentationMode
    let subject: Subject
    
    @State private var name = ""
    @State private var parentTopic: Topic?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Allgemeine Informationen")) {
                    TextField("Name", text: $name)
                }
                
                Section(header: Text("Übergeordnetes Thema (optional)")) {
                    Text("Übergeordnetes Thema auswählen")
                }
            }
            .navigationTitle("Neues Thema")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        // viewModel.addTopic(name, parentTopic)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    SubjectsView()
}
