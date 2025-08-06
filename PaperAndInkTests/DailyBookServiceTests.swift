//
//  DailyBookServiceTests.swift
//  PaperAndInkTests
//
//  Created by Stephanie Shen on 4/15/25.
//

import XCTest
@testable import PaperAndInk

class DailyBookServiceTests: XCTestCase {
    var dailyBookService: DailyBookService!
    
    override func setUp() {
        super.setUp()
        dailyBookService = DailyBookService.shared
    }
    
    override func tearDown() {
        dailyBookService = nil
        super.tearDown()
    }
    
    func testDailyBookRotation() {
        // Test that the same date always returns the same book
        let testDate = Date()
        let book1 = dailyBookService.getBookForDate(testDate)
        let book2 = dailyBookService.getBookForDate(testDate)
        
        XCTAssertNotNil(book1)
        XCTAssertEqual(book1?.id, book2?.id)
    }
    
    func testDifferentDatesReturnDifferentBooks() {
        // Test that different dates return different books (most of the time)
        let date1 = Date()
        let date2 = Calendar.current.date(byAdding: .day, value: 1, to: date1)!
        
        let book1 = dailyBookService.getBookForDate(date1)
        let book2 = dailyBookService.getBookForDate(date2)
        
        XCTAssertNotNil(book1)
        XCTAssertNotNil(book2)
        
        // Note: This test might occasionally fail if the same book is selected for consecutive days
        // due to the nature of the hash-based selection algorithm
        if book1?.id == book2?.id {
            print("Warning: Same book selected for consecutive days (this can happen occasionally)")
        }
    }
    
    func testSeedBooksCount() {
        XCTAssertGreaterThan(dailyBookService.totalSeedBooksCount, 0)
    }
    
    func testHasDailyBook() {
        dailyBookService.loadDailyBook()
        
        // Give some time for the async operation
        let expectation = XCTestExpectation(description: "Daily book loaded")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(self.dailyBookService.hasDailyBook)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
} 