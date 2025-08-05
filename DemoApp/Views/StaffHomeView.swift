//
//  StaffHomeView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 6/20/25.
//

import SwiftUI

struct StaffHomeView: View {
    @ObservedObject var viewModel: CollectionViewModel
    @ObservedObject private var calendarService = CalendarChallengeService.shared
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    @AppStorage("theme") private var selectedTheme: AppTheme = .classic
    
    @State private var showingBarcodeScanner = false
    @State private var showingMonthlyPicker = false
    @State private var showingBulkImport = false
    @State private var showingAnalytics = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Staff Welcome Header
                    StaffWelcomeHeader()
                    
                    // Quick Actions Grid
                    QuickActionsGrid()
                    
                    // Current Status Cards
                    StatusCardsSection()
                    
                    // Recent Activity
                    RecentActivitySection()
                    
                    // Analytics Preview
                    AnalyticsPreviewSection()
                }
                .padding()
            }
            .navigationTitle("Staff Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingAnalytics = true
                        } label: {
                            Label("View Analytics", systemImage: "chart.bar.fill")
                        }
                        
                        Button {
                            showingBulkImport = true
                        } label: {
                            Label("Bulk Import", systemImage: "square.and.arrow.down.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .foregroundColor(selectedTheme.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingBarcodeScanner) {
                EnhancedBarcodeScannerView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingMonthlyPicker) {
                EnhancedMonthlyPickEditor()
            }
            .sheet(isPresented: $showingBulkImport) {
                BulkImportView()
            }
            .sheet(isPresented: $showingAnalytics) {
                StaffAnalyticsView(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Staff Welcome Header
    @ViewBuilder
    private func StaffWelcomeHeader() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Staff Dashboard")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Manage books, collections, and monthly picks")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Staff badge
                VStack {
                    Image(systemName: "person.badge.key.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                    Text("STAFF")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [selectedTheme.primaryColor.opacity(0.1), selectedTheme.primaryColor.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
    
    // MARK: - Quick Actions Grid
    @ViewBuilder
    private func QuickActionsGrid() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                StaffActionCard(
                    icon: "barcode.viewfinder",
                    title: "Scan Books",
                    subtitle: "Add books via barcode",
                    color: .blue,
                    action: { showingBarcodeScanner = true }
                )
                
                StaffActionCard(
                    icon: "calendar.badge.plus",
                    title: "Monthly Pick",
                    subtitle: "Set this month's book",
                    color: .purple,
                    action: { showingMonthlyPicker = true }
                )
                
                StaffActionCard(
                    icon: "books.vertical",
                    title: "Manage Collections",
                    subtitle: "Organize book collections",
                    color: .green,
                    action: { /* Navigate to collections */ }
                )
                
                StaffActionCard(
                    icon: "tray.full",
                    title: "Seed Books",
                    subtitle: "Manage book database",
                    color: .orange,
                    action: { /* Navigate to seed books */ }
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Status Cards Section
    @ViewBuilder
    private func StatusCardsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Status")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Monthly Pick Status
                MonthlyPickStatusCard()
                
                // Collections Status
                CollectionsStatusCard(viewModel: viewModel)
                
                // Reading Activity Status
                ReadingActivityStatusCard()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Recent Activity Section
    @ViewBuilder
    private func RecentActivitySection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to full activity log
                }
                .font(.caption)
                .foregroundColor(selectedTheme.primaryColor)
            }
            
            VStack(spacing: 8) {
                StaffActivityRow(
                    icon: "plus.circle.fill",
                    title: "Added 5 books via barcode scan",
                    time: "2 hours ago",
                    color: .green
                )
                
                StaffActivityRow(
                    icon: "calendar.badge.plus",
                    title: "Updated monthly pick for December",
                    time: "1 day ago",
                    color: .blue
                )
                
                StaffActivityRow(
                    icon: "folder.badge.plus",
                    title: "Created 'Holiday Reads' collection",
                    time: "2 days ago",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Analytics Preview Section
    @ViewBuilder
    private func AnalyticsPreviewSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Analytics Overview")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View Details") {
                    showingAnalytics = true
                }
                .font(.caption)
                .foregroundColor(selectedTheme.primaryColor)
            }
            
            HStack(spacing: 16) {
                AnalyticsCard(
                    title: "Total Books",
                    value: "\(getTotalBooksCount())",
                    change: "+12 this week",
                    color: .blue
                )
                
                AnalyticsCard(
                    title: "Active Readers",
                    value: "\(readingTracker.readingLogs.count)",
                    change: "+3 this week",
                    color: .green
                )
                
                AnalyticsCard(
                    title: "Collections",
                    value: "\(viewModel.collections.count)",
                    change: "+2 this week",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Helper Functions
    private func getTotalBooksCount() -> Int {
        // This would typically come from your database
        return 150 // Placeholder
    }
}

// MARK: - Supporting Views

struct StaffActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
        .buttonStyle(PlainButtonStyle())
    }
}

struct MonthlyPickStatusCard: View {
    @ObservedObject private var calendarService = CalendarChallengeService.shared
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Monthly Pick")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let monthlyBook = calendarService.currentMonthlyBook {
                    Text("\"\(monthlyBook.title ?? "Unknown")\" is set")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("No book set for this month")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            if calendarService.currentMonthlyBook != nil {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct CollectionsStatusCard: View {
    @ObservedObject var viewModel: CollectionViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "books.vertical")
                .font(.title2)
                .foregroundColor(.purple)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Collections")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(viewModel.collections.count) collections active")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(getTotalBooksInCollections()) books")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private func getTotalBooksInCollections() -> Int {
        viewModel.collections.reduce(0) { $0 + $1.books.count }
    }
}

struct ReadingActivityStatusCard: View {
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Reading Activity")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(readingTracker.readingLogs.count) books logged by readers")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("Active")
                .font(.caption)
                .foregroundColor(.green)
                .fontWeight(.medium)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct StaffActivityRow: View {
    let icon: String
    let title: String
    let time: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let change: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
            
            Text(change)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}