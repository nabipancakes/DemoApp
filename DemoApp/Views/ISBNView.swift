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
                ZStack(alignment: .topTrailing) {
                    BarcodeScannerView(code: $scannedISBN)
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
        }
    }
}
