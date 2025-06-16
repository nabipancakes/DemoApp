//
//  Book.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/14/25.
//


// Book.swift
import Foundation
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
