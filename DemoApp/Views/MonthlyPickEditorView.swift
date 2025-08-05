//
//  MonthlyPickEditorView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import SwiftUI

struct MonthlyPickEditorView: View {
    @ObservedObject private var calendarService = CalendarChallengeService.shared
    @State private var showingAddBook = false
    @State private var selectedMonth = ""
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    
    private let months = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Current Monthly Book
                if let currentBook = calendarService.currentMonthlyBook {
                    CurrentMonthlyBookCard(monthlyBook: currentBook)
                } else {
                    EmptyMonthlyBookCard()
                }
                
                // Month/Year Selector
                MonthYearSelectorView(
                    selectedMonth: $selectedMonth,
                    selectedYear: $selectedYear,
                    months: months
                )
                
                // Historical Picks
                HistoricalPicksView()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Monthly Pick Editor")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Book") {
                        showingAddBook = true
                    }
                }
            }
            .sheet(isPresented: $showingAddBook) {
                AddMonthlyBookView(
                    selectedMonth: selectedMonth.isEmpty ? months[Calendar.current.component(.month, from: Date()) - 1] : selectedMonth,
                    selectedYear: selectedYear
                )
            }
        }
    }
}

struct CurrentMonthlyBookCard: View {
    let monthlyBook: MonthlyBook
    @ObservedObject private var calendarService = CalendarChallengeService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Current Monthly Pick")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(monthlyBook.title ?? "Unknown Title")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("by \(monthlyBook.author ?? "Unknown Author")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(monthlyBook.month ?? "Unknown") \(String(monthlyBook.year))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let coverURL = monthlyBook.coverURL, !coverURL.isEmpty {
                    AsyncImage(url: URL(string: coverURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Image(systemName: "book.closed")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
                    .frame(width: 80, height: 120)
                    .cornerRadius(8)
                } else {
                    Image(systemName: "book.closed")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                        .frame(width: 80, height: 120)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            if let description = monthlyBook.bookDescription, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            HStack {
                Button("Edit") {
                    // TODO: Navigate to edit view
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Delete", role: .destructive) {
                    calendarService.deleteCurrentMonthlyBook()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct EmptyMonthlyBookCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("No Monthly Pick Set")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add a book for the current month to start the reading challenge.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct MonthYearSelectorView: View {
    @Binding var selectedMonth: String
    @Binding var selectedYear: Int
    let months: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Month/Year")
                .font(.headline)
            
            HStack {
                Picker("Month", selection: $selectedMonth) {
                    ForEach(months, id: \.self) { month in
                        Text(month).tag(month)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Spacer()
                
                Picker("Year", selection: $selectedYear) {
                    ForEach(2020...2030, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct HistoricalPicksView: View {
    @StateObject private var coreDataManager = CoreDataManager.shared
    @State private var historicalBooks: [MonthlyBook] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Historical Picks")
                .font(.headline)
            
            if historicalBooks.isEmpty {
                Text("No historical picks available")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(historicalBooks, id: \.id) { book in
                            HistoricalBookCard(monthlyBook: book)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            loadHistoricalBooks()
        }
    }
    
    private func loadHistoricalBooks() {
        // TODO: Implement loading historical books from Core Data
        // For now, this is a placeholder
    }
}

struct HistoricalBookCard: View {
    let monthlyBook: MonthlyBook
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let coverURL = monthlyBook.coverURL, !coverURL.isEmpty {
                AsyncImage(url: URL(string: coverURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Image(systemName: "book.closed")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                }
                .frame(width: 60, height: 90)
                .cornerRadius(6)
            } else {
                Image(systemName: "book.closed")
                    .font(.system(size: 30))
                    .foregroundColor(.gray)
                    .frame(width: 60, height: 90)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(monthlyBook.title ?? "Unknown")
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text("\(monthlyBook.month ?? "Unknown") \(String(monthlyBook.year))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 80)
    }
}

struct AddMonthlyBookView: View {
    let selectedMonth: String
    let selectedYear: Int
    @ObservedObject private var calendarService = CalendarChallengeService.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var author = ""
    @State private var coverURL = ""
    @State private var description = ""
    @State private var month = ""
    @State private var year = 2025
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Book Details")) {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("Cover URL (optional)", text: $coverURL)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Month/Year")) {
                    HStack {
                        Text("Month")
                        Spacer()
                        Text(month.isEmpty ? selectedMonth : month)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Year")
                        Spacer()
                        Text("\(year)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("Save Monthly Book") {
                        calendarService.setMonthlyBook(
                            title: title,
                            author: author,
                            coverURL: coverURL.isEmpty ? nil : coverURL,
                            description: description.isEmpty ? nil : description
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty || author.isEmpty)
                }
            }
            .navigationTitle("Add Monthly Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                month = selectedMonth
                year = selectedYear
            }
        }
    }
} 