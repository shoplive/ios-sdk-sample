//
//  VideoView.swift
//  ShopLiveSDK
//
//  Created by purpleworks on 2021/02/04.
//

import UIKit
import AVKit

final class VideoView: UIView {
    var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
    
    override class var layerClass : AnyClass {
        return AVPlayerLayer.self
    }
}
