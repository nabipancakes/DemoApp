//
//  SettingsView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @AppStorage("role") private var userRole: UserRole = .reader
    @AppStorage("theme") private var selectedTheme: AppTheme = .classic
    @State private var showingRoleAlert = false
    @State private var showingPasswordAlert = false
    @State private var password = ""
    @State private var showingPasswordError = false
    @State private var showingShareSheet = false
    @State private var csvFileURL: URL?
    
    var body: some View {
        NavigationView {
            Form {
                // User Role Section
                Section(header: Text("User Role")) {
                    HStack {
                        Label("Current Role", systemImage: "person.circle")
                        Spacer()
                        Text(userRole.displayName)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Switch Role") {
                        showingRoleAlert = true
                    }
                    .foregroundColor(.blue)
                }
                
                // Theme Section
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    ThemePreviewView(theme: selectedTheme)
                }
                
                // App Info Section
                Section(header: Text("App Information")) {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Build", systemImage: "hammer")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Support Section
                Section(header: Text("Support")) {
                    NavigationLink(destination: DonationView()) {
                        Label("Support Us", systemImage: "heart")
                    }
                    
                    Button("Send Feedback") {
                        if let url = URL(string: "mailto:info.thebookdiaries@gmail.com?subject=App%20Feedback") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                // Data Section
                Section(header: Text("Data")) {
                    Button("Export Reading Data") {
                        exportReadingData()
                    }
                    .foregroundColor(.blue)
                    
                    Button("Clear All Data", role: .destructive) {
                        clearAllData()
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Switch User Role", isPresented: $showingRoleAlert) {
                Button("Reader") {
                    userRole = .reader
                }
                Button("Staff") {
                    showingPasswordAlert = true
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Select your role to access different features.")
            }
            .alert("Staff Access", isPresented: $showingPasswordAlert) {
                SecureField("Enter password", text: $password)
                Button("Submit") {
                    if password == "hello" {
                        userRole = .staff
                        password = ""
                    } else {
                        showingPasswordError = true
                        password = ""
                    }
                }
                Button("Cancel", role: .cancel) {
                    password = ""
                }
            } message: {
                Text("Enter the staff password to switch to Staff role.")
            }
            .alert("Incorrect Password", isPresented: $showingPasswordError) {
                Button("OK") { }
            } message: {
                Text("The password you entered is incorrect. Please try again.")
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = csvFileURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }
    
    private func exportReadingData() {
        let readingTracker = ReadingTrackerService.shared
        let logs = readingTracker.readingLogs
        
        var csvContent = "Title,Author,Date Finished,Notes\n"
        
        for log in logs {
            let title = log.book?.title ?? "Unknown"
            let author = log.book?.authors?.joined(separator: ", ") ?? "Unknown"
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            let date = log.dateFinished.map { dateFormatter.string(from: $0) } ?? "Unknown"
            let notes = log.notes ?? ""
            
            csvContent += "\"\(title)\",\"\(author)\",\"\(date)\",\"\(notes)\"\n"
        }
        
        // Create a temporary file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("reading_data.csv")
        
        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            csvFileURL = tempURL
            showingShareSheet = true
        } catch {
            print("Error exporting data: \(error)")
        }
    }
    
    private func clearAllData() {
        let coreDataManager = CoreDataManager.shared
        
        // Clear all reading logs
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ReadingLog.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coreDataManager.context.execute(deleteRequest)
            try coreDataManager.context.save()
            
            // Refresh reading tracker
            ReadingTrackerService.shared.loadReadingLogs()
        } catch {
            print("Error clearing data: \(error)")
        }
    }
}

struct ThemePreviewView: View {
    let theme: AppTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preview")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(theme.primaryColor)
                    .frame(width: 20, height: 20)
                
                Text("Primary Color")
                    .font(.caption)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(theme.accentColor)
                    .frame(width: 20, height: 20)
                
                Text("Accent Color")
                    .font(.caption)
            }
            
            Text("This theme will be applied throughout the app.")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheet>) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareSheet>) {}
}
