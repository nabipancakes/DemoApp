//
//  OpenLibraryService.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import Foundation
import Combine

struct OpenLibraryBook: Codable {
    let title: String
    let authors: [OpenLibraryAuthor]?
    let description: OpenLibraryDescription?
    let covers: [Int]?
    let number_of_pages_median: Int?
    let subjects: [String]?
    let key: String
    
    struct OpenLibraryAuthor: Codable {
        let name: String
    }
    
    struct OpenLibraryDescription: Codable {
        let value: String
    }
}

typealias OpenLibraryResponse = [String: OpenLibraryBook]

class OpenLibraryService: ObservableObject {
    static let shared = OpenLibraryService()
    
    @Published var isLoading = false
    @Published var error: String?
    
    private let baseURL = "https://openlibrary.org"
    var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchBookByISBN(_ isbn: String) -> AnyPublisher<DemoApp.Book?, Never> {
        isLoading = true
        error = nil
        
        let cleanedISBN = isbn.replacingOccurrences(of: "[^0-9X]", with: "", options: .regularExpression)
        
        guard !cleanedISBN.isEmpty else {
            DispatchQueue.main.async { [weak self] in
                self?.error = "Invalid ISBN format"
                self?.isLoading = false
            }
            return Just(nil).eraseToAnyPublisher()
        }
        
        let urlString = "\(baseURL)/api/books?bibkeys=ISBN:\(cleanedISBN)&format=json&jscmd=data"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async { [weak self] in
                self?.error = "Invalid URL"
                self?.isLoading = false
            }
            return Just(nil).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: OpenLibraryResponse.self, decoder: JSONDecoder())
            .map { response -> DemoApp.Book? in
                let isbnKey = "ISBN:\(cleanedISBN)"
                guard let openLibraryBook = response[isbnKey] else { return nil }
                
                return DemoApp.Book(
                    id: openLibraryBook.key,
                    title: openLibraryBook.title,
                    authors: openLibraryBook.authors?.map { $0.name } ?? ["Unknown Author"],
                    description: openLibraryBook.description?.value,
                    thumbnail: self.getCoverURL(for: openLibraryBook.covers?.first),
                    pageCount: openLibraryBook.number_of_pages_median,
                    categories: openLibraryBook.subjects,
                    price: nil,
                    ageRange: nil
                )
            }
            .catch { error -> AnyPublisher<DemoApp.Book?, Never> in
                DispatchQueue.main.async { [weak self] in
                    self?.error = "Failed to fetch book: \(error.localizedDescription)"
                    self?.isLoading = false
                }
                return Just(nil).eraseToAnyPublisher()
            }
            .handleEvents(receiveCompletion: { _ in
                DispatchQueue.main.async { [weak self] in
                    self?.isLoading = false
                }
            })
            .eraseToAnyPublisher()
    }
    
    func searchBooks(query: String) -> AnyPublisher<[DemoApp.Book], Never> {
        isLoading = true
        error = nil
        
        let cleanedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/search.json?q=\(cleanedQuery)&limit=20"
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async { [weak self] in
                self?.error = "Invalid URL"
                self?.isLoading = false
            }
            return Just([]).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: OpenLibrarySearchResponse.self, decoder: JSONDecoder())
            .map { response in
                return response.docs.map { doc in
                    DemoApp.Book(
                        id: doc.key,
                        title: doc.title,
                        authors: doc.author_name ?? ["Unknown Author"],
                        description: doc.description?.first,
                        thumbnail: self.getCoverURL(for: doc.cover_i),
                        pageCount: doc.number_of_pages_median,
                        categories: doc.subject,
                        price: nil,
                        ageRange: nil
                    )
                }
            }
            .catch { error -> AnyPublisher<[DemoApp.Book], Never> in
                DispatchQueue.main.async { [weak self] in
                    self?.error = "Failed to search books: \(error.localizedDescription)"
                    self?.isLoading = false
                }
                return Just([]).eraseToAnyPublisher()
            }
            .handleEvents(receiveCompletion: { _ in
                DispatchQueue.main.async { [weak self] in
                    self?.isLoading = false
                }
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    private func getCoverURL(for coverId: Int?) -> String? {
        guard let coverId = coverId else { return nil }
        return "https://covers.openlibrary.org/b/id/\(coverId)-M.jpg"
    }
}

// MARK: - Search Response Models

struct OpenLibrarySearchResponse: Codable {
    let docs: [OpenLibrarySearchDoc]
}

struct OpenLibrarySearchDoc: Codable {
    let key: String
    let title: String
    let author_name: [String]?
    let description: [String]?
    let cover_i: Int?
    let number_of_pages_median: Int?
    let subject: [String]?
} 