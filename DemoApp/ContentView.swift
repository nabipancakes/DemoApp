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
                // Reader tabs - Simplified and intuitive
                ReaderHomeView(viewModel: viewModel)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                MyBooksView(viewModel: viewModel)
                    .tabItem {
                        Label("My Books", systemImage: "books.vertical.fill")
                    }
                
                DiscoverView()
                    .tabItem {
                        Label("Discover", systemImage: "magnifyingglass")
                    }
                
                NavigationView {
                    VStack(spacing: 24) {
                        // Support Section
                        VStack(spacing: 16) {
                            Text("Support The Book Diaries")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Help us keep the app running and improve your reading experience!")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            NavigationLink(destination: DonationView()) {
                                HStack {
                                    Image(systemName: "heart.fill")
                                    Text("Support Us")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        // Settings
                        SettingsView()
                        
                        Spacer()
                    }
                    .padding()
                    .navigationTitle("Settings")
                }
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            } else {
                // Staff-only tabs - Keep existing functionality
                BarcodeScannerView()
                    .tabItem {
                        Label("Scanner", systemImage: "barcode.viewfinder")
                    }
                
                CollectionView(viewModel: viewModel)
                    .tabItem {
                        Label("Collections", systemImage: "books.vertical")
                    }
                
                MonthlyPickEditorView()
                    .tabItem {
                        Label("Monthly Pick", systemImage: "calendar.badge.plus")
                    }
                
                SeedImporterView()
                    .tabItem {
                        Label("Seed Books", systemImage: "tray.full")
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
