//
//  OpenApp.swift
//  PaperAndInk
//
//  Created by Benjamin Guo on 6/19/25.
//

import UIKit
import AVKit
import SwiftUI

class SplashViewController: UIViewController {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    override func viewDidLoad() {
        view.isUserInteractionEnabled = true
        super.viewDidLoad()
        playIntroVideo()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap))
        view.addGestureRecognizer(tap)
        
        // Auto-advance after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.transitionToMainView()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }

    private func playIntroVideo() {
        guard let path = Bundle.main.path(forResource: "Paper & Ink (2)", ofType: "mp4") else {
            print("Video not found")
            transitionToMainView()
            return
        }

        let url = URL(fileURLWithPath: path)
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        playerLayer?.frame = view.bounds
        if let playerLayer = playerLayer {
            view.layer.addSublayer(playerLayer)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )

        player?.play()
    }

    @objc private func videoDidEnd(notification: Notification) {
        transitionToMainView()
    }

    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap))
        view.addGestureRecognizer(tap)
    }

    @objc private func handleScreenTap() {
        transitionToMainView()
    }

    private func transitionToMainView() {
        player?.pause()
        player = nil

        let viewModel = CollectionViewModel()
        let mainVC = UIHostingController(rootView: ContentView(viewModel: viewModel))
        mainVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        mainVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(mainVC, animated: true, completion: nil)
    }
}
