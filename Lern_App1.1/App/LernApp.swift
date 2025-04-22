import SwiftUI

@main
struct LernApp: App {
    @StateObject private var userSettings = UserSettings()

    var body: some Scene {
        WindowGroup {
            if userSettings.isFirstLaunch {
                OnboardingView()
                    .environmentObject(userSettings)
            } else {
                MainTabView()
                    .environmentObject(userSettings)
            }
        }
    }
}

class UserSettings: ObservableObject {
    @Published var isFirstLaunch: Bool {
        didSet {
            UserDefaults.standard.set(isFirstLaunch, forKey: "isFirstLaunch")
        }
    }

    @Published var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: "userName")
        }
    }

    @Published var userAge: Int {
        didSet {
            UserDefaults.standard.set(userAge, forKey: "userAge")
        }
    }

    @Published var learningPreferences: LearningPreferences {
        didSet {
            saveLearningPreferences()
        }
    }

    init() {
        self.isFirstLaunch = UserDefaults.standard.object(forKey: "isFirstLaunch") as? Bool ?? true
        self.userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        self.userAge = UserDefaults.standard.integer(forKey: "userAge")
        self.learningPreferences = UserSettings.loadLearningPreferences()
    }

    func completeOnboarding(name: String, age: Int, preferences: LearningPreferences) {
        self.userName = name
        self.userAge = age
        self.learningPreferences = preferences
        self.isFirstLaunch = false
    }

    private func saveLearningPreferences() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(learningPreferences) {
            UserDefaults.standard.set(data, forKey: "learningPreferences")
        }
    }


    private static func loadLearningPreferences() -> LearningPreferences {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: "learningPreferences"),
           let prefs = try? decoder.decode(LearningPreferences.self, from: data) {
            return prefs
        } else {
            return LearningPreferences()
        }
    }
}
