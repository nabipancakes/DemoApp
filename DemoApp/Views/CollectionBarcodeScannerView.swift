//
//  CollectionBarcodeScannerView.swift
//  TheBookDiaries
//
//  Created by AI Assistant on 6/25/25.
//

import SwiftUI
import AVFoundation
import Combine

struct CollectionBarcodeScannerView: View {
    @ObservedObject var viewModel: CollectionViewModel
    let collection: Collection
    
    @ObservedObject private var openLibraryService = OpenLibraryService.shared
    @State private var scannedCode = ""
    @State private var showingScanner = true
    @State private var scannedBook: DemoApp.Book?
    @State private var addedToCollection = false
    @State private var showingSuccessAlert = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let book = scannedBook {
                    BookCoverView(book: book, width: 150, height: 200)
                        .padding()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(book.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("by \(book.authors.joined(separator: ", "))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let pageCount = book.pageCount {
                            Text("\(pageCount) pages")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        if addedToCollection {
                            VStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                                Text("Added to \(collection.name)!")
                                    .foregroundColor(.green)
                                    .font(.headline)
                            }
                        } else {
                            Button("Add to \(collection.name)") {
                                addBookToCollection(book)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        
                        Button("Scan Another") {
                            resetScanner()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Scan Book for \(collection.name)")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Point your camera at a book's barcode to add it to your collection")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        if !showingScanner {
                            Button("Start Scanning") {
                                showingScanner = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                }
                
                if openLibraryService.isLoading {
                    ProgressView("Looking up book...")
                        .padding()
                }
                
                if let error = openLibraryService.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Add to Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                ScannerView(scannedCode: $scannedCode, onScan: handleScannedCode)
            }
            .onChange(of: scannedCode) { _, newValue in
                if !newValue.isEmpty {
                    handleScannedCode(newValue)
                }
            }
            .alert("Success!", isPresented: $showingSuccessAlert) {
                Button("OK") { }
            } message: {
                Text("Book has been successfully added to the \(collection.name) collection!")
            }
        }
    }
    
    private func handleScannedCode(_ code: String) {
        showingScanner = false
        
        // Look up book using OpenLibrary API
        openLibraryService.fetchBookByISBN(code)
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
            .store(in: &openLibraryService.cancellables)
    }
    
    private func addBookToCollection(_ book: DemoApp.Book) {
        viewModel.addBookToCollection(book, collectionID: collection.id)
        addedToCollection = true
        showingSuccessAlert = true
        
        // Reset after a delay to allow user to see the success message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            dismiss()
        }
    }
    
    private func resetScanner() {
        scannedCode = ""
        scannedBook = nil
        openLibraryService.error = nil
        addedToCollection = false
        showingScanner = true
    }
}

