//
//  LiveStreamViewController.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/02/04.
//

import UIKit
import WebKit
import AVKit
import CallKit
import MediaPlayer
import ExternalAccessory

internal final class LiveStreamViewController: UIViewController {

    @objc dynamic lazy var viewModel: LiveStreamViewModel = LiveStreamViewModel()
    weak var delegate: LiveStreamViewControllerDelegate?

    var webViewConfiguration: WKWebViewConfiguration?

    private var overlayView: OverlayWebView?
    private var imageView: UIImageView?
    private var foregroundImageView: UIImageView?

    var playerView: ShopLivePlayerView = .init()
//    private lazy var videoView: UIView = .init()//VideoView = VideoView()

    private var playTimeObserver: Any?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private var bufferingTask: DispatchWorkItem?

    var playerLayer: AVPlayerLayer? {
        return playerView.playerLayer
    }
    // optional: cancel task
    deinit {
        ShopLiveController.retryPlay = false
        removeObserver()
        removePlaytimeObserver()
    }

    override func removeFromParent() {
        super.removeFromParent()
        overlayView?.delegate = nil

        overlayView?.removeFromSuperview()
        imageView?.removeFromSuperview()
        foregroundImageView?.removeFromSuperview()
        playerView.removeFromSuperview()

        overlayView = nil
        imageView = nil
        foregroundImageView = nil
    }

    private func addPlayTimeObserver() {
        let time = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        playTimeObserver = ShopLiveController.player?.addPeriodicTimeObserver(forInterval: time, queue: .main, using: { (time) in
                let time = CMTimeGetSeconds(time)
//                let duration = CMTimeGetSeconds(ShopLiveController.player?.currentItem?.asset.duration ?? CMTime())
//                ShopLiveLogger.debugLog("addPlayTimeObserver time: \(time)  duration: \(duration)")
                ShopLiveController.webInstance?.sendEventToWeb(event: .onVideoTimeUpdated, time)
            })
    }

    private func removePlaytimeObserver() {
        if let playTimeObserver = self.playTimeObserver {
            ShopLiveController.player?.removeTimeObserver(playTimeObserver)
            self.playTimeObserver = nil
        }
    }

    @objc func audioRouteChangeListener(notification: NSNotification) {
        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt

        switch audioRouteChangeReason {
        case AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue:
            updateHeadPhoneStatus(plugged: true)
        case AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue:
            updateHeadPhoneStatus(plugged: false)
        default:
            break
        }
    }

    private func updateHeadPhoneStatus(plugged: Bool) {
        if !ShopLiveConfiguration.soundPolicy.keepPlayVideoOnHeadphoneUnplugged {
            ShopLiveController.playControl = plugged ? .resume : ShopLiveController.isReplayMode ? .pause : .stop
        }
    }

    var callObserver = CXCallObserver()
    func setupCallState() {
        callObserver.setDelegate(self, queue: DispatchQueue.main)
    }

    private func setupAudioConfig() {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute
            if currentRoute.outputs.count != 0 {
                for description in currentRoute.outputs {
                    if description.portType == AVAudioSession.Port.headphones {
                        updateHeadPhoneStatus(plugged: true)
                    } else {
                        updateHeadPhoneStatus(plugged: false)
                    }
                }
            } else {
                //print("requires connection to device")
            }
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(audioRouteChangeListener(notification:)),
                name: AVAudioSession.routeChangeNotification,
                object: nil)
    }

    var hasKeyboard: Bool = false
    private func setKeyboard(notification: Notification) {
        guard let keyboardFrameEndUserInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
              let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom else { return }

        let keyboardScreenEndFrame = keyboardFrameEndUserInfo.cgRectValue
        let keyboard = self.view.convert(keyboardScreenEndFrame, from: self.view.window)
        let height = self.view.frame.size.height
        var isHiddenView = true
        switch notification.name.rawValue {
        case "UIKeyboardWillHideNotification":
            lastKeyboardHeight = 0
//            self.overlayView?.setBlockView(show: false)
            if chatInputView.isFocused() {
                self.hasKeyboard = true
                isHiddenView = false
                self.chatInputView.isHidden = false
                self.chatInputBG.isHidden = false
            }

            let param: Dictionary = Dictionary<String, Any>.init(dictionaryLiteral: ("value", hasKeyboard ? "\(self.chatInputView.frame.height)px" : "0px"), ("keyboard", hasKeyboard))
            ShopLiveController.webInstance?.sendEventToWeb(event: .setChatListMarginBottom, param.toJson())
            ShopLiveController.webInstance?.sendEventToWeb(event: .hiddenChatInput)
            chatConstraint.constant = 0
            break
        case "UIKeyboardWillShowNotification":
            hasKeyboard = (keyboard.origin.y + keyboard.size.height) > height
            lastKeyboardHeight = keyboardScreenEndFrame.height
            chatConstraint.constant = -(keyboardScreenEndFrame.height - bottomPadding)
//            self.overlayView?.setBlockView(show: true)
            let param: Dictionary = Dictionary<String, Any>.init(dictionaryLiteral: ("value", "\(Int((hasKeyboard ? 0 : lastKeyboardHeight) + self.chatInputView.frame.height))px"), ("keyboard", hasKeyboard))
            ShopLiveController.webInstance?.sendEventToWeb(event: .setChatListMarginBottom, param.toJson())
            isHiddenView = false
        default:
            break
        }
        let options = UIView.AnimationOptions(rawValue: curve << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            if isHiddenView {
                self.chatInputView.isHidden = isHiddenView
                self.chatInputBG.isHidden = isHiddenView
            }
            self.view.layoutIfNeeded()
        } completion: { (isComplete) in
            if isComplete {
                self.chatInputView.focusOut()
            }
        }
    }

//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        playerView.player.fit()
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadOveray()
        setupCallState()
        setupAudioConfig()
        addPlayTimeObserver()
        addObserver()
    }

    private func setupView() {
        view.backgroundColor = .black

        setupBackgroundImageView()
        setupPlayerView()
        setupForegroungImageView()
        setupOverayWebview()
        setupChatInputView()
    }

    func play() {
//        viewModel.play()
    }

    func pause() {
        ShopLiveController.player?.pause()
        ShopLiveController.isPlaying = false
    }

    func stop() {
        guard let videoUrl = ShopLiveController.videoUrl, !videoUrl.absoluteString.isEmpty || videoUrl.absoluteString != "null" else {
                        ShopLiveController.retryPlay = false
                        return
                    }
            ShopLiveController.retryPlay = true
//        ShopLiveController.webInstance?.sendEventToWeb(event: .reloadBtn, true)
        viewModel.stop()
    }

    func resume() {
        if ShopLiveController.isReplayMode {
            ShopLiveController.isPlaying = true
            self.play()
        } else {
//            ShopLiveController.webInstance?.sendEventToWeb(event: .reloadBtn, false)
            self.play()
        }
    }

    func reload() {
        ShopLiveController.overlayUrl = playUrl
    }

    func didCompleteDownLoadCoupon(with couponId: String) {
        overlayView?.didCompleteDownloadCoupon(with: couponId)
    }

    func didCompleteCustomAction(with id: String) {
        overlayView?.didCompleteCustomAction(with: id)
    }

    func hideBackgroundPoster() {
        imageView?.isHidden = true
        dismissKeyboard()
    }

    func showBackgroundPoster() {
        imageView?.isHidden = false
    }

    func onTerminated() {
        overlayView?.closeWebSocket()
    }

    func onBackground() {
        overlayView?.sendEventToWeb(event: .onBackground)
    }

    func onForeground() {
        overlayView?.sendEventToWeb(event: .onForeground)
    }

    private func setupForegroungImageView() {
        let foregroundImageView = UIImageView()
        foregroundImageView.isHidden = true
        foregroundImageView.contentMode = .scaleAspectFill
        view.addSubview(foregroundImageView)
        foregroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[foregroundImageView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["foregroundImageView": foregroundImageView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[foregroundImageView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["foregroundImageView": foregroundImageView]))
        self.foregroundImageView = foregroundImageView
    }

    private func setupBackgroundImageView() {
        let imageView = UIImageView()
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["imageView": imageView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["imageView": imageView]))
        self.imageView = imageView
    }

    private let bottomItemSpacing: CGFloat = 21
    private func setupOverayWebview() {
        let overlayView = OverlayWebView(with: webViewConfiguration)
        overlayView.webviewUIDelegate = self
        overlayView.delegate = self

        view.addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([overlayView.topAnchor.constraint(equalTo: view.topAnchor),
                                     overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     overlayView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     overlayView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        self.overlayView = overlayView
    }
    
    var topAnchor: NSLayoutConstraint!
    var topSafeAnchor: NSLayoutConstraint!
    private func setupPlayerView() {

        playerView.playerLayer.player = playerView.player
        playerView.playerLayer.videoGravity = .resizeAspectFill
        playerView.playerLayer.needsDisplayOnBoundsChange = true
        ShopLiveController.shared.playerItem.player = playerView.player
        ShopLiveController.shared.playerItem.playerLayer = playerLayer

        view.addSubview(playerView)
//        videoView.addSubview(playerView)
//        playerView.fitToSuperView()

        topAnchor = playerView.topAnchor.constraint(equalTo: view.topAnchor)
        topSafeAnchor = playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        playerView.translatesAutoresizingMaskIntoConstraints = false

        topAnchor.isActive = true
        topSafeAnchor.isActive = false
//        updateTopAnchor(isPip: false)
        NSLayoutConstraint.activate([playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func updateTopAnchor(isPip: Bool) {
        topAnchor.isActive = isPip
        topSafeAnchor.isActive = !isPip
    }

    private var chatConstraint: NSLayoutConstraint!
    private lazy var chatInputView: ChattingWriteView = {
        let chatView = ChattingWriteView()
        chatView.isHidden = true
        chatView.translatesAutoresizingMaskIntoConstraints = false
        chatView.delegate = self
        return chatView
    }()

    private lazy var chatInputBG: UIView = {
            let chatBG = UIView()
            chatBG.translatesAutoresizingMaskIntoConstraints = false
            chatBG.backgroundColor = .white
            chatBG.isHidden = true
            return chatBG
        }()

    private var lastKeyboardHeight: CGFloat = 0

    private func setupChatInputView() {
        view.addSubview(chatInputView)

        chatConstraint = NSLayoutConstraint.init(item: chatInputView, attribute: .bottom, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0)
        let chatLeading = NSLayoutConstraint.init(item: chatInputView, attribute: .leading, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1.0, constant: 0)
        let chatTrailing = NSLayoutConstraint.init(item: chatInputView, attribute: .trailing, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1.0, constant: 0)

        self.view.addConstraints([
            chatLeading, chatTrailing, chatConstraint
        ])

        self.view.addSubview(chatInputBG)
        NSLayoutConstraint.activate([
                                     chatInputBG.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     chatInputBG.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)])
        self.view.addConstraints([
            NSLayoutConstraint(item: chatInputBG, attribute: .top, relatedBy: .equal, toItem: self.chatInputView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: chatInputBG, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        ])
        
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
    }

    private func loadOveray() {
        ShopLiveController.overlayUrl = playUrl
    }

    private var playUrl: URL? {
        guard let baseUrl = viewModel.overayUrl else { return nil }
        var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
        var queryItems = urlComponents?.queryItems ?? [URLQueryItem]()

        if let authToken = viewModel.authToken, !authToken.isEmpty {
            queryItems.append(URLQueryItem(name: "tk", value: authToken))
        }
        if let name = viewModel.user?.name, !name.isEmpty {
            queryItems.append(URLQueryItem(name: "userName", value: name))
        }
        if let userId = viewModel.user?.id, !userId.isEmpty {
            queryItems.append(URLQueryItem(name: "userId", value: userId))
        }
        if let gender = viewModel.user?.gender, gender != .unknown {
            queryItems.append(URLQueryItem(name: "gender", value: gender.description))
        }
        if let age = viewModel.user?.age, age > 0 {
            queryItems.append(URLQueryItem(name: "age", value: String(age)))
        }
        urlComponents?.queryItems = queryItems
        debugPrint("play url: \(urlComponents?.url?.absoluteString ?? "")")
        return urlComponents?.url
    }

    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func handleNotification(_ notification: Notification) {
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            self.chatInputView.isHidden = false
            self.chatInputBG.isHidden = false
            self.setKeyboard(notification: notification)
            break
        case UIResponder.keyboardWillHideNotification:
            self.setKeyboard(notification: notification)
            break
        default:
            break
        }
    }
}

extension LiveStreamViewController: OverlayWebViewDelegate {
    func didTouchCustomAction(id: String, type: String, payload: Any?) {
        ShopLiveLogger.debugLog("id \(id) type \(type) payload: \(payload)")
        delegate?.didTouchCustomAction(id: id, type: type, payload: payload)
    }

    func shareAction(url: URL) {
//        let text = "Hello, How are you doing?...."
        let shareAll:[Any] = [url]//, text]

        let activityViewController = UIActivityViewController(activityItems: shareAll , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    func didTouchShareButton(with url: URL) {
        guard let custom = ShopLiveController.shared.customShareAction else {
            // common 공유하기
            shareAction(url: url)
            return
        }
        custom()
    }

    func didTouchBlockView() {
        dismissKeyboard()
    }

    func replay(with size: CGSize) {
        ShopLiveController.isReplayMode = true
        delegate?.replay(with: size)
    }

    func didTouchCoupon(with couponId: String) {
        delegate?.didTouchCoupon(with: couponId)
    }

    func didTouchMuteButton(with isMuted: Bool) {
        ShopLiveController.player?.isMuted = isMuted
    }

    func reloadVideo() {
//        viewModel.reloadVideo()
    }

    func setVideoCurrentTime(to: CMTime) {
        viewModel.seek(to: to)
    }

    func didUpdatePoster(with url: URL) {
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: url) else { return }
            guard let image = UIImage(data: imageData) else { return }
            DispatchQueue.main.async {
                self.imageView?.image = image
            }
        }
    }

    func didUpdateForegroundPoster(with url: URL) {
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: url) else { return }
            guard let image = UIImage(data: imageData) else { return }
            DispatchQueue.main.async {
                self.foregroundImageView?.image = image
                self.foregroundImageView?.isHidden = false
            }
        }
    }

    func didUpdateVideo(with url: URL) {
        ShopLiveController.videoUrl = url
    }

    func didTouchPlayButton() {
        play()
    }

    func didTouchPauseButton() {
        pause()
    }

    func didTouchPlayButton(with isPlaying: Bool) {
        if isPlaying {
            play()
        }
        else {
            pause()
        }
    }

    func didTouchNavigation(with url: URL) {
        delegate?.didTouchNavigation(with: url)
    }

    func updatePipStyle(with style: ShopLive.PresentationStyle) {
        overlayView?.updatePipStyle(with: style)
    }

    @objc func didTouchPipButton() {
        delegate?.didTouchPipButton()
    }

    @objc func didTouchCloseButton() {
        overlayView?.closeWebSocket()
        delegate?.didTouchCloseButton()
    }

    func handleCommand(_ command: String, with payload: Any?) {
        let interface = WebInterface.WebFunction.init(rawValue: command)
        switch interface  {
        case .setConf:
            let chatInitData = payload as? [String : Any]
            let placeHolder = chatInitData?["chatInputPlaceholderText"] as? String
            let sendText = chatInitData?["chatInputSendText"] as? String
            let chatInputMaxLength = chatInitData?["chatInputMaxLength"] as? Int
            chatInputView.configure(viewModel: .init(placeholder: placeHolder ?? NSLocalizedString("chat.placeholder", comment: "메시지를 입력하세요"), sendText: sendText ?? NSLocalizedString("chat.send.title", comment: "보내기"), maxLength: chatInputMaxLength ?? 50))
            break
        case .showChatInput:
            chatInputView.focus()
            break
        case .written:
            if (payload as? Int ?? 1) == 0 { chatInputView.clear() }
            break
        default:
            delegate?.handleCommand(command, with: payload)
            break
        }
    }

    func showDefaultAlert(with title: String?, message: String?, handler: (() -> ())? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "확인", style: .cancel, handler: { (action) in
            handler?()
        }))
        let veiwController = presentedViewController ?? self

//        if UIDevice.current.userInterfaceIdiom == .pad {
//            //디바이스 타입이 iPad일때
//            if let popoverController = alertController.popoverPresentationController {
//                // ActionSheet가 표현되는 위치를 저장해줍니다.
//                popoverController.sourceView = veiwController.view
//                popoverController.sourceRect = CGRect(x: veiwController.view.bounds.midX, y: veiwController.view.bounds.midY, width: 0, height: 0)
//                popoverController.permittedArrowDirections = []
//                veiwController.present(alertController, animated: true, completion: nil)
//            }
//        }
//        else {
            veiwController.present(alertController, animated: true, completion: nil)
//        }
    }
}

extension LiveStreamViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))

        if UIDevice.current.userInterfaceIdiom == .pad {
            //디바이스 타입이 iPad일때
            if let popoverController = alertController.popoverPresentationController {
                // ActionSheet가 표현되는 위치를 저장해줍니다.
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                present(alertController, animated: true, completion: nil)
            }
        }
        else {
            present(alertController, animated: true, completion: nil)
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))

        if UIDevice.current.userInterfaceIdiom == .pad {
            //디바이스 타입이 iPad일때
            if let popoverController = alertController.popoverPresentationController {
                // ActionSheet가 표현되는 위치를 저장해줍니다.
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                present(alertController, animated: true, completion: nil)
            }
        }
        else {
            present(alertController, animated: true, completion: nil)
        }
        present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .actionSheet)

        alertController.addTextField { (textField) in
            textField.text = defaultText
        }

        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))

        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        if UIDevice.current.userInterfaceIdiom == .pad {
            //디바이스 타입이 iPad일때
            if let popoverController = alertController.popoverPresentationController {
                // ActionSheet가 표현되는 위치를 저장해줍니다.
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                present(alertController, animated: true, completion: nil)
            }
        }
        else {
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension LiveStreamViewController: ChattingWriteDelegate {
    func didTouchSendButton() {
        let message: Dictionary = Dictionary<String, Any>.init(dictionaryLiteral: ("message", chatInputView.chatText))
        ShopLiveController.webInstance?.sendEventToWeb(event: .write, message.toJson())
    }

    func updateHeight() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
            debugPrint("heightLog lastKeyboardHeight: \(self.lastKeyboardHeight)   self.chatInputView.frame.height: \(self.chatInputView.frame.height)")
            let param: Dictionary = Dictionary<String, Any>.init(dictionaryLiteral: ("value", "\(Int((self.hasKeyboard ? 0 : self.lastKeyboardHeight) + self.chatInputView.frame.height))px"), ("keyboard", self.hasKeyboard))
            ShopLiveController.webInstance?.sendEventToWeb(event: .setChatListMarginBottom, param.toJson())
        })
    }
}

extension LiveStreamViewController: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        // 통화 종료
        if call.hasEnded == true {
            if ShopLiveConfiguration.soundPolicy.autoResumeVideoOnCallEnded {
                ShopLiveController.playControl = .resume
            }
        }

        // 전화 발신
        if call.isOutgoing == true && call.hasConnected == false {
            ShopLiveController.playControl = ShopLiveController.isReplayMode ? .pause : .stop
        }

        // 통화벨 울림
        if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            ShopLiveController.playControl = ShopLiveController.isReplayMode ? .pause : .stop
        }

        // 통화 시작
        if call.hasConnected == true && call.hasEnded == false {
        }
    }
}
