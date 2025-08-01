//
//  SeedImporterView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import SwiftUI

struct SeedImporterView: View {
    @ObservedObject private var dailyBookService = DailyBookService.shared
    @State private var showingImportSheet = false
    @State private var showingAddBook = false
    @State private var searchText = ""
    
    var filteredBooks: [Book] {
        if searchText.isEmpty {
            return dailyBookService.seedBooks
        } else {
            return dailyBookService.seedBooks.filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.authors.contains { author in
                    author.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding()
                
                // Stats
                SeedBooksStatsView()
                    .padding(.horizontal)
                
                // Books List
                List {
                    ForEach(filteredBooks, id: \.id) { book in
                        SeedBookRow(book: book)
                    }
                    .onDelete(perform: deleteBooks)
                }
            }
            .navigationTitle("Seed Books")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Import") {
                        showingImportSheet = true
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Book") {
                        showingAddBook = true
                    }
                }
            }
            .sheet(isPresented: $showingImportSheet) {
                ImportSeedBooksView()
            }
            .sheet(isPresented: $showingAddBook) {
                AddSeedBookView()
            }
        }
    }
    
    private func deleteBooks(at offsets: IndexSet) {
        // TODO: Implement delete functionality
        // This would require updating the DailyBookService to support removing books
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search books...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct SeedBooksStatsView: View {
    @ObservedObject private var dailyBookService = DailyBookService.shared
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(dailyBookService.totalSeedBooksCount)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Total Books")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .center) {
                Text("Daily Rotation")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Active")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Last Updated")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Today")
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct SeedBookRow: View {
    let book: Book
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    
    var body: some View {
        HStack {
            // Book Cover
            if let thumbnail = book.thumbnail, !thumbnail.isEmpty {
                AsyncImage(url: URL(string: thumbnail)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Image(systemName: "book.closed")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
                .frame(width: 40, height: 60)
                .cornerRadius(4)
            } else {
                Image(systemName: "book.closed")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                    .frame(width: 40, height: 60)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
            
            // Book Info
            VStack(alignment: .leading, spacing: 2) {
                Text(book.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("by \(book.authors.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let pageCount = book.pageCount {
                    Text("\(pageCount) pages")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Status
            VStack(alignment: .trailing, spacing: 2) {
                if readingTracker.isBookRead(book) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
                
                Text("Seed Book")
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ImportSeedBooksView: View {
    @Environment(\.dismiss) var dismiss
    @State private var importText = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Import Seed Books")
                    .font(.headline)
                
                Text("Paste JSON data to import books into the seed collection.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                TextEditor(text: $importText)
                    .frame(minHeight: 200)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Import") {
                        importBooks()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(importText.isEmpty)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Import Books")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Import Result", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("success") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func importBooks() {
        // TODO: Implement JSON parsing and book import
        // This would require updating the DailyBookService to support adding books
        alertMessage = "Import functionality coming soon!"
        showingAlert = true
    }
}

struct AddSeedBookView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var authors = ""
    @State private var description = ""
    @State private var pageCount = ""
    @State private var categories = ""
    @State private var coverURL = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Book Details")) {
                    TextField("Title", text: $title)
                    TextField("Authors (comma separated)", text: $authors)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Page Count", text: $pageCount)
                        .keyboardType(.numberPad)
                    TextField("Categories (comma separated)", text: $categories)
                    TextField("Cover URL", text: $coverURL)
                }
                
                Section {
                    Button("Add to Seed Books") {
                        addBook()
                    }
                    .disabled(title.isEmpty || authors.isEmpty)
                }
            }
            .navigationTitle("Add Seed Book")
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
    
    private func addBook() {
        // TODO: Implement adding book to seed collection
        // This would require updating the DailyBookService to support adding books
        dismiss()
    }
} 