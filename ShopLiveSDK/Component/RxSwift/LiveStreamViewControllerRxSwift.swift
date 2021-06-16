//
//  LiveStreamViewControllerRxSwift.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/05/18.
//

import UIKit
import WebKit
import AVKit
import RxSwift
import RxCocoa

final class LiveStreamViewControllerRxSwift: UIViewController {

    lazy var viewModel: LiveStreamViewModelRxSwift = LiveStreamViewModelRxSwift()
    weak var delegate: LiveStreamViewControllerDelegate?

    var webViewConfiguration: WKWebViewConfiguration?

    private var overlayView: OverlayWebViewRxSwift?
    private var imageView: UIImageView?
    private var foregroundImageView: UIImageView?
    var isReplayMode: Bool = false
    private lazy var videoView: VideoView = VideoView()

    var playerLayer: AVPlayerLayer? {
        return videoView.playerLayer
    }

    var isHiddenOverlay: BehaviorRelay<Bool> = .init(value: false)

    private lazy var cancellableDisposeBag = DisposeBag()
    private var waitingPlayCancellableDispable: Disposable? = nil

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

//    override var inputAccessoryView: UIView? {
//        return toolbar
//    }

    private lazy var textField: UITextField = .init(frame: .init(x: 0, y: 0, width: self.view.frame.width, height: 48))

    deinit {
        cancellableDisposeBag = DisposeBag()
        waitingPlayCancellableDispable?.dispose()
        waitingPlayCancellableDispable = nil
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

        isHiddenOverlay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (isHiddenOverlay) in
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
            }).disposed(by: cancellableDisposeBag)

        viewModel.isMuted
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (isMuted) in
                self?.overlayView?.isMuted.accept(isMuted)
            }).disposed(by: cancellableDisposeBag)

        viewModel.timeControlStatus
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] status in
                self?.waitingPlayCancellableDispable?.dispose()
                switch status {
                case .paused:
                    self?.overlayView?.isPlaying.accept(false)
                case .waitingToPlayAtSpecifiedRate: //버퍼링
                    self?.waitingPlayCancellableDispable = Observable.just(false)
                        .delay(RxTimeInterval.milliseconds(10), scheduler: MainScheduler.instance)
                        .subscribe(onNext: { [weak self] isPlaying in
                            self?.overlayView?.isPlaying.accept(isPlaying)
                        })
                case .playing:
                    self?.overlayView?.isPlaying.accept(true)
                @unknown default:
                     break
                }
            }).disposed(by: cancellableDisposeBag)

        viewModel.isPlaybackLikelyToKeepUp
            .skip(1)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { isPlaybackLikelyToKeepUp in

            }).disposed(by: cancellableDisposeBag)

        viewModel.playerItemStatus
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (itemStatus) in
                switch itemStatus {
                case .readyToPlay:
                    self?.play()
                case .failed:
                    self?.waitingPlayCancellableDispable?.dispose()
                    self?.waitingPlayCancellableDispable = Observable.just(false)
                        .delay(RxTimeInterval.milliseconds(10), scheduler: MainScheduler.instance)
                        .subscribe(onNext: { [weak self] isPlaying in
                            self?.overlayView?.isPlaying.accept(isPlaying)
                        })
                default:
                    break
                }
            }).disposed(by: cancellableDisposeBag)
    }

    private func setupView() {
        view.backgroundColor = .black

        setupBackgroundImageView()
        setupPlayerView()
        setupForegroungImageView()
        setupOverayWebview()
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
        overlayView?.overlayUrl.accept(playUrl)
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
        let overlayView = OverlayWebViewRxSwift(with: webViewConfiguration)
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

        NSLayoutConstraint.activate([videoView.topAnchor.constraint(equalTo: view.topAnchor),
                                     videoView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func loadOveray() {
        overlayView?.overlayUrl.accept(playUrl)
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


extension LiveStreamViewControllerRxSwift: OverlayWebViewDelegate {
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
        viewModel.videoUrl.accept(url)
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

extension LiveStreamViewControllerRxSwift: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        // 여기서 키보드 악세사리뷰 넣어서 테스트 ( 공유버튼 눌러서 테스트 )
//        txtView.becomeFirstResponder()
        completionHandler()
/*
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        present(alertController, animated: true, completion: nil)
 */
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
