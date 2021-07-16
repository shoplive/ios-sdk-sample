//
//  OverlayWebViewRxSwift.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/05/19.
//
#if canImport(RxCocoa)
import UIKit
import WebKit
import RxSwift
import RxCocoa

internal final class OverlayWebViewRxSwift: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    var overlayUrl: BehaviorRelay<URL?> = .init(value: nil)
    var isMuted: BehaviorRelay<Bool> = .init(value: false)
    var isPlaying: BehaviorRelay<Bool> = .init(value: false)
    var isPipMode: BehaviorRelay<Bool> = .init(value: false)

    private var isSystemInitialized: Bool = false
    private weak var webView: ShopLiveWebView?

    private lazy var cancellableDisposeBag = DisposeBag()

    weak var delegate: OverlayWebViewDelegate?
    weak var webviewUIDelegate: WKUIDelegate? {
        didSet {
            webView?.uiDelegate = webviewUIDelegate
        }
    }

    deinit {
        cancellableDisposeBag = DisposeBag()
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
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func initWebView(with webViewConfiguration: WKWebViewConfiguration? = nil) {
        let configuration = webViewConfiguration ?? WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = false
        configuration.mediaTypesRequiringUserActionForPlayback = []
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
    }

    private func initObserver() {

        overlayUrl
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] url in
                guard let url = url else { return }
                self?.loadOverlay(with: url)
            }).disposed(by: cancellableDisposeBag)

        isPlaying
            .skip(1)
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] isPlayingVideo in
                guard let self = self else { return }
                guard self.isSystemInitialized else { return }
                self.webView?.sendEventToWeb(event: .setIsPlayingVideo(isPlaying: isPlayingVideo), isPlayingVideo)
            }).disposed(by: cancellableDisposeBag)

        isMuted
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isMuted in
                guard let self = self else { return }
                guard self.isSystemInitialized else { return }
                self.webView?.sendEventToWeb(event: .setIsMute, isMuted)
            }.disposed(by: cancellableDisposeBag)

        isPipMode
            .skip(1)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isPipMode in
                guard let self = self else { return }
                guard self.isSystemInitialized else { return }
                self.webView?.sendEventToWeb(event: .onPipModeChanged, isPipMode)
            }.disposed(by: cancellableDisposeBag)
    }

    private func loadOverlay(with url: URL) {
        webView?.load(URLRequest(url: url))
    }

    func reload() {
        webView?.reload()
    }

    func didCompleteDownloadCoupon(with couponId: String) {
        webView?.sendEventToWeb(event: .completeDownloadCoupon, couponId)
    }

    func updatePipStyle(with style: ShopLive.PresentationStyle) {
        isPipMode.accept(style == .pip)
    }

    func sendEventToWeb(event: WebInterface, _ param: Any? = nil, _ wrapping: Bool = false) {
        self.webView?.sendEventToWeb(event: event, param, wrapping)
    }

}

extension OverlayWebViewRxSwift: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

    }
}

extension OverlayWebViewRxSwift: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let interface = WebInterface(message: message) else { return }
        switch interface {
        case .systemInit:
            ShopLiveLogger.debugLog("systemInit")
            self.isSystemInitialized = true
            self.webView?.sendEventToWeb(event: .videoInitialized)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.webView?.sendEventToWeb(event: .setVideoMute(isMuted: self.isMuted.value), self.isMuted.value)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                self.webView?.sendEventToWeb(event: .onPipModeChanged, self.isPipMode.value)
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
            self.isPlaying.accept(isPlaying)
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
            self.isPlaying.accept(true)
        case .pauseVideo:
            ShopLiveLogger.debugLog("navigation")
            self.delegate?.didTouchPauseButton()
            self.isPlaying.accept(false)
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
#endif
