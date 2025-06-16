//
//  CollectionViewModel.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 6/15/25.
//

import Foundation

struct Collection: Identifiable {
    let id = UUID()
    var name: String
    var books: [Book] = []
}

class CollectionViewModel: ObservableObject {
    @Published var collections: [Collection] = []
    
    // Fetch book and add it to a general list if needed (optional)
    @Published var books: [Book] = []
    
    func fetchBook(from isbn: String) {
        BookAPI.fetchBookInfo(isbn: isbn) { [weak self] book in
            guard let self = self, let book = book else { return }
            
            DispatchQueue.main.async {
                if !self.books.contains(book) {
                    self.books.append(book)
                }
            }
        }
    }
    
    func addCollection(name: String) {
        if !collections.contains(where: { $0.name == name }) {
            collections.append(Collection(name: name))
        }
    }
    
    func addBookToCollection(_ book: Book, collectionName: String = "Default") {
        if let index = collections.firstIndex(where: { $0.name == collectionName }) {
            if !collections[index].books.contains(book) {
                collections[index].books.append(book)
            }
        } else {
            // Create collection if it doesn't exist
            let newCollection = Collection(name: collectionName, books: [book])
            collections.append(newCollection)
        }
    }
}

