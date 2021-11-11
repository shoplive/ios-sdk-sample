//
//  OverlayWebView.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/02/08.
//

import UIKit
import WebKit

internal class OverlayWebView: UIView {
    @objc dynamic var isPipMode: Bool = false
    
    private var isSystemInitialized: Bool = false
    private weak var webView: ShopLiveWebView?
    
    weak var delegate: OverlayWebViewDelegate?
    weak var webviewUIDelegate: WKUIDelegate? {
        didSet {
            webView?.uiDelegate = webviewUIDelegate
        }
    }

    private var retryTimer: Timer?
    private var retryCount: Int = 0
    private var needSeek: Bool = false

    deinit {

    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: ShopLiveDefines.webInterface)
        webView?.removeFromSuperview()
        webView = nil
    }
    
    init(with webViewConfiguration: WKWebViewConfiguration? =  nil) {
        super.init(frame: .zero)
        initWebView(with: webViewConfiguration)
        addObserver()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initWebView()
        addObserver()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWebView()
        addObserver()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func setHidden(toHidden: Bool) {
        self.webView?.isHidden = toHidden
    }
    
    private lazy var blockTouchView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .red
//        view.alpha = 0.3
        view.isHidden = true
        return view
    }()

    private func initWebView(with webViewConfiguration: WKWebViewConfiguration? = nil) {
        ShopLiveController.shared.addPlayerDelegate(delegate: self)
        let configuration = webViewConfiguration ?? WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = false
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = ShopLiveWebView(frame: CGRect.zero, configuration: configuration)
//        webView.scrollView.contentInsetAdjustmentBehavior = .never
        ShopLiveController.webInstance = webView
        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([webView.topAnchor.constraint(equalTo: self.topAnchor),
                                     webView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                                     webView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                                     webView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
                
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.allowsLinkPreview = false
        webView.scrollView.layer.masksToBounds = false
//        webView.configuration.userContentController.addUserScript(WKUserScript(source: source, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false))
        self.clipsToBounds = true

        webView.evaluateJavaScript("navigator.userAgent") { [weak webView] (result, error) in
            if let webView = webView, let defaultUserAgent = result as? String {
                webView.customUserAgent = defaultUserAgent + " shoplive/\(ShopLiveDefines.sdkVersion)"
                ShopLiveLogger.debugLog("userAgent: "+defaultUserAgent + " shoplive/\(ShopLiveDefines.sdkVersion)")
                ShopLiveViewLogger.shared.addLog(log: .init(logType: .interface, log: "userAgent: "+defaultUserAgent + " shoplive/\(ShopLiveDefines.sdkVersion)"))
            }
        }
        //TODO: 라이브 스트림 없어질 때 webView.configuration.userContentController.removeAllScriptMessageHandlers() 해줘야 한다
        webView.configuration.userContentController.add(LeakAvoider(delegate: self), name: ShopLiveDefines.webInterface)
        self.webView = webView
        // setupBlockTouchView()
    }

    private func setupBlockTouchView() {
        self.addSubview(blockTouchView)
        self.bringSubviewToFront(blockTouchView)
        NSLayoutConstraint.activate([blockTouchView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
                                     blockTouchView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                                     blockTouchView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                                     blockTouchView.widthAnchor.constraint(equalTo: self.widthAnchor)
        ])

        self.blockTouchView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapBLockTouchView)))
    }

    func setBlockView(show: Bool) {
        self.blockTouchView.isHidden = !show
    }

    @objc private func tapBLockTouchView() {
        delegate?.didTouchBlockView()
    }
    
    private func loadOverlay(with url: URL) {
        DispatchQueue.main.async {
            self.webView?.load(URLRequest(url: url))
        }
    }
    
    func reload() {
        webView?.reload()
    }

    func didCompleteDownloadCoupon(with couponId: String) {
            self.webView?.sendEventToWeb(event: .completeDownloadCoupon, couponId, true)
        }

    func didCompleteDownloadCoupon(with couponResult: CouponResult) {
        guard let couponResultJson = couponResult.toJson() else {
            return
        }

        self.webView?.sendEventToWeb(event: .downloadCouponResult, couponResultJson)
    }

    func didCompleteCustomAction(with customActionResult: CustomActionResult) {
        guard let customActionResultJson = customActionResult.toJson() else {
            return
        }

        self.webView?.sendEventToWeb(event: .customActionResult, customActionResultJson)
    }

    func didCompleteCustomAction(with id: String) {
        self.webView?.sendEventToWeb(event: .completeCustomAction, id)
    }

    func closeWebSocket() {
        self.sendEventToWeb(event: .onTerminated)
    }

    func updatePipStyle(with style: ShopLive.PresentationStyle) {
        isPipMode = style == .pip
    }

    func sendEventToWeb(event: WebInterface, _ param: Any? = nil, _ wrapping: Bool = false) {
        self.webView?.sendEventToWeb(event: event, param, wrapping)
    }

     func addObserver() {
        self.addObserver(self, forKeyPath: "isPipMode", options: [.initial, .old, .new], context: nil)
     }

     func removeObserver() {
        self.removeObserver(self, forKeyPath: "isPipMode")
     }

     override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
         switch keyPath {
         case "isPipMode":
             guard let newValue: Bool = change?[.newKey] as? Bool else { return }
             guard self.isSystemInitialized else { return }
             self.webView?.sendEventToWeb(event: .onPipModeChanged, newValue)
             break
         default:
             break
         }
     }
}

extension OverlayWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ShopLiveController.shared.loading = false
    }
}

extension OverlayWebView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        ShopLiveLogger.debugLog("interface: \(WebInterface(message: message)?.functionString)")
        guard let interface = WebInterface(message: message) else { return }
        switch interface {
        case .systemInit:
            ShopLiveLogger.debugLog("systemInit")
            self.isSystemInitialized = true
            self.webView?.sendEventToWeb(event: .videoInitialized)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.webView?.sendEventToWeb(event: .setVideoMute(isMuted: ShopLiveController.isMuted), ShopLiveController.isMuted)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                self.webView?.sendEventToWeb(event: .onPipModeChanged, self.isPipMode)
            }
        case .setVideoMute(let isMuted):
            ShopLiveLogger.debugLog("setVideoMute(\(isMuted))")
            delegate?.didTouchMuteButton(with: isMuted)
        case .setPosterUrl(let posterUrl):
            ShopLiveLogger.debugLog("setPosterUrl(\(posterUrl))")
            self.delegate?.didUpdatePoster(with: posterUrl)
        case .setForegroundPosterUrl(let posterUrl):
            ShopLiveLogger.debugLog("setForegroundPosterUrl(\(posterUrl))")
            self.delegate?.didUpdateForegroundPoster(with: posterUrl)
        case .setLiveStreamUrl(let streamUrl):
            ShopLiveLogger.debugLog("setLiveStreamUrl(\(streamUrl.absoluteString))")
            self.delegate?.didUpdateVideo(with: streamUrl)
        case .setIsPlayingVideo(let isPlaying):
            if isPlaying {
                self.delegate?.didTouchPlayButton()
            }
            else {
                self.delegate?.didTouchPauseButton()
            }
            ShopLiveLogger.debugLog("setIsPlayingVideo(\(isPlaying))")
            ShopLiveController.isPlaying = isPlaying
        case .reloadVideo:
            ShopLiveLogger.debugLog("reloadVideo")
            self.delegate?.reloadVideo()
        case .startPictureInPicture:
            ShopLiveLogger.debugLog("startPictureInPicture")
            self.delegate?.didTouchPipButton()
        case .close:
            ShopLiveLogger.debugLog("close")
            self.delegate?.didTouchCloseButton()
        case .navigation(let navigationUrl):
            ShopLiveLogger.debugLog("navigation")
            self.delegate?.didTouchNavigation(with: navigationUrl)
        case .coupon(let id):
            ShopLiveLogger.debugLog("coupon")
            self.delegate?.didTouchCoupon(with: id)
        case .playVideo:
            ShopLiveLogger.debugLog("navigation")
            self.delegate?.didTouchPlayButton()
            ShopLiveController.isPlaying = true
        case .pauseVideo:
            ShopLiveLogger.debugLog("navigation")
            self.delegate?.didTouchPauseButton()
            ShopLiveController.isPlaying = false
        case .clickShareButton(let url):
            ShopLiveLogger.debugLog("clickShareButton(\(String(describing: url)))")
            self.delegate?.didTouchShareButton(with: url)
        case .replay(let width, let height):
            ShopLiveLogger.debugLog("replay")
            self.delegate?.replay(with: CGSize(width: width, height: height))
        case .setVideoCurrentTime(let time):
            self.delegate?.setVideoCurrentTime(to: .init(seconds: time, preferredTimescale: 1))
        case .enableSwipeDown:
            ShopLiveController.shared.swipeEnabled = true
        case .disableSwipeDown:
            ShopLiveController.shared.swipeEnabled = false
        case .customAction(let id, let type, let payload):
            self.delegate?.didTouchCustomAction(id: id, type: type, payload: payload)
            break
        case .onCampaignStatusChanged(let status):
            delegate?.didChangeCampaignStatus(status: status)
            break
        case .setParam(let key, let value):
            ShopLiveLogger.debugLog("setparam key: \(key) value: \(value)")
            ShopLiveStorage.set(key: key, value: value)
            break
        case .delParam(let key):
            ShopLiveStorage.remove(key: key)
            break
        case .showNativeDebug:
            ShopLiveViewLogger.shared.setVisible(show: true)
            break
        case .debuglog(let log):
            ShopLiveViewLogger.shared.addLog(log: .init(logType: .applog, log: log))
            break
        case .setUserName(let payload):
            delegate?.onSetUserName(payload)
            break
        case .error(let code, let message):
            delegate?.onError(code: code, message: message)
            break
        case .command(let command, let payload):
            ShopLiveLogger.debugLog("rawCommand: \(command)\(payload == nil ? "" : "(\(payload as? String ?? "")")")
            self.delegate?.handleCommand(command, with: payload)
        default:
            break
        }
    }
}

extension OverlayWebView: ShopLivePlayerDelegate {
    func clear() {
        ShopLiveController.shared.removePlayerDelegate(delegate: self)
        resetRetry()
        removeObserver()
        webView = nil
        delegate = nil
    }

    func handlePlayerItemStatus() {
        switch ShopLiveController.playerItemStatus {
        case .readyToPlay:
            ShopLiveController.retryPlay = false
            ShopLiveController.shared.takeSnapShot = false
            break
        case .failed:
            ShopLiveController.retryPlay = true
            ShopLiveLogger.debugLog("[OverlayWebview] PlayerItemStatus failed")
            ShopLiveLogger.debugLog("[OverlayWebview] retryPlay = true")
            break
        default:
            break
        }
    }

    func handleTimeControlStatus() {
        ShopLiveLogger.debugLog("timeControlStatus: \(ShopLiveController.timeControlStatus.rawValue)")
        switch ShopLiveController.timeControlStatus {
        case .paused: //0
            if ShopLiveController.isReplayMode {
//                ShopLiveController.webInstance?.sendEventToWeb(event: .setIsPlayingVideo(isPlaying: false), false)
                ShopLiveController.isPlaying = false
            }
            if ShopLiveController.windowStyle == .osPip, !ShopLiveController.isReplayMode {
                ShopLiveController.shared.needReload = true
                ShopLiveLogger.debugLog("timeControlStatus: needSeek true")
                needSeek = true
            }
            if ShopLiveController.playControl == .play {
                ShopLiveLogger.debugLog("timeControlStatus: pause")
                ShopLiveController.retryPlay = true
            }
        case .waitingToPlayAtSpecifiedRate: //버퍼링 1
            ShopLiveLogger.debugLog("timeControlStatus: buffering")
            ShopLiveController.shared.takeSnapShot = true
            if ShopLiveController.windowStyle == .osPip, !ShopLiveController.isReplayMode {
                ShopLiveController.shared.needReload = true
            } else {
                ShopLiveController.retryPlay = true
            }

            break
        case .playing: // 2

            if ShopLiveController.windowStyle == .osPip, needSeek, !ShopLiveController.isReplayMode {
                needSeek = false
                ShopLiveLogger.debugLog("seekToLatest")
                ShopLiveController.shared.seekToLatest()
            }

            if ShopLiveController.isReplayMode {
                ShopLiveController.webInstance?.sendEventToWeb(event: .setIsPlayingVideo(isPlaying: true), true)
            }

            ShopLiveLogger.debugLog("timeControlStatus: play")
            ShopLiveController.retryPlay = false
            ShopLiveController.shared.takeSnapShot = false
            ShopLiveController.isPlaying = true
        @unknown default:
            ShopLiveLogger.debugLog("TimeControlStatus - unknown")
             break
        }
    }

    func handleIsHiddenOverlay() {
        guard !ShopLiveController.isReplayMode else {
            self.isUserInteractionEnabled = !ShopLiveController.isHiddenOverlay
            return
        }
        guard !ShopLiveController.isHiddenOverlay else {
            self.isHidden = ShopLiveController.isHiddenOverlay
            return
        }
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        } completion: { (completion) in
            self.isHidden = ShopLiveController.isHiddenOverlay
        }
    }

    private func resetRetry() {
//        ShopLiveController.shared.takeSnapShot = false
        retryTimer?.invalidate()
        retryTimer = nil
        retryCount = 0
    }

    func handleRetryPlay() {
        ShopLiveLogger.debugLog("handleRetryPlay in \(ShopLiveController.retryPlay)")
        guard ShopLiveController.windowStyle != .osPip else {
            resetRetry()
            return
        }
        if ShopLiveController.retryPlay {

            retryTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                self.retryCount += 1

                if ShopLiveController.shared.streamUrl == nil {
                    ShopLiveLogger.debugLog("handleRetryPlay close loop in retry timer")
                    self.resetRetry()
                    return
                }

                ShopLiveLogger.debugLog("handleRetryPlay loop \(self.retryCount)")
                if (self.retryCount < 20 && self.retryCount % 2 == 0) || (self.retryCount >= 20 && self.retryCount % 5 == 0) {
                    if let videoUrl = ShopLiveController.streamUrl {
                        ShopLiveController.videoUrl = videoUrl
                        ShopLiveLogger.debugLog("videoUrl: \(videoUrl)")
                    } else {
                        ShopLiveController.retryPlay = false
                        ShopLiveController.shared.takeSnapShot = false
                        ShopLiveLogger.debugLog("videoUrl: ---nil")
                    }
                }
            }
        } else {
            resetRetry()
        }
    }

    var identifier: String {
        return "OverlayWebView"
    }

    func updatedValue(key: ShopLivePlayerObserveValue) {
        switch key {
        case .playerItemStatus:
            handlePlayerItemStatus()
            break
        case .timeControlStatus:
            handleTimeControlStatus()
            break
        case .isHiddenOverlay:
            handleIsHiddenOverlay()
            break
        case .overlayUrl:
            if let overlayUrl = ShopLiveController.overlayUrl { //}, !ShopLiveController.shared.isPreview {
                self.loadOverlay(with: overlayUrl)
                ShopLiveLogger.debugLog("overlayUrl exist \(overlayUrl.absoluteString)")
            } else {
                ShopLiveLogger.debugLog(".overlayUrl")
            }
            break
        case .isPlaying:
            guard self.isSystemInitialized else { return }
            ShopLiveController.webInstance?.sendEventToWeb(event: .setIsPlayingVideo(isPlaying: ShopLiveController.isPlaying), ShopLiveController.isPlaying)
            break
        case .retryPlay:
            handleRetryPlay()
            break
        default:
            break
        }
    }


}

class LeakAvoider : NSObject, WKScriptMessageHandler {
    weak var delegate : WKScriptMessageHandler?
    init(delegate:WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(
            userContentController, didReceive: message)
    }
}

extension NSObject {
    func propertyNames() -> [String] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap{ $0.label }
    }
}

internal extension CouponResult {
    func toJson() -> String? {
        let couponJson = NSMutableDictionary()
        couponJson.setValue(self.success, forKey: "success")
        couponJson.setValue(self.coupon, forKey: "coupon")
        couponJson.setValue(self.message ?? "", forKey: "message")
        couponJson.setValue(self.couponStatus.name, forKey: "couponStatus")
        couponJson.setValue(self.alertType.name, forKey: "alertType")
        return couponJson.toJson()
    }
}

internal extension CustomActionResult {
    func toJson() -> String? {
        let couponJson = NSMutableDictionary()
        couponJson.setValue(self.success, forKey: "success")
        couponJson.setValue(self.id, forKey: "id")
        couponJson.setValue(self.message ?? "", forKey: "message")
        couponJson.setValue(self.couponStatus.name, forKey: "couponStatus")
        couponJson.setValue(self.alertType.name, forKey: "alertType")
        return couponJson.toJson()
    }
}
