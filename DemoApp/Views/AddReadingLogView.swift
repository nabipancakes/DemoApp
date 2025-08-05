//
//  AddReadingLogView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 6/20/25.
//

import SwiftUI

struct AddReadingLogView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    @ObservedObject private var openLibraryService = OpenLibraryService.shared
    
    @State private var selectedMethod: LogMethod = .search
    @State private var searchQuery = ""
    @State private var searchResults: [Book] = []
    @State private var selectedBook: Book?
    @State private var isSearching = false
    @State private var scannedISBN = ""
    @State private var showingScanner = false
    
    // Manual entry fields
    @State private var manualTitle = ""
    @State private var manualAuthor = ""
    @State private var manualPages = ""
    
    // Reading log details
    @State private var dateFinished = Date()
    @State private var rating: Int = 0
    @State private var notes = ""
    @State private var showingDatePicker = false
    
    enum LogMethod: String, CaseIterable {
        case search = "Search"
        case scan = "Scan ISBN"
        case manual = "Manual Entry"
        
        var icon: String {
            switch self {
            case .search: return "magnifyingglass"
            case .scan: return "barcode.viewfinder"
            case .manual: return "pencil"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Method Selection
                    MethodSelectionView()
                    
                    // Book Selection Based on Method
                    BookSelectionView()
                    
                    // Reading Details (shown when book is selected)
                    if selectedBook != nil || !manualTitle.isEmpty {
                        ReadingDetailsView()
                    }
                }
                .padding()
            }
            .navigationTitle("Log a Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveReadingLog()
                    }
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showingScanner) {
                ScannerView(scannedCode: $scannedISBN, onScan: handleScannedISBN)
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerSheet(selectedDate: $dateFinished)
            }
        }
    }
    
    // MARK: - Method Selection
    @ViewBuilder
    private func MethodSelectionView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How would you like to add this book?")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                ForEach(LogMethod.allCases, id: \.self) { method in
                    Button {
                        selectedMethod = method
                        resetBookSelection()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: method.icon)
                                .font(.title2)
                            Text(method.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(selectedMethod == method ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedMethod == method ? Color.blue : Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Book Selection
    @ViewBuilder
    private func BookSelectionView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            switch selectedMethod {
            case .search:
                SearchBookView()
            case .scan:
                ScanBookView()
            case .manual:
                ManualEntryView()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Search View
    @ViewBuilder
    private func SearchBookView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Search for a book")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                TextField("Enter book title or author", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        searchBooks()
                    }
                
                Button("Search") {
                    searchBooks()
                }
                .buttonStyle(.borderedProminent)
                .disabled(searchQuery.isEmpty)
            }
            
            if isSearching {
                ProgressView("Searching...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if !searchResults.isEmpty {
                LazyVStack(spacing: 8) {
                    ForEach(searchResults.prefix(5), id: \.id) { book in
                        SearchResultRow(book: book, isSelected: selectedBook?.id == book.id) {
                            selectedBook = book
                        }
                    }
                }
            } else if !searchQuery.isEmpty && !isSearching {
                Text("No books found. Try a different search or use manual entry.")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
    
    // MARK: - Scan View
    @ViewBuilder
    private func ScanBookView() -> some View {
        VStack(spacing: 16) {
            Text("Scan book barcode")
                .font(.headline)
                .fontWeight(.semibold)
            
            if scannedISBN.isEmpty {
                Button {
                    showingScanner = true
                } label: {
                    VStack(spacing: 12) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        Text("Tap to Scan Barcode")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                VStack(spacing: 12) {
                    if openLibraryService.isLoading {
                        ProgressView("Looking up book...")
                    } else if let book = selectedBook {
                        BookCard(book: book)
                    } else {
                        VStack(spacing: 8) {
                            Text("Book not found")
                                .font(.headline)
                            Text("ISBN: \(scannedISBN)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Button("Try Manual Entry") {
                                selectedMethod = .manual
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    
                    Button("Scan Another") {
                        scannedISBN = ""
                        selectedBook = nil
                        showingScanner = true
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
    
    // MARK: - Manual Entry View
    @ViewBuilder
    private func ManualEntryView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter book details")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                TextField("Book title *", text: $manualTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Author *", text: $manualAuthor)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Number of pages (optional)", text: $manualPages)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
            }
            
            Text("* Required fields")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Reading Details
    @ViewBuilder
    private func ReadingDetailsView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reading Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Date finished
            VStack(alignment: .leading, spacing: 8) {
                Text("Date Finished")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Button {
                    showingDatePicker = true
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text(dateFinished, style: .date)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Rating
            VStack(alignment: .leading, spacing: 8) {
                Text("Rating (optional)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    ForEach(1...5, id: \.self) { star in
                        Button {
                            rating = rating == star ? 0 : star
                        } label: {
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundColor(star <= rating ? .yellow : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    if rating > 0 {
                        Button("Clear") {
                            rating = 0
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            
            // Notes
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes (optional)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("What did you think of this book?", text: $notes, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Helper Functions
    private var canSave: Bool {
        if selectedMethod == .manual {
            return !manualTitle.isEmpty && !manualAuthor.isEmpty
        } else {
            return selectedBook != nil
        }
    }
    
    private func searchBooks() {
        guard !searchQuery.isEmpty else { return }
        
        isSearching = true
        searchResults = []
        
        BookAPI.searchBooks(query: searchQuery) { [searchQuery] (books: [Book]) in
            DispatchQueue.main.async {
                // Only update if this is still the current search
                if self.searchQuery == searchQuery {
                    self.searchResults = books
                    self.isSearching = false
                }
            }
        }
    }
    
    private func handleScannedISBN(_ isbn: String) {
        scannedISBN = isbn
        
        // Try OpenLibrary first
        openLibraryService.fetchBookByISBN(isbn)
            .receive(on: DispatchQueue.main)
            .sink { book in
                if let book = book {
                    selectedBook = book
                } else {
                    // Try Google Books as fallback
                    BookAPI.fetchBookInfo(isbn: isbn) { fetchedBook in
                        if let fetchedBook = fetchedBook {
                            selectedBook = fetchedBook
                        }
                    }
                }
            }
            .store(in: &openLibraryService.cancellables)
    }
    
    private func resetBookSelection() {
        selectedBook = nil
        searchQuery = ""
        searchResults = []
        scannedISBN = ""
        manualTitle = ""
        manualAuthor = ""
        manualPages = ""
    }
    
    private func saveReadingLog() {
        let bookToSave: Book
        
        if selectedMethod == .manual {
            bookToSave = Book(
                id: UUID().uuidString,
                title: manualTitle,
                authors: [manualAuthor],
                description: nil,
                thumbnail: nil,
                pageCount: Int(manualPages),
                categories: nil,
                price: nil,
                ageRange: nil
            )
        } else {
            guard let book = selectedBook else { return }
            bookToSave = book
        }
        
        readingTracker.addReadingLog(
            for: bookToSave,
            dateFinished: dateFinished,
            rating: rating > 0 ? rating : nil,
            notes: notes.isEmpty ? nil : notes
        )
        
        dismiss()
    }
}

// MARK: - Supporting Views

struct SearchResultRow: View {
    let book: Book
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                BookCoverView(book: book, width: 40, height: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
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
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Date Finished", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Date Finished")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}