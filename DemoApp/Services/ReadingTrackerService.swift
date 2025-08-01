//
//  ReadingTrackerService.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import Foundation
import Combine
import CoreData

struct ChecklistProgress {
    let readCount: Int
    let unreadCount: Int
    let totalCount: Int
    let percentComplete: Double
    
    init(readCount: Int, totalCount: Int) {
        self.readCount = readCount
        self.totalCount = totalCount
        self.unreadCount = totalCount - readCount
        self.percentComplete = totalCount > 0 ? Double(readCount) / Double(totalCount) : 0.0
    }
}

class ReadingTrackerService: ObservableObject {
    static let shared = ReadingTrackerService()
    
    @Published var readingLogs: [ReadingLog] = []
    @Published var totalReadCount: Int = 0
    @Published var progressPercent: Double = 0.0
    @Published var checklistProgress: ChecklistProgress = ChecklistProgress(readCount: 0, totalCount: 0)
    @Published var isLoading = false
    @Published var error: String?
    
    private let coreDataManager = CoreDataManager.shared
    private let dailyBookService = DailyBookService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadReadingLogs()
        setupPublishers()
    }
    
    // MARK: - Public Methods
    
    func loadReadingLogs() {
        isLoading = true
        error = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let logs = self.coreDataManager.fetchReadingLogs()
            
            DispatchQueue.main.async {
                self.readingLogs = logs
                self.updateProgress()
                self.isLoading = false
            }
        }
    }
    
    func addReadingLog(for book: DemoApp.Book, dateFinished: Date = Date(), notes: String? = nil) {
        // First ensure the book exists in Core Data
        let coreDataBook = coreDataManager.createBook(from: book)
        
        // Add reading log
        coreDataManager.addReadingLog(for: coreDataBook, dateFinished: dateFinished, notes: notes)
        
        // Reload reading logs
        loadReadingLogs()
    }
    
    func removeReadingLog(_ readingLog: ReadingLog) {
        coreDataManager.context.delete(readingLog)
        coreDataManager.save()
        loadReadingLogs()
    }
    
    func isBookRead(_ book: DemoApp.Book) -> Bool {
        let coreDataBook = coreDataManager.createBook(from: book)
        return !coreDataManager.fetchReadingLogs(for: coreDataBook).isEmpty
    }
    
    func getReadingLogs(for book: DemoApp.Book) -> [ReadingLog] {
        let coreDataBook = coreDataManager.createBook(from: book)
        return coreDataManager.fetchReadingLogs(for: coreDataBook)
    }
    
    // MARK: - Private Methods
    
    private func setupPublishers() {
        // Update progress when daily book service changes
        dailyBookService.$dailyBook
            .sink { [weak self] _ in
                self?.updateProgress()
            }
            .store(in: &cancellables)
    }
    
    private func updateProgress() {
        totalReadCount = readingLogs.count
        
        let totalBooks = dailyBookService.totalSeedBooksCount
        progressPercent = totalBooks > 0 ? Double(totalReadCount) / Double(totalBooks) : 0.0
        
        checklistProgress = ChecklistProgress(readCount: totalReadCount, totalCount: totalBooks)
    }
    
    // MARK: - Helper Methods
    
    var hasReadBooks: Bool {
        return totalReadCount > 0
    }
    
    var recentReads: [ReadingLog] {
        return Array(readingLogs.prefix(5))
    }
    
    func getBooksReadThisMonth() -> [ReadingLog] {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return readingLogs.filter { log in
            guard let dateFinished = log.dateFinished else { return false }
            return dateFinished >= startOfMonth
        }
    }
    
    func getBooksReadThisYear() -> [ReadingLog] {
        let calendar = Calendar.current
        let now = Date()
        let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
        
        return readingLogs.filter { log in
            guard let dateFinished = log.dateFinished else { return false }
            return dateFinished >= startOfYear
        }
    }
} 