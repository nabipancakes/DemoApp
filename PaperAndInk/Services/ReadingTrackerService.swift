//
//  ReadingTrackerService.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import Foundation
import Combine
import CoreData
import SwiftUI

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
    @Published var readingGoal: Int = 10
    
    private let coreDataManager = CoreDataManager.shared
    private let dailyBookService = DailyBookService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadReadingGoal()
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
    
    func addReadingLog(for book: PaperAndInk.Book, dateFinished: Date = Date(), rating: Int? = nil, notes: String? = nil) {
        // First ensure the book exists in Core Data
        let coreDataBook = coreDataManager.createBook(from: book)
        
        // Add reading log (rating will be ignored for now until Core Data model is updated)
        coreDataManager.addReadingLog(for: coreDataBook, dateFinished: dateFinished, notes: notes)
        
        // Reload reading logs
        loadReadingLogs()
    }
    
    func removeReadingLog(_ readingLog: ReadingLog) {
        coreDataManager.context.delete(readingLog)
        coreDataManager.save()
        loadReadingLogs()
    }
    
    func isBookRead(_ book: PaperAndInk.Book) -> Bool {
        let coreDataBook = coreDataManager.createBook(from: book)
        return !coreDataManager.fetchReadingLogs(for: coreDataBook).isEmpty
    }
    
    func getReadingLogs(for book: PaperAndInk.Book) -> [ReadingLog] {
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
        
        // Use reading goal for progress calculation instead of total seed books
        progressPercent = readingGoal > 0 ? min(Double(totalReadCount) / Double(readingGoal), 1.0) : 0.0
        
        checklistProgress = ChecklistProgress(readCount: totalReadCount, totalCount: readingGoal)
    }
    
    private func loadReadingGoal() {
        // Load reading goal from UserDefaults/AppStorage
        readingGoal = UserDefaults.standard.object(forKey: "readingGoal") as? Int ?? 10
        
        // Monitor changes to reading goal
        NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            let newGoal = UserDefaults.standard.object(forKey: "readingGoal") as? Int ?? 10
            if self?.readingGoal != newGoal {
                self?.readingGoal = newGoal
                self?.updateProgress()
            }
        }
    }
    
    func updateReadingGoal(_ newGoal: Int) {
        readingGoal = newGoal
        UserDefaults.standard.set(newGoal, forKey: "readingGoal")
        updateProgress()
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