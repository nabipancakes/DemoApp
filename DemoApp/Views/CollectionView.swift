//
//  CollectionView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import SwiftUI

struct CollectionView: View {
    @ObservedObject var viewModel: CollectionViewModel
    @State private var showingAddCollection = false

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.collections) { collection in
                    NavigationLink(destination: CollectionDetailView(collection: collection)) {
                        Text(collection.name)
                    }

                }
            }
            .navigationTitle("My Collections")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddCollection = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCollection) {
                AddCollectionView(viewModel: viewModel)
            }
        }
    }
}
