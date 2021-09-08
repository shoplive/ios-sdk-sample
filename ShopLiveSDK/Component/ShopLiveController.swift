//
//  ShopLiveController.swift
//  ShopLivePlayer
//
//  Created by ShopLive on 2021/08/01.
//

import Foundation
import AVKit
import WebKit
import UIKit

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
    case takeSnapShot = "takeSnapShot"
    case loading = "loading"
}

enum ShopLiveWindowStyle {
    case none
    case inAppPip
    case osPip
    case normal
}

protocol ShopLivePlayerDelegate {
    var identifier: String { get }
    func isEqualTo(_ other: ShopLivePlayerDelegate) -> Bool

    func updatedValue(key: ShopLivePlayerObserveValue)
    func clear()
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
    }

    deinit {
    }

    private var playerDelegates: [ShopLivePlayerDelegate?] = []
    @objc dynamic var playItem: ShopLivePlayItem? = .init()
    @objc dynamic var playerItem: ShopLivePlayerItem? = .init()
    @objc dynamic var playControl: ShopLiveConfiguration.SLPlayControl = .none
    var isReplayMode: Bool = false
    var isMuted: Bool = false
    @objc dynamic var isHiddenOverlay: Bool = false
    @objc dynamic var overlayUrl: URL? = nil
    @objc dynamic var isPlaying: Bool = false
    @objc dynamic var retryPlay: Bool = false
    @objc dynamic var releasePlayer: Bool = false
    @objc dynamic var takeSnapShot: Bool = true
    @objc dynamic var isPreview: Bool = false
    @objc dynamic var loading: Bool = false
    var needReload: Bool = false
    var keyboardHeight: CGFloat = .zero

    var indicatorColor: UIColor = .white

    var snapShot: UIImage? = nil
    var streamUrl: URL? {
        didSet {
            ShopLiveController.videoUrl = streamUrl
        }
    }
    var windowStyle: ShopLiveWindowStyle = .normal
    var customShareAction: (() -> Void)?
    var hookNavigation: ((URL) -> Void)?
    var webInstance: ShopLiveWebView?
    var inputBoxFont: UIFont?
    var sendButtonFont: UIFont?
    var pipAnimationg: Bool = false
    var swipeEnabled: Bool = true

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, let key = ShopLivePlayerObserveValue(rawValue: keyPath), let _ = change?[.newKey] else { return }
        switch key {
        case .videoUrl, .isPlayable, .playControl, .isHiddenOverlay, .overlayUrl, .isPlaying, .releasePlayer, .takeSnapShot, .timeControlStatus:
            postPlayerObservers(key: key)
            break
        case .loading:
            postPlayerObservers(key: key)
            break
        case .playerItemStatus:
            if ShopLiveController.playerItemStatus == .readyToPlay {
                ShopLiveController.player?.isMuted = isPreview ? true : false
            }
            postPlayerObservers(key: key)
            break
        case .isMuted:
            if let old: Bool = change?[.oldKey] as? Bool, let new: Bool = change?[.newKey] as? Bool {
                if old != new {
                    postPlayerObservers(key: key)
                }
            } else {
                postPlayerObservers(key: key)
            }
            break
        case .retryPlay:
            if let old: Bool = change?[.oldKey] as? Bool, let new: Bool = change?[.newKey] as? Bool {
                if old != new {
                    guard let videoUrl = ShopLiveController.streamUrl, !videoUrl.absoluteString.isEmpty && videoUrl.absoluteString != "null" else {
                        ShopLiveLogger.debugLog("\(keyPath): guard return - videoUrl: \(String(describing: ShopLiveController.streamUrl))")
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
        guard self.playerDelegates.filter({ $0?.identifier == delegate.identifier }).isEmpty else { return }

        if playerDelegates.isEmpty {
            addPlayerObserver()
        }

        playerDelegates.append(delegate)
    }


    func removePlayerDelegate(delegate: ShopLivePlayerDelegate) {
        guard let index = self.playerDelegates.firstIndex(where: { $0?.identifier == delegate.identifier }) else { return }
        self.playerDelegates.remove(at: index)
        if playerDelegates.isEmpty {
            removePlayerObserver()
        }
    }

    func clear() {
        playerDelegates.forEach { delegate in
            delegate?.clear()
        }
        playerDelegates.removeAll()
        removePlayerObserver()
        reset()
    }

    func resetOnlyFinished() {
        indicatorColor = .white
    }

    private func reset() {
        playItem = nil
        playItem = .init()

        playerItem = nil
        playerItem = .init()

        playControl = .none
        isReplayMode = false
        isMuted = false
        isHiddenOverlay = false
        overlayUrl = nil
        isPlaying = false
        retryPlay = false
        streamUrl = nil
        releasePlayer = false
        webInstance = nil
        pipAnimationg = false
        windowStyle = .none
        needReload = false
    }

    func getSnapShot(completion: @escaping (UIImage?) -> Void) {
        guard let videoOutput = playItem?.videoOutput,
              let currentItem = playerItem?.player?.currentItem else { return }

        let currentTime = currentItem.currentTime()
        if let buffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
            let ciImage = CIImage(cvPixelBuffer: buffer)
            let imgRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
            if let videoImage = CIContext().createCGImage(ciImage, from: imgRect) {
                let image = UIImage.init(cgImage: videoImage)
                completion(image)
            } else {
                completion(nil)
            }
        }
    }

    func seekToLatest() {
        ShopLiveController.player?.seek(to: CMTimeMakeWithSeconds(Float64(MAXFLOAT), preferredTimescale: Int32(NSEC_PER_SEC)))
    }

}

// MARK: ShopLive Player Section
extension ShopLiveController {
    func addPlayerObserver() { 
        playItem?.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.videoUrl.rawValue, options: .new, context: nil)
        playItem?.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.isPlayable.rawValue, options: .new, context: nil)
        playItem?.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.playerItemStatus.rawValue, options: .new, context: nil)
        playItem?.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.videoUrl.rawValue, options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.timeControlStatus.rawValue, options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.isMuted.rawValue, options: .new, context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.isHiddenOverlay.rawValue, options: [.initial, .new], context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.overlayUrl.rawValue, options: [.initial, .old, .new], context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.isPlaying.rawValue, options: .new, context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.playControl.rawValue, options: .new, context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.retryPlay.rawValue, options: [.old, .new], context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.releasePlayer.rawValue, options: .new, context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.takeSnapShot.rawValue, options: .new, context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.loading.rawValue, options: .new, context: nil)
    }

    func removePlayerObserver() {
        playItem?.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.videoUrl.rawValue)
        playItem?.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.isPlayable.rawValue)
        playItem?.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.playerItemStatus.rawValue)
        playItem?.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.videoUrl.rawValue)
        playerItem?.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.timeControlStatus.rawValue)
        playerItem?.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.isMuted.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.isHiddenOverlay.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.overlayUrl.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.isPlaying.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.playControl.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.retryPlay.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.releasePlayer.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.takeSnapShot.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.loading.rawValue)
    }

    func postPlayerObservers(key: ShopLivePlayerObserveValue) {
        ShopLiveLogger.debugLog("key: \(key.rawValue)")

        playerDelegates.forEach { delegate in
            ShopLiveLogger.debugLog("playerDelegate.identifier: \(delegate?.identifier) - key: \(key)")
            delegate?.updatedValue(key: key)
        }
    }
}

extension ShopLiveController {

    static var player: AVPlayer? {
        set {
            shared.playerItem?.player = newValue
        }
        get {
            return shared.playerItem?.player
        }
    }

    static var videoUrl: URL? {
        set {
            shared.playItem?.videoUrl = newValue
        }
        get {
            return shared.playItem?.videoUrl
        }
    }

    static var playerItem: AVPlayerItem? {
        set {
            shared.playItem?.playerItem = newValue
            if let videoOutput = shared.playItem?.videoOutput {
                player?.currentItem?.remove(videoOutput)
                shared.playItem?.videoOutput = nil
            }
            let settings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            shared.playItem?.videoOutput = AVPlayerItemVideoOutput.init(pixelBufferAttributes: settings)
            if let videoOutput = shared.playItem?.videoOutput {
                shared.playItem?.playerItem?.add(videoOutput)
            }
        }
        get {
            return shared.playItem?.playerItem
        }
    }

    static var urlAsset: AVURLAsset? {
        set {
            shared.playItem?.urlAsset = newValue
        }
        get {
            return shared.playItem?.urlAsset
        }
    }

    static var playerItemStatus: AVPlayerItem.Status {
        get {
            return shared.playItem?.playerItem?.status ?? .unknown
        }
    }

    static var perfMeasurements: PerfMeasurements? {
        set {
            shared.playItem?.perfMeasurements = newValue
        }
        get {
            return shared.playItem?.perfMeasurements
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
        return shared.playerItem?.player?.currentItem?.asset.duration
    }

    static var timeControlStatus: AVPlayer.TimeControlStatus {
        return shared.playerItem?.player?.timeControlStatus ?? .paused
    }

    static var timebase: CMTimebase? {
        return shared.playItem?.playerItem?.timebase
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
            if ShopLiveController.streamUrl != nil {
                shared.retryPlay = newValue
            }
        }
        get {
            return shared.retryPlay
        }
    }

    static var streamUrl: URL? {
        set {
            shared.streamUrl = newValue
        }
        get {
            return shared.streamUrl
        }
    }

    static var windowStyle: ShopLiveWindowStyle {
        set {
            shared.windowStyle = newValue
        }
        get {
            return shared.windowStyle
        }
    }

    static var loading: Bool {
        set {
            shared.loading = newValue
        }
        get {
            return shared.loading
        }
    }
}
