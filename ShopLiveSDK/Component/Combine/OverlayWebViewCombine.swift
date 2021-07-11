//
//  OverlayWebView.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/02/08.
//

import UIKit
import WebKit
import Combine

@available(iOS 13.0, *)
class OverlayWebViewCombine: UIView {
    @Published var overlayUrl: URL?
    @Published var isMuted: Bool = false
    @Published var isPlaying: Bool = false
    @Published var isPipMode: Bool = false
    
    private var isSystemInitialized: Bool = false
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
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: ShopLiveDefines.webInterface)
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
        initObserver()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
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
        let configuration = webViewConfiguration ?? WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = false
        configuration.mediaTypesRequiringUserActionForPlayback = []
        //viewport-fit=cover //content="viewport-fit=cover"
        let source: String = "var meta = document.createElement('meta');" + "meta.name = 'viewport';" + "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover';" + "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);";

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
        webView.scrollView.contentInsetAdjustmentBehavior = .always
        webView.allowsLinkPreview = false
        webView.scrollView.layer.masksToBounds = false
        webView.configuration.userContentController.addUserScript(WKUserScript(source: source, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false))
        self.clipsToBounds = true

        webView.evaluateJavaScript("navigator.userAgent") { [weak webView] (result, error) in
            if let webView = webView, let defaultUserAgent = result as? String {
                webView.customUserAgent = defaultUserAgent + " shoplive/1.0.0"
            }
        }
        //TODO: 라이브 스트림 없어질 때 webView.configuration.userContentController.removeAllScriptMessageHandlers() 해줘야 한다
        webView.configuration.userContentController.add(self, name: ShopLiveDefines.webInterface)
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
                self.webView?.sendEventToWeb(event: .setIsPlayingVideo(isPlaying: isPlayingVideo), isPlayingVideo)
            }
            .store(in: &cancellableSet)
        
        $isMuted
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] (isMuted) in
                guard let self = self else { return }
                guard self.isSystemInitialized else { return }
                self.webView?.sendEventToWeb(event: .setIsMute, isMuted)
            }
            .store(in: &cancellableSet)
        
        $isPipMode
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] (isPipMode) in
                guard let self = self else { return }
                guard self.isSystemInitialized else { return }
                self.webView?.sendEventToWeb(event: .onPipModeChanged, isPipMode)
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
        self.webView?.sendEventToWeb(event: .completeDownloadCoupon, couponId)
    }
    
    func updatePipStyle(with style: ShopLive.PresentationStyle) {
        isPipMode = style == .pip
    }

    func sendEventToWeb(event: WebInterface, _ param: Any? = nil, _ wrapping: Bool = false) {
        self.webView?.sendEventToWeb(event: event, param, wrapping)
    }
}

@available(iOS 13.0, *)
extension OverlayWebViewCombine: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
}

@available(iOS 13.0, *)
extension OverlayWebViewCombine: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let interface = WebInterface(message: message) else { return }
        switch interface {
        case .systemInit:
            ShopLiveLogger.debugLog("systemInit")
            self.isSystemInitialized = true
            self.webView?.sendEventToWeb(event: .videoInitialized)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.webView?.sendEventToWeb(event: .setVideoMute(isMuted: self.isMuted), self.isMuted)
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
        case .setVideoCurrentTime(let time):
            self.delegate?.setVideoCurrentTime(to: .init(seconds: time, preferredTimescale: 1))
        case .command(let command, let payload):
            ShopLiveLogger.debugLog("rawCommand: \(command)\(payload == nil ? "" : "(\(payload as? String ?? "")")")
            self.delegate?.handleCommand(command, with: payload)
        default:
            break
        }
    }
}
