//
//  ReadingTrackerTests.swift
//  PaperAndInkTests
//
//  Created by Stephanie Shen on 4/15/25.
//

import XCTest
@testable import PaperAndInk

class ReadingTrackerTests: XCTestCase {
    var readingTracker: ReadingTrackerService!
    var dailyBookService: DailyBookService!
    
    override func setUp() {
        super.setUp()
        readingTracker = ReadingTrackerService.shared
        dailyBookService = DailyBookService.shared
    }
    
    override func tearDown() {
        readingTracker = nil
        dailyBookService = nil
        super.tearDown()
    }
    
    func testProgressPercentCalculation() {
        // Test initial state
        XCTAssertEqual(readingTracker.progressPercent, 0.0)
        
        // Test with some books read
        let testBook = Book(
            id: "test1",
            title: "Test Book",
            authors: ["Test Author"],
            description: "Test description",
            thumbnail: nil,
            pageCount: 100,
            categories: ["Test"],
            price: 10.0,
            ageRange: "Adult"
        )
        
        readingTracker.addReadingLog(for: testBook)
        
        // Give some time for the async operation
        let expectation = XCTestExpectation(description: "Reading log added")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertGreaterThan(self.readingTracker.totalReadCount, 0)
            XCTAssertGreaterThan(self.readingTracker.progressPercent, 0.0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testChecklistProgress() {
        let progress = readingTracker.checklistProgress
        
        XCTAssertGreaterThanOrEqual(progress.totalCount, 0)
        XCTAssertGreaterThanOrEqual(progress.readCount, 0)
        XCTAssertGreaterThanOrEqual(progress.unreadCount, 0)
        XCTAssertGreaterThanOrEqual(progress.percentComplete, 0.0)
        XCTAssertLessThanOrEqual(progress.percentComplete, 1.0)
    }
    
    func testIsBookRead() {
        let testBook = Book(
            id: "test2",
            title: "Test Book 2",
            authors: ["Test Author 2"],
            description: "Test description 2",
            thumbnail: nil,
            pageCount: 200,
            categories: ["Test"],
            price: 15.0,
            ageRange: "Adult"
        )
        
        // Initially should not be read
        XCTAssertFalse(readingTracker.isBookRead(testBook))
        
        // Add reading log
        readingTracker.addReadingLog(for: testBook)
        
        // Give some time for the async operation
        let expectation = XCTestExpectation(description: "Book marked as read")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(self.readingTracker.isBookRead(testBook))
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testRecentReads() {
        let recentReads = readingTracker.recentReads
        XCTAssertLessThanOrEqual(recentReads.count, 5)
    }
    
    func testBooksReadThisMonth() {
        let thisMonthBooks = readingTracker.getBooksReadThisMonth()
        XCTAssertGreaterThanOrEqual(thisMonthBooks.count, 0)
    }
    
    func testBooksReadThisYear() {
        let thisYearBooks = readingTracker.getBooksReadThisYear()
        XCTAssertGreaterThanOrEqual(thisYearBooks.count, 0)
    }
} 