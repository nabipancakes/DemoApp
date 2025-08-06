//
//  Book.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/14/25.
//

import Foundation
import CoreData

struct Book: Identifiable, Codable, Equatable {
    var id: String
    var title: String
    var authors: [String]
    var description: String?
    var thumbnail: String?
    var pageCount: Int?
    var categories: [String]?
    var price: Double?
    var ageRange: String?
    
    static func == (lhs: Book, rhs: Book) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - CoreDataBook Extension
extension CoreDataBook {
    func toBook() -> Book {
        return Book(
            id: self.id ?? UUID().uuidString,
            title: self.title ?? "Unknown Title",
            authors: self.authors ?? ["Unknown Author"],
            description: self.bookDescription,
            thumbnail: self.thumbnail,
            pageCount: self.pageCount > 0 ? Int(self.pageCount) : nil,
            categories: self.categories,
            price: self.price?.doubleValue,
            ageRange: self.ageRange
        )
    }
}
