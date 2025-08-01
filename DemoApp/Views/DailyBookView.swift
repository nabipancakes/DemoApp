//
//  DailyBookView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import SwiftUI

struct DailyBookView: View {
    @ObservedObject private var dailyBookService = DailyBookService.shared
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    @State private var showingBookDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if dailyBookService.isLoading {
                        ProgressView("Loading today's book...")
                            .padding()
                    } else if let dailyBook = dailyBookService.dailyBook {
                        DailyBookCard(
                            book: dailyBook,
                            isRead: readingTracker.isBookRead(dailyBook),
                            onMarkAsRead: {
                                readingTracker.addReadingLog(for: dailyBook)
                            }
                        )
                    } else {
                        EmptyDailyBookView()
                    }
                    
                    if dailyBookService.hasDailyBook {
                        DailyBookStatsView()
                    }
                }
                .padding()
            }
            .navigationTitle("Daily Pick")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        dailyBookService.refreshDailyBook()
                    }
                }
            }
            .sheet(isPresented: $showingBookDetail) {
                if let book = dailyBookService.dailyBook {
                    BookDetailView(book: book)
                }
            }
        }
    }
}

struct DailyBookCard: View {
    let book: Book
    let isRead: Bool
    let onMarkAsRead: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Today's Pick")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(book.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(2)
                    
                    Text("by \(book.authors.joined(separator: ", "))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let thumbnail = book.thumbnail, !thumbnail.isEmpty {
                    AsyncImage(url: URL(string: thumbnail)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Image(systemName: "book.closed")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
                    .frame(width: 80, height: 120)
                    .cornerRadius(8)
                } else {
                    Image(systemName: "book.closed")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                        .frame(width: 80, height: 120)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            if let description = book.description, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(4)
            }
            
            HStack {
                if let pageCount = book.pageCount {
                    Label("\(pageCount) pages", systemImage: "doc.text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let categories = book.categories, !categories.isEmpty {
                    Text(categories.prefix(2).joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Button(isRead ? "Already Read" : "Mark as Read") {
                    if !isRead {
                        onMarkAsRead()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isRead)
                
                Spacer()
                
                Button("Learn More") {
                    // TODO: Navigate to book detail
                }
                .buttonStyle(.bordered)
            }
            
            if isRead {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.green)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct EmptyDailyBookView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed.circle")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("No Daily Book Available")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Check back tomorrow for a new book recommendation.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct DailyBookStatsView: View {
    @StateObject private var dailyBookService = DailyBookService.shared
    @StateObject private var readingTracker = ReadingTrackerService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Reading Stats")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(readingTracker.totalReadCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Books Read")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("\(dailyBookService.totalSeedBooksCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Total Books")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(Int(readingTracker.progressPercent * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ProgressView(value: readingTracker.progressPercent)
                .progressViewStyle(LinearProgressViewStyle())
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 
