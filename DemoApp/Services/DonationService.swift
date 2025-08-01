//
//  DonationService.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import Foundation
import Combine

enum DonationError: Error, LocalizedError {
    case invalidAmount
    case invalidPaymentToken
    case networkError
    case serverError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Invalid donation amount"
        case .invalidPaymentToken:
            return "Invalid payment token"
        case .networkError:
            return "Network connection error"
        case .serverError:
            return "Server error occurred"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

struct DonationResult {
    let success: Bool
    let transactionId: String?
    let error: DonationError?
    let amount: Decimal
    let timestamp: Date
}

class DonationService: ObservableObject {
    static let shared = DonationService()
    
    @Published var isProcessing = false
    @Published var lastDonationResult: DonationResult?
    @Published var error: String?
    
    var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Public Methods
    
    func makeDonation(amount: Decimal, paymentToken: String) -> AnyPublisher<DonationResult, DonationError> {
        isProcessing = true
        error = nil
        
        // Validate inputs
        guard amount > 0 else {
            return Fail(error: DonationError.invalidAmount)
                .eraseToAnyPublisher()
        }
        
        guard !paymentToken.isEmpty else {
            return Fail(error: DonationError.invalidPaymentToken)
                .eraseToAnyPublisher()
        }
        
        // Simulate network delay
        return Future<DonationResult, DonationError> { promise in
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 2.0) {
                // Simulate success 90% of the time for testing
                let success = Double.random(in: 0...1) < 0.9
                
                if success {
                    let result = DonationResult(
                        success: true,
                        transactionId: UUID().uuidString,
                        error: nil,
                        amount: amount,
                        timestamp: Date()
                    )
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.lastDonationResult = result
                        self?.isProcessing = false
                    }
                    
                    promise(.success(result))
                } else {
                    let error = DonationError.serverError
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.error = error.localizedDescription
                        self?.isProcessing = false
                    }
                    
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func makeDonationWithApplePay(amount: Decimal) -> AnyPublisher<DonationResult, DonationError> {
        // Simulate Apple Pay token
        let applePayToken = "apple_pay_token_\(UUID().uuidString)"
        return makeDonation(amount: amount, paymentToken: applePayToken)
    }
    
    func makeDonationWithStripe(amount: Decimal, paymentMethodId: String) -> AnyPublisher<DonationResult, DonationError> {
        return makeDonation(amount: amount, paymentToken: paymentMethodId)
    }
    
    // MARK: - Helper Methods
    
    func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$\(amount)"
    }
    
    var hasRecentDonation: Bool {
        guard let lastResult = lastDonationResult else { return false }
        let timeInterval = Date().timeIntervalSince(lastResult.timestamp)
        return timeInterval < 24 * 60 * 60 // Within 24 hours
    }
    
    var totalDonated: Decimal {
        guard let lastResult = lastDonationResult, lastResult.success else { return 0 }
        return lastResult.amount
    }
} 