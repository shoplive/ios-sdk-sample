//
//  LiveStreamViewModelRxSwift.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/05/19.
//

#if canImport(RxCocoa)
import Foundation
import AVKit
import RxSwift
import RxCocoa

extension Reactive where Base: AVPlayer {
    public var muted: Observable<Bool> {
        return self
          .observe(Bool.self, #keyPath(AVPlayer.isMuted))
            .map { $0 ?? false }
      }

    @available(iOS 10.0, *)
    public var timeControlStatus: Observable<AVPlayer.TimeControlStatus> {
        return self
            .observe(AVPlayer.TimeControlStatus.self, #keyPath(AVPlayer.timeControlStatus))
          .map { $0 ?? .paused }
      }
}
extension Reactive where Base: AVURLAsset {
    public var playable: Observable<Bool> {
        return self
            .observe(Bool.self, #keyPath(AVURLAsset.isPlayable))
            .map { $0 ?? false }
    }
}

extension Reactive where Base: AVPlayerItem {
    public var status: Observable<AVPlayerItem.Status> {
        return self
            .observe(AVPlayerItem.Status.self, #keyPath(AVPlayerItem.status))
            .map { $0 ?? .unknown }
    }

    public var playbackLikelyToKeepUp: Observable<Bool> {
        return self
            .observe(Bool.self, #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp))
            .map { $0 ?? false }
    }

    public var itemDuration: Observable<CMTime> {
        return self
            .observe(CMTime.self, #keyPath(AVPlayerItem.asset.duration))
            .map { $0 ?? CMTime() }
    }
}

final class LiveStreamViewModelRxSwift {

    var videoUrl: BehaviorRelay<URL?> = .init(value: nil)
    var playerItemStatus: BehaviorRelay<AVPlayerItem.Status> = .init(value: .unknown)
    var isMuted: BehaviorRelay<Bool> = .init(value: false)
    var timeControlStatus: BehaviorRelay<AVPlayer.TimeControlStatus> = .init(value: .paused)
    var isPlaybackLikelyToKeepUp: BehaviorRelay<Bool> = .init(value: false)
    var playerItemDuration: BehaviorRelay<CMTime> = .init(value: .init())
    var playControl: BehaviorRelay<ShopLiveConfiguration.SLPlayControl> = .init(value: .none)

    var overayUrl: URL?
    var accessKey: String?
    var campaignKey: String?
    var authToken: String? = nil
    var user: ShopLiveUser? = nil

    let videoPlayer: AVPlayer = AVPlayer()

    private var urlAsset: AVURLAsset?
    private var playerItem: AVPlayerItem?
    private var perfMeasurements: PerfMeasurements?

    private var cancellableDisposeBag = DisposeBag()
    private var playerItemStatusCancellable: Disposable?
    private var playerItemTimebaseCancellable: Disposable?
    private var playerItemPlaybackStalledCancellable: Disposable?
    private var urlAssetIsPlayableCancellable: Disposable?
    private var playItemIsPlaybackLikelyToKeepUpCancellable: Disposable?
    private var playerItemDurationCancellable: Disposable?

    deinit {
        cancellableDisposeBag = DisposeBag()
        playerItemStatusCancellable?.dispose()
        playerItemStatusCancellable = nil

        playerItemTimebaseCancellable?.dispose()
        playerItemTimebaseCancellable = nil

        playerItemPlaybackStalledCancellable?.dispose()
        playerItemPlaybackStalledCancellable = nil

        urlAssetIsPlayableCancellable?.dispose()
        urlAssetIsPlayableCancellable = nil

        playItemIsPlaybackLikelyToKeepUpCancellable?.dispose()
        playItemIsPlaybackLikelyToKeepUpCancellable = nil
    }

    init() {
        setupRx()
    }

    private func setupRx() {
        videoUrl
            .skip(1)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] url in
                guard let videoUrl = url else { return }
                self?.updatePlayerItem(with: videoUrl)
            }.disposed(by: cancellableDisposeBag)

        videoPlayer.rx.muted
            .skip(1)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorRecover: { _ in .never() })
            .drive(self.isMuted).disposed(by: self.cancellableDisposeBag)

        videoPlayer.rx.timeControlStatus
            .skip(1)
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorRecover: { _ in .never() })
            .drive(self.timeControlStatus)
            .disposed(by: self.cancellableDisposeBag)
    }

    private func resetPlayer() {
        videoPlayer.pause()
        videoPlayer.replaceCurrentItem(with: nil)

        playerItemStatusCancellable?.dispose()
        playerItemStatusCancellable = nil

        playerItemTimebaseCancellable?.dispose()
        playerItemTimebaseCancellable = nil

        playerItemPlaybackStalledCancellable?.dispose()
        playerItemPlaybackStalledCancellable = nil

        playerItemDurationCancellable?.dispose()
        playerItemDurationCancellable = nil

        urlAssetIsPlayableCancellable?.dispose()
        urlAssetIsPlayableCancellable = nil

        playItemIsPlaybackLikelyToKeepUpCancellable?.dispose()
        playItemIsPlaybackLikelyToKeepUpCancellable = nil

        perfMeasurements?.playbackEnded()
        perfMeasurements = nil

        playerItem = nil
        urlAsset = nil
    }

    func play() {
        if let url = videoUrl.value, (playerItemStatus.value == .failed || videoPlayer.reasonForWaitingToPlay == AVPlayer.WaitingReason.evaluatingBufferingRate) {
            updatePlayerItem(with: url)
        }
        else {
            videoPlayer.play()
        }
    }

    private func updatePlayerItem(with url: URL) {
        //같은 url이 들어왔을 때 play item 의 상태와 현태 play 상태를 보고 url을 변경할지 결정한다.
        //끝나지 않는 버퍼링 상태(evaluatingBufferingRate) 일때 url 다시 세팅
        let isSameUrl = (playerItem?.asset as? AVURLAsset)?.url == url
        guard !isSameUrl || timeControlStatus.value != .playing else { return }
        guard !isSameUrl || playerItemStatus.value != .readyToPlay || videoPlayer.reasonForWaitingToPlay == AVPlayer.WaitingReason.evaluatingBufferingRate else {
            return
        }

        resetPlayer()

        urlAsset = AVURLAsset(url: url)
        urlAssetIsPlayableCancellable = urlAsset?.rx.playable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                guard let asset = self.urlAsset else { return }
                let playerItem = AVPlayerItem(asset: asset)

                self.perfMeasurements = PerfMeasurements(playerItem: playerItem)
                self.playerItemStatusCancellable = playerItem.rx.status
                    .asDriver(onErrorRecover: { _ in .never() })
                    .drive(self.playerItemStatus)
                self.playItemIsPlaybackLikelyToKeepUpCancellable = playerItem.rx.playbackLikelyToKeepUp
                    .asDriver(onErrorRecover: { _ in .never() })
                    .drive(self.isPlaybackLikelyToKeepUp)
                self.playerItemDurationCancellable = playerItem.rx.itemDuration
                    .asDriver(onErrorRecover: { _ in .never() })
                    .drive(self.playerItemDuration)

                self.playerItemTimebaseCancellable = NotificationCenter.default.rx.notification(.TimebaseEffectiveRateChangedNotification, object: playerItem.timebase)
                        .map { $0.object as! CMTimebase }
                        .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] timebase in
                        let rate = CMTimebaseGetRate(timebase)
                        self?.perfMeasurements?.rateChanged(rate: rate)
                    })

                self.playerItemPlaybackStalledCancellable =
                    NotificationCenter.default.rx.notification(.AVPlayerItemPlaybackStalled, object: playerItem)
                    .map { $0.object as? AVPlayerItem }
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] playeritem in
                        self?.perfMeasurements?.playbackStalled()
                    })

                self.videoPlayer.replaceCurrentItem(with: playerItem)

                self.playerItem = playerItem
            })
    }

    func stop() {
        resetPlayer()
    }

    func reloadVideo() {
        guard let url = videoUrl.value else {
            resetPlayer()
            return
        }

        updatePlayerItem(with: url)
    }

    func seek(to: CMTime) {
        videoPlayer.seek(to: to)
    }

}
#endif
