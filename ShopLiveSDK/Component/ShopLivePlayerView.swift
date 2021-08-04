//
//  ShopLivePlayerView.swift
//  ShopLivePlayer
//
//  Created by ShopLive on 2021/07/31.
//

import AVKit

final class ShopLivePlayerView: UIView {

    lazy var player: ShopLivePlayer = {
        let player = ShopLivePlayer(superview: self)
        return player
    }()

    init() {
        super.init(frame: .zero)
        setupPlayer()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPlayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlayer()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        player.fit()
    }

    func setupPlayer() {
        self.layer.addSublayer(player.playerLayer)
        player.fit()
    }
}
