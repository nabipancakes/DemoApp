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
    
    func addBookToCollection(_ book: DemoApp.Book, collectionID: UUID) {
        guard let collection = collections.first(where: { $0.id == collectionID }) else { return }
        
        // Add book to collection
        var updatedCollection = collection
        updatedCollection.books.append(book)
        
        // Update collections array
        if let index = collections.firstIndex(where: { $0.id == collectionID }) {
            collections[index] = updatedCollection
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
