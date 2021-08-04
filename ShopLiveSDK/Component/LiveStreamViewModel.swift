//
//  LiveStreamViewModel.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/02/04.
//

import Foundation
import AVKit

@available(iOS 13.0, *)
internal final class LiveStreamViewModel: NSObject {
    @objc dynamic var videoUrl: URL?
    @objc dynamic var playerItemStatus: AVPlayerItem.Status = .unknown
    @objc dynamic var isMuted: Bool = false
    @objc dynamic var timeControlStatus: AVPlayer.TimeControlStatus = .paused
    @objc dynamic var isPlaybackLikelyToKeepUp: Bool = false
    @objc dynamic var playerItemDuration: CMTime = .init()
    @objc dynamic var playControl: ShopLiveConfiguration.SLPlayControl = .none

    var overayUrl: URL?
    var accessKey: String?
    var campaignKey: String?
    var authToken: String? = nil
    var user: ShopLiveUser? = nil
    
    var videoPlayer: AVPlayer? {
        return ShopLiveController.shared.playerItem.player
    }
    
    private var urlAsset: AVURLAsset?
    private var playerItem: AVPlayerItem?
    private var perfMeasurements: PerfMeasurements?
    
    deinit {
        ShopLiveController.shared.addPlayerDelegate(delegate: self)
        removeObserver()
        resetPlayer()
    }
    
    override init() {
        super.init()
        addObserver()
        ShopLiveController.shared.addPlayerDelegate(delegate: self)
    }
    
    private func updatePlayerItem(with url: URL) {
        guard let player = ShopLiveController.shared.playerItem.player else { return }
        let playerItemStatus = ShopLiveController.shared.playItem.playerItem?.status ?? .unknown
        let isSameUrl = ShopLiveController.shared.playItem.urlAsset?.url == url
        guard !isSameUrl || player.timeControlStatus != .playing else { return }
        guard !isSameUrl || playerItemStatus != .readyToPlay || player.reasonForWaitingToPlay == .evaluatingBufferingRate else { return }

        resetPlayer()

        ShopLiveController.shared.playItem.urlAsset = AVURLAsset(url: url)
    }

    private func resetPlayer() {
        ShopLiveController.shared.playerItem.player?.replaceCurrentItem(with: nil)
        ShopLiveController.shared.playerItem.player?.pause()
        ShopLiveController.shared.playItem.playerItem = nil
        ShopLiveController.shared.playItem.urlAsset = nil
        ShopLiveController.shared.playItem.perfMeasurements = nil
//        NotificationCenter.default.removeObserver(self, name: .timebase, object: <#T##Any?#>)
        removePlayableAction()

        perfMeasurements?.playbackEnded()
        perfMeasurements = nil

        playerItem = nil
        urlAsset = nil
    }

    private func setupIsPlayble() {
        guard let playAsset = ShopLiveController.shared.playItem.urlAsset else { return }
        let playerItem = AVPlayerItem(asset: playAsset)
        ShopLiveController.shared.playItem.perfMeasurements = PerfMeasurements(playerItem: playerItem)
        ShopLiveController.shared.playItem.playerItem = playerItem

        ShopLiveController.shared.playerItem.player?.replaceCurrentItem(with: playerItem)
    }
    
    func play() {
        if let url = videoUrl, (playerItemStatus == .failed || videoPlayer?.reasonForWaitingToPlay == AVPlayer.WaitingReason.evaluatingBufferingRate) {
            updatePlayerItem(with: url)
        }
        else {
            videoPlayer?.play()
        }
    }
    
    func stop() {
        resetPlayer()
    }
    
    func reloadVideo() {
        guard let url = videoUrl else {
            resetPlayer()
            return
        }
        
        updatePlayerItem(with: url)
    }

    func seek(to: CMTime) {
        videoPlayer?.seek(to: to)
    }

    func addObserver() {
        self.addObserver(self, forKeyPath: "videoUrl", options: [.initial, .new], context: nil)
//        videoPlayer?.addObserver(self, forKeyPath: "isMuted", options: [.initial, .old, .new], context: nil)
//        videoPlayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.initial,.new], context: nil)
    }

    func removeObserver() {
        self.removeObserver(self, forKeyPath: "videoUrl")
//        videoPlayer?.removeObserver(self, forKeyPath: "isMuted")
//        videoPlayer?.removeObserver(self, forKeyPath: "timeControlStatus")
    }

//    private func addIsPlayableObserver() {
//        urlAsset?.addObserver(self, forKeyPath: "isPlayable", options: [.initial, .new], context: nil)
//    }
//
//    private func removeIsPlayableObserver() {
//        urlAsset?.removeObserver(self, forKeyPath: "isPlayable")
//    }

    private func addPlayableAction() {
        guard let asset = self.urlAsset else { return }
        let _playerItem = AVPlayerItem(asset: asset)

        self.perfMeasurements = PerfMeasurements(playerItem: _playerItem)

        self.playerItem?.addObserver(self, forKeyPath: "status", options: [.initial, .new], context: nil)
//        self.playerItemStatusCancellable = playerItem.publisher(for: \.status).assign(to: \.playerItemStatus, on: self)

        self.playerItem?.addObserver(self, forKeyPath: "isPlaybackLikelyToKeepUp", options: [.initial, .new], context: nil)
//        self.playItemIsPlaybackLikelyToKeepUpCancellable = playerItem.publisher(for: \.isPlaybackLikelyToKeepUp).assign(to: \.isPlaybackLikelyToKeepUp, on: self)

        self.playerItem?.addObserver(self, forKeyPath: "duration", options: [.initial, .new], context: nil)
//        self.playerItemDurationCancellable = playerItem.asset.publisher(for: \.duration).assign(to: \.playerItemDuration, on: self)

        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .TimebaseEffectiveRateChangedNotification, object: self.playerItem?.timebase)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .AVPlayerItemPlaybackStalled, object: self.playerItem)

        self.videoPlayer?.replaceCurrentItem(with: _playerItem)

        self.playerItem = _playerItem
    }

    private func removePlayableAction() {
        self.playerItem?.removeObserver(self, forKeyPath: "status")
        self.playerItem?.removeObserver(self, forKeyPath: "isPlaybackLikelyToKeepUp")
        self.playerItem?.removeObserver(self, forKeyPath: "duration")
        NotificationCenter.default.removeObserver(self, name: .TimebaseEffectiveRateChangedNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: nil)
    }

    @objc func handleNotification(_ notification: Notification) {
        switch notification.name {
        case .TimebaseEffectiveRateChangedNotification:
            let timebase = notification.object as! CMTimebase
            let rate = CMTimebaseGetRate(timebase)
            self.perfMeasurements?.rateChanged(rate: rate)
            break
        case .AVPlayerItemPlaybackStalled:
            if let _ = notification.object as? AVPlayerItem {
                self.perfMeasurements?.playbackStalled()
            }
            break
        default:
            break
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("whkim vm observe \(keyPath)")
        switch keyPath {
        case "videoUrl":
            guard let newValue: URL = change?[.newKey] as? URL else { return }
            ShopLiveController.shared.playItem.videoUrl = newValue
//            self.updatePlayerItem(with: newValue)
            break
        case "isMuted":
            guard let newValue: Bool = change?[.newKey] as? Bool else { return }
            self.isMuted = newValue
            break
        case "timeControlStatus":
            guard let newValue: AVPlayer.TimeControlStatus = change?[.newKey] as? AVPlayer.TimeControlStatus else { return }
//            guard let oldValue: AVPlayer.TimeControlStatus = change?[.oldKey] as? AVPlayer.TimeControlStatus,
//                  let newValue: AVPlayer.TimeControlStatus = change?[.newKey] as? AVPlayer.TimeControlStatus, oldValue != newValue else { return }
            self.timeControlStatus = newValue
            break
        case "isPlayable":
            self.addPlayableAction()
            break
        case "status":
            guard let newValue: AVPlayerItem.Status = change?[.newKey] as? AVPlayerItem.Status else { return }
            self.playerItemStatus = newValue
            break
        case "isPlaybackLikelyToKeepUp":
            guard let newValue: Bool = change?[.newKey] as? Bool else { return }
            self.isPlaybackLikelyToKeepUp = newValue
            break
        case "duration":
            guard let newValue: CMTime = change?[.newKey] as? CMTime else { return }
            self.playerItemDuration = newValue
            break
        default:
            break
        }
    }
}

@available(iOS 13.0, *)
extension LiveStreamViewModel: ShopLivePlayerDelegate {
    var identifier: String {
        return "LiveStreamViewModel"
    }

    func updatedValue(key: ShopLivePlayerObserveValue) {
        switch key {
        case .videoUrl:
            print("whkim \(ShopLiveController.shared.playItem.videoUrl?.absoluteString ?? "videoUrl nil")")
            guard let videoUrl = ShopLiveController.shared.playItem.videoUrl else { return }
            updatePlayerItem(with: videoUrl)
        case .isPlayable:
            setupIsPlayble()
            break
        default:
            break
        }
    }
}
