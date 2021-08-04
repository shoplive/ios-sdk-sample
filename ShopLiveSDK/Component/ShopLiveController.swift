//
//  ShopLiveController.swift
//  ShopLivePlayer
//
//  Created by ShopLive on 2021/08/01.
//

import Foundation
import AVKit
import WebKit

enum ShopLivePlayerObserveValue: String {
    case videoUrl = "videoUrl"
    case timeControlStatus = "player.timeControlStatus"
    case isPlayable = "urlAsset.isPlayable"
    case playerItemStatus = "playerItem.status"
    case isPlaybackLikelyToKeepUp = "playerItem.isPlaybackLikelyToKeepUp"
    case playControl = "playControl"
    case isHiddenOverlay = "isHiddenOverlay"
    case overlayUrl = "overlayUrl"
    case isMuted = "player.isMuted"
    case isPlaying = "isPlaying"
    case retryPlay = "retryPlay"
    case releasePlayer = "releasePlayer"
}

protocol ShopLivePlayerDelegate {
    var identifier: String { get }
    func isEqualTo(_ other: ShopLivePlayerDelegate) -> Bool

    func updatedValue(key: ShopLivePlayerObserveValue)
}

extension ShopLivePlayerDelegate where Self: Equatable {
    func isEqualTo(_ other: ShopLivePlayerDelegate) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }
}

final class ShopLiveController: NSObject {
    static let shared = ShopLiveController()

    private override init() {
        super.init()
        self.addPlayerObserver()
    }

    deinit {
        self.removePlayerObserver()
    }

    private var playerDelegates: [ShopLivePlayerDelegate] = []
    @objc dynamic var playItem: ShopLivePlayItem = .init()
    @objc dynamic var playerItem: ShopLivePlayerItem = .init()
    @objc dynamic var playControl: ShopLiveConfiguration.SLPlayControl = .none
    var isReplayMode: Bool = false
    var isMuted: Bool = false
    @objc dynamic var isHiddenOverlay: Bool = false
    @objc dynamic var overlayUrl: URL? = nil
    @objc dynamic var isPlaying: Bool = false
    @objc dynamic var retryPlay: Bool = false
    @objc dynamic var releasePlayer: Bool = false

    var webInstance: ShopLiveWebView?

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, let key = ShopLivePlayerObserveValue(rawValue: keyPath), let _ = change?[.newKey] else { return }
        switch key {
        case .videoUrl, .timeControlStatus, .isPlayable, .playerItemStatus, .playControl, .isHiddenOverlay, .overlayUrl, .isPlaying, .releasePlayer:
            postPlayerObservers(key: key)
            break
        case .isMuted, .retryPlay:
            if let old: Bool = change?[.oldKey] as? Bool, let new: Bool = change?[.newKey] as? Bool {
                if old != new {
                    guard let videoUrl = ShopLiveController.videoUrl, videoUrl.absoluteString.isEmpty || videoUrl.absoluteString == "null" else {
                        return
                    }
                    postPlayerObservers(key: key)
                }
            } else {
                postPlayerObservers(key: key)
            }
            break
        default:
            break
        }
    }

    func addPlayerDelegate(delegate: ShopLivePlayerDelegate) {
        guard self.playerDelegates.filter({ $0.identifier == delegate.identifier }).isEmpty else { return }
            playerDelegates.append(delegate)
        }

    func removePlayerDelegate(delegate: ShopLivePlayerDelegate) {
        guard let index = self.playerDelegates.firstIndex(where: { $0.identifier == delegate.identifier }) else { return }
        self.playerDelegates.remove(at: index)
    }

}

// MARK: ShopLive Player Section
extension ShopLiveController {
    func addPlayerObserver() { 
        playItem.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.videoUrl.rawValue, options: .new, context: nil)
        playItem.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.isPlayable.rawValue, options: .new, context: nil)
        playItem.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.playerItemStatus.rawValue, options: .new, context: nil)
        playItem.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.videoUrl.rawValue, options: .new, context: nil)
        playerItem.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.timeControlStatus.rawValue, options: .new, context: nil)
        playerItem.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.isMuted.rawValue, options: .new, context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.isHiddenOverlay.rawValue, options: [.initial, .new], context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.overlayUrl.rawValue, options: [.initial, .old, .new], context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.isPlaying.rawValue, options: .new, context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.retryPlay.rawValue, options: [.old, .new], context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.releasePlayer.rawValue, options: .new, context: nil)
    }

    func removePlayerObserver() {
        playItem.removeObserver(self, forKeyPath: ShopLivePlayerObserveValue.videoUrl.rawValue)
        playItem.removeObserver(self, forKeyPath: ShopLivePlayerObserveValue.isPlayable.rawValue)
        playItem.removeObserver(self, forKeyPath: ShopLivePlayerObserveValue.playerItemStatus.rawValue)
        playItem.removeObserver(self, forKeyPath: ShopLivePlayerObserveValue.videoUrl.rawValue)
        playerItem.removeObserver(self, forKeyPath: ShopLivePlayerObserveValue.timeControlStatus.rawValue)
        playerItem.removeObserver(self, forKeyPath: ShopLivePlayerObserveValue.isMuted.rawValue)
        self.removeObserver(self, forKeyPath: ShopLivePlayerObserveValue.isHiddenOverlay.rawValue)
        self.removeObserver(self, forKeyPath: ShopLivePlayerObserveValue.overlayUrl.rawValue)
        self.removeObserver(self, forKeyPath: ShopLivePlayerObserveValue.isPlaying.rawValue)
        self.removeObserver(self, forKeyPath: ShopLivePlayerObserveValue.retryPlay.rawValue)
        self.removeObserver(self, forKeyPath: ShopLivePlayerObserveValue.releasePlayer.rawValue)
    }

    func postPlayerObservers(key: ShopLivePlayerObserveValue) {
        ShopLiveLogger.debugLog("key: \(key.rawValue)")

        playerDelegates.forEach { delegate in
            ShopLiveLogger.debugLog("playerDelegate.identifier: \(delegate.identifier) - key: \(key)")
            delegate.updatedValue(key: key)
        }
    }
}

extension ShopLiveController {

    static var player: AVPlayer? {
        set {
            shared.playerItem.player = newValue
        }
        get {
            return shared.playerItem.player
        }
    }

    static var videoUrl: URL? {
        set {
            shared.playItem.videoUrl = newValue
        }
        get {
            return shared.playItem.videoUrl
        }
    }

    static var playerItem: AVPlayerItem? {
        set {
            shared.playItem.playerItem = newValue
        }
        get {
            return shared.playItem.playerItem
        }
    }

    static var urlAsset: AVURLAsset? {
        set {
            shared.playItem.urlAsset = newValue
        }
        get {
            return shared.playItem.urlAsset
        }
    }

    static var playerItemStatus: AVPlayerItem.Status {
        get {
            return shared.playItem.playerItem?.status ?? .unknown
        }
    }

    static var perfMeasurements: PerfMeasurements? {
        set {
            shared.playItem.perfMeasurements = newValue
        }
        get {
            return shared.playItem.perfMeasurements
        }
    }

    static var isReplayMode: Bool {
        set {
            shared.isReplayMode = newValue
        }
        get {
            return shared.isReplayMode
        }
    }

    static var isHiddenOverlay: Bool {
        set {
            shared.isHiddenOverlay = newValue
        }
        get {
            return shared.isHiddenOverlay
        }
    }

    static var playControl: ShopLiveConfiguration.SLPlayControl {
        set {
            shared.playControl = newValue
        }
        get {
            return shared.playControl
        }
    }

    static var webInstance: ShopLiveWebView? {
        set {
            shared.webInstance = newValue
        }
        get {
            return shared.webInstance
        }
    }

    static var duration: CMTime? {
        return shared.playerItem.player?.currentItem?.asset.duration
    }

    static var timeControlStatus: AVPlayer.TimeControlStatus {
        return shared.playerItem.player?.timeControlStatus ?? .paused
    }

    static var timebase: CMTimebase? {
        return shared.playItem.playerItem?.timebase
    }

    static var overlayUrl: URL? {
        set {
            shared.overlayUrl = newValue
        }
        get {
            return shared.overlayUrl
        }
    }

    static var isMuted: Bool {
        set {
            shared.isMuted = newValue
        }
        get {
            return shared.isMuted
        }
    }

    static var isPlaying: Bool {
        set {
            shared.isPlaying = newValue
        }
        get {
            return shared.isPlaying
        }
    }

    static var retryPlay: Bool {
        set {
            shared.retryPlay = newValue
        }
        get {
            return shared.retryPlay
        }
    }
}
