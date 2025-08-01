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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Log") {
                        showingAddLog = true
                    }
                }
            }
            .sheet(isPresented: $showingAddLog) {
                AddReadingLogView()
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
                    Text("\(dailyBookService.totalSeedBooksCount)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Total Books")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(Int(readingTracker.progressPercent * 100))%")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ProgressView(value: readingTracker.progressPercent)
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
                Text(readingLog.book?.title ?? "Unknown Book")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("by \(readingLog.book?.authors?.joined(separator: ", ") ?? "Unknown Author")")
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

struct AddReadingLogView: View {
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    @ObservedObject private var dailyBookService = DailyBookService.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedBook: DemoApp.Book?
    @State private var dateFinished = Date()
    @State private var notes = ""
    @State private var showingBookPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Book")) {
                    if let selectedBook = selectedBook {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(selectedBook.title)
                                    .font(.headline)
                                Text("by \(selectedBook.authors.joined(separator: ", "))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("Change") {
                                showingBookPicker = true
                            }
                            .font(.caption)
                        }
                    } else {
                        Button("Select Book") {
                            showingBookPicker = true
                        }
                    }
                }
                
                Section(header: Text("Details")) {
                    DatePicker("Date Finished", selection: $dateFinished, displayedComponents: .date)
                    
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Button("Add Reading Log") {
                        if let book = selectedBook {
                            readingTracker.addReadingLog(for: book, dateFinished: dateFinished, notes: notes.isEmpty ? nil : notes)
                            dismiss()
                        }
                    }
                    .disabled(selectedBook == nil)
                }
            }
            .navigationTitle("Add Reading Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingBookPicker) {
                BookPickerView(selectedBook: $selectedBook)
            }
        }
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