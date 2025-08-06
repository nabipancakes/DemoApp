//
//  CalendarChallengeView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import SwiftUI
import Combine

struct CalendarChallengeView: View {
    @ObservedObject private var calendarService = CalendarChallengeService.shared
    @State private var showingEditSheet = false
    @AppStorage("theme") private var selectedTheme: AppTheme = .classic
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if calendarService.isLoading {
                        ProgressView("Loading monthly challenge...")
                            .padding()
                    } else if let monthlyBook = calendarService.currentMonthlyBook {
                        MonthlyBookCard(monthlyBook: monthlyBook)
                    } else {
                        EmptyMonthlyBookView()
                    }
                    
                    if calendarService.hasCurrentMonthlyBook {
                        ReadingProgressView()
                    }
                }
                .padding()
            }
            .navigationTitle("Monthly Challenge")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditSheet = true
                    }
                    .foregroundColor(selectedTheme.primaryColor)
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                EditMonthlyBookView()
            }
        }
    }
}

struct MonthlyBookCard: View {
    let monthlyBook: MonthlyBook
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(monthlyBook.month ?? "Unknown Month")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(monthlyBook.title ?? "Unknown Title")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("by \(monthlyBook.author ?? "Unknown Author")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Create a temporary Book object for the cover view
                BookCoverView(
                    book: Book(
                        id: UUID().uuidString,
                        title: monthlyBook.title ?? "Unknown Title",
                        authors: [monthlyBook.author ?? "Unknown Author"],
                        description: monthlyBook.bookDescription,
                        thumbnail: monthlyBook.coverURL,
                        pageCount: nil,
                        categories: nil,
                        price: nil,
                        ageRange: nil
                    ),
                    width: 80,
                    height: 120
                )
            }
            
            if let description = monthlyBook.bookDescription, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            HStack {
                Button("Mark as Read") {
                    let book = Book(
                        id: monthlyBook.id?.uuidString ?? UUID().uuidString,
                        title: monthlyBook.title ?? "Unknown",
                        authors: [monthlyBook.author ?? "Unknown"],
                        description: monthlyBook.bookDescription,
                        thumbnail: monthlyBook.coverURL,
                        pageCount: nil,
                        categories: nil,
                        price: nil,
                        ageRange: nil
                    )
                    ReadingTrackerService.shared.addReadingLog(for: book)
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
                
                Button("Learn More") {
                    // Navigate to book detail
                    // For now, we'll just show an alert with book info
                    // TODO: Implement proper navigation to BookDetailView
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

struct EmptyMonthlyBookView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("No Monthly Challenge Set")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Staff can set a monthly reading challenge for the community.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct ReadingProgressView: View {
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Progress")
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
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct EditMonthlyBookView: View {
    @ObservedObject private var calendarService = CalendarChallengeService.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var author = ""
    @State private var coverURL = ""
    @State private var description = ""
    @State private var showingScanner = false
    @State private var scannedBook: PaperAndInk.Book?
    
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
                
                Section(header: Text("Scan Book")) {
                    Button("Scan Barcode") {
                        showingScanner = true
                    }
                    .foregroundColor(.blue)
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
                    
                    if calendarService.hasCurrentMonthlyBook {
                        Button("Delete Current Book", role: .destructive) {
                            calendarService.deleteCurrentMonthlyBook()
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Edit Monthly Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                ScannerView(scannedCode: .constant(""), onScan: handleScannedCode)
            }
            .onAppear {
                if let monthlyBook = calendarService.currentMonthlyBook {
                    title = monthlyBook.title ?? ""
                    author = monthlyBook.author ?? ""
                    coverURL = monthlyBook.coverURL ?? ""
                    description = monthlyBook.bookDescription ?? ""
                }
            }
            .onChange(of: scannedBook) { _, book in
                if let book = book {
                    title = book.title
                    author = book.authors.joined(separator: ", ")
                    coverURL = book.thumbnail ?? ""
                    description = book.description ?? ""
                }
            }
        }
    }
    
    private func handleScannedCode(_ code: String) {
        // Look up book using OpenLibrary API
        OpenLibraryService.shared.fetchBookByISBN(code)
            .receive(on: DispatchQueue.main)
            .sink { book in
                if let book = book {
                    scannedBook = book
                } else {
                    // Try Google Books API as fallback
                    BookAPI.fetchBookInfo(isbn: code) { fetchedBook in
                        if let fetchedBook = fetchedBook {
                            scannedBook = fetchedBook
                        }
                    }
                }
            }
            .store(in: &OpenLibraryService.shared.cancellables)
    }
} 