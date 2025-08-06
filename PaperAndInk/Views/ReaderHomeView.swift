//
//  ReaderHomeView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 6/20/25.
//

import SwiftUI

struct ReaderHomeView: View {
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    @ObservedObject private var dailyBookService = DailyBookService.shared
    @ObservedObject var viewModel: CollectionViewModel
    @AppStorage("readingGoal") private var readingGoal: Int = 10
    @AppStorage("theme") private var selectedTheme: AppTheme = .classic
    @State private var showingAddLog = false
    @State private var showingGoalEditor = false
    @State private var selectedTab = 0 // For tab navigation
    @State private var showingDonation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Header
                    WelcomeHeaderView()
                    
                    // Reading Progress Card
                    ReadingProgressCard()
                    

                    
                    // Quick Actions
                    QuickActionsSection()
                    
                    // Recent Activity
                    RecentActivitySection()
                }
                .padding()
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddLog = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(selectedTheme.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddLog) {
                AddReadingLogView()
            }
            .sheet(isPresented: $showingGoalEditor) {
                GoalEditorView(currentGoal: $readingGoal)
            }
        }
    }
    
    // MARK: - Welcome Header
    @ViewBuilder
    private func WelcomeHeaderView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Good \(timeOfDayGreeting())!")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text("Ready to dive into a book?")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                // Reading streak or motivational element
                VStack {
                    Image(systemName: "flame.fill")
                        .font(.title)
                        .foregroundColor(.orange)
                    Text("\(readingTracker.readingLogs.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("books read")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(selectedTheme.backgroundColor.opacity(0.5))
        .cornerRadius(16)
    }
    
    // MARK: - Reading Progress Card
    @ViewBuilder
    private func ReadingProgressCard() -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Reading Goal Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    showingGoalEditor = true
                } label: {
                    Text("Edit Goal")
                        .font(.caption)
                        .foregroundColor(selectedTheme.primaryColor)
                }
            }
            
            // Progress Ring
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: readingTracker.progressPercent)
                        .stroke(selectedTheme.primaryColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: readingTracker.progressPercent)
                    
                    VStack {
                        Text("\(readingTracker.totalReadCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("of \(readingGoal)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(Int(readingTracker.progressPercent * 100))% Complete")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(max(0, readingGoal - readingTracker.totalReadCount)) books to go!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if readingTracker.progressPercent >= 1.0 {
                        Text("🎉 Goal achieved!")
                            .font(.caption)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Today's Book Section
    @ViewBuilder
    private func TodaysBookSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Pick")
                .font(.headline)
                .fontWeight(.semibold)
            
            if dailyBookService.isLoading {
                ProgressView("Loading today's book...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if let dailyBook = dailyBookService.dailyBook {
                CompactBookCard(
                    book: dailyBook,
                    isRead: readingTracker.isBookRead(dailyBook),
                    onMarkAsRead: {
                        readingTracker.addReadingLog(for: dailyBook)
                    }
                )
            } else {
                Text("No daily pick available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Quick Actions
    @ViewBuilder
    private func QuickActionsSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                QuickActionButton(
                    icon: "plus.circle.fill",
                    title: "Log a Book",
                    subtitle: "Mark a book as read",
                    color: .blue
                ) {
                    showingAddLog = true
                }
                
                NavigationLink(destination: MyBooksView(viewModel: viewModel)) {
                    QuickActionCard(
                        icon: "books.vertical.fill",
                        title: "My Collections",
                        subtitle: "Organize your books",
                        color: .purple
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                QuickActionButton(
                    icon: "target",
                    title: "Update Goal",
                    subtitle: "Change reading target",
                    color: .green
                ) {
                    showingGoalEditor = true
                }
                
                NavigationLink(destination: DonationView()) {
                    QuickActionCard(
                        icon: "heart.fill",
                        title: "Support Us",
                        subtitle: "Help keep the app running",
                        color: .red
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Recent Activity
    @ViewBuilder
    private func RecentActivitySection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("View All in My Books →")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            if readingTracker.readingLogs.isEmpty {
                Text("No books logged yet. Start by adding your first book!")
                    .foregroundColor(.secondary)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(Array(readingTracker.readingLogs.prefix(3).enumerated()), id: \.element.id) { index, log in
                        RecentActivityRow(log: log)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Helper Functions
    private func timeOfDayGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "morning"
        case 12..<17: return "afternoon"
        default: return "evening"
        }
    }
}

// MARK: - Supporting Views

struct CompactBookCard: View {
    let book: Book
    let isRead: Bool
    let onMarkAsRead: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            BookCoverView(book: book, width: 60, height: 80)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text("by \(book.authors.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if let pageCount = book.pageCount {
                    Text("\(pageCount) pages")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if isRead {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    Text("Read")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            } else {
                Button("Mark Read") {
                    onMarkAsRead()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.mini)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct RecentActivityRow: View {
    let log: ReadingLog
    
    var body: some View {
        HStack(spacing: 12) {
            if let coreDataBook = log.book {
                BookCoverView(book: coreDataBook.toBook(), width: 30, height: 40)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 30, height: 40)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(log.book?.toBook().title ?? "Unknown Book")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if let dateFinished = log.dateFinished {
                    Text(dateFinished, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

struct GoalEditorView: View {
    @Binding var currentGoal: Int
    @Environment(\.dismiss) var dismiss
    @State private var newGoal: Int
    
    init(currentGoal: Binding<Int>) {
        self._currentGoal = currentGoal
        self._newGoal = State(initialValue: currentGoal.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Set Your Reading Goal")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("How many books would you like to read?")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    Text("\(newGoal)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Text("books")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                Stepper("", value: $newGoal, in: 1...100)
                    .labelsHidden()
                
                Spacer()
                
                Button("Save Goal") {
                    currentGoal = newGoal
                    ReadingTrackerService.shared.updateReadingGoal(newGoal)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .navigationTitle("Reading Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}