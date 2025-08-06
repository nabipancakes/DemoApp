//
//  ISBNView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import SwiftUI

struct ISBNView: View {
    @ObservedObject var viewModel: CollectionViewModel
    @State private var showingScanner = false
    @State private var scannedISBN = ""
    @State private var scannedBook: PaperAndInk.Book?
    
    @State private var selectedCollectionID: UUID? = nil

    var body: some View {
        NavigationView {
            VStack {
                if let book = scannedBook {
                    NavigationLink(destination: BookDetailView(book: book)) {
                        BookCard(book: book)
                    }
                    .padding()
                    
                    if !viewModel.collections.isEmpty {
                        Picker("Add to Collection", selection: $selectedCollectionID) {
                            ForEach(viewModel.collections) { collection in
                                Text(collection.name).tag(collection.id as UUID?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                    } else {
                        Text("No collections yet. Create one first!")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    
                    Button("Add to Selected Collection") {
                        guard let book = scannedBook,
                              let collectionID = selectedCollectionID else { return }
                        viewModel.addBookToCollection(book, collectionID: collectionID)
                        resetScan()
                    }
                    .disabled(selectedCollectionID == nil)
                    .padding()
                } else {
                    Text("No ISBN scanned yet.")
                        .padding()
                }

                Button("Scan ISBN") {
                    showingScanner = true
                }
                .padding()
            }
            .navigationTitle("ISBN Scanner")
            .sheet(isPresented: $showingScanner) {
                ZStack(alignment: .topTrailing) {
                    BarcodeScannerView()
                        .onChange(of: scannedISBN) { newISBN in
                            if !newISBN.isEmpty {
                                viewModel.fetchBook(from: newISBN)
                            }
                        }
                    Button("Close") {
                        showingScanner = false
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Capsule())
                    .padding()
                }
            }
            .onReceive(viewModel.$books) { books in
                if let lastBook = books.last {
                    scannedBook = lastBook
                    showingScanner = false
                    // Default select first collection if exists
                    if selectedCollectionID == nil, let firstCollection = viewModel.collections.first {
                        selectedCollectionID = firstCollection.id
                    }
                }
            }
        }
    }
    
    private func resetScan() {
        scannedISBN = ""
        scannedBook = nil
        selectedCollectionID = nil
    }
}
