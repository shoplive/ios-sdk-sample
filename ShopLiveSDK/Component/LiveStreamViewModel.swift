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
        ShopLiveLogger.debugLog("reset viewModel")
        reset()
    }
    
    override init() {
        super.init()
        ShopLiveController.shared.addPlayerDelegate(delegate: self)
    }

    func reset() {
        overayUrl = nil
        accessKey = nil
        campaignKey = nil
        authToken = nil
        user = nil
    }

    func updatePlayerItem(with url: URL) {
        guard ShopLiveController.player != nil else { return }
//        _ = ShopLiveController.playerItemStatus
//        _ = ShopLiveController.urlAsset?.url == url
        resetPlayer()

        let asset = AVURLAsset(url: url)
//        ShopLiveController.urlAsset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        if asset.isPlayable {
            ShopLiveLogger.debugLog("abc")
            ShopLiveController.shared.playItem?.perfMeasurements = PerfMeasurements(playerItem: playerItem)
            let metadataOutput = AVPlayerItemMetadataOutput(identifiers: nil)
            metadataOutput.setDelegate(self, queue: DispatchQueue.main)
            playerItem.add(metadataOutput)
            playerItem.preferredForwardBufferDuration = 5

            ShopLiveController.playerItem = playerItem
            self.playerItem = playerItem

            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .TimebaseEffectiveRateChangedNotification, object: self.playerItem?.timebase)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .AVPlayerItemPlaybackStalled, object: self.playerItem)
            ShopLiveController.shared.playerItem?.player?.replaceCurrentItem(with: playerItem)
        } else {
            ShopLiveLogger.debugLog("def")
        }
    }

    private func resetPlayer() {
        guard ShopLiveController.player != nil else { return }
        if ShopLiveController.player?.currentItem == nil {
            return
        }
        ShopLiveController.videoUrl = nil
//        ShopLiveController.player?.pause()
        ShopLiveController.player?.currentItem?.asset.cancelLoading()
        ShopLiveController.player?.cancelPendingPrerolls()
        ShopLiveController.player?.replaceCurrentItem(with: nil)
        ShopLiveController.playerItem = nil
        ShopLiveController.urlAsset = nil
        ShopLiveController.shared.playItem?.perfMeasurements = nil

        ShopLiveController.perfMeasurements?.playbackEnded()
        ShopLiveController.perfMeasurements = nil

        NotificationCenter.default.removeObserver(self, name: .TimebaseEffectiveRateChangedNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: nil)

        ShopLiveController.playControl = .none
    }

    private func handleIsPlayble() {
//        guard let asset = ShopLiveController.urlAsset else { return }
//        let playerItem = AVPlayerItem(asset: asset)
//        ShopLiveController.shared.playItem?.perfMeasurements = PerfMeasurements(playerItem: playerItem)
//        let metadataOutput = AVPlayerItemMetadataOutput(identifiers: nil)
//        metadataOutput.setDelegate(self, queue: DispatchQueue.main)
//        playerItem.add(metadataOutput)
//        ShopLiveController.playerItem = playerItem
//        self.playerItem = playerItem
//
//        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .TimebaseEffectiveRateChangedNotification, object: self.playerItem?.timebase)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .AVPlayerItemPlaybackStalled, object: self.playerItem)
//        ShopLiveController.shared.playerItem?.player?.replaceCurrentItem(with: playerItem)
    }
    
    func play() {
        if let url = ShopLiveController.streamUrl, !url.absoluteString.isEmpty, (ShopLiveController.playerItemStatus == .failed || ShopLiveController.player?.reasonForWaitingToPlay == AVPlayer.WaitingReason.evaluatingBufferingRate) {
            ShopLiveLogger.debugLog("LiveStreamViewModel play()")
            updatePlayerItem(with: url)
        }
        else {
            if ShopLiveController.isReplayMode {
                if ShopLiveController.isReplayFinished {
                    seek(to: .init(value: 0, timescale: 1))
                }
            }
            /*
            else {
                if ShopLiveController.shared.needSeek { //}, ShopLiveController.windowStyle == .osPip {
                    ShopLiveLogger.debugLog("[REASON] time paused live needSeek ---> seek")
                    ShopLiveController.shared.needSeek = false
                    ShopLiveController.shared.seekToLatest()
                }
            }
             */
            ShopLiveController.player?.play()
        }
    }
    
    func stop() {
        resetPlayer()
    }

    func resume() {
        guard ShopLiveController.player?.timeControlStatus != .playing else { return }

        if ShopLiveController.isReplayMode {
            ShopLiveController.player?.play()
        } else {
            if let url = ShopLiveController.streamUrl, !url.absoluteString.isEmpty {
                if ShopLiveController.shared.needSeek {
                    ShopLiveLogger.debugLog("[REASON] time paused live needSeek ---> resume seek")
                    ShopLiveController.shared.needSeek = false
                    ShopLiveController.shared.seekToLatest()
                }
                ShopLiveController.player?.play()
//                if ShopLiveController.windowStyle == .osPip {
//                    ShopLiveController.player?.play()
//                } else {
//                    updatePlayerItem(with: url)
//                }
            }
        }
    }
    
    func reloadVideo() {
        guard let url = ShopLiveController.streamUrl else {
            resetPlayer()
            return
        }
        
        updatePlayerItem(with: url)
    }

    func seek(to: CMTime) {
        ShopLiveLogger.debugLog("seek to: \(to.value)")
        ShopLiveController.shared.currentPlayTime = to.value
        ShopLiveController.player?.seek(to: to)
    }

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
            if ShopLiveController.playControl != .pause, ShopLiveController.playControl != .play, ShopLiveController.windowStyle != .osPip {
                if ShopLiveController.isReplayMode && ShopLiveController.playControl == .resume { return }
                if ShopLiveController.isReplayMode, let duration = ShopLiveController.duration {
                    ShopLiveViewLogger.shared.addLog(log: .init(logType: .interface, log: "[ON_VIDEO_DURATION_CHANGED] duration total: \(duration)  CMTimeGetSeconds(duration): \(CMTimeGetSeconds(duration))"))
                    ShopLiveController.webInstance?.sendEventToWeb(event: .onVideoDurationChanged, CMTimeGetSeconds(duration))
                }
                ShopLiveLogger.debugLog("[ViewModel] handlePlayerItemStatus")
                self.play()
            }
        case .failed:
            ShopLiveLogger.debugLog("[ViewModel] PlayerItemStatus failed")
            ShopLiveLogger.debugLog("[REASON] player Item Status 'failed'")
            ShopLiveController.retryPlay = true
            break
        default:
            break
        }
    }

}

extension LiveStreamViewModel: ShopLivePlayerDelegate {
    func clear() {
        ShopLiveController.shared.removePlayerDelegate(delegate: self)
        resetPlayer()
    }

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
        case .releasePlayer:
            resetPlayer()
            break
        default:
            break
        }
    }
}

extension LiveStreamViewModel: AVPlayerItemMetadataOutputPushDelegate {
    func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {

        let payloads: NSMutableDictionary = .init()
        var timedMeta: String = "[timedMeta]\n"
        groups.forEach { group in
            group.items.forEach { item in

                if let key = item.key as? String, let datav = item.value as? Data {
                    timedMeta += "\(key): \(String(describing: item.value)) \n"
                    payloads[key] = datav.base64EncodedString()
//                    ShopLiveLogger.debugLog("item base64  \(datav.base64EncodedString())    origin: \(item.value)")
                }

                ShopLiveViewLogger.shared.addLog(log: .init(logType: .applog, log: timedMeta))
/*
                if let dataVa = item.dataValue, let valeng = item.dataValue?.count {
                    let str = String(decoding: dataVa, as: UTF8.self)
                    let startIdx: String.Index = str.index(str.startIndex, offsetBy: 1)
                    var result = String(str[startIdx...])

                    ShopLiveLogger.debugLog("whkimMeta test String str: \(str)")
                    ShopLiveLogger.debugLog("whkimMeta test String: \(result.fotmattedString())")
                    ShopLiveViewLogger.shared.addLog(log: .init(logType: .applog, log: "\(result.fotmattedString())"))
                } else if let strVa = item.stringValue {
                    ShopLiveLogger.debugLog("whkimMeta test String: \(strVa)")
                }
 */
            }
        }

        if payloads.count > 0 {
            ShopLiveController.shared.webInstance?.sendEventToWeb(event: .onVideoMetadataUpdated, payloads.toJson())
        }
        /*
        if let item = groups.first?.items.first {

            ShopLiveLogger.debugLog("item: \(item.description)\nitem debug: \(item.debugDescription)\nitem time: \(item.time)\nitem startdate: \(item.startDate)")

            ShopLiveLogger.debugLog("raw Metadata value: \n \(item.value(forKeyPath: #keyPath(AVMetadataItem.value))!)")

            if let dataVa = item.dataValue, let valeng = item.dataValue?.count {
                let str = String(decoding: dataVa, as: UTF8.self)
                let startIdx: String.Index = str.index(str.startIndex, offsetBy: 1)
                var result = String(str[startIdx...])

                ShopLiveLogger.debugLog("whkimMeta test String str: \(str)")
                ShopLiveLogger.debugLog("whkimMeta test String: \(result.fotmattedString())")
                ShopLiveViewLogger.shared.addLog(log: .init(logType: .applog, log: "\(result.fotmattedString())"))
            }


//            ShopLiveLogger.debugLog("timedMeta value: \(item.value?.debugDescription)")

//            if let timeValue = item.value {
//                let data: NSData = .init(bytes: timeValue, length: timeValue)
//                if let str = String(data: data, encoding: NSUTF8StringEncoding) {
//                    print(str)
//                } else {
//                    print("not a valid UTF-8 sequence")
//                }
//            }

        }
        */
    }
}
