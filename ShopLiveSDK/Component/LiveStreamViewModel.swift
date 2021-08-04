//
//  LiveStreamViewModel.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/02/04.
//

import Foundation
import AVKit

internal final class LiveStreamViewModel: NSObject {

    var overayUrl: URL?
    var accessKey: String?
    var campaignKey: String?
    var authToken: String? = nil
    var user: ShopLiveUser? = nil
    
    private var urlAsset: AVURLAsset?
    private var playerItem: AVPlayerItem?
    private var perfMeasurements: PerfMeasurements?
    
    deinit {
        ShopLiveController.shared.addPlayerDelegate(delegate: self)
        resetPlayer()
    }
    
    override init() {
        super.init()
        ShopLiveController.shared.addPlayerDelegate(delegate: self)
    }
    
    private func updatePlayerItem(with url: URL) {
        guard let player = ShopLiveController.player else { return }
        let playerItemStatus = ShopLiveController.playerItemStatus
        let isSameUrl = ShopLiveController.urlAsset?.url == url
        guard !isSameUrl || player.timeControlStatus != .playing else { return }
        guard !isSameUrl || playerItemStatus != .readyToPlay || player.reasonForWaitingToPlay == .evaluatingBufferingRate else { return }

        resetPlayer()

        ShopLiveController.urlAsset = AVURLAsset(url: url)
    }

    private func resetPlayer() {
        ShopLiveController.player?.replaceCurrentItem(with: nil)
        ShopLiveController.player?.pause()
        ShopLiveController.playerItem = nil
        ShopLiveController.urlAsset = nil
        ShopLiveController.shared.playItem.perfMeasurements = nil

        ShopLiveController.perfMeasurements?.playbackEnded()
        ShopLiveController.perfMeasurements = nil

        NotificationCenter.default.removeObserver(self, name: .TimebaseEffectiveRateChangedNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: nil)

        ShopLiveController.playControl = .none
    }

    private func handleIsPlayble() {
        guard let asset = ShopLiveController.urlAsset else { return }
        let playerItem = AVPlayerItem(asset: asset)
        ShopLiveController.shared.playItem.perfMeasurements = PerfMeasurements(playerItem: playerItem)
        ShopLiveController.playerItem = playerItem

        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .TimebaseEffectiveRateChangedNotification, object: self.playerItem?.timebase)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .AVPlayerItemPlaybackStalled, object: self.playerItem)

        ShopLiveController.shared.playerItem.player?.replaceCurrentItem(with: playerItem)
/*
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .TimebaseEffectiveRateChangedNotification, object: self.playerItem?.timebase)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .AVPlayerItemPlaybackStalled, object: self.playerItem)

        ShopLiveController.player?.replaceCurrentItem(with: _playerItem)

        self.playerItem = _playerItem
        NotificationCenter.default.removeObserver(self, name: .TimebaseEffectiveRateChangedNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: nil)
 */
    }
    
    func play() {
        if let url = ShopLiveController.videoUrl, (ShopLiveController.playerItemStatus == .failed || ShopLiveController.player?.reasonForWaitingToPlay == AVPlayer.WaitingReason.evaluatingBufferingRate) {
            updatePlayerItem(with: url)
        }
        else {
            ShopLiveController.player?.play()
        }
    }
    
    func stop() {
        resetPlayer()
    }
    
    func reloadVideo() {
        guard let url = ShopLiveController.videoUrl else {
            resetPlayer()
            return
        }
        
        updatePlayerItem(with: url)
    }

    func seek(to: CMTime) {
        ShopLiveController.player?.seek(to: to)
    }

//    private func addIsPlayableObserver() {
//        urlAsset?.addObserver(self, forKeyPath: "isPlayable", options: [.initial, .new], context: nil)
//    }
//
//    private func removeIsPlayableObserver() {
//        urlAsset?.removeObserver(self, forKeyPath: "isPlayable")
//    }

    @objc func handleNotification(_ notification: Notification) {
        switch notification.name {
        case .TimebaseEffectiveRateChangedNotification:
            if let timebase = ShopLiveController.timebase {
                let rate = CMTimebaseGetRate(timebase)
                self.perfMeasurements?.rateChanged(rate: rate)
            }
            break
        case .AVPlayerItemPlaybackStalled:
            if let _ = ShopLiveController.playerItem {
                self.perfMeasurements?.playbackStalled()
            }
            break
        default:
            break
        }
    }

    func handlePlayerItemStatus() {
        switch ShopLiveController.playerItemStatus {
        case .readyToPlay:
            if ShopLiveController.playControl != .pause, ShopLiveController.playControl != .play {
                if ShopLiveController.isReplayMode && ShopLiveController.playControl == .resume { return }
                if ShopLiveController.isReplayMode, let duration = ShopLiveController.duration {
                    ShopLiveController.webInstance?.sendEventToWeb(event: .onVideoDurationChanged, CMTimeGetSeconds(duration))
                }
                self.play()
            }
        case .failed:
            break
        default:
            break
        }
    }
}

extension LiveStreamViewModel: ShopLivePlayerDelegate {
    var identifier: String {
        return "LiveStreamViewModel"
    }

    func updatedValue(key: ShopLivePlayerObserveValue) {
        switch key {
        case .videoUrl:
            guard let videoUrl = ShopLiveController.videoUrl else { return }
            updatePlayerItem(with: videoUrl)
            break
        case .isPlayable:
            handleIsPlayble()
            break
        case .playerItemStatus:
            handlePlayerItemStatus()
            break
        default:
            break
        }
    }
}
