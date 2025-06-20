//
//  CollectionDetailView.swift
//  DemoApp
//
//  Created by Stephanie Shen on 6/18/25.
//

import SwiftUI

struct CollectionDetailView: View {
    @ObservedObject var viewModel: CollectionViewModel
    var collection: Collection

    @State private var searchQuery = ""
    @State private var searchResults: [Book] = []
    @State private var isSearching = false

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
