//
//  TheBookDiariesApp.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 6/15/25.
//

import SwiftUI

@main
struct TheBookDiariesApp: App {
    @StateObject private var viewModel = CollectionViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
