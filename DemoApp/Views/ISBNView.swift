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
    @State private var scannedBook: Book?

    var body: some View {
        NavigationView {
            VStack {
                if let book = scannedBook {
                    BookCard(book: book)
                    
                    Button("Add to Collection") {
    
                        viewModel.addBookToCollection(book, collectionName: "Default")
                        scannedBook = nil
                        scannedISBN = ""
                    }
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
                BarcodeScannerView(code: $scannedISBN)
                    .onDisappear {
                        if !scannedISBN.isEmpty {
                            BookAPI.fetchBookInfo(isbn: scannedISBN) { book in
                                DispatchQueue.main.async {
                                    self.scannedBook = book
                                }
                            }
                        }
                    }
            }
        }
    }
}
