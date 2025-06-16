//
//  ContentView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/14/25.
//

import SwiftUI
struct ContentView: View {
    @ObservedObject var viewModel: CollectionViewModel
    
    var body: some View {
        TabView {
            // Home tab (stats)
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // Collection tab
            CollectionView(viewModel: viewModel)
                .tabItem {
                    Label("Collection", systemImage: "books.vertical.fill")
                }
            
            // ISBN Scanner tab
            ISBNView(viewModel: viewModel)
                .tabItem {
                    Label("ISBN", systemImage: "barcode.viewfinder")
                }
        }
        .accentColor(.blue)
    }
}
