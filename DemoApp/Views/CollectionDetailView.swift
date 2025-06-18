import SwiftUI

struct CollectionDetailView: View {
    var collection: Collection

    var body: some View {
        List {
            if collection.books.isEmpty {
                Text("No books in this collection yet.")
                    .foregroundColor(.gray)
            } else {
                ForEach(collection.books) { book in
                    BookCard(book: book)  // This assumes you’ve defined BookCard elsewhere
                }
            }
        }
        .navigationTitle(collection.name)
    }
}
