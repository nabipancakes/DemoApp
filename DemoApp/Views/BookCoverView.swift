//
//  BookCoverView.swift
//  TheBookDiaries
//
//  Created by AI Assistant on 6/25/25.
//

import SwiftUI

struct BookCoverView: View {
    let book: Book
    let width: CGFloat
    let height: CGFloat
    
    @State private var currentImageIndex = 0
    @State private var imageLoadFailed = false
    
    // Multiple potential cover sources
    private var potentialCoverURLs: [String] {
        var urls: [String] = []
        
        // Primary thumbnail from API
        if let thumbnail = book.thumbnail, !thumbnail.isEmpty {
            urls.append(thumbnail)
        }
        
        // Google Books API search by title and author
        if let titleEncoded = book.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let authorEncoded = book.authors.first?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            urls.append("https://books.google.com/books/content/images/frontcover/\(book.id)?fife=w\(Int(width))-h\(Int(height))")
        }
        
        // OpenLibrary cover by title
        if let titleEncoded = book.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            urls.append("https://covers.openlibrary.org/b/title/\(titleEncoded)-L.jpg")
        }
        
        return urls
    }
    
    var body: some View {
        Group {
            if !potentialCoverURLs.isEmpty && !imageLoadFailed {
                AsyncImage(url: URL(string: potentialCoverURLs[currentImageIndex])) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure(_):
                        // Try next URL or show placeholder
                        Color.clear
                            .onAppear {
                                tryNextImage()
                            }
                    case .empty:
                        ProgressView()
                            .frame(width: width, height: height)
                    @unknown default:
                        PlaceholderCoverView(book: book, width: width, height: height)
                    }
                }
                .frame(width: width, height: height)
            } else {
                PlaceholderCoverView(book: book, width: width, height: height)
            }
        }
        .cornerRadius(8)
    }
    
    private func tryNextImage() {
        if currentImageIndex < potentialCoverURLs.count - 1 {
            currentImageIndex += 1
        } else {
            imageLoadFailed = true
        }
    }
}

struct PlaceholderCoverView: View {
    let book: Book
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: width, height: height)
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "book.closed")
                        .font(.system(size: min(width, height) * 0.3))
                        .foregroundColor(.white)
                    
                    if width > 80 {
                        Text(book.title)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .padding(.horizontal, 4)
                    }
                }
            )
            .cornerRadius(8)
    }
}