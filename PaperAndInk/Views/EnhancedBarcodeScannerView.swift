//
//  EnhancedBarcodeScannerView.swift
//  TheBookDiaries
//
//  Created by Benjamin Guo on 6/20/25.
//

import SwiftUI
import Combine

struct EnhancedBarcodeScannerView: View {
    @ObservedObject var viewModel: CollectionViewModel
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject private var openLibraryService = OpenLibraryService.shared
    @State private var scannedBooks: [ScannedBookItem] = []
    @State private var currentScannedCode = ""
    @State private var showingScanner = false
    @State private var isProcessing = false
    @State private var selectedCollection: Collection?
    @State private var showingCollectionPicker = false
    @State private var showingBulkActions = false
    @State private var showingExportSheet = false
    @State private var csvFileURL: URL?
    
    struct ScannedBookItem: Identifiable {
        let id = UUID()
        let isbn: String
        var book: Book?
        var status: ScanStatus
        var addedToCollection: Bool = false
        let dateScanned: Date
        
        init(isbn: String, book: Book? = nil, status: ScanStatus = .scanning, addedToCollection: Bool = false, dateScanned: Date = Date()) {
            self.isbn = isbn
            self.book = book
            self.status = status
            self.addedToCollection = addedToCollection
            self.dateScanned = dateScanned
        }
        
        enum ScanStatus: String {
            case scanning = "scanning"
            case found = "found"
            case notFound = "not found"
            case error = "error"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
                // Header with stats
                HeaderStatsView()
                
                // Scan controls
                ScanControlsView()
                
                // Scanned books list
                ScannedBooksListView()
                
                // Bottom actions
                BottomActionsView()
            }
            .navigationTitle("Enhanced Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingScanner) {
                ScannerView(scannedCode: $currentScannedCode, onScan: handleScannedCode)
            }
            .sheet(isPresented: $showingCollectionPicker) {
                CollectionPickerView(selectedCollection: $selectedCollection, viewModel: viewModel)
            }
            .sheet(isPresented: $showingBulkActions) {
                BulkActionsView(scannedBooks: $scannedBooks, viewModel: viewModel)
            }
            .sheet(isPresented: $showingExportSheet) {
                if let url = csvFileURL {
                    ShareSheet(activityItems: [url])
                }
            }
    }
    
    // MARK: - Header Stats
    @ViewBuilder
    private func HeaderStatsView() -> some View {
        HStack(spacing: 20) {
            StatBadge(
                title: "Scanned",
                value: "\(scannedBooks.count)",
                color: .blue
            )
            
            StatBadge(
                title: "Found",
                value: "\(scannedBooks.filter { $0.status == .found }.count)",
                color: .green
            )
            
            StatBadge(
                title: "Not Found",
                value: "\(scannedBooks.filter { $0.status == .notFound }.count)",
                color: .orange
            )
            
            StatBadge(
                title: "Added",
                value: "\(scannedBooks.filter { $0.addedToCollection }.count)",
                color: .purple
            )
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }
    
    // MARK: - Scan Controls
    @ViewBuilder
    private func ScanControlsView() -> some View {
        VStack(spacing: 16) {
            // Main scan button
            Button {
                showingScanner = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.title2)
                    
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Processing...")
                    } else {
                        Text("Scan Another Book")
                            .fontWeight(.semibold)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .disabled(isProcessing)
            
            // Collection selector
            HStack {
                Text("Add to Collection:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button {
                    showingCollectionPicker = true
                } label: {
                    HStack {
                        Text(selectedCollection?.name ?? "Select Collection")
                            .foregroundColor(selectedCollection != nil ? .primary : .secondary)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Scanned Books List
    @ViewBuilder
    private func ScannedBooksListView() -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if scannedBooks.isEmpty {
                    EmptyScanView()
                } else {
                    ForEach(scannedBooks) { item in
                        ScannedBookRow(
                            item: item,
                            selectedCollection: selectedCollection,
                            onAddToCollection: { addToCollection(item) },
                            onRemove: { removeScannedBook(item) }
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Bottom Actions
    @ViewBuilder
    private func BottomActionsView() -> some View {
        if !scannedBooks.isEmpty {
            VStack(spacing: 12) {
                Divider()
                
                HStack(spacing: 12) {
                    Button {
                        addAllFoundBooksToCollection()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add All Found")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                    .disabled(selectedCollection == nil || scannedBooks.filter { $0.status == .found && !$0.addedToCollection }.isEmpty)
                    
                    Button {
                        exportScanResults()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export")
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Helper Functions
    private func handleScannedCode(_ code: String) {
        currentScannedCode = code
        
        // Check if already scanned
        if scannedBooks.contains(where: { $0.isbn == code }) {
            return
        }
        
        // Add to scanning list
        let scanItem = ScannedBookItem(isbn: code, status: .scanning)
        scannedBooks.append(scanItem)
        isProcessing = true
        
        // Lookup book
        openLibraryService.fetchBookByISBN(code)
            .receive(on: DispatchQueue.main)
            .sink { [code] (book: Book?) in
                if let book = book {
                    updateScannedBook(isbn: code, book: book, status: .found)
                } else {
                    // Try Google Books as fallback
                    BookAPI.fetchBookInfo(isbn: code) { fetchedBook in
                        DispatchQueue.main.async {
                            if let fetchedBook = fetchedBook {
                                updateScannedBook(isbn: code, book: fetchedBook, status: .found)
                            } else {
                                updateScannedBook(isbn: code, book: nil, status: .notFound)
                            }
                            isProcessing = false
                        }
                    }
                    return
                }
                isProcessing = false
            }
            .store(in: &openLibraryService.cancellables)
    }
    
    private func updateScannedBook(isbn: String, book: Book?, status: ScannedBookItem.ScanStatus) {
        if let index = scannedBooks.firstIndex(where: { $0.isbn == isbn }) {
            let originalItem = scannedBooks[index]
            scannedBooks[index] = ScannedBookItem(
                isbn: isbn,
                book: book,
                status: status,
                addedToCollection: originalItem.addedToCollection,
                dateScanned: originalItem.dateScanned
            )
        }
    }
    
    private func addToCollection(_ item: ScannedBookItem) {
        guard let collection = selectedCollection,
              let book = item.book else { return }
        
        viewModel.addBookToCollection(book, collectionID: collection.id)
        
        // Update the item status
        if let index = scannedBooks.firstIndex(where: { $0.id == item.id }) {
            scannedBooks[index] = ScannedBookItem(
                isbn: item.isbn,
                book: item.book,
                status: item.status,
                addedToCollection: true,
                dateScanned: item.dateScanned
            )
        }
    }
    
    private func addAllFoundBooksToCollection() {
        guard let collection = selectedCollection else { return }
        
        for item in scannedBooks where item.status == .found && !item.addedToCollection {
            if let book = item.book {
                viewModel.addBookToCollection(book, collectionID: collection.id)
                
                // Update status
                if let index = scannedBooks.firstIndex(where: { $0.id == item.id }) {
                    scannedBooks[index] = ScannedBookItem(
                        isbn: item.isbn,
                        book: item.book,
                        status: item.status,
                        addedToCollection: true,
                        dateScanned: item.dateScanned
                    )
                }
            }
        }
    }
    
    private func removeScannedBook(_ item: ScannedBookItem) {
        scannedBooks.removeAll { $0.id == item.id }
    }
    
    private func clearAllScans() {
        scannedBooks.removeAll()
    }
    
    private func exportScanResults() {
        var csvContent = "ISBN,Title,Author,Status,Date Scanned\n"
        
        for item in scannedBooks {
            let isbn = item.isbn
            let title = item.book?.title ?? "Unknown"
            let author = item.book?.authors.joined(separator: ", ") ?? "Unknown"
            let status = item.status.rawValue
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            let dateScanned = dateFormatter.string(from: item.dateScanned)
            
            csvContent += "\"\(isbn)\",\"\(title)\",\"\(author)\",\"\(status)\",\"\(dateScanned)\"\n"
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("scanned_books.csv")
        
        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            csvFileURL = tempURL
            showingExportSheet = true
        } catch {
            print("Error exporting scan results: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct StatBadge: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ScannedBookRow: View {
    let item: EnhancedBarcodeScannerView.ScannedBookItem
    let selectedCollection: Collection?
    let onAddToCollection: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            StatusIndicator(status: item.status)
            
            // Book info or ISBN
            VStack(alignment: .leading, spacing: 4) {
                if let book = item.book {
                    Text(book.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    Text("by \(book.authors.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Text("ISBN: \(item.isbn)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else {
                    Text("ISBN: \(item.isbn)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if item.status == .scanning {
                        Text("Looking up...")
                            .font(.caption)
                            .foregroundColor(.blue)
                    } else if item.status == .notFound {
                        Text("Book not found")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 8) {
                if item.status == .found && !item.addedToCollection && selectedCollection != nil {
                    Button("Add") {
                        onAddToCollection()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                } else if item.addedToCollection {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Added")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Button {
                    onRemove()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct StatusIndicator: View {
    let status: EnhancedBarcodeScannerView.ScannedBookItem.ScanStatus
    
    var body: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 12, height: 12)
            .overlay(
                statusIcon
                    .font(.caption2)
                    .foregroundColor(.white)
            )
    }
    
    private var statusColor: Color {
        switch status {
        case .scanning: return .blue
        case .found: return .green
        case .notFound: return .orange
        case .error: return .red
        }
    }
    
    private var statusIcon: some View {
        switch status {
        case .scanning:
            return Image(systemName: "clock.fill")
        case .found:
            return Image(systemName: "checkmark")
        case .notFound:
            return Image(systemName: "questionmark")
        case .error:
            return Image(systemName: "xmark")
        }
    }
}

struct EmptyScanView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Books Scanned Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap the scan button above to start adding books via barcode scanning")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

struct CollectionPickerView: View {
    @Binding var selectedCollection: Collection?
    @ObservedObject var viewModel: CollectionViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.collections) { collection in
                    Button {
                        selectedCollection = collection
                        dismiss()
                    } label: {
                        HStack {
                            Text(collection.name)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(collection.books.count) books")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if selectedCollection?.id == collection.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct BulkActionsView: View {
    @Binding var scannedBooks: [EnhancedBarcodeScannerView.ScannedBookItem]
    @ObservedObject var viewModel: CollectionViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Bulk Actions")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Choose an action to apply to all found books")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 12) {
                    Button("Add All to Catalog") {
                        // Add all found books to the main catalog
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Button("Export as CSV") {
                        // Export all scanned books
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    
                    Button("Remove Not Found") {
                        scannedBooks.removeAll { $0.status == .notFound }
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Bulk Actions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
