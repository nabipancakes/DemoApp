//
//  ReadingTrackerView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import SwiftUI

struct ReadingTrackerView: View {
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    @State private var showingAddLog = false
    @State private var selectedTimeFilter: TimeFilter = .allTime
    @AppStorage("readingGoal") private var readingGoal: Int = 10
    @State private var showingGoalEditor = false
    
    enum TimeFilter: String, CaseIterable {
        case allTime = "All Time"
        case thisYear = "This Year"
        case thisMonth = "This Month"
        
        var displayName: String {
            return rawValue
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Progress Overview
                    ProgressOverviewCard()
                    
                    // Time Filter
                    Picker("Time Filter", selection: $selectedTimeFilter) {
                        ForEach(TimeFilter.allCases, id: \.self) { filter in
                            Text(filter.displayName).tag(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Reading Logs
                    ReadingLogsList(timeFilter: selectedTimeFilter)
                }
                .padding()
            }
            .navigationTitle("Reading Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Goal") {
                        showingGoalEditor = true
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Log") {
                        showingAddLog = true
                    }
                }
            }
            .sheet(isPresented: $showingAddLog) {
                AddReadingLogView()
            }
            .sheet(isPresented: $showingGoalEditor) {
                ReadingGoalEditorView(readingGoal: $readingGoal)
            }
            .refreshable {
                readingTracker.loadReadingLogs()
            }
        }
    }
}

struct ProgressOverviewCard: View {
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    @ObservedObject private var dailyBookService = DailyBookService.shared
    @AppStorage("readingGoal") private var readingGoal: Int = 10
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Reading Progress")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(readingTracker.totalReadCount)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Books Read")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("\(readingGoal)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Goal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(Int(min(Double(readingTracker.totalReadCount) / Double(readingGoal), 1.0) * 100))%")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ProgressView(value: min(Double(readingTracker.totalReadCount) / Double(readingGoal), 1.0))
                .progressViewStyle(LinearProgressViewStyle())
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(readingTracker.getBooksReadThisMonth().count)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("This Month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("\(readingTracker.getBooksReadThisYear().count)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("This Year")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(readingTracker.recentReads.count)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Recent")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ReadingLogsList: View {
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    let timeFilter: ReadingTrackerView.TimeFilter
    
    var filteredLogs: [ReadingLog] {
        switch timeFilter {
        case .allTime:
            return readingTracker.readingLogs
        case .thisYear:
            return readingTracker.getBooksReadThisYear()
        case .thisMonth:
            return readingTracker.getBooksReadThisMonth()
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reading Logs")
                .font(.headline)
            
            if filteredLogs.isEmpty {
                EmptyReadingLogsView()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(filteredLogs, id: \.id) { log in
                        ReadingLogRow(readingLog: log)
                    }
                }
            }
        }
    }
}

struct ReadingLogRow: View {
    let readingLog: ReadingLog
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(readingLog.book?.toBook().title ?? "Unknown Book")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("by \(readingLog.book?.toBook().authors.joined(separator: ", ") ?? "Unknown Author")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let notes = readingLog.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if let dateFinished = readingLog.dateFinished {
                    Text(dateFinished, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button("Remove") {
                    readingTracker.removeReadingLog(readingLog)
                }
                .font(.caption)
                .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

struct EmptyReadingLogsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No Reading Logs")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Start reading books to track your progress!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}



struct BookPickerView: View {
    @Binding var selectedBook: DemoApp.Book?
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var dailyBookService = DailyBookService.shared
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dailyBookService.seedBooks, id: \.id) { book in
                    Button {
                        selectedBook = book
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(book.title)
                                    .font(.headline)
                                Text("by \(book.authors.joined(separator: ", "))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Select Book")
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

struct ReadingGoalEditorView: View {
    @Binding var readingGoal: Int
    @Environment(\.dismiss) var dismiss
    @State private var tempGoal: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Reading Goal")) {
                    TextField("Number of books", text: $tempGoal)
                        .keyboardType(.numberPad)
                        .onAppear {
                            tempGoal = String(readingGoal)
                        }
                }
                
                Section(header: Text("Goal Types")) {
                    Button("10 books (Monthly)") {
                        readingGoal = 10
                        dismiss()
                    }
                    
                    Button("25 books (Quarterly)") {
                        readingGoal = 25
                        dismiss()
                    }
                    
                    Button("50 books (Semi-annual)") {
                        readingGoal = 50
                        dismiss()
                    }
                    
                    Button("100 books (Annual)") {
                        readingGoal = 100
                        dismiss()
                    }
                }
                
                Section {
                    Button("Save Custom Goal") {
                        if let goal = Int(tempGoal), goal > 0 {
                            readingGoal = goal
                            dismiss()
                        }
                    }
                    .disabled(Int(tempGoal) == nil || Int(tempGoal) ?? 0 <= 0)
                }
            }
            .navigationTitle("Set Reading Goal")
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