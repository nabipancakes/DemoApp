//
//  DonationView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import SwiftUI
import Combine

struct DonationView: View {
    @ObservedObject private var donationService = DonationService.shared
    @State private var selectedAmount: Decimal = 5.00
    @State private var customAmount = ""
    @State private var showingApplePay = false
    @State private var showingStripe = false
    @State private var showingSuccess = false
    
    private let presetAmounts: [Decimal] = [5.00, 10.00, 25.00, 50.00, 100.00]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    DonationHeaderView()
                    
                    // Amount Selection
                    AmountSelectionView(
                        selectedAmount: $selectedAmount,
                        customAmount: $customAmount,
                        presetAmounts: presetAmounts
                    )
                    
                    // Payment Methods
                    PaymentMethodsView(
                        onApplePay: {
                            showingApplePay = true
                        },
                        onStripe: {
                            showingStripe = true
                        }
                    )
                    
                    // Recent Donation
                    if donationService.hasRecentDonation {
                        RecentDonationView()
                    }
                    
                    // Impact
                    DonationImpactView()
                }
                .padding()
            }
            .navigationTitle("Support Us")
            .sheet(isPresented: $showingApplePay) {
                ApplePayView(amount: getSelectedAmount())
            }
            .sheet(isPresented: $showingStripe) {
                StripePaymentView(amount: getSelectedAmount())
            }
            .alert("Donation Successful!", isPresented: $showingSuccess) {
                Button("OK") { }
            } message: {
                Text("Thank you for your generous donation!")
            }
        }
    }
    
    private func getSelectedAmount() -> Decimal {
        if !customAmount.isEmpty, let amount = Double(customAmount) {
            selectedAmount = Decimal(amount)
        }
        return selectedAmount
    }
}

struct DonationHeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Support Book-Diaries")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Your donation helps us maintain and improve the reading community. Every contribution makes a difference!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct AmountSelectionView: View {
    @Binding var selectedAmount: Decimal
    @Binding var customAmount: String
    let presetAmounts: [Decimal]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Amount")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(presetAmounts, id: \.self) { amount in
                    Button {
                        selectedAmount = amount
                        customAmount = ""
                    } label: {
                        Text("$\(Double(truncating: amount as NSNumber), specifier: "%.0f")")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedAmount == amount ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedAmount == amount ? .white : .primary)
                            .cornerRadius(8)
                    }
                }
            }
            
            HStack {
                Text("$")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                TextField("Custom amount", text: $customAmount)
                    .keyboardType(.decimalPad)
                    .font(.title2)
                    .onChange(of: customAmount) { newValue in
                        if !newValue.isEmpty {
                            selectedAmount = 0
                        }
                    }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct PaymentMethodsView: View {
    let onApplePay: () -> Void
    let onStripe: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Method")
                .font(.headline)
            
            VStack(spacing: 12) {
                Button {
                    onApplePay()
                } label: {
                    HStack {
                        Image(systemName: "applelogo")
                            .font(.title2)
                        Text("Apple Pay")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button {
                    onStripe()
                } label: {
                    HStack {
                        Image(systemName: "creditcard")
                            .font(.title2)
                        Text("Credit Card")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
    }
}

struct RecentDonationView: View {
    @ObservedObject private var donationService = DonationService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Donation")
                .font(.headline)
            
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
                VStack(alignment: .leading) {
                    Text("Thank you for your donation!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if let lastResult = donationService.lastDonationResult {
                        Text(donationService.formatAmount(lastResult.amount))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct DonationImpactView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Impact")
                .font(.headline)
            
            VStack(spacing: 12) {
                ImpactRow(
                    icon: "book.closed",
                    title: "Reading Programs",
                    description: "Support community reading initiatives"
                )
                
                ImpactRow(
                    icon: "person.2",
                    title: "Community Events",
                    description: "Help organize book clubs and discussions"
                )
                
                ImpactRow(
                    icon: "wifi",
                    title: "Platform Maintenance",
                    description: "Keep the app running smoothly"
                )
            }
        }
    }
}

struct ImpactRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ApplePayView: View {
    let amount: Decimal
    @ObservedObject private var donationService = DonationService.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "applelogo")
                    .font(.system(size: 60))
                    .foregroundColor(.black)
                
                Text("Apple Pay")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Amount: \(donationService.formatAmount(amount))")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                if donationService.isProcessing {
                    ProgressView("Processing payment...")
                        .padding()
                } else {
                    Button("Pay with Apple Pay") {
                        processApplePay()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Apple Pay")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func processApplePay() {
        donationService.makeDonationWithApplePay(amount: amount)
            .receive(on: DispatchQueue.main)
            .catch { error in
                Just(DonationResult(
                    success: false,
                    transactionId: nil,
                    error: error,
                    amount: amount,
                    timestamp: Date()
                ))
            }
            .sink { result in
                if result.success {
                    dismiss()
                }
            }
            .store(in: &donationService.cancellables)
    }
}

struct StripePaymentView: View {
    let amount: Decimal
    @ObservedObject private var donationService = DonationService.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var cardholderName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Payment Details")) {
                    TextField("Card Number", text: $cardNumber)
                        .keyboardType(.numberPad)
                    
                    HStack {
                        TextField("MM/YY", text: $expiryDate)
                            .keyboardType(.numberPad)
                        
                        TextField("CVV", text: $cvv)
                            .keyboardType(.numberPad)
                    }
                    
                    TextField("Cardholder Name", text: $cardholderName)
                }
                
                Section {
                    Text("Amount: \(donationService.formatAmount(amount))")
                        .font(.headline)
                    
                    if donationService.isProcessing {
                        HStack {
                            ProgressView()
                            Text("Processing payment...")
                        }
                    } else {
                        Button("Pay \(donationService.formatAmount(amount))") {
                            processStripePayment()
                        }
                        .disabled(cardNumber.isEmpty || expiryDate.isEmpty || cvv.isEmpty || cardholderName.isEmpty)
                    }
                }
            }
            .navigationTitle("Credit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func processStripePayment() {
        let paymentMethodId = "stripe_payment_method_\(UUID().uuidString)"
        donationService.makeDonationWithStripe(amount: amount, paymentMethodId: paymentMethodId)
            .receive(on: DispatchQueue.main)
            .catch { error in
                Just(DonationResult(
                    success: false,
                    transactionId: nil,
                    error: error,
                    amount: amount,
                    timestamp: Date()
                ))
            }
            .sink { result in
                if result.success {
                    dismiss()
                }
            }
            .store(in: &donationService.cancellables)
    }
} 