//
//  CollectionViewModel.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/14/25.
//

import Foundation

struct Collection: Identifiable {
    let id = UUID()
    var name: String
    var books: [Book] = []
}

class CollectionViewModel: ObservableObject {
    @Published var collections: [Collection] = []
    
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
    
    func addBookToCollection(_ book: Book, collectionID: UUID) {
        if let index = collections.firstIndex(where: { $0.id == collectionID }) {
            if !collections[index].books.contains(book) {
                collections[index].books.append(book)
            }
        } else {
            // If collection with given ID does not exist, create a new "Default" collection with the book
            let newCollection = Collection(name: "Default", books: [book])
            collections.append(newCollection)
        }
    }
    
    func removeBooks(at offsets: IndexSet, from collection: Collection) {
        guard let index = collections.firstIndex(where: { $0.id == collection.id }) else { return }
        collections[index].books.remove(atOffsets: offsets)
    }
    
    func deleteCollections(at offsets: IndexSet) {
        collections.remove(atOffsets: offsets)
    }
}
