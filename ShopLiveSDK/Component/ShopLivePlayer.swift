//
//  ShopLivePlayer.swift
//  ShopLivePlayer
//
//  Created by ShopLive on 2021/07/30.
//

import AVKit

final class ShopLivePlayer: AVPlayer {

    var superview: UIView?

    override init() {
        super.init()
    }

    init(superview: UIView) {
        super.init()
        self.superview = superview
    }
}
