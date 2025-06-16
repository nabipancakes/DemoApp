//
//  BookCard.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//


import SwiftUI

struct BookCard: View {
    var book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let thumbnail = book.thumbnail, let url = URL(string: thumbnail) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .cornerRadius(10)
                } placeholder: {
                    ProgressView()
                }
            }

            Text(book.title)
                .font(.headline)

            Text(book.authors.joined(separator: ", "))
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let description = book.description {
                Text(description)
                    .font(.body)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}
