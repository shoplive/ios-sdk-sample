//
//  OverlayWebView.swift
//  ShopLiveSDK
//
//  Created by purpleworks on 2021/02/08.
//

import UIKit
import WebKit
import Combine

protocol OverlayWebViewDelegate: class {
    func didUpdateVideo(with url: URL)
    func reloadVideo()
    func didUpdatePoster(with url: URL)
    func didUpdateForegroundPoster(with url: URL)
    func replay(with size: CGSize)
    
    func didTouchPlayButton()
    func didTouchPauseButton()
    func didTouchMuteButton(with isMuted: Bool)
    func didTouchPipButton()
    func didTouchCloseButton()
    func didTouchNavigation(with url: URL)
    func didTouchCoupon(with couponId: String)
    func handleCommand(_ command: String, with payload: Any?)
}

class OverlayWebView: UIView {
    @Published var overlayUrl: URL?
    @Published var isMuted: Bool = false
    @Published var isPlaying: Bool = false
    @Published var isPipMode: Bool = false
    
    private var isSystemInitialized: Bool = false
    private var isShownKeyboard: Bool = false
    private weak var webView: ShopLiveWebView?
    private lazy var cancellableSet = Set<AnyCancellable>()
    
    weak var delegate: OverlayWebViewDelegate?
    weak var webviewUIDelegate: WKUIDelegate? {
        didSet {
            webView?.uiDelegate = webviewUIDelegate
        }
    }
    
    deinit {
        cancellableSet.forEach { (cancellable) in
            cancellable.cancel()
        }
        cancellableSet.removeAll()
        delegate = nil
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "ShopLiveAppInterface")
        webView?.removeFromSuperview()
        webView = nil
    }
    
    init(with webViewConfiguration: WKWebViewConfiguration? =  nil) {
        super.init(frame: .zero)
        initWebView(with: webViewConfiguration)
        initObserver()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initWebView()
        initObserver()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWebView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func initWebView(with webViewConfiguration: WKWebViewConfiguration? = nil) {
        let configuration = webViewConfiguration ?? WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = false
        configuration.mediaTypesRequiringUserActionForPlayback = []
        let webView = ShopLiveWebView(frame: CGRect.zero, configuration: configuration)
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
        webView.allowsLinkPreview = false
        self.clipsToBounds = true
        
        webView.evaluateJavaScript("navigator.userAgent") { [weak webView] (result, error) in
            if let webView = webView, let defaultUserAgent = result as? String {
                webView.customUserAgent = defaultUserAgent + " shoplive/1.0.0"
            }
        }
        //TODO: 라이브 스트림 없어질 때 webView.configuration.userContentController.removeAllScriptMessageHandlers() 해줘야 한다
        webView.configuration.userContentController.add(self, name: "ShopLiveAppInterface")
        self.webView = webView
    }
    
    private func initObserver() {
        $overlayUrl
            .receive(on: RunLoop.main)
            .compactMap({ $0 })
            .sink { [weak self] (url) in
                self?.loadOverlay(with: url)
            }
            .store(in: &cancellableSet)
        
        $isPlaying
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] (isPlayingVideo) in
                guard let self = self else { return }
                guard self.isSystemInitialized else { return }
                self.webView?.evaluateJavaScript("window.__receiveAppEvent('SET_IS_PLAYING_VIDEO', \(isPlayingVideo));", completionHandler: nil)
            }
            .store(in: &cancellableSet)
        
        $isMuted
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] (isMuted) in
                guard let self = self else { return }
                guard self.isSystemInitialized else { return }
                self.webView?.evaluateJavaScript("window.__receiveAppEvent('SET_IS_MUTE', \(isMuted));", completionHandler: nil)
            }
            .store(in: &cancellableSet)
        
        $isPipMode
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] (isPipMode) in
                guard let self = self else { return }
                guard self.isSystemInitialized else { return }
                self.webView?.evaluateJavaScript("window.__receiveAppEvent('ON_PIP_MODE_CHANGED', \(isPipMode));", completionHandler: nil)
            }
            .store(in: &cancellableSet)
        
        // handle keyboard event
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] (notification) in
                self?.isShownKeyboard = true
            }
            .store(in: &cancellableSet)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardDidChangeFrameNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] (notification) in
                guard let keyboardFrameEndUserInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
                guard let keyboardFrameBeginUserInfo = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue else { return }
                guard let self = self else { return }
                guard self.isShownKeyboard else { return }
                let keyboardScreenBeginFrame = keyboardFrameBeginUserInfo.cgRectValue
                let keyboardScreenEndFrame = keyboardFrameEndUserInfo.cgRectValue
                
                if keyboardScreenBeginFrame == .zero, keyboardScreenEndFrame.width != self.webView?.bounds.width {
                    self.webView?.scrollView.contentOffset.y = -self.safeAreaInsets.top
                }
                else {
                    self.webView?.scrollView.contentOffset.y = keyboardScreenEndFrame.height - (self.safeAreaInsets.top)
                }
            }
            .store(in: &cancellableSet)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] (notification) in
                guard let self = self else { return }
                guard self.isShownKeyboard else { return }
                self.webView?.scrollView.contentOffset.y = -self.safeAreaInsets.top
            }
            .store(in: &cancellableSet)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] (notification) in
                guard let self = self else { return }
                guard self.isShownKeyboard else { return }
                guard self.isSystemInitialized else { return }
                guard let webView = self.webView else { return }
                self.isShownKeyboard = false
                webView.evaluateJavaScript("window.__receiveAppEvent('DOWN_KEYBOARD');", completionHandler: nil)
            }
            .store(in: &cancellableSet)
    }
    
    private func loadOverlay(with url: URL) {
        webView?.load(URLRequest(url: url))
    }
    
    func reload() {
        webView?.reload()
    }
    
    func didCompleteDownloadCoupon(with couponId: String) {
        webView?.evaluateJavaScript("window.__receiveAppEvent('COMPLETE_DOWNLOAD_COUPON', '\(couponId)');", completionHandler: nil)
    }
    
    func updatePipStyle(with style: ShopLive.PresentationStyle) {
        isPipMode = style == .pip
    }
}

extension OverlayWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
}

extension OverlayWebView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let interface = WebInterface(message: message) else { return }
        switch interface {
        case .systemInit:
            ShopLiveLogger.debugLog("systemInit")
            self.isSystemInitialized = true
            self.webView?.evaluateJavaScript("window.__receiveAppEvent('VIDEO_INITIALIZED');", completionHandler: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.webView?.evaluateJavaScript("window.__receiveAppEvent('SET_VIDEO_MUTE', \(self.isMuted));", completionHandler: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                self.webView?.evaluateJavaScript("window.__receiveAppEvent('ON_PIP_MODE_CHANGED', \(self.isPipMode));", completionHandler: nil)
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
            ShopLiveLogger.debugLog("setLiveStreamUrl(\(streamUrl))")
            self.delegate?.didUpdateVideo(with: streamUrl)
        case .setIsPlayingVideo(let isPlaying):
            if isPlaying {
                self.delegate?.didTouchPlayButton()
            }
            else {
                self.delegate?.didTouchPauseButton()
            }
            ShopLiveLogger.debugLog("setIsPlayingVideo(\(isPlaying))")
            self.isPlaying = isPlaying
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
            self.isPlaying = true
        case .pauseVideo:
            ShopLiveLogger.debugLog("navigation")
            self.delegate?.didTouchPauseButton()
            self.isPlaying = false
        case .clickShareButton(let url):
            ShopLiveLogger.debugLog("clickShareButton(\(url))")
        case .replay(let width, let height):
            ShopLiveLogger.debugLog("replay")
            self.delegate?.replay(with: CGSize(width: width, height: height))
        case .command(let command, let payload):
            ShopLiveLogger.debugLog("rawCommand: \(command)\(payload == nil ? "" : "(\(payload as? String ?? "")")")
            self.delegate?.handleCommand(command, with: payload)
        }
    }
}
