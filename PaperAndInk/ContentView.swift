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
                // Staff tabs - Enhanced and organized
                StaffHomeView(viewModel: viewModel)
                    .tabItem {
                        Label("Dashboard", systemImage: "house.fill")
                    }
                
                EnhancedBarcodeScannerView(viewModel: viewModel)
                    .tabItem {
                        Label("Scanner", systemImage: "barcode.viewfinder")
                    }
                
                CollectionView(viewModel: viewModel)
                    .tabItem {
                        Label("Collections", systemImage: "books.vertical")
                    }
                
                NavigationView {
                    VStack(spacing: 24) {
                        // Quick actions for staff
                        VStack(spacing: 16) {
                            Text("Management Tools")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                                NavigationLink(destination: MonthlyPickEditorView()) {
                                    StaffToolCard(
                                        icon: "calendar.badge.plus",
                                        title: "Monthly Pick",
                                        subtitle: "Set featured book",
                                        color: .purple
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                NavigationLink(destination: SeedImporterView()) {
                                    StaffToolCard(
                                        icon: "tray.full",
                                        title: "Seed Books",
                                        subtitle: "Manage database",
                                        color: .orange
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                NavigationLink(destination: StaffAnalyticsView(viewModel: viewModel)) {
                                    StaffToolCard(
                                        icon: "chart.bar.fill",
                                        title: "Analytics",
                                        subtitle: "View insights",
                                        color: .blue
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                NavigationLink(destination: BulkImportView()) {
                                    StaffToolCard(
                                        icon: "square.and.arrow.down.fill",
                                        title: "Bulk Import",
                                        subtitle: "Import books",
                                        color: .green
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
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
                    .navigationTitle("Tools")
                }
                .tabItem {
                    Label("Tools", systemImage: "wrench.and.screwdriver.fill")
                }
            }
        }
        .accentColor(selectedTheme.accentColor)
        .preferredColorScheme(selectedTheme.colorScheme)
        .background(selectedTheme.backgroundColor)
    }
}

// MARK: - Staff Tool Card
struct StaffToolCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
