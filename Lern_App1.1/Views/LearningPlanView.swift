//
//  LearningPlanView.swift
//  Lern_App1.1
//
//  Created by Kasi Weichenberger on 13.04.25.
//

import SwiftUI

struct LearningPlanView: View {
    @StateObject private var viewModel = LearningPlanViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Lernplan-Übersicht
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Dein aktueller Lernplan")
                            .font(.headline)
                        
                        if let currentPlan = viewModel.currentPlan {
                            planOverview(for: currentPlan)
                        } else {
                            createPlanSection
                        }
                    }
                    .padding(.horizontal)
                    
                    // Anstehende Lernsitzungen
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Anstehende Lernsitzungen")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if viewModel.upcomingSessions.isEmpty {
                            Text("Keine anstehenden Lernsitzungen")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .padding(.horizontal)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.upcomingSessions) { session in
                                        sessionCard(for: session)
                                            .frame(width: 280)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Abgeschlossene Lernsitzungen
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Abgeschlossene Lernsitzungen")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if viewModel.completedSessions.isEmpty {
                            Text("Keine abgeschlossenen Lernsitzungen")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .padding(.horizontal)
                        } else {
                            ForEach(viewModel.completedSessions.prefix(3)) { session in
                                completedSessionRow(for: session)
                                    .padding(.horizontal)
                            }
                            
                            if viewModel.completedSessions.count > 3 {
                                Button(action: {
                                    // Zeige alle abgeschlossenen Sitzungen
                                }) {
                                    Text("Alle abgeschlossenen Sitzungen anzeigen")
                                        .font(.subheadline)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    
                    // Lernfortschritt
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Dein Lernfortschritt")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Gesamtfortschritt")
                                Spacer()
                                Text("\(Int(viewModel.learningProgress * 100))%")
                            }
                            
                            ProgressView(value: viewModel.learningProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .accentColor(.blue)
                            
                            if let currentPlan = viewModel.currentPlan, let exam = currentPlan.exam {
                                Text("Prüfung: \(exam.title) am \(exam.date, style: .date)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Lernplan")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Öffne Lernplan-Einstellungen
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
    
    private var createPlanSection: some View {
        VStack(alignment: .center, spacing: 16) {
            Image(systemName: "book.closed")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
            
            Text("Noch kein Lernplan erstellt")
                .font(.headline)
            
            Text("Erstelle einen personalisierten Lernplan für deine nächste Prüfung")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                // Öffne Lernplan-Erstellung
            }) {
                Text("Lernplan erstellen")
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
    
    private func planOverview(for plan: LearningPlan) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(plan.subject.color)
                    .frame(width: 12, height: 12)
                
                Text(plan.subject.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if let exam = plan.exam {
                    Text("Bis: \(exam.date, style: .date)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            ProgressView(value: viewModel.learningProgress)
                .progressViewStyle(LinearProgressViewStyle())
                .accentColor(.blue)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Sitzungen")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(plan.sessions.filter { $0.isCompleted }.count)/\(plan.sessions.count)")
                        .font(.headline)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Nächste Sitzung")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let nextSession = viewModel.upcomingSessions.first {
                        Text(nextSession.date, style: .date)
                            .font(.headline)
                    } else {
                        Text("Keine")
                            .font(.headline)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Anpassungen")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(plan.adaptationHistory.count)")
                        .font(.headline)
                }
            }
            
            if !plan.adaptationHistory.isEmpty, let lastAdaptation = plan.adaptationHistory.last {
                Text("Letzte Anpassung: \(lastAdaptation.description)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private func sessionCard(for session: LearningSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(session.date, style: .date)
                    .font(.headline)
                
                Spacer()
                
                Text(session.date, style: .time)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            Text("Themen:")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ForEach(session.topics) { topic in
                HStack {
                    Circle()
                        .fill(topic.subject?.color ?? Color.gray)
                        .frame(width: 8, height: 8)
                    
                    Text(topic.name)
                        .font(.caption)
                }
            }
            
            Divider()
            
            Text("Dauer: \(Int(session.duration / 60)) Minuten")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: {
                // Öffne Sitzungsdetails
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
    
    private func completedSessionRow(for session: LearningSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.date, style: .date)
                    .font(.subheadline)
                
                Text(session.topics.map { $0.name }.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let performance = session.performance {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(performance.correctAnswers)/\(performance.totalQuestions)")
                        .font(.headline)
                    
                    Text("\(Int(performance.timeSpent / 60)) Minuten")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    LearningPlanView()
}
