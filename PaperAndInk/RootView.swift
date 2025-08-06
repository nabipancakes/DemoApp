//
//  RootView.swift
//  PaperAndInk
//
//  Created by Benjamin Guo on 6/19/25.
//

import SwiftUI
import UIKit

struct SplashViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SplashViewController {
        SplashViewController()
    }
    
    func updateUIViewController(_ uiViewController: SplashViewController, context: Context) {}
}

struct RootView: View {
    @State private var showSplash = true

    var body: some View {
        Group {
            if showSplash {
                SplashViewControllerRepresentable()
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("SplashDidFinish"))) { _ in
                        withAnimation {
                            showSplash = false
                        }
                    }
            } else {
                ContentView(viewModel: CollectionViewModel())
            }
        }
    }
}
