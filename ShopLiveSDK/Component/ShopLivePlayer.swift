//
//  ShopLivePlayer.swift
//  ShopLivePlayer
//
//  Created by ShopLive on 2021/07/30.
//

import AVKit

final class ShopLivePlayer: AVPlayer {

    var superview: UIView?

    lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer()
        playerLayer.player = self
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.needsDisplayOnBoundsChange = true
        ShopLiveController.shared.playerItem.player = self
        ShopLiveController.shared.playerItem.playerLayer = playerLayer
        return playerLayer
    }()

    deinit {
        ShopLiveController.shared.removePlayerDelegate(delegate: self)
    }

    override init() {
        super.init()
        setupPlayer()
    }

    init(superview: UIView) {
        super.init()
        self.superview = superview
        setupPlayer()
    }

    func setupPlayer() {
        ShopLiveController.shared.addPlayerDelegate(delegate: self)
    }

    func fit() {
        guard let superview = self.superview else { return }
        print("whkim fit player layer view \(superview.frame)\nwhkim layer\(playerLayer.frame)")

        playerLayer.fitToSuperView(superview: superview)
    }

}

extension ShopLivePlayer {

    private func timebaseEffectiveRateChanged(notification: Notification) {

    }
}

extension ShopLivePlayer: ShopLivePlayerDelegate {
    var identifier: String {
        return "ShopLivePlayer"
    }

    func updatedValue(key: ShopLivePlayerObserveValue) {
        switch key {
        default:
            break
        }
    }

}
