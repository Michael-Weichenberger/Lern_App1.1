import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var userSettings: UserSettings
    @State private var currentPage = 0
    @State private var userName = ""
    @State private var userAge = ""
    @State private var learningPreferences = LearningPreferences()
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                // Welcome page
                VStack(spacing: 20) {
                    Image(systemName: "graduationcap.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text("Willkommen bei LernApp!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Dein persönlicher Lernbegleiter für die Schule")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Scanne deine Schuldokumente, erstelle personalisierte Lernpläne und verwalte deine Prüfungstermine - alles in einer App!")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .tag(0)
                
                // Profile setup
                VStack(spacing: 20) {
                    Text("Erzähl uns etwas über dich")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    TextField("Dein Name", text: $userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    TextField("Dein Alter", text: $userAge)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .padding(.horizontal)
                    
                    Text("Diese Informationen helfen uns, deinen Lernplan zu personalisieren")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .tag(1)
                
                // Learning preferences
                VStack(spacing: 20) {
                    Text("Wie lernst du am besten?")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading) {
                        Text("Visueller Lerntyp")
                            .font(.headline)
                        Slider(value: $learningPreferences.visualLearner, in: 0...1)
                        Text("Ich lerne gut durch Bilder, Diagramme und Videos")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Auditiver Lerntyp")
                            .font(.headline)
                        Slider(value: $learningPreferences.auditoryLearner, in: 0...1)
                        Text("Ich lerne gut durch Hören und Gespräche")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Kinästhetischer Lerntyp")
                            .font(.headline)
                        Slider(value: $learningPreferences.kinestheticLearner, in: 0...1)
                        Text("Ich lerne gut durch praktisches Tun und Bewegung")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                }
                .tag(2)
                
                // Learning time preferences
                VStack(spacing: 20) {
                    Text("Wann lernst du am liebsten?")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading) {
                        Text("Morgenlerner")
                            .font(.headline)
                        Slider(value: $learningPreferences.morningLearner, in: 0...1)
                        Text("Ich lerne gut am Morgen")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Abendlerner")
                            .font(.headline)
                        Slider(value: $learningPreferences.eveningLearner, in: 0...1)
                        Text("Ich lerne gut am Abend")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    Picker("Bevorzugte Lerndauer", selection: $learningPreferences.preferredSessionLength) {
                        Text("15 Minuten").tag(15 * 60.0)
                        Text("30 Minuten").tag(30 * 60.0)
                        Text("45 Minuten").tag(45 * 60.0)
                        Text("60 Minuten").tag(60 * 60.0)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                .tag(3)
                
                // Final page
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green)
                    
                    Text("Alles bereit!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Dein persönlicher Lernplan wird jetzt erstellt")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        if let age = Int(userAge) {
                            userSettings.completeOnboarding(
                                name: userName,
                                age: age,
                                preferences: learningPreferences
                            )
                        }
                    }) {
                        Text("Los geht's!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .tag(4)
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            HStack {
                Button(action: {
                    if currentPage > 0 {
                        currentPage -= 1
                    }
                }) {
                    Text("Zurück")
                        .opacity(currentPage > 0 ? 1 : 0)
                }
                
                Spacer()
                
                Button(action: {
                    if currentPage < 4 {
                        currentPage += 1
                    }
                }) {
                    Text("Weiter")
                        .opacity(currentPage < 4 ? 1 : 0)
                }
            }
            .padding()
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(UserSettings())
    }
}
