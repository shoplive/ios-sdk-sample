//
//  LiveStreamViewController.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/02/04.
//

import UIKit
import WebKit
import Combine
import AVKit

@available(iOS 13.0, *)
final class LiveStreamViewControllerCombine: UIViewController {

    lazy var viewModel: LiveStreamViewModelCombine = LiveStreamViewModelCombine()
    weak var delegate: LiveStreamViewControllerDelegate?

    var webViewConfiguration: WKWebViewConfiguration?

    private var overlayView: OverlayWebViewCombine?
    private var imageView: UIImageView?
    private var foregroundImageView: UIImageView?
    var isReplayMode: Bool = false
    private lazy var videoView: VideoView = VideoView()

    var playerLayer: AVPlayerLayer? {
        return videoView.playerLayer
    }

    @Published var isHiddenOverlay: Bool = false

    private lazy var cancellableSet = Set<AnyCancellable>()
    private var waitingPlayCancellable: AnyCancellable? = nil

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    deinit {
        for cancellable in cancellableSet {
            cancellable.cancel()
        }
        cancellableSet.removeAll()
        waitingPlayCancellable?.cancel()
        waitingPlayCancellable = nil
    }

    override func removeFromParent() {
        super.removeFromParent()

        videoView.playerLayer.player = nil
        overlayView?.delegate = nil

        overlayView?.removeFromSuperview()
        imageView?.removeFromSuperview()
        foregroundImageView?.removeFromSuperview()
        videoView.removeFromSuperview()

        overlayView = nil
        imageView = nil
        foregroundImageView = nil
    }

    private func setupKeyboardEvent() {
        // handle keyboard event
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] (notification) in
                guard let self = self else { return }
                self.chatInputView.isHidden = false
                self.chatInputBG.isHidden = false
                self.setKeyboard(notification: notification)
            }
            .store(in: &cancellableSet)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] (notification) in
                guard let self = self else { return }
                self.setKeyboard(notification: notification)
            }
            .store(in: &cancellableSet)
    }

    private func setKeyboard(notification: Notification) {
        guard let keyboardFrameEndUserInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
              let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom else { return }

        var isHiddenView = true
        switch notification.name.rawValue {
        case "UIKeyboardWillHideNotification":
            overlayView?.sendEventToWeb(event: .hiddenChatInput)
            chatConstraint.constant = 0
            break
        case "UIKeyboardWillShowNotification":
            let keyboardScreenEndFrame = keyboardFrameEndUserInfo.cgRectValue

            chatConstraint.constant = -(keyboardScreenEndFrame.height - bottomPadding)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupKeyboardEvent()
        loadOveray()

        $isHiddenOverlay
            .receive(on: RunLoop.main)
            .sink { [weak self] (isHiddenOverlay) in
                guard let self = self else { return }
                guard !self.isReplayMode else {
                    self.overlayView?.isUserInteractionEnabled = !isHiddenOverlay
                    return
                }
                guard !isHiddenOverlay else {
                    self.overlayView?.isHidden = isHiddenOverlay
                    return
                }
                self.overlayView?.alpha = 0
                self.overlayView?.isHidden = false
                UIView.animate(withDuration: 0.3) {
                    self.overlayView?.alpha = 1.0
                } completion: { (completion) in
                    self.overlayView?.isHidden = isHiddenOverlay
                }
            }
            .store(in: &cancellableSet)

        viewModel.$isMuted
            .removeDuplicates()
            .receive(on: RunLoop.main).sink(receiveValue: { [weak self] (isMuted) in
                self?.overlayView?.isMuted = isMuted
            })
            .store(in: &cancellableSet)


        viewModel.$timeControlStatus
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] (status) in
                self?.waitingPlayCancellable?.cancel()
                switch status {
                case .paused:
                    self?.overlayView?.isPlaying = false
                case .waitingToPlayAtSpecifiedRate: //버퍼링
                    self?.waitingPlayCancellable = Just(false).delay(for: 10, scheduler: RunLoop.main).sink { (isPlaying) in
                        self?.overlayView?.isPlaying = isPlaying
                    }
                case .playing:
                    self?.overlayView?.isPlaying = true
                @unknown default:
                     break
                }
            }
            .store(in: &cancellableSet)

        viewModel.$isPlaybackLikelyToKeepUp
            .dropFirst()
            .removeDuplicates()
            .receive(on: RunLoop.main).sink { (isPlaybackLikelyToKeepUp) in
            //show loading here
            //
            }
            .store(in: &cancellableSet)

        viewModel.$playerItemStatus
            .receive(on: RunLoop.main)
            .sink { [weak self] (itemStatus) in
                switch itemStatus {
                case .readyToPlay:
                    self?.play()
                case .failed:
                    self?.waitingPlayCancellable?.cancel()
                    self?.waitingPlayCancellable = Just(false).delay(for: 10, scheduler: RunLoop.main).sink { (isPlaying) in
                        self?.overlayView?.isPlaying = isPlaying
                    }
                default:
                    break
                }
            }
            .store(in: &cancellableSet)

        overlayView?.$isPipMode
            .dropFirst()
            .receive(on: RunLoop.main).sink { [weak self] (isPipMode) in
                self?.updateTopAnchor(isPip: isPipMode)
            }
            .store(in: &cancellableSet)
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
        viewModel.play()
    }

    func pause() {
        viewModel.videoPlayer.pause()
    }

    func stop() {
        viewModel.stop()
    }

    func reload() {
        overlayView?.overlayUrl = playUrl
    }

    func didCompleteDownLoadCoupon(with couponId: String) {
        overlayView?.didCompleteDownloadCoupon(with: couponId)
    }

    func hideBackgroundPoster() {
        imageView?.isHidden = true
        dismissKeyboard()
    }

    func showBackgroundPoster() {
        imageView?.isHidden = false
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

    private func setupOverayWebview() {
        let overlayView = OverlayWebViewCombine(with: webViewConfiguration)
        overlayView.webviewUIDelegate = self
        overlayView.delegate = self

        view.addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([overlayView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                     overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     overlayView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     overlayView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        self.overlayView = overlayView
    }
    
    var topAnchor: NSLayoutConstraint!
    var topSafeAnchor: NSLayoutConstraint!
    private func setupPlayerView() {
        videoView.playerLayer.videoGravity = .resizeAspectFill
        videoView.playerLayer.player = viewModel.videoPlayer

        view.addSubview(videoView)
        topAnchor = videoView.topAnchor.constraint(equalTo: view.topAnchor)
        topSafeAnchor = videoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        videoView.translatesAutoresizingMaskIntoConstraints = false

        updateTopAnchor(isPip: false)
        NSLayoutConstraint.activate([videoView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
        overlayView?.overlayUrl = playUrl
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
}

@available(iOS 13.0, *)
extension LiveStreamViewControllerCombine: OverlayWebViewDelegate {
    func replay(with size: CGSize) {
        isReplayMode = true
        delegate?.replay(with: size)
    }

    func didTouchCoupon(with couponId: String) {
        delegate?.didTouchCoupon(with: couponId)
    }

    func didTouchMuteButton(with isMuted: Bool) {
        viewModel.videoPlayer.isMuted = isMuted
    }

    func reloadVideo() {
        viewModel.reloadVideo()
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
        viewModel.videoUrl = url
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
        delegate?.didTouchCloseButton()
    }

    func handleCommand(_ command: String, with payload: Any?) {
        let interface = WebInterface.WebFunction.init(rawValue: command)
        switch interface  {
        case .setConf:
            let chatInitData = payload as? [String : Any]
            let placeHolder = chatInitData?["chatInputPlaceholderText"] as? String
            let sendText = chatInitData?["chatInputSendText"] as? String
            chatInputView.configure(viewModel: .init(placeholder: placeHolder ?? "채팅을 입력하세요", sendText: sendText ?? "보내기"))
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
        veiwController.present(alertController, animated: true, completion: nil)
    }
}

@available(iOS 13.0, *)
extension LiveStreamViewControllerCombine: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))

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
        present(alertController, animated: true, completion: nil)
    }
}

@available(iOS 13.0, *)
extension LiveStreamViewControllerCombine: ChattingWriteDelegate {
    func didTouchSendButton() {
        let message: Dictionary = Dictionary<String, Any>.init(dictionaryLiteral: ("message", chatInputView.chatText))
        overlayView?.sendEventToWeb(event: .write, message.toJson())
    }
}
