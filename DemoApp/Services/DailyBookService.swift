//
//  DailyBookService.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import Foundation
import Combine

class DailyBookService: ObservableObject {
    static let shared = DailyBookService()
    
    @Published var dailyBook: DemoApp.Book?
    @Published var isLoading = false
    @Published var error: String?
    
    var seedBooks: [DemoApp.Book] = []
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadSeedBooks()
        loadDailyBook()
    }
    
    // MARK: - Public Methods
    
    func loadDailyBook() {
        guard !seedBooks.isEmpty else {
            loadSeedBooks()
            return
        }
        
        isLoading = true
        error = nil
        
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: today)
        
        // Use date as seed for deterministic selection
        let seed = dateString.hashValue
        let selectedIndex = abs(seed) % seedBooks.count
        let selectedBook = seedBooks[selectedIndex]
        
        DispatchQueue.main.async { [weak self] in
            self?.dailyBook = selectedBook
            self?.isLoading = false
        }
    }
    
    func refreshDailyBook() {
        loadDailyBook()
    }
    
    // MARK: - Private Methods
    
    private func loadSeedBooks() {
        guard let url = Bundle.main.url(forResource: "SeedBooks", withExtension: "json") else {
            // Create default seed books if file doesn't exist
            createDefaultSeedBooks()
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let books = try JSONDecoder().decode([DemoApp.Book].self, from: data)
            self.seedBooks = books
        } catch {
            print("Error loading seed books: \(error)")
            createDefaultSeedBooks()
        }
    }
    
    private func createDefaultSeedBooks() {
        seedBooks = [
            DemoApp.Book(id: "1", title: "The Great Gatsby", authors: ["F. Scott Fitzgerald"], description: "A story of the fabulously wealthy Jay Gatsby and his love for the beautiful Daisy Buchanan.", thumbnail: nil, pageCount: 180, categories: ["Fiction", "Classic"], price: 9.99, ageRange: "Adult"),
            DemoApp.Book(id: "2", title: "To Kill a Mockingbird", authors: ["Harper Lee"], description: "The story of young Scout Finch and her father Atticus in a racially divided Alabama town.", thumbnail: nil, pageCount: 281, categories: ["Fiction", "Classic"], price: 12.99, ageRange: "Young Adult"),
            DemoApp.Book(id: "3", title: "1984", authors: ["George Orwell"], description: "A dystopian novel about totalitarianism and surveillance society.", thumbnail: nil, pageCount: 328, categories: ["Fiction", "Dystopian"], price: 10.99, ageRange: "Adult"),
            DemoApp.Book(id: "4", title: "Pride and Prejudice", authors: ["Jane Austen"], description: "A romantic novel of manners that follows the emotional development of Elizabeth Bennet.", thumbnail: nil, pageCount: 432, categories: ["Fiction", "Romance"], price: 8.99, ageRange: "Adult"),
            DemoApp.Book(id: "5", title: "The Hobbit", authors: ["J.R.R. Tolkien"], description: "A fantasy novel about Bilbo Baggins' journey with thirteen dwarves.", thumbnail: nil, pageCount: 366, categories: ["Fantasy", "Adventure"], price: 14.99, ageRange: "All Ages")
        ]
    }
    
    // MARK: - Helper Methods
    
    var hasDailyBook: Bool {
        return dailyBook != nil
    }
    
    var totalSeedBooksCount: Int {
        return seedBooks.count
    }
    
    func getBookForDate(_ date: Date) -> DemoApp.Book? {
        guard !seedBooks.isEmpty else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        // Use date string as seed for consistent selection
        let seed = dateString.hashValue
        let index = abs(seed) % seedBooks.count
        
        return seedBooks[index]
    }
} 