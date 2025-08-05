//
//  DonationView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import SwiftUI

struct DonationView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    DonationHeaderView()
                    
                    // PayPal Donation Button
                    PayPalDonationView()
                    
                    // Impact
                    DonationImpactView()
                }
                .padding()
            }
            .navigationTitle("Support Us")
        }
    }
}

struct DonationHeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Support The Book Diaries")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Your donation helps us maintain and improve the reading community. Every contribution makes a difference!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Instagram Link
            Button {
                if let url = URL(string: "https://www.instagram.com/thebookdiariesorg/") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "camera")
                        .font(.title2)
                    Text("Follow us on Instagram")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.purple)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(20)
            }
        }
        .padding()
    }
}

struct PayPalDonationView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Support Our Mission")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Your donations help us maintain and improve The Book Diaries app for our amazing reading community.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                if let url = URL(string: "https://paypal.me/thebookdiariesco") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "heart.fill")
                        .font(.title2)
                    Text("Donate via PayPal")
                        .font(.headline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(Color.blue)
                .cornerRadius(25)
            }
            .scaleEffect(1.05)
            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
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
                    title: "Book Donations",
                    description: "Directly fund book purchases for underprivileged readers and schools"
                )
                
                ImpactRow(
                    icon: "person.2",
                    title: "Community Building",
                    description: "Support reading programs and literacy initiatives"
                )
                
                ImpactRow(
                    icon: "wifi",
                    title: "Platform Development",
                    description: "Maintain and improve the reading community platform"
                )
                
                ImpactRow(
                    icon: "heart.fill",
                    title: "Educational Access",
                    description: "Ensure every reader has access to quality literature"
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
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}