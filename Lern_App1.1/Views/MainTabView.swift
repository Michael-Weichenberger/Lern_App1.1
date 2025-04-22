import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
            
            DocumentScannerView()
                .tabItem {
                    Label("Scannen", systemImage: "doc.text.viewfinder")
                }
            
            LearningPlanView()
                .tabItem {
                    Label("Lernplan", systemImage: "book.fill")
                }
            
            ExamsView()
                .tabItem {
                    Label("Prüfungen", systemImage: "calendar")
                }
            
            SubjectsView()
                .tabItem {
                    Label("Fächer", systemImage: "folder.fill")
                }
        }
        .accentColor(Color("PrimaryColor"))
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(UserSettings())
    }
}
