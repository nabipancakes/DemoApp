//
//  AddCollectionView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import SwiftUI

struct AddCollectionView: View {
    @ObservedObject var viewModel: CollectionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var collectionName = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Collection Name", text: $collectionName)
            }
            .navigationTitle("New Collection")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !collectionName.isEmpty {
                            viewModel.addCollection(name: collectionName)
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}


