//
//  CoreDataManager.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import Foundation
import CoreData
import Combine

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BookDiaries")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data store failed to load: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving Core Data context: \(error)")
            }
        }
    }
    
    // MARK: - Book Operations
    
    func createBook(from book: DemoApp.Book) -> CoreDataBook {
        let fetchRequest: NSFetchRequest<CoreDataBook> = CoreDataBook.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", book.id)
        
        if let existingBook = try? context.fetch(fetchRequest).first {
            return existingBook
        }
        
        let newBook = CoreDataBook(context: context)
        newBook.id = book.id
        newBook.title = book.title
        newBook.authors = book.authors
        newBook.bookDescription = book.description
        newBook.thumbnail = book.thumbnail
        newBook.pageCount = Int32(book.pageCount ?? 0)
        newBook.categories = book.categories
        newBook.price = NSDecimalNumber(value: book.price ?? 0.0)
        newBook.ageRange = book.ageRange
        newBook.isbn = nil // Will be set separately if needed
        
        save()
        return newBook
    }
    
    func fetchAllBooks() -> [CoreDataBook] {
        let fetchRequest: NSFetchRequest<CoreDataBook> = CoreDataBook.fetchRequest()
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    func fetchBook(by id: String) -> CoreDataBook? {
        let fetchRequest: NSFetchRequest<CoreDataBook> = CoreDataBook.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        return try? context.fetch(fetchRequest).first
    }
    
    // MARK: - Reading Log Operations
    
    func addReadingLog(for book: CoreDataBook, dateFinished: Date, notes: String? = nil) {
        let readingLog = ReadingLog(context: context)
        readingLog.id = UUID()
        readingLog.dateFinished = dateFinished
        readingLog.notes = notes
        readingLog.book = book
        
        save()
    }
    
    func fetchReadingLogs() -> [ReadingLog] {
        let fetchRequest: NSFetchRequest<ReadingLog> = ReadingLog.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ReadingLog.dateFinished, ascending: false)]
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    func fetchReadingLogs(for book: CoreDataBook) -> [ReadingLog] {
        let fetchRequest: NSFetchRequest<ReadingLog> = ReadingLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "book == %@", book)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ReadingLog.dateFinished, ascending: false)]
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    // MARK: - Monthly Book Operations
    
    func setMonthlyBook(_ monthlyBook: MonthlyBook) {
        // Remove existing monthly book for the same month/year
        let fetchRequest: NSFetchRequest<MonthlyBook> = MonthlyBook.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "month == %@ AND year == %d", monthlyBook.month ?? "", monthlyBook.year)
        
        if let existing = try? context.fetch(fetchRequest).first {
            context.delete(existing)
        }
        
        let newMonthlyBook = MonthlyBook(context: context)
        newMonthlyBook.id = monthlyBook.id
        newMonthlyBook.title = monthlyBook.title
        newMonthlyBook.author = monthlyBook.author
        newMonthlyBook.coverURL = monthlyBook.coverURL
        newMonthlyBook.month = monthlyBook.month
        newMonthlyBook.year = Int32(monthlyBook.year)
        newMonthlyBook.bookDescription = monthlyBook.bookDescription
        
        save()
    }
    
    func fetchMonthlyBook(for month: String, year: Int) -> MonthlyBook? {
        let fetchRequest: NSFetchRequest<MonthlyBook> = MonthlyBook.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "month == %@ AND year == %d", month, year)
        return try? context.fetch(fetchRequest).first
    }
    
    func fetchCurrentMonthlyBook() -> MonthlyBook? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let currentMonth = dateFormatter.string(from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        return fetchMonthlyBook(for: currentMonth, year: currentYear)
    }
} 