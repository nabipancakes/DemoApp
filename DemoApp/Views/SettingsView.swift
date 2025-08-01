//
//  SettingsView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("role") private var userRole: UserRole = .reader
    @AppStorage("theme") private var selectedTheme: AppTheme = .classic
    @State private var showingRoleAlert = false
    @State private var showingPasswordAlert = false
    @State private var password = ""
    @State private var showingPasswordError = false
    
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
                        // TODO: Implement feedback functionality
                    }
                    .foregroundColor(.blue)
                }
                
                // Data Section
                Section(header: Text("Data")) {
                    Button("Export Reading Data") {
                        // TODO: Implement data export
                    }
                    .foregroundColor(.blue)
                    
                    Button("Clear All Data", role: .destructive) {
                        // TODO: Implement data clearing
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
                    if password == "bookiecookie123" {
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
