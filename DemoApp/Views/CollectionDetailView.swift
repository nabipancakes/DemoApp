//
//  CollectionDetailView.swift
//  DemoApp
//
//  Created by Stephanie Shen on 6/18/25.
//


import SwiftUI

struct CollectionDetailView: View {
    var collection: Collection

    var body: some View {
        List {
            if collection.books.isEmpty {
                Text("No books in this collection yet.")
                    .foregroundColor(.gray)
            } else {
                ForEach(collection.books) { book in
                    BookCard(book: book)
                }
            }
        }
        .navigationTitle(collection.name)
    }
}
