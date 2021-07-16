//
//  LiveStreamViewModel.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/02/04.
//

import Foundation
import Combine
import AVKit

@available(iOS 13.0, *)
internal final class LiveStreamViewModelCombine {
    @Published var videoUrl: URL?
    @Published var playerItemStatus: AVPlayerItem.Status = .unknown
    @Published var isMuted: Bool = false
    @Published var timeControlStatus: AVPlayer.TimeControlStatus = .paused
    @Published var isPlaybackLikelyToKeepUp: Bool = false
    @Published var playerItemDuration: CMTime = .init()
    @Published var playControl: ShopLiveConfiguration.SLPlayControl = .none

    var overayUrl: URL?
    var accessKey: String?
    var campaignKey: String?
    var authToken: String? = nil
    var user: ShopLiveUser? = nil
    
    let videoPlayer: AVPlayer = AVPlayer()
    
    private var urlAsset: AVURLAsset?
    private var playerItem: AVPlayerItem?
    private var perfMeasurements: PerfMeasurements?
    
    private var cancellableSet = Set<AnyCancellable>()
    private var playerItemStatusCancellable: AnyCancellable?
    private var playerItemTimebaseCancellable: AnyCancellable?
    private var playerItemPlaybackStalledCancellable: AnyCancellable?
    private var urlAssetIsPlayableCancellable: AnyCancellable?
    private var playItemIsPlaybackLikelyToKeepUpCancellable: AnyCancellable?
    private var playerItemDurationCancellable: AnyCancellable?
    
    deinit {
        resetPlayer()
        
        for cancellable in cancellableSet {
            cancellable.cancel()
        }
        cancellableSet.removeAll()
    }
    
    init() {
        $videoUrl
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] (url) in
                guard let videoUrl = url else { return }
                self?.updatePlayerItem(with: videoUrl)
            }
            .store(in: &cancellableSet)
        
        videoPlayer.publisher(for: \.isMuted)
            .dropFirst()
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assign(to: \.isMuted, on: self)
            .store(in: &cancellableSet)
        
        videoPlayer.publisher(for: \.timeControlStatus)
            .dropFirst()
            .receive(on: RunLoop.main)
            .assign(to: \.timeControlStatus, on: self)
            .store(in: &cancellableSet)
    }
    
    private func updatePlayerItem(with url: URL) {
        //같은 url이 들어왔을 때 play item 의 상태와 현태 play 상태를 보고 url을 변경할지 결정한다.
        //끝나지 않는 버퍼링 상태(evaluatingBufferingRate) 일때 url 다시 세팅
        let isSameUrl = (playerItem?.asset as? AVURLAsset)?.url == url
        guard !isSameUrl || timeControlStatus != .playing else { return }
        guard !isSameUrl || playerItemStatus != .readyToPlay || videoPlayer.reasonForWaitingToPlay == AVPlayer.WaitingReason.evaluatingBufferingRate else {
            return
        }
        resetPlayer()
        
        urlAsset = AVURLAsset(url: url)
        urlAssetIsPlayableCancellable = urlAsset?.publisher(for: \.isPlayable)
            .receive(on: RunLoop.main)
            .filter({ $0 })
            .sink(receiveValue: { [weak self] (isPlayable) in
                guard let self = self else { return }
                guard let asset = self.urlAsset else { return }
                let playerItem = AVPlayerItem(asset: asset)
                
                self.perfMeasurements = PerfMeasurements(playerItem: playerItem)
                self.playerItemStatusCancellable = playerItem.publisher(for: \.status).assign(to: \.playerItemStatus, on: self)
                self.playItemIsPlaybackLikelyToKeepUpCancellable = playerItem.publisher(for: \.isPlaybackLikelyToKeepUp).assign(to: \.isPlaybackLikelyToKeepUp, on: self)
                self.playerItemDurationCancellable = playerItem.asset.publisher(for: \.duration).assign(to: \.playerItemDuration, on: self)
                self.playerItemTimebaseCancellable = NotificationCenter.default.publisher(for: .TimebaseEffectiveRateChangedNotification, object: playerItem.timebase)
                    .compactMap({ $0.object })
                    .map({ $0 as! CMTimebase })
                    .receive(on: RunLoop.main)
                    .sink(receiveValue: { [weak self] (timebase) in
                        let rate = CMTimebaseGetRate(timebase)
                        self?.perfMeasurements?.rateChanged(rate: rate)
                    })
                self.playerItemPlaybackStalledCancellable = NotificationCenter.default.publisher(for: .AVPlayerItemPlaybackStalled, object: playerItem)
                    .compactMap({ $0.object as? AVPlayerItem })
                    .receive(on: RunLoop.main)
                    .sink { [weak self] (playerItem) in
                        self?.perfMeasurements?.playbackStalled()
                    }
                
                self.videoPlayer.replaceCurrentItem(with: playerItem)
                
                self.playerItem = playerItem
            })
    }
    
    private func resetPlayer() {
        videoPlayer.pause()
        videoPlayer.replaceCurrentItem(with: nil)
        
        playerItemStatusCancellable?.cancel()
        playerItemStatusCancellable = nil
        playerItemTimebaseCancellable?.cancel()
        playerItemTimebaseCancellable = nil
        playerItemPlaybackStalledCancellable?.cancel()
        playerItemPlaybackStalledCancellable = nil
        urlAssetIsPlayableCancellable?.cancel()
        urlAssetIsPlayableCancellable = nil
        playItemIsPlaybackLikelyToKeepUpCancellable?.cancel()
        playItemIsPlaybackLikelyToKeepUpCancellable = nil
        
        perfMeasurements?.playbackEnded()
        perfMeasurements = nil
        
        playerItem = nil
        urlAsset = nil
    }
    
    func play() {
        if let url = videoUrl, (playerItemStatus == .failed || videoPlayer.reasonForWaitingToPlay == AVPlayer.WaitingReason.evaluatingBufferingRate) {
            updatePlayerItem(with: url)
        }
        else {
            videoPlayer.play()
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
        videoPlayer.seek(to: to)
    }
}
