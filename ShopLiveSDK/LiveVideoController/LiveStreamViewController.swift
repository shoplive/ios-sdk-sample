//
//  LiveStreamViewController.swift
//  ShopLiveSDK
//
//  Created by purpleworks on 2021/02/04.
//

import UIKit
import WebKit
import Combine
import AVKit

protocol LiveStreamViewControllerDelegate: class {
    func didTouchPipButton()
    func didTouchCloseButton()
    func didTouchNavigation(with url: URL)
    func didTouchCoupon(with couponId: String)
    func handleCommand(_ command: String, with payload: Any?)
    func replay(with size: CGSize)
}

class LiveStreamViewController: UIViewController {
    
    lazy var viewModel: LiveStreamViewModel = LiveStreamViewModel()
    weak var delegate: LiveStreamViewControllerDelegate?
    
    var webViewConfiguration: WKWebViewConfiguration?
    
    private var overlayView: OverlayWebView?
    private var imageView: UIImageView?
    private var foregroundImageView: UIImageView?
    var isReplayMode: Bool = false
    private lazy var videoView: VideoView = VideoView()
    
    var playerLayer: AVPlayerLayer? {
        return videoView.playerLayer
    }
    
    @Published var isHiddenOverlay: Bool = false
    
    private lazy var cancellableSet = Set<AnyCancellable>()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        for cancellable in cancellableSet {
            cancellable.cancel()
        }
        cancellableSet.removeAll()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] (status) in
                switch status {
                case .paused:
                    self?.overlayView?.isPlaying = false
                case .waitingToPlayAtSpecifiedRate: //버퍼링
                    break
                case .playing:
                    self?.overlayView?.isPlaying = true
                }
            }
            .store(in: &cancellableSet)
        
        viewModel.$isPlaybackLikelyToKeepUp.dropFirst().removeDuplicates().receive(on: RunLoop.main).sink { (isPlaybackLikelyToKeepUp) in
            //show loading here
            //
        }.store(in: &cancellableSet)
        
        viewModel.$playerItemStatus
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] (itemStatus) in
                switch itemStatus {
                case .readyToPlay:
                    self?.play()
                default:
                    break
                }
            }
            .store(in: &cancellableSet)
        
        
    }
    
    private func setupView() {
        view.backgroundColor = .black
        
        setupBackgroundImageView()
        setupPlayerView()
        setupForegroungImageView()
        setupOverayWebview()
    }
    
    func play() {
        viewModel.videoPlayer.play()
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
        let overlayView = OverlayWebView(with: webViewConfiguration)
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
    
    private func setupPlayerView() {
        videoView.playerLayer.videoGravity = .resizeAspectFill
        videoView.playerLayer.player = viewModel.videoPlayer
        
        view.addSubview(videoView)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([videoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                     videoView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
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

extension LiveStreamViewController: OverlayWebViewDelegate {
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
        delegate?.handleCommand(command, with: payload)
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

extension LiveStreamViewController: WKUIDelegate {
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
