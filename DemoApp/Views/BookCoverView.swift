//
//  BookCoverView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 6/20/25.
//

import SwiftUI

struct BookCoverView: View {
    let book: Book
    let width: CGFloat
    let height: CGFloat
    
    // Generate a consistent color based on book title
    private var coverColor: Color {
        let hash = abs(book.title.hashValue)
        let colors: [Color] = [.blue, .purple, .green, .orange, .red, .pink, .indigo, .teal]
        return colors[hash % colors.count]
    }
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [coverColor.opacity(0.8), coverColor.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: width, height: height)
            .overlay(
                VStack(spacing: 6) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: min(width, height) * 0.25))
                        .foregroundColor(.white)
                    
                    if width > 60 {
                        Text(book.title)
                            .font(.system(size: min(width * 0.12, 11), weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(width > 100 ? 4 : 3)
                            .padding(.horizontal, 6)
                    }
                    
                    if width > 100 && !book.authors.isEmpty {
                        Text("by \(book.authors.first ?? "")")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 6)
                    }
                }
            )
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}