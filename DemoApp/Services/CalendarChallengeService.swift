//
//  CalendarChallengeService.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import Foundation
import Combine
import CoreData

class CalendarChallengeService: ObservableObject {
    static let shared = CalendarChallengeService()
    
    @Published var currentMonthlyBook: MonthlyBook?
    @Published var isLoading = false
    @Published var error: String?
    
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadCurrentMonthlyBook()
    }
    
    // MARK: - Public Methods
    
    func loadCurrentMonthlyBook() {
        isLoading = true
        error = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let monthlyBook = self.coreDataManager.fetchCurrentMonthlyBook()
            
            DispatchQueue.main.async {
                self.currentMonthlyBook = monthlyBook
                self.isLoading = false
            }
        }
    }
    
    func setMonthlyBook(title: String, author: String, coverURL: String?, description: String?) {
        isLoading = true
        error = nil
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let currentMonth = dateFormatter.string(from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let monthlyBook = MonthlyBook(context: coreDataManager.context)
        monthlyBook.id = UUID()
        monthlyBook.title = title
        monthlyBook.author = author
        monthlyBook.coverURL = coverURL
        monthlyBook.month = currentMonth
        monthlyBook.year = Int32(currentYear)
        monthlyBook.bookDescription = description
        
        coreDataManager.setMonthlyBook(monthlyBook)
        
        DispatchQueue.main.async { [weak self] in
            self?.currentMonthlyBook = monthlyBook
            self?.isLoading = false
        }
    }
    
    func updateMonthlyBook(title: String, author: String, coverURL: String?, description: String?) {
        setMonthlyBook(title: title, author: author, coverURL: coverURL, description: description)
    }
    
    func deleteCurrentMonthlyBook() {
        guard let monthlyBook = currentMonthlyBook else { return }
        
        coreDataManager.context.delete(monthlyBook)
        coreDataManager.save()
        
        DispatchQueue.main.async { [weak self] in
            self?.currentMonthlyBook = nil
        }
    }
    
    // MARK: - Helper Methods
    
    var hasCurrentMonthlyBook: Bool {
        return currentMonthlyBook != nil
    }
    
    var currentMonthDisplay: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: Date())
    }
} 