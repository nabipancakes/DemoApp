//
//  BookDetailView.swift
//  DemoApp
//
//  Created by Stephanie Shen on 6/20/25.
//

import SwiftUI

struct BookDetailView: View {
    let book: Book

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let urlString = book.thumbnail, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200)
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 200, height: 300)
                        .overlay(Text("No Image").foregroundColor(.gray))
                }

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
