//
//  WeeklyView.swift
//  DemoApp
//
//  Created by Benjamin Guo on 6/22/25.
//

import SwiftUI

struct WeeklyView: View {
    @ObservedObject var viewModel: CollectionViewModel
    @State private var book: DemoApp.Book?
    @State private var isLoading = false

    private var currentWeek: Int {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)! // UTC
        return calendar.component(.weekOfYear, from: Date())
    }

    var body: some View {
        VStack(spacing: 16) {
            if let book = book {
                if let urlString = book.thumbnail, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(8)
                        case .failure(_):
                            Image(systemName: "book.closed")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .foregroundColor(.gray)
                        default:
                            ProgressView()
                                .frame(height: 200)
                        }
                    }
                } else {
                    Image(systemName: "book.closed")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .foregroundColor(.gray)
                }

                Text(book.title)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("by " + book.authors.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                ScrollView {
                    Text(book.description ?? "No review available.")
                        .padding()
                }
                
                Button("test") {
                    loadWeeklyBook(forceRefresh: true)
                }
                .padding(.top)
            } else if isLoading {
                ProgressView("Loading weekly book...")
            }
        }
        .padding()
        .onAppear {
            loadWeeklyBook(forceRefresh: false)
        }
    }

    private func weeklySearchTerm() -> String {
        let letters = Array("abcdefghijklmnopqrstuvwxyz")
        return String(letters[currentWeek % letters.count])
    }

    private func loadWeeklyBook(forceRefresh: Bool) {
        isLoading = true

        if !forceRefresh,
           let cachedData = UserDefaults.standard.data(forKey: "weeklyBook-\(currentWeek)"),
           let cachedBook = try? JSONDecoder().decode(DemoApp.Book.self, from: cachedData) {
            self.book = cachedBook
            self.isLoading = false
            return
        }

        fetchWeeklyBook { fetchedBook in
            DispatchQueue.main.async {
                self.book = fetchedBook
                self.isLoading = false

                if let book = fetchedBook,
                   let encoded = try? JSONEncoder().encode(book) {
                    UserDefaults.standard.set(encoded, forKey: "weeklyBook-\(currentWeek)")
                }
            }
        }
    }

    private func fetchWeeklyBook(completion: @escaping (DemoApp.Book?) -> Void) {
        let term = weeklySearchTerm()
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(term)+subject:fiction&langRestrict=en&printType=books&maxResults=40"

        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil, let data = data else {
                print("Network error:", error ?? "unknown")
                completion(nil)
                return
            }

            do {
                let response = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
                guard let items = response.items, !items.isEmpty else {
                    completion(nil)
                    return
                }

                let randomItem = items.randomElement()!
                let volumeInfo = randomItem.volumeInfo

                let thumbnail: String?
                if let thumb = volumeInfo.imageLinks?.thumbnail {
                    thumbnail = thumb.replacingOccurrences(of: "http://", with: "https://")
                } else {
                    thumbnail = nil
                }

                let book = DemoApp.Book(
                    id: randomItem.id,
                    title: volumeInfo.title,
                    authors: volumeInfo.authors ?? ["Unknown"],
                    description: volumeInfo.description,
                    thumbnail: thumbnail,
                    pageCount: volumeInfo.pageCount,
                    categories: volumeInfo.categories,
                    price: nil,
                    ageRange: nil
                )

                completion(book)
            } catch {
                print("Decoding error:", error)
                completion(nil)
            }
        }.resume()
    }
}
