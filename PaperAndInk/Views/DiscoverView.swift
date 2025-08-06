//
//  DiscoverView.swift
//  TheBookDiaries
//
//  Created by Benjamin Guo on 6/20/25.
//

import SwiftUI

struct DiscoverView: View {
    @ObservedObject private var calendarService = CalendarChallengeService.shared
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    @ObservedObject private var dailyBookService = DailyBookService.shared
    @ObservedObject private var readingListService = ReadingListService.shared
    @State private var selectedBooks: [Book] = []
    @State private var isLoadingRecommendations = false
    @AppStorage("theme") private var selectedTheme: AppTheme = .classic
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Monthly Challenge Section
                    MonthlyChallengeSectionView()
                    
                    // Today's Pick Section
                    TodaysPickSection()
                    
                    // Book Recommendations
                    BookRecommendationsSection()
                    
                    // Popular This Month
                    PopularBooksSection()
                    
                    // Reading Inspiration
                    ReadingInspirationSection()
                }
                .padding()
            }
            .navigationTitle("Discover")
            .refreshable {
                await refreshContent()
            }
        }
    }
    
    // MARK: - Monthly Challenge Section
    @ViewBuilder
    private func MonthlyChallengeSectionView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Challenge")
                .font(.title2)
                .fontWeight(.bold)
            
            if calendarService.isLoading {
                ProgressView("Loading this month's pick...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if let monthlyBook = calendarService.currentMonthlyBook {
                MonthlyBookDiscoverCard(monthlyBook: monthlyBook)
                                } else {
                        EmptyMonthlyPickCard()
                    }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Book Recommendations
    @ViewBuilder
    private func BookRecommendationsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recommended for You")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Refresh") {
                    loadRecommendations()
                }
                .font(.caption)
                .foregroundColor(selectedTheme.primaryColor)
            }
            
            if isLoadingRecommendations {
                ProgressView("Finding great books for you...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if selectedBooks.isEmpty {
                Text("Tap refresh to discover new books!")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(selectedBooks, id: \.id) { book in
                            RecommendedBookCard(book: book)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onAppear {
            if selectedBooks.isEmpty {
                loadRecommendations()
            }
        }
    }
    
    // MARK: - Popular Books Section
    @ViewBuilder
    private func PopularBooksSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Popular This Month")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(getPopularBooks(), id: \.id) { book in
                    PopularBookCard(book: book)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Reading Inspiration
    @ViewBuilder
    private func ReadingInspirationSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reading Inspiration")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVStack(spacing: 12) {
                InspirationCard(
                    icon: "quote.bubble.fill",
                    title: "Quote of the Day",
                    content: "\"A reader lives a thousand lives before he dies. The man who never reads lives only one.\" - George R.R. Martin",
                    color: .purple
                )
                
                InspirationCard(
                    icon: "lightbulb.fill",
                    title: "Reading Tip",
                    content: "Try the 5-page rule: read 5 pages of a book before deciding if you want to continue. Sometimes it takes a few pages to get into the story!",
                    color: .orange
                )
                
                InspirationCard(
                    icon: "target",
                    title: "Challenge Yourself",
                    content: "Read a book from a genre you've never tried before. You might discover your new favorite author!",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Helper Functions
    private func loadRecommendations() {
        isLoadingRecommendations = true
        
        // Get random books from seed data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let allBooks = SeedBooksLoader.loadSeedBooks()
            selectedBooks = Array(allBooks.shuffled().prefix(5))
            isLoadingRecommendations = false
        }
    }
    
    private func getPopularBooks() -> [Book] {
        let allBooks = SeedBooksLoader.loadSeedBooks()
        return Array(allBooks.shuffled().prefix(4))
    }
    
    private func refreshContent() async {
        calendarService.loadCurrentMonthlyBook()
        loadRecommendations()
    }
    
    // MARK: - Today's Pick Section
    @ViewBuilder
    private func TodaysPickSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Pick")
                .font(.headline)
                .fontWeight(.semibold)
            
            if dailyBookService.isLoading {
                ProgressView("Loading today's book...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if let dailyBook = dailyBookService.dailyBook {
                CompactBookCard(
                    book: dailyBook,
                    isRead: readingTracker.isBookRead(dailyBook),
                    onMarkAsRead: {
                        readingTracker.addReadingLog(for: dailyBook)
                    }
                )
            } else {
                Text("No daily pick available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Supporting Views

struct MonthlyBookDiscoverCard: View {
    let monthlyBook: MonthlyBook
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📅 \(monthlyBook.month ?? "This Month")'s Pick")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if isBookRead {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            HStack(spacing: 16) {
                // Create a temporary Book object for the cover view
                BookCoverView(
                    book: Book(
                        id: UUID().uuidString,
                        title: monthlyBook.title ?? "Unknown Title",
                        authors: [monthlyBook.author ?? "Unknown Author"],
                        description: monthlyBook.bookDescription,
                        thumbnail: monthlyBook.coverURL,
                        pageCount: nil,
                        categories: nil,
                        price: nil,
                        ageRange: nil
                    ),
                    width: 80,
                    height: 120
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(monthlyBook.title ?? "Unknown Title")
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(2)
                    
                    Text("by \(monthlyBook.author ?? "Unknown Author")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let description = monthlyBook.bookDescription, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button(isBookRead ? "Read ✓" : "Mark as Read") {
                            if !isBookRead {
                                markAsRead()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .disabled(isBookRead)
                        
                        Button("Details") {
                            showingDetail = true
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .sheet(isPresented: $showingDetail) {
            MonthlyBookDetailView(monthlyBook: monthlyBook)
        }
    }
    
    private var isBookRead: Bool {
        readingTracker.readingLogs.contains { log in
            log.book?.toBook().title == monthlyBook.title
        }
    }
    
    private func markAsRead() {
        let book = Book(
            id: UUID().uuidString,
            title: monthlyBook.title ?? "Unknown Title",
            authors: [monthlyBook.author ?? "Unknown Author"],
            description: monthlyBook.bookDescription,
            thumbnail: monthlyBook.coverURL,
            pageCount: nil,
            categories: nil,
            price: nil,
            ageRange: nil
        )
        readingTracker.addReadingLog(for: book)
    }
}



struct RecommendedBookCard: View {
    let book: Book
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    @ObservedObject private var readingListService = ReadingListService.shared
    @State private var showingDetail = false
    
    var body: some View {
        Button {
            showingDetail = true
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                BookCoverView(book: book, width: 120, height: 160)
                
                Text(book.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text("by \(book.authors.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if readingTracker.isBookRead(book) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Read")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                } else {
                    Button(readingListService.isInReadingList(book) ? "In Reading List" : "Add to Reading List") {
                        readingListService.toggleReadingListStatus(book)
                    }
                    .font(.caption2)
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                    .foregroundColor(readingListService.isInReadingList(book) ? .orange : .blue)
                }
            }
            .frame(width: 120)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            BookDetailView(book: book)
        }
    }
}

struct PopularBookCard: View {
    let book: Book
    @State private var showingDetail = false
    
    var body: some View {
        Button {
            showingDetail = true
        } label: {
            VStack(spacing: 8) {
                BookCoverView(book: book, width: 80, height: 120)
                
                Text(book.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            BookDetailView(book: book)
        }
    }
}

struct InspirationCard: View {
    let icon: String
    let title: String
    let content: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(content)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct MonthlyBookDetailView: View {
    let monthlyBook: MonthlyBook
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Book cover and basic info
                    HStack(spacing: 16) {
                        BookCoverView(
                            book: Book(
                                id: UUID().uuidString,
                                title: monthlyBook.title ?? "Unknown Title",
                                authors: [monthlyBook.author ?? "Unknown Author"],
                                description: monthlyBook.bookDescription,
                                thumbnail: monthlyBook.coverURL,
                                pageCount: nil,
                                categories: nil,
                                price: nil,
                                ageRange: nil
                            ),
                            width: 120,
                            height: 180
                        )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(monthlyBook.title ?? "Unknown Title")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("by \(monthlyBook.author ?? "Unknown Author")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("📅 \(monthlyBook.month ?? "This Month")'s Pick")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                    
                    // Description
                    if let description = monthlyBook.bookDescription, !description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(description)
                                .font(.body)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Monthly Pick")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EmptyMonthlyPickCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No Monthly Pick Yet")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Check back soon for this month's featured book!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Seed Books Loader Helper
struct SeedBooksLoader {
    static func loadSeedBooks() -> [Book] {
        guard let url = Bundle.main.url(forResource: "SeedBooks", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let books = try? JSONDecoder().decode([Book].self, from: data) else {
            return []
        }
        return books
    }
}
