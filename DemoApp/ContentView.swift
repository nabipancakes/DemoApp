//
//  ContentView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/14/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: CollectionViewModel
    @AppStorage("role") private var userRole: UserRole = .reader
    @AppStorage("theme") private var selectedTheme: AppTheme = .classic
    
    var body: some View {
        TabView {
            if userRole.isReader {
                // Reader-only tabs
                CalendarChallengeView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                
                DailyBookView()
                    .tabItem {
                        Label("Daily Pick", systemImage: "book.closed")
                    }
                
                ReadingTrackerView()
                    .tabItem {
                        Label("Tracker", systemImage: "chart.bar")
                    }
                
                DonationView()
                    .tabItem {
                        Label("Donate", systemImage: "heart")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            } else {
                // Staff-only tabs
                BarcodeScannerView()
                    .tabItem {
                        Label("Scanner", systemImage: "barcode.viewfinder")
                    }
                
                MonthlyPickEditorView()
                    .tabItem {
                        Label("Monthly Pick", systemImage: "calendar.badge.plus")
                    }
                
                SeedImporterView()
                    .tabItem {
                        Label("Seed Books", systemImage: "books.vertical")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
        .accentColor(selectedTheme.accentColor)
        .preferredColorScheme(selectedTheme.colorScheme)
        .background(selectedTheme.backgroundColor)
    }
}
