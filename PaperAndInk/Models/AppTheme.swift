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
    case forest = "forest"
    case ocean = "ocean"
    case sunset = "sunset"
    
    var displayName: String {
        switch self {
        case .classic:
            return "Classic"
        case .midnight:
            return "Midnight"
        case .sepia:
            return "Sepia"
        case .forest:
            return "Forest"
        case .ocean:
            return "Ocean"
        case .sunset:
            return "Sunset"
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
        case .forest:
            return .light
        case .ocean:
            return .light
        case .sunset:
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
        case .forest:
            return .green
        case .ocean:
            return .cyan
        case .sunset:
            return .red
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
        case .forest:
            return Color(.systemGreen).opacity(0.1)
        case .ocean:
            return Color(.systemBlue).opacity(0.1)
        case .sunset:
            return Color(.systemOrange).opacity(0.1)
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
        case .forest:
            return .mint
        case .ocean:
            return .teal
        case .sunset:
            return .pink
        }
    }
} 