//
//  BookDetailView.swift
//  PaperAndInk
//
//  Created by Stephanie Shen on 6/20/25.
//

import SwiftUI

struct BookDetailView: View {
    let book: Book

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BookCoverView(book: book, width: 200, height: 300)

                Text(book.title)
                    .font(.title)
                    .bold()

                Text("By: \(book.authors.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let description = book.description {
                    Text(description)
                        .font(.body)
                } else {
                    Text("No description available.")
                        .italic()
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Book Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
