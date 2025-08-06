//
//  HomeView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import SwiftUI

struct HomeView: View {
    var viewModel: CollectionViewModel

    var body: some View {
        VStack {
            Text("Welcome to The Book Diaries 📚")
                .font(.title)
                .padding()

            Text("You currently have \(viewModel.books.count) books in your collection.")
                .font(.headline)

            Spacer()
        }
        .padding()
    }
}
