//
//  DonationServiceTests.swift
//  DemoAppTests
//
//  Created by Stephanie Shen on 4/15/25.
//

import XCTest
import Combine
@testable import DemoApp

class DonationServiceTests: XCTestCase {
    var donationService: DonationService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        donationService = DonationService.shared
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        donationService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testMakeDonationSuccess() {
        let expectation = XCTestExpectation(description: "Donation completed")
        
        donationService.makeDonation(amount: 10.0, paymentToken: "test_token")
            .sink { result in
                XCTAssertTrue(result.success)
                XCTAssertNotNil(result.transactionId)
                XCTAssertEqual(result.amount, 10.0)
                XCTAssertNil(result.error)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testMakeDonationWithApplePay() {
        let expectation = XCTestExpectation(description: "Apple Pay donation completed")
        
        donationService.makeDonationWithApplePay(amount: 25.0)
            .sink { result in
                XCTAssertTrue(result.success)
                XCTAssertNotNil(result.transactionId)
                XCTAssertEqual(result.amount, 25.0)
                XCTAssertNil(result.error)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testMakeDonationWithStripe() {
        let expectation = XCTestExpectation(description: "Stripe donation completed")
        
        donationService.makeDonationWithStripe(amount: 50.0, paymentMethodId: "stripe_test_method")
            .sink { result in
                XCTAssertTrue(result.success)
                XCTAssertNotNil(result.transactionId)
                XCTAssertEqual(result.amount, 50.0)
                XCTAssertNil(result.error)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testInvalidAmount() {
        let expectation = XCTestExpectation(description: "Invalid amount error")
        
        donationService.makeDonation(amount: -5.0, paymentToken: "test_token")
            .sink { result in
                XCTAssertFalse(result.success)
                XCTAssertNotNil(result.error)
                XCTAssertEqual(result.error, .invalidAmount)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testInvalidPaymentToken() {
        let expectation = XCTestExpectation(description: "Invalid payment token error")
        
        donationService.makeDonation(amount: 10.0, paymentToken: "")
            .sink { result in
                XCTAssertFalse(result.success)
                XCTAssertNotNil(result.error)
                XCTAssertEqual(result.error, .invalidPaymentToken)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFormatAmount() {
        let formattedAmount = donationService.formatAmount(10.50)
        XCTAssertEqual(formattedAmount, "$10.50")
        
        let formattedAmount2 = donationService.formatAmount(0.99)
        XCTAssertEqual(formattedAmount2, "$0.99")
    }
    
    func testHasRecentDonation() {
        // Initially should be false
        XCTAssertFalse(donationService.hasRecentDonation)
        
        // Make a donation
        let expectation = XCTestExpectation(description: "Donation made")
        
        donationService.makeDonation(amount: 5.0, paymentToken: "test_token")
            .sink { result in
                XCTAssertTrue(result.success)
                // Check if recent donation is detected
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    XCTAssertTrue(self.donationService.hasRecentDonation)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testTotalDonated() {
        // Initially should be 0
        XCTAssertEqual(donationService.totalDonated, 0)
        
        // Make a donation
        let expectation = XCTestExpectation(description: "Donation made")
        
        donationService.makeDonation(amount: 15.0, paymentToken: "test_token")
            .sink { result in
                XCTAssertTrue(result.success)
                // Check total donated
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    XCTAssertEqual(self.donationService.totalDonated, 15.0)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
} 