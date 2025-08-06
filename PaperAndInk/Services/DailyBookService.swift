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
    
    @Published var dailyBook: PaperAndInk.Book?
    @Published var isLoading = false
    @Published var error: String?
    
    var seedBooks: [PaperAndInk.Book] = []
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
            let books = try JSONDecoder().decode([PaperAndInk.Book].self, from: data)
            self.seedBooks = books
        } catch {
            print("Error loading seed books: \(error)")
            createDefaultSeedBooks()
        }
    }
    
    private func createDefaultSeedBooks() {
        seedBooks = [
            PaperAndInk.Book(id: "1", title: "The Great Gatsby", authors: ["F. Scott Fitzgerald"], description: "A story of the fabulously wealthy Jay Gatsby and his love for the beautiful Daisy Buchanan.", thumbnail: nil, pageCount: 180, categories: ["Fiction", "Classic"], price: 9.99, ageRange: "Adult"),
            PaperAndInk.Book(id: "2", title: "To Kill a Mockingbird", authors: ["Harper Lee"], description: "The story of young Scout Finch and her father Atticus in a racially divided Alabama town.", thumbnail: nil, pageCount: 281, categories: ["Fiction", "Classic"], price: 12.99, ageRange: "Young Adult"),
            PaperAndInk.Book(id: "3", title: "1984", authors: ["George Orwell"], description: "A dystopian novel about totalitarianism and surveillance society.", thumbnail: nil, pageCount: 328, categories: ["Fiction", "Dystopian"], price: 10.99, ageRange: "Adult"),
            PaperAndInk.Book(id: "4", title: "Pride and Prejudice", authors: ["Jane Austen"], description: "A romantic novel of manners that follows the emotional development of Elizabeth Bennet.", thumbnail: nil, pageCount: 432, categories: ["Fiction", "Romance"], price: 8.99, ageRange: "Adult"),
            PaperAndInk.Book(id: "5", title: "The Hobbit", authors: ["J.R.R. Tolkien"], description: "A fantasy novel about Bilbo Baggins' journey with thirteen dwarves.", thumbnail: nil, pageCount: 366, categories: ["Fantasy", "Adventure"], price: 14.99, ageRange: "All Ages"),
            PaperAndInk.Book(id: "6", title: "The Catcher in the Rye", authors: ["J.D. Salinger"], description: "A novel about teenage alienation and loss of innocence in post-World War II America.", thumbnail: nil, pageCount: 277, categories: ["Fiction", "Coming of Age"], price: 11.99, ageRange: "Young Adult"),
            PaperAndInk.Book(id: "7", title: "Lord of the Flies", authors: ["William Golding"], description: "A novel about a group of British boys stranded on an uninhabited island.", thumbnail: nil, pageCount: 224, categories: ["Fiction", "Allegory"], price: 9.99, ageRange: "Young Adult"),
            PaperAndInk.Book(id: "8", title: "Animal Farm", authors: ["George Orwell"], description: "A satirical allegory about the Russian Revolution and Stalin's rise to power.", thumbnail: nil, pageCount: 112, categories: ["Fiction", "Satire"], price: 7.99, ageRange: "Adult"),
            PaperAndInk.Book(id: "9", title: "The Alchemist", authors: ["Paulo Coelho"], description: "A novel about a young Andalusian shepherd who dreams of finding a worldly treasure.", thumbnail: nil, pageCount: 208, categories: ["Fiction", "Philosophy"], price: 13.99, ageRange: "Adult"),
            PaperAndInk.Book(id: "10", title: "The Little Prince", authors: ["Antoine de Saint-Exupéry"], description: "A poetic tale about a young prince who visits various planets in space.", thumbnail: nil, pageCount: 96, categories: ["Fiction", "Philosophy"], price: 6.99, ageRange: "All Ages"),
            PaperAndInk.Book(id: "11", title: "The Diary of a Young Girl", authors: ["Anne Frank"], description: "The diary of Anne Frank, a Jewish girl hiding during the Holocaust.", thumbnail: nil, pageCount: 283, categories: ["Non-fiction", "History"], price: 8.99, ageRange: "Young Adult"),
            PaperAndInk.Book(id: "12", title: "The Book Thief", authors: ["Markus Zusak"], description: "A novel set in Nazi Germany, narrated by Death.", thumbnail: nil, pageCount: 552, categories: ["Fiction", "Historical"], price: 12.99, ageRange: "Young Adult"),
            PaperAndInk.Book(id: "13", title: "The Kite Runner", authors: ["Khaled Hosseini"], description: "A novel about the unlikely friendship between a wealthy boy and the son of his father's servant.", thumbnail: nil, pageCount: 371, categories: ["Fiction", "Drama"], price: 11.99, ageRange: "Adult"),
            PaperAndInk.Book(id: "14", title: "Life of Pi", authors: ["Yann Martel"], description: "A novel about an Indian boy who survives a shipwreck and is stranded in the Pacific Ocean.", thumbnail: nil, pageCount: 460, categories: ["Fiction", "Adventure"], price: 13.99, ageRange: "Adult"),
            PaperAndInk.Book(id: "15", title: "The Fault in Our Stars", authors: ["John Green"], description: "A novel about two teenagers who meet at a cancer support group.", thumbnail: nil, pageCount: 313, categories: ["Fiction", "Romance"], price: 10.99, ageRange: "Young Adult"),
            PaperAndInk.Book(id: "16", title: "The Hunger Games", authors: ["Suzanne Collins"], description: "A dystopian novel about a televised battle to the death.", thumbnail: nil, pageCount: 374, categories: ["Fiction", "Dystopian"], price: 12.99, ageRange: "Young Adult"),
            PaperAndInk.Book(id: "17", title: "Harry Potter and the Sorcerer's Stone", authors: ["J.K. Rowling"], description: "The first novel in the Harry Potter series about a young wizard.", thumbnail: nil, pageCount: 223, categories: ["Fiction", "Fantasy"], price: 14.99, ageRange: "All Ages"),
            PaperAndInk.Book(id: "18", title: "The Da Vinci Code", authors: ["Dan Brown"], description: "A mystery thriller novel about a murder in the Louvre Museum.", thumbnail: nil, pageCount: 689, categories: ["Fiction", "Thriller"], price: 15.99, ageRange: "Adult"),
            PaperAndInk.Book(id: "19", title: "Gone Girl", authors: ["Gillian Flynn"], description: "A psychological thriller about a woman who disappears on her fifth wedding anniversary.", thumbnail: nil, pageCount: 415, categories: ["Fiction", "Thriller"], price: 13.99, ageRange: "Adult"),
            PaperAndInk.Book(id: "20", title: "The Girl with the Dragon Tattoo", authors: ["Stieg Larsson"], description: "A crime novel about a journalist and a computer hacker investigating a 40-year-old disappearance.", thumbnail: nil, pageCount: 465, categories: ["Fiction", "Crime"], price: 12.99, ageRange: "Adult")
        ]
    }
    
    // MARK: - Helper Methods
    
    var hasDailyBook: Bool {
        return dailyBook != nil
    }
    
    var totalSeedBooksCount: Int {
        return seedBooks.count
    }
    
    func getBookForDate(_ date: Date) -> PaperAndInk.Book? {
        guard !seedBooks.isEmpty else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        // Use date string as seed for consistent selection
        let seed = dateString.hashValue
        let index = abs(seed) % seedBooks.count
        
        return seedBooks[index]
    }
    
    func addBookToSeedBooks(_ book: PaperAndInk.Book) {
        // Check if book already exists
        if !seedBooks.contains(where: { $0.id == book.id }) {
            seedBooks.append(book)
            // Save to persistent storage
            saveSeedBooks()
        }
    }
    
    func removeBookFromSeedBooks(_ book: PaperAndInk.Book) {
        seedBooks.removeAll { $0.id == book.id }
        saveSeedBooks()
    }
    
    private func saveSeedBooks() {
        // TODO: Implement persistent storage for seed books
        // For now, just update the in-memory array
    }
} 