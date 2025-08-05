//
//  EnhancedMonthlyPickEditor.swift
//  TheBookDiaries
//
//  Created by Benjamin Guo on 6/20/25.
//

import SwiftUI

struct EnhancedMonthlyPickEditor: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var calendarService = CalendarChallengeService.shared
    
    @State private var selectedMethod: BookSelectionMethod = .search
    @State private var searchQuery = ""
    @State private var searchResults: [Book] = []
    @State private var selectedBook: Book?
    @State private var isSearching = false
    
    // Manual entry fields
    @State private var manualTitle = ""
    @State private var manualAuthor = ""
    @State private var manualDescription = ""
    @State private var manualCoverURL = ""
    
    // Barcode scanning
    @State private var scannedISBN = ""
    @State private var showingScanner = false
    @State private var scannedBook: Book?
    
    // Month/Year selection
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    
    enum BookSelectionMethod: String, CaseIterable {
        case search = "Search"
        case scan = "Scan"
        case manual = "Manual"
        
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
                    // Current monthly pick status
                    CurrentPickStatusCard()
                    
                    // Month/Year selector
                    MonthYearSelector()
                    
                    // Book selection method
                    BookSelectionMethodPicker()
                    
                    // Book selection content
                    BookSelectionContent()
                    
                    // Selected book preview
                    if selectedBook != nil || !manualTitle.isEmpty {
                        SelectedBookPreview()
                    }
                }
                .padding()
            }
            .navigationTitle("Monthly Pick Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMonthlyPick()
                    }
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showingScanner) {
                ScannerView(scannedCode: $scannedISBN, onScan: handleScannedISBN)
            }
        }
    }
    
    // MARK: - Current Pick Status
    @ViewBuilder
    private func CurrentPickStatusCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Monthly Pick")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let currentPick = calendarService.currentMonthlyBook {
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: currentPick.coverURL ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 50, height: 70)
                    .cornerRadius(6)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentPick.title ?? "Unknown Title")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("by \(currentPick.author ?? "Unknown Author")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(currentPick.month ?? "Unknown") \(currentPick.year)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Replace") {
                        // Pre-fill the form to replace current pick
                        selectedMonth = Int(currentPick.year)
                        // Extract month number from month name
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            } else {
                HStack {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    Text("No monthly pick set for current month")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Month/Year Selector
    @ViewBuilder
    private func MonthYearSelector() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Month & Year")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Month")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text(DateFormatter().monthSymbols[month - 1])
                                .tag(month)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Year")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Year", selection: $selectedYear) {
                        ForEach(2024...2030, id: \.self) { year in
                            Text(String(year))
                                .tag(year)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Book Selection Method Picker
    @ViewBuilder
    private func BookSelectionMethodPicker() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How would you like to add the book?")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                ForEach(BookSelectionMethod.allCases, id: \.self) { method in
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
    
    // MARK: - Book Selection Content
    @ViewBuilder
    private func BookSelectionContent() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            switch selectedMethod {
            case .search:
                SearchBookSection()
            case .scan:
                ScanBookSection()
            case .manual:
                ManualEntrySection()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Search Section
    @ViewBuilder
    private func SearchBookSection() -> some View {
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
                        SearchResultRow(
                            book: book,
                            isSelected: selectedBook?.id == book.id
                        ) {
                            selectedBook = book
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Scan Section
    @ViewBuilder
    private func ScanBookSection() -> some View {
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
            } else if let book = scannedBook {
                BookCard(book: book)
                
                Button("Scan Another") {
                    scannedISBN = ""
                    scannedBook = nil
                    selectedBook = nil
                }
                .buttonStyle(.bordered)
            } else {
                VStack(spacing: 12) {
                    ProgressView("Looking up book...")
                    Text("ISBN: \(scannedISBN)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Manual Entry Section
    @ViewBuilder
    private func ManualEntrySection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter book details")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                TextField("Book title *", text: $manualTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Author *", text: $manualAuthor)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Description", text: $manualDescription, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
                
                TextField("Cover image URL (optional)", text: $manualCoverURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Text("* Required fields")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Selected Book Preview
    @ViewBuilder
    private func SelectedBookPreview() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Pick Preview")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                // Book cover
                if let book = selectedBook {
                    BookCoverView(book: book, width: 80, height: 120)
                } else if !manualCoverURL.isEmpty {
                    AsyncImage(url: URL(string: manualCoverURL)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 80, height: 120)
                    .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 120)
                        .overlay(
                            Image(systemName: "book.closed")
                                .font(.title2)
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(selectedBook?.title ?? manualTitle)
                        .font(.title3)
                        .fontWeight(.bold)
                        .lineLimit(2)
                    
                    Text("by \(selectedBook?.authors.joined(separator: ", ") ?? manualAuthor)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(DateFormatter().monthSymbols[selectedMonth - 1]) \(selectedYear)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    if let description = selectedBook?.description ?? (manualDescription.isEmpty ? nil : manualDescription) {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
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
        
        BookAPI.searchBooks(query: searchQuery) { (books: [Book]) in
            DispatchQueue.main.async {
                self.searchResults = books
                self.isSearching = false
            }
        }
    }
    
    private func handleScannedISBN(_ isbn: String) {
        scannedISBN = isbn
        
        // Try OpenLibrary first
        OpenLibraryService.shared.fetchBookByISBN(isbn)
            .receive(on: DispatchQueue.main)
            .sink { book in
                if let book = book {
                    self.scannedBook = book
                    self.selectedBook = book
                } else {
                    // Try Google Books as fallback
                    BookAPI.fetchBookInfo(isbn: isbn) { fetchedBook in
                        DispatchQueue.main.async {
                            if let fetchedBook = fetchedBook {
                                self.scannedBook = fetchedBook
                                self.selectedBook = fetchedBook
                            }
                        }
                    }
                }
            }
            .store(in: &OpenLibraryService.shared.cancellables)
    }
    
    private func resetBookSelection() {
        selectedBook = nil
        searchQuery = ""
        searchResults = []
        scannedISBN = ""
        scannedBook = nil
        manualTitle = ""
        manualAuthor = ""
        manualDescription = ""
        manualCoverURL = ""
    }
    
    private func saveMonthlyPick() {
        let title: String
        let author: String
        let description: String?
        let coverURL: String?
        
        if let book = selectedBook {
            title = book.title
            author = book.authors.joined(separator: ", ")
            description = book.description
            coverURL = book.thumbnail
        } else {
            title = manualTitle
            author = manualAuthor
            description = manualDescription.isEmpty ? nil : manualDescription
            coverURL = manualCoverURL.isEmpty ? nil : manualCoverURL
        }
        
        calendarService.setMonthlyBook(
            title: title,
            author: author,
            coverURL: coverURL,
            description: description
        )
        
        dismiss()
    }
}

// MARK: - Supporting Views
// SearchResultRow is defined in AddReadingLogView.swift and shared across the app
