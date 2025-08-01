//
//  AppTheme.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import Foundation
import SwiftUI

enum AppTheme: String, CaseIterable {
    case classic = "classic"
    case midnight = "midnight"
    case sepia = "sepia"
    
    var displayName: String {
        switch self {
        case .classic:
            return "Classic"
        case .midnight:
            return "Midnight"
        case .sepia:
            return "Sepia"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .classic:
            return nil // System default
        case .midnight:
            return .dark
        case .sepia:
            return .light
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .classic:
            return .blue
        case .midnight:
            return .purple
        case .sepia:
            return .orange
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .classic:
            return Color(.systemBackground)
        case .midnight:
            return Color(.systemGray6)
        case .sepia:
            return Color(.systemYellow).opacity(0.1)
        }
    }
    
    var accentColor: Color {
        switch self {
        case .classic:
            return .blue
        case .midnight:
            return .cyan
        case .sepia:
            return .brown
        }
    }
} 