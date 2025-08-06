//
//  ReadingListService.swift
//  TheBookDiaries
//
//  Created by Benjamin Guo on 6/20/25.
//

import Foundation
import Combine

class ReadingListService: ObservableObject {
    static let shared = ReadingListService()
    
    @Published var readingList: [Book] = []
    
    private let userDefaults = UserDefaults.standard
    private let readingListKey = "reading_list"
    
    private init() {
        loadReadingList()
    }
    
    func addToReadingList(_ book: Book) {
        guard !readingList.contains(where: { $0.id == book.id }) else { return }
        readingList.append(book)
        saveReadingList()
    }
    
    func removeFromReadingList(_ book: Book) {
        readingList.removeAll { $0.id == book.id }
        saveReadingList()
    }
    
    func isInReadingList(_ book: Book) -> Bool {
        return readingList.contains { $0.id == book.id }
    }
    
    func toggleReadingListStatus(_ book: Book) {
        if isInReadingList(book) {
            removeFromReadingList(book)
        } else {
            addToReadingList(book)
        }
    }
    
    private func loadReadingList() {
        guard let data = userDefaults.data(forKey: readingListKey),
              let books = try? JSONDecoder().decode([Book].self, from: data) else {
            readingList = []
            return
        }
        readingList = books
    }
    
    private func saveReadingList() {
        guard let data = try? JSONEncoder().encode(readingList) else { return }
        userDefaults.set(data, forKey: readingListKey)
    }
}