//
//  TheBookDiariesApp.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import SwiftUI

@main
struct DemoAppApp: App {
    @StateObject private var viewModel = CollectionViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
