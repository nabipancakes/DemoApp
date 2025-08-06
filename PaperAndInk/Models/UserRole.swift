//
//  UserRole.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import Foundation

enum UserRole: String, CaseIterable {
    case reader = "reader"
    case staff = "staff"
    
    var displayName: String {
        switch self {
        case .reader:
            return "Reader"
        case .staff:
            return "Staff"
        }
    }
    
    var isReader: Bool {
        return self == .reader
    }
    
    var isStaff: Bool {
        return self == .staff
    }
} 