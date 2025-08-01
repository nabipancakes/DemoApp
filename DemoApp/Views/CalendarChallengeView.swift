//
//  CalendarChallengeView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import SwiftUI

struct CalendarChallengeView: View {
    @ObservedObject private var calendarService = CalendarChallengeService.shared
    @State private var showingEditSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if calendarService.isLoading {
                        ProgressView("Loading monthly challenge...")
                            .padding()
                    } else if let monthlyBook = calendarService.currentMonthlyBook {
                        MonthlyBookCard(monthlyBook: monthlyBook)
                    } else {
                        EmptyMonthlyBookView()
                    }
                    
                    if calendarService.hasCurrentMonthlyBook {
                        ReadingProgressView()
                    }
                }
                .padding()
            }
            .navigationTitle("Monthly Challenge")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                EditMonthlyBookView()
            }
        }
    }
}

struct MonthlyBookCard: View {
    let monthlyBook: MonthlyBook
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(monthlyBook.month ?? "Unknown Month")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(monthlyBook.title ?? "Unknown Title")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("by \(monthlyBook.author ?? "Unknown Author")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let coverURL = monthlyBook.coverURL, !coverURL.isEmpty {
                    AsyncImage(url: URL(string: coverURL)) { image in
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
            
            if let description = monthlyBook.bookDescription, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            HStack {
                Button("Mark as Read") {
                    // TODO: Implement mark as read functionality
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
                
                Button("Learn More") {
                    // TODO: Implement learn more functionality
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct EmptyMonthlyBookView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("No Monthly Challenge Set")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Staff can set a monthly reading challenge for the community.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct ReadingProgressView: View {
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Progress")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(readingTracker.totalReadCount)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Books Read")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(Int(readingTracker.progressPercent * 100))%")
                        .font(.title)
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

struct EditMonthlyBookView: View {
    @ObservedObject private var calendarService = CalendarChallengeService.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var author = ""
    @State private var coverURL = ""
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Book Details")) {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("Cover URL (optional)", text: $coverURL)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Button("Save Monthly Book") {
                        calendarService.setMonthlyBook(
                            title: title,
                            author: author,
                            coverURL: coverURL.isEmpty ? nil : coverURL,
                            description: description.isEmpty ? nil : description
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty || author.isEmpty)
                    
                    if calendarService.hasCurrentMonthlyBook {
                        Button("Delete Current Book", role: .destructive) {
                            calendarService.deleteCurrentMonthlyBook()
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Edit Monthly Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let monthlyBook = calendarService.currentMonthlyBook {
                    title = monthlyBook.title ?? ""
                    author = monthlyBook.author ?? ""
                    coverURL = monthlyBook.coverURL ?? ""
                    description = monthlyBook.bookDescription ?? ""
                }
            }
        }
    }
} 