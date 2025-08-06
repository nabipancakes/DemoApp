//
//  BookAPI.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/14/25.
//

import Foundation

class BookAPI {
    static let baseURL = "https://www.googleapis.com/books/v1/volumes"
    
    static func searchBooks(query: String, completion: @escaping ([Book]) -> Void) {
        let cleanedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)?q=\(cleanedQuery)&maxResults=20"
        
        guard let url = URL(string: urlString) else {
            print("ERROR: Invalid URL for query: \(urlString)")
            completion([])
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("TheBookDiaries/1.0", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("DEBUG: HTTP Status Code: \(httpResponse.statusCode)")
            }
            if let error = error {
                print("ERROR: Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            guard let data = data else {
                print("ERROR: No data received from API")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(GoogleBooksResponse.self, from: data)
                
                let books: [Book] = response.items?.compactMap { item in
                    let info = item.volumeInfo
                    return Book(
                        id: item.id,
                        title: info.title,
                        authors: info.authors ?? ["Unknown Author"],
                        description: info.description,
                        thumbnail: info.imageLinks?.thumbnail?.replacingOccurrences(of: "http://", with: "https://"),
                        pageCount: info.pageCount,
                        categories: info.categories,
                        price: nil,
                        ageRange: nil
                    )
                } ?? []
                
                DispatchQueue.main.async {
                    completion(books)
                }
            } catch {
                print("ERROR: JSON decoding failed: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }.resume()
    }

    
    static func fetchBookInfo(isbn: String, completion: @escaping (PaperAndInk.Book?) -> Void) {

        let cleanedISBN = isbn.replacingOccurrences(of: "[^0-9X]", with: "", options: .regularExpression)
        

        guard !cleanedISBN.isEmpty else {
            print("ERROR: Invalid ISBN format")
            completion(nil)
            return
        }
        

        let urlString = "\(baseURL)?q=isbn:\(cleanedISBN)"
        guard let url = URL(string: urlString) else {
            print("ERROR: Invalid URL: \(urlString)")
            completion(nil)
            return
        }
        
        print("DEBUG: Fetching book from URL: \(urlString)")
        

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        

        request.addValue("TheBookDiaries/1.0", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
    
            if let httpResponse = response as? HTTPURLResponse {
                print("DEBUG: HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            if let error = error {
                print("ERROR: Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let data = data else {
                print("ERROR: No data received from API")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
        
            if let jsonString = String(data: data, encoding: .utf8) {
                let truncated = jsonString.prefix(200) + (jsonString.count > 200 ? "..." : "")
                print("DEBUG: Response preview: \(truncated)")
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(GoogleBooksResponse.self, from: data)
                
                if let items = response.items, !items.isEmpty {
                    if let firstBook = items.first {
                        print("DEBUG: Book found! Title: \(firstBook.volumeInfo.title)")
                        let book = Book(
                            id: firstBook.id,
                            title: firstBook.volumeInfo.title,
                            authors: firstBook.volumeInfo.authors ?? ["Unknown Author"],
                            description: firstBook.volumeInfo.description,
                            thumbnail: firstBook.volumeInfo.imageLinks?.thumbnail?.replacingOccurrences(of: "http://", with: "https://"),
                            pageCount: firstBook.volumeInfo.pageCount,
                            categories: firstBook.volumeInfo.categories,
                            price: nil,
                            ageRange: nil
                        )
                        DispatchQueue.main.async {
                            completion(book)
                        }
                    }
                } else {
                    print("ERROR: No items found in the response for ISBN: \(cleanedISBN)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } catch {
                print("ERROR: JSON decoding failed: \(error)")
                
   
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("DEBUG: Raw JSON that failed to decode: \(jsonString)")
                }
                
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
}
    
struct GoogleBooksResponse: Codable {
    var items: [GoogleBook]?
}
struct GoogleBook: Codable {
    var id: String
    var volumeInfo: VolumeInfo
}
struct VolumeInfo: Codable {
    var title: String
    var authors: [String]?
    var description: String?
    var imageLinks: ImageLinks?
    var pageCount: Int?
    var categories: [String]?
}
struct ImageLinks: Codable {
    var thumbnail: String?
}

