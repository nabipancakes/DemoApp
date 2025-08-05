//
//  CollectionDetailView.swift
//  DemoApp
//
//  Created by Benjamin Guo on 6/18/25.
//

import SwiftUI

struct CollectionDetailView: View {
    @ObservedObject var viewModel: CollectionViewModel
    var collection: Collection

    @State private var searchQuery = ""
    @State private var searchResults: [Book] = []
    @State private var isSearching = false
    @State private var showingBarcodeScanner = false
    @State private var showingExportSheet = false
    @State private var csvFileURL: URL?

    var body: some View {
        VStack {
            TextField("Search books", text: $searchQuery, onCommit: {
                searchBooks(query: searchQuery)
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()

            if isSearching {
                ProgressView()
                    .padding()
            }

            if !searchResults.isEmpty {
                List(searchResults) { book in
                    HStack {
                        Text(book.title)
                        Spacer()
                        Button("Add") {
                            viewModel.addBookToCollection(book, collectionID: collection.id)
                            searchQuery = ""
                            searchResults = []
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .frame(height: 200)
            }

            List {
                if collection.books.isEmpty {
                    Text("No books in this collection yet.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(collection.books) { book in
                        NavigationLink(destination: BookDetailView(book: book)) {
                            BookCard(book: book)
                        }
                    }
                    .onDelete { offsets in
                        viewModel.removeBooks(at: offsets, from: collection)
                    }
                }
            }
        }
        .navigationTitle(collection.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingBarcodeScanner = true
                    } label: {
                        Label("Scan Book", systemImage: "barcode.viewfinder")
                    }
                    
                    Button {
                        exportCollection()
                    } label: {
                        Label("Export Collection", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingBarcodeScanner) {
            CollectionBarcodeScannerView(viewModel: viewModel, collection: collection)
        }
        .sheet(isPresented: $showingExportSheet) {
            if let url = csvFileURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    private func exportCollection() {
        var csvContent = "Title,Author,Description,Page Count,Categories\n"
        
        for book in collection.books {
            let title = book.title
            let author = book.authors.joined(separator: ", ")
            let description = book.description ?? ""
            let pageCount = book.pageCount?.description ?? ""
            let categories = book.categories?.joined(separator: ", ") ?? ""
            
            csvContent += "\"\(title)\",\"\(author)\",\"\(description)\",\"\(pageCount)\",\"\(categories)\"\n"
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(collection.name)_books.csv")
        
        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            csvFileURL = tempURL
            showingExportSheet = true
        } catch {
            print("Error exporting collection: \(error)")
        }
    }

    func searchBooks(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        isSearching = true
        BookAPI.searchBooks(query: query) { results in
            searchResults = results
            isSearching = false
        }
    }
}
