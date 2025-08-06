//
//  MyBooksView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 6/20/25.
//

import SwiftUI

struct MyBooksView: View {
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    @ObservedObject private var readingListService = ReadingListService.shared
    @ObservedObject var viewModel: CollectionViewModel
    @State private var selectedTab: MyBooksTab = .readingLog
    @State private var showingAddLog = false
    @State private var showingAddCollection = false
    @AppStorage("theme") private var selectedTheme: AppTheme = .classic
    
    enum MyBooksTab: String, CaseIterable {
        case readingLog = "Reading Log"
        case readingList = "Reading List"
        case collections = "Collections"
        
        var icon: String {
            switch self {
            case .readingLog: return "book.fill"
            case .readingList: return "bookmark.fill"
            case .collections: return "books.vertical.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Tab Selector
                TabSelectorView()
                
                // Content based on selected tab
                Group {
                    switch selectedTab {
                    case .readingLog:
                        ReadingLogTabView()
                    case .readingList:
                        ReadingListTabView()
                    case .collections:
                        CollectionsTabView()
                    }
                }
            }
            .navigationTitle("My Books")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingAddLog = true
                        } label: {
                            Label("Log a Book", systemImage: "plus.circle")
                        }
                        
                        Button {
                            showingAddCollection = true
                        } label: {
                            Label("New Collection", systemImage: "folder.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(selectedTheme.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddLog) {
                AddReadingLogView()
            }
            .sheet(isPresented: $showingAddCollection) {
                AddCollectionView(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Tab Selector
    @ViewBuilder
    private func TabSelectorView() -> some View {
        HStack(spacing: 0) {
            ForEach(MyBooksTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: tab.icon)
                            .font(.title3)
                        
                        Text(tab.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedTab == tab ? selectedTheme.primaryColor : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedTab == tab ? 
                        selectedTheme.primaryColor.opacity(0.1) : 
                        Color.clear
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.separator)),
            alignment: .bottom
        )
    }
    
    // MARK: - Reading Log Tab
    @ViewBuilder
    private func ReadingLogTabView() -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if readingTracker.readingLogs.isEmpty {
                    EmptyReadingLogView()
                } else {
                    // Reading Stats Summary
                    ReadingStatsCard()
                    
                    // Books List
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Your Books (\(readingTracker.readingLogs.count))")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Menu {
                                Button("All Books") { }
                                Button("This Year") { }
                                Button("This Month") { }
                            } label: {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .foregroundColor(selectedTheme.primaryColor)
                            }
                        }
                        
                        ForEach(readingTracker.readingLogs) { log in
                            ReadingLogCard(log: log)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Collections Tab
    @ViewBuilder
    private func CollectionsTabView() -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.collections.isEmpty {
                    EmptyCollectionsView()
                } else {
                    ForEach(viewModel.collections) { collection in
                        CollectionCard(collection: collection, viewModel: viewModel)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Reading List Tab
    @ViewBuilder
    private func ReadingListTabView() -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if readingListService.readingList.isEmpty {
                    EmptyReadingListView()
                } else {
                    ForEach(readingListService.readingList) { book in
                        ReadingListBookCard(book: book)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Supporting Views

struct ReadingStatsCard: View {
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    @AppStorage("readingGoal") private var readingGoal: Int = 10
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Reading Stats")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                StatItem(
                    title: "Books Read",
                    value: "\(readingTracker.totalReadCount)",
                    icon: "book.fill",
                    color: .blue
                )
                
                StatItem(
                    title: "Goal Progress",
                    value: "\(Int(readingTracker.progressPercent * 100))%",
                    icon: "target",
                    color: .green
                )
                
                StatItem(
                    title: "This Year",
                    value: "\(readingTracker.getBooksReadThisYear().count)",
                    icon: "calendar",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ReadingLogCard: View {
    let log: ReadingLog
    @State private var showingDetail = false
    
    var body: some View {
        Button {
            showingDetail = true
        } label: {
            HStack(spacing: 12) {
                if let coreDataBook = log.book {
                    BookCoverView(book: coreDataBook.toBook(), width: 50, height: 70)
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 70)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(log.book?.toBook().title ?? "Unknown Book")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text("by \(log.book?.toBook().authors.joined(separator: ", ") ?? "Unknown Author")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    if let dateFinished = log.dateFinished {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption2)
                            Text(dateFinished, style: .date)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    if let notes = log.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                    
                    Text("Read")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            if let coreDataBook = log.book {
                BookDetailView(book: coreDataBook.toBook())
            }
        }
    }
}

struct CollectionCard: View {
    let collection: Collection
    @ObservedObject var viewModel: CollectionViewModel
    
    var body: some View {
        NavigationLink(destination: CollectionDetailView(viewModel: viewModel, collection: collection)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(collection.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(collection.books.count) books")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(8)
                }
                
                if collection.books.isEmpty {
                    Text("No books in this collection yet")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 20)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(collection.books.prefix(5)), id: \.id) { book in
                                BookCoverView(book: book, width: 40, height: 60)
                            }
                            
                            if collection.books.count > 5 {
                                Text("+\(collection.books.count - 5)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 40, height: 60)
                                    .background(Color(.tertiarySystemBackground))
                                    .cornerRadius(6)
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
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyReadingLogView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Books Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start logging the books you've read to track your reading journey!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Log Your First Book") {
                // This will be handled by the parent view
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}

struct EmptyCollectionsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "books.vertical")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Collections Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create collections to organize your books by genre, mood, or any way you like!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Create Your First Collection") {
                // This will be handled by the parent view
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}

struct ReadingListBookCard: View {
    let book: Book
    @ObservedObject private var readingListService = ReadingListService.shared
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    @State private var showingDetail = false
    
    var body: some View {
        Button {
            showingDetail = true
        } label: {
            HStack(spacing: 12) {
                BookCoverView(book: book, width: 50, height: 70)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text("by \(book.authors.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    if let pageCount = book.pageCount {
                        Text("\(pageCount) pages")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 8) {
                    if readingTracker.isBookRead(book) {
                        VStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                            Text("Read")
                                .font(.caption2)
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                        }
                    } else {
                        Button {
                            readingTracker.addReadingLog(for: book)
                            readingListService.removeFromReadingList(book)
                        } label: {
                            VStack {
                                Image(systemName: "plus.circle")
                                    .font(.title3)
                                Text("Mark Read")
                                    .font(.caption2)
                            }
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Button {
                        readingListService.removeFromReadingList(book)
                    } label: {
                        Image(systemName: "xmark.circle")
                            .font(.title3)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            BookDetailView(book: book)
        }
    }
}

struct EmptyReadingListView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "bookmark")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("Your Reading List is Empty")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Discover new books and add them to your reading list to keep track of what you want to read next!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            NavigationLink(destination: DiscoverView()) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Discover Books")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}