//
//  ShopLiveCombine.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/02/04.
//

import UIKit
import AVKit
import WebKit

@objc internal final class ShopLiveBase: NSObject {

    private var shopLiveWindow: UIWindow? = nil
    private var videoWindowPanGestureRecognizer: UIPanGestureRecognizer?
    private var videoWindowTapGestureRecognizer: UITapGestureRecognizer?
    private var videoWindowSwipeDownGestureRecognizer: UISwipeGestureRecognizer?
    private var _webViewConfiguration: WKWebViewConfiguration?
    private var isRestoredPip: Bool = false
    private var accessKey: String? = nil
    private var shareScheme: String? = nil
    private var phase: ShopLive.Phase = .REAL {
        didSet {
            ShopLiveDefines.phase = phase
        }
    }

    private var isKeyboardShow: Bool = false
    private var lastPipPosition: ShopLive.PipPosition = .default
    private var lastPipScale: CGFloat = 2/5
    private var replaySize: CGSize = CGSize(width: 9, height: 16)
    weak private var mainWindow: UIWindow? = nil
    
    @objc dynamic var _style: ShopLive.PresentationStyle = .unknown
    @objc dynamic var _authToken: String?
    @objc dynamic var _user: ShopLiveUser?

    private var previewCallback: (() -> Void)?
    
    var liveStreamViewController: LiveStreamViewController?
    var pictureInPictureController: AVPictureInPictureController?
    
    var pipPossibleObservation: NSKeyValueObservation?
    var originAudioSessionCategory: AVAudioSession.Category?

    weak var _delegate: ShopLiveSDKDelegate?
    
    override init() {
        super.init()
        ShopLiveController.shared.keyboardHeight = KeyboardService.keyboardHeight()
        addObserver()
    }

    deinit {
        removeObserver()
    }

    func showPreview(previewUrl: URL, completion: @escaping () -> Void) {
        liveStreamViewController?.viewModel.authToken = _authToken
        liveStreamViewController?.viewModel.user = _user
        showShopLiveView(with: previewUrl)
    }

    func showShopLiveView(with overlayUrl: URL, _ completion: (() -> Void)? = nil) {
        if _style == .fullScreen {
            ShopLiveController.loading = true
            liveStreamViewController?.viewModel.overayUrl = overlayUrl
            liveStreamViewController?.reload()
        } else if _style == .pip {
            liveStreamViewController?.viewModel.overayUrl = overlayUrl
            liveStreamViewController?.reload()
            if !ShopLiveController.shared.isPreview {
                stopShopLivePictureInPicture()
                return
            }
        }

        guard liveStreamViewController == nil else {
            return
        }

        if !ShopLiveController.shared.isPreview {
            delegate?.handleCommand("willShopLiveOn", with: nil)
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        originAudioSessionCategory = audioSession.category
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
        } catch  {
            print("Audio session failed")
        }

        ShopLiveController.shared.clear()

        liveStreamViewController = LiveStreamViewController()
        liveStreamViewController?.delegate = self
        liveStreamViewController?.webViewConfiguration = _webViewConfiguration
        liveStreamViewController?.viewModel.overayUrl = overlayUrl
        liveStreamViewController?.viewModel.authToken = _authToken
        liveStreamViewController?.viewModel.user = _user
        
        mainWindow = (UIApplication.shared.windows.first(where: { $0.isKeyWindow }))
        
        shopLiveWindow = UIWindow()
        if #available(iOS 13.0, *) {
            shopLiveWindow?.windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        }
        shopLiveWindow?.backgroundColor = .clear
        shopLiveWindow?.windowLevel = .init(rawValue: 1)
        shopLiveWindow?.frame = ShopLiveController.shared.isPreview ? pipPosition(with: lastPipScale, position: lastPipPosition) : mainWindow?.frame ?? UIScreen.main.bounds
        shopLiveWindow?.rootViewController = liveStreamViewController
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(liveWindowPanGestureHandler))
        shopLiveWindow?.addGestureRecognizer(panGesture)
        videoWindowPanGestureRecognizer = panGesture
        videoWindowPanGestureRecognizer?.isEnabled = ShopLiveController.shared.isPreview ? true : false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pipTapGestureHandler))
        shopLiveWindow?.addGestureRecognizer(tapGesture)
        videoWindowTapGestureRecognizer = tapGesture
        videoWindowTapGestureRecognizer?.isEnabled = ShopLiveController.shared.isPreview ? true : false
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownGestureHandler))
        swipeDownGesture.direction = .down
        shopLiveWindow?.addGestureRecognizer(swipeDownGesture)
        videoWindowSwipeDownGestureRecognizer = swipeDownGesture
        videoWindowSwipeDownGestureRecognizer?.isEnabled = ShopLiveController.shared.isPreview ? false : true
        
        setupPictureInPicture()
        shopLiveWindow?.makeKeyAndVisible()

        liveStreamViewController?.view.alpha = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
            self.liveStreamViewController?.view.alpha = 1.0
        }

        if ShopLiveController.shared.isPreview {
            willChangePreview()
            _style = .pip
        } else {
            _style = .fullScreen
        }
    }
    
    func hideShopLiveView(_ animated: Bool = true) {
        ShopLiveController.webInstance?.sendEventToWeb(event: .onTerminated)
        delegate?.handleCommand("willShopLiveOff", with: ["style" : style.rawValue])
        if let originAudioSessionCategory = self.originAudioSessionCategory {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(originAudioSessionCategory)
            } catch  {
                print("Audio session failed")
            }
        }
        
        if let videoWindowPanGestureRecognizer = self.videoWindowPanGestureRecognizer {
            shopLiveWindow?.removeGestureRecognizer(videoWindowPanGestureRecognizer)
        }
        if let videoWindowTapGestureRecognizer = self.videoWindowTapGestureRecognizer {
            shopLiveWindow?.removeGestureRecognizer(videoWindowTapGestureRecognizer)
        }
        if let videoWindowSwipeDownGestureRecognizer = self.videoWindowSwipeDownGestureRecognizer {
            shopLiveWindow?.removeGestureRecognizer(videoWindowSwipeDownGestureRecognizer)
        }

        ShopLiveController.shared.clear()

        let transform = self.shopLiveWindow?.transform.concatenating(CGAffineTransform(scaleX: 0.1, y: 0.1)) ?? .identity
        let animateDuration = animated ? 0.2 : 0.0
        UIView.animate(withDuration: animateDuration, delay: 0, options: [.curveEaseIn]) {
            self.shopLiveWindow?.transform = transform
            self.shopLiveWindow?.alpha = 0
        } completion: { (isCompleted) in
            self.shopLiveWindow?.transform = .identity
            self.shopLiveWindow?.alpha = 1
            
            self.shopLiveWindow?.resignKey()
            self.mainWindow?.makeKeyAndVisible()

            self.videoWindowPanGestureRecognizer = nil
            self.videoWindowTapGestureRecognizer = nil
            self.pictureInPictureController = nil
            
            self.liveStreamViewController?.removeFromParent()
            self.liveStreamViewController?.stop()
            self.liveStreamViewController?.delegate = nil
            self.liveStreamViewController = nil
            
            self.mainWindow = nil
            self.shopLiveWindow?.removeFromSuperview()
            self.shopLiveWindow?.rootViewController = nil
            
            self.shopLiveWindow = nil

            self.delegate?.handleCommand("didShopLiveOff", with: ["style" : self.style.rawValue])
            self._style = .unknown
            ShopLiveController.shared.customShareAction = nil
            ShopLiveController.shared.hookNavigation = nil
            ShopLiveController.shared.resetOnlyFinished()
        }
    }
    
    //OS 제공 PIP 세팅
    func setupPictureInPicture() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            ShopLiveLogger.debugLog("interruption setActive")
        }
        catch let error {
            ShopLiveLogger.debugLog("interruption setActive Failed error: \(error.localizedDescription)")
            debugPrint(error)
        }

        guard let playerLayer = liveStreamViewController?.playerLayer else { return }
        playerLayer.frame = CGRect(x: 100, y: 100, width: 320, height: 180)
        // Ensure PiP is supported by current device.
        if AVPictureInPictureController.isPictureInPictureSupported() {
            // Create a new controller, passing the reference to the AVPlayerLayer.
            pictureInPictureController = AVPictureInPictureController(playerLayer: playerLayer)
            pictureInPictureController?.delegate = self
            /*
                pictureInPictureController?.publisher(for: \.isPictureInPicturePossible)
                    .receive(on: RunLoop.main)
                    .sink(receiveValue: { [weak self] (isPictureInPicturePossible) in
    //                    self?.liveStreamViewController?.pipButton?.isEnabled = isPictureInPicturePossible
                    })
                    .store(in: &pipControllerPublisherCancellableSet)

                pictureInPictureController?.publisher(for: \.isPictureInPictureActive)
                    .receive(on: RunLoop.main)
                    .sink(receiveValue: { [weak self] (isPictureInPictureActive) in
    //                    self?.style = isPictureInPictureActive ? .pip : .fullScreen
                    })
                    .store(in: &pipControllerPublisherCancellableSet)

                pictureInPictureController?.publisher(for: \.isPictureInPictureSuspended)
                    .receive(on: RunLoop.main)
                    .sink(receiveValue: { (isPictureInPictureSuspended) in

                    })
                    .store(in: &pipControllerPublisherCancellableSet)
             */
        } else {
            // PiP isn't supported by the current device. Disable the PiP button.
//            liveStreamViewController?.pipButton?.isEnabled = false
        }
    }
    
    func startShopLivePictureInPicture() {
        startCustomPictureInPicture(with: lastPipPosition, scale: lastPipScale)
    }
    
    func stopShopLivePictureInPicture() {
        stopCustomPictureInPicture()
    }
    
    private func pipSize(with scale: CGFloat) -> CGSize {
        guard let mainWindow = self.mainWindow else { return .zero }
        var videoSize = ShopLiveController.player?.currentItem?.presentationSize ?? .zero
        videoSize = videoSize == .zero ? replaySize : videoSize
        
        let width = mainWindow.bounds.width * scale
        let height = (videoSize.height / videoSize.width) * width
        
        return CGSize(width: width, height: height)
    }

    private func pipPosition(with scale: CGFloat = 2/5, position: ShopLive.PipPosition = .default) -> CGRect {
        guard let mainWindow = self.mainWindow else { return .zero }

        var pipPosition: CGRect = .zero
        var origin = CGPoint.zero
        let safeAreaInsets = mainWindow.safeAreaInsets
        let pipSize = self.pipSize(with: scale)
        let pipEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let keyboardHeight: CGFloat = isKeyboardShow ? ShopLiveController.shared.keyboardHeight : 0

        switch position {
        case .bottomRight, .default:
            origin.x = mainWindow.frame.width - safeAreaInsets.right - pipEdgeInsets.right - pipSize.width
            origin.y = mainWindow.frame.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - pipSize.height - keyboardHeight
        case .bottomLeft:
            origin.x = safeAreaInsets.left + pipEdgeInsets.left
            origin.y = mainWindow.frame.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - pipSize.height - keyboardHeight
        case .topRight:
            origin.x = mainWindow.frame.width - safeAreaInsets.right - pipEdgeInsets.right - pipSize.width
            origin.y = safeAreaInsets.top + pipEdgeInsets.top
        case .topLeft:
            origin.x = safeAreaInsets.left + pipEdgeInsets.left
            origin.y = safeAreaInsets.top + pipEdgeInsets.top

        }

        pipPosition = CGRect(origin: origin, size: pipSize)

        return pipPosition
    }

    private func pipCenter(with position: ShopLive.PipPosition) -> CGPoint {
        guard let mainWindow = self.mainWindow else { return .zero }
        let pipSize = self.pipPosition(with: lastPipScale, position: lastPipPosition).size
        let padding: CGFloat = 20
        let safeAreaInset = mainWindow.safeAreaInsets
        
        let leftCenterX = (pipSize.width / 2) + padding + safeAreaInset.left
        let rightCenterX = mainWindow.bounds.width - ((pipSize.width / 2) + padding + safeAreaInset.right)
        let topCenterY = (pipSize.height / 2) + padding + safeAreaInset.top
        let bottomCenterY = mainWindow.bounds.height - ((pipSize.height / 2) + padding + safeAreaInset.bottom) - (isKeyboardShow ? ShopLiveController.shared.keyboardHeight : 0)
        switch position {
        case .bottomRight, .default:
            return CGPoint(x: rightCenterX, y: bottomCenterY)
        case .bottomLeft:
            return CGPoint(x: leftCenterX, y: bottomCenterY)
        case .topRight:
            return CGPoint(x: rightCenterX, y: topCenterY)
        case .topLeft:
            return CGPoint(x: leftCenterX, y: topCenterY)
        }
    }
    
    private func startCustomPictureInPicture(with position: ShopLive.PipPosition = .default, scale: CGFloat = 2/5) {
        delegate?.handleCommand("willShopLiveOff", with: ["style" : style.rawValue])
        guard !ShopLiveController.shared.pipAnimationg else { return }
        guard let shopLiveWindow = self.shopLiveWindow else { return }
        let pipPosition: CGRect = self.pipPosition(with: scale, position: position)

        ShopLiveController.windowStyle = .inAppPip
        shopLiveWindow.clipsToBounds = false
        shopLiveWindow.rootViewController?.view.layer.cornerRadius = 10
        shopLiveWindow.rootViewController?.view.backgroundColor = .clear
        liveStreamViewController?.hideBackgroundPoster()
        
        videoWindowPanGestureRecognizer?.isEnabled = true
        videoWindowTapGestureRecognizer?.isEnabled = true
        videoWindowSwipeDownGestureRecognizer?.isEnabled = false


        UIView.animate(withDuration: 0.4, delay: 0, options: []) {
            ShopLiveController.isHiddenOverlay = true
            shopLiveWindow.frame = pipPosition
            shopLiveWindow.rootViewController?.view.clipsToBounds = true
            shopLiveWindow.layer.shadowColor = UIColor.black.cgColor
            shopLiveWindow.layer.shadowOpacity = 0.5
            shopLiveWindow.layer.shadowOffset = .zero
            shopLiveWindow.layer.shadowRadius = 10
            ShopLiveController.shared.pipAnimationg = false
            shopLiveWindow.setNeedsLayout()
            shopLiveWindow.layoutIfNeeded()
        } completion: { (isCompleted) in
            shopLiveWindow.rootViewController?.view.backgroundColor = .black
        }

        delegate?.handleCommand("didShopLiveOff", with: ["style" : style.rawValue])

        _style = .pip
    }

    private func stopCustomPictureInPicture() {
        guard !ShopLiveController.shared.pipAnimationg else { return }
        guard let mainWindow = self.mainWindow else { return }
        guard let shopLiveWindow = self.shopLiveWindow else { return }

        delegate?.handleCommand("willShopLiveOn", with: nil)
        ShopLiveController.shared.pipAnimationg = true
        videoWindowPanGestureRecognizer?.isEnabled = false
        videoWindowTapGestureRecognizer?.isEnabled = false
        videoWindowSwipeDownGestureRecognizer?.isEnabled = true
        ShopLiveController.windowStyle = .normal

        shopLiveWindow.layer.shadowColor = nil
        shopLiveWindow.layer.shadowOpacity = 0.0
        shopLiveWindow.layer.shadowOffset = .zero
        shopLiveWindow.layer.shadowRadius = 0
        
        shopLiveWindow.rootViewController?.view.backgroundColor = .clear
            
        UIView.animate(withDuration: 0.3, delay: 0, options: []) {
            shopLiveWindow.frame = mainWindow.bounds
            shopLiveWindow.layer.cornerRadius = 0
            shopLiveWindow.setNeedsLayout()
            shopLiveWindow.layoutIfNeeded()
            shopLiveWindow.rootViewController?.view.layer.cornerRadius = 0
        } completion: { (isCompleted) in
            shopLiveWindow.rootViewController?.view.backgroundColor = .black
            self.liveStreamViewController?.showBackgroundPoster()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300), execute: {
                ShopLiveController.isHiddenOverlay = false
                ShopLiveController.shared.pipAnimationg = false
            })
        }
        
        _style = .fullScreen
    }

    func willChangePreview() {
        ShopLiveController.windowStyle = .inAppPip
        self.shopLiveWindow?.clipsToBounds = false
        self.shopLiveWindow?.rootViewController?.view.layer.cornerRadius = 10
        self.shopLiveWindow?.rootViewController?.view.backgroundColor = .black
        liveStreamViewController?.hideBackgroundPoster()

        videoWindowPanGestureRecognizer?.isEnabled = true
        videoWindowTapGestureRecognizer?.isEnabled = true
        videoWindowSwipeDownGestureRecognizer?.isEnabled = false

        ShopLiveController.isHiddenOverlay = true

        self.shopLiveWindow?.rootViewController?.view.clipsToBounds = true
        self.shopLiveWindow?.layer.shadowColor = UIColor.black.cgColor
        self.shopLiveWindow?.layer.shadowOpacity = 0.5
        self.shopLiveWindow?.layer.shadowOffset = .zero
        self.shopLiveWindow?.layer.shadowRadius = 10

        self.shopLiveWindow?.setNeedsLayout()
        self.shopLiveWindow?.layoutIfNeeded()
    }

    func didChangeOSPIP() {
        guard let mainWindow = self.mainWindow else { return }
        guard let shopLiveWindow = self.shopLiveWindow else { return }
        guard _style != .fullScreen else { return }
        shopLiveWindow.frame = mainWindow.bounds

//        ShopLiveController.shared.pipAnimationg = true
        videoWindowPanGestureRecognizer?.isEnabled = false
        videoWindowTapGestureRecognizer?.isEnabled = false
        videoWindowSwipeDownGestureRecognizer?.isEnabled = true
//        ShopLiveController.windowStyle = .normal

        shopLiveWindow.layer.shadowColor = nil
        shopLiveWindow.layer.shadowOpacity = 0.0
        shopLiveWindow.layer.shadowOffset = .zero
        shopLiveWindow.layer.shadowRadius = 0

        shopLiveWindow.rootViewController?.view.backgroundColor = .clear

        shopLiveWindow.layer.cornerRadius = 0
//        shopLiveWindow.setNeedsLayout()
//        shopLiveWindow.layoutIfNeeded()
        shopLiveWindow.rootViewController?.view.layer.cornerRadius = 0
        shopLiveWindow.rootViewController?.view.backgroundColor = .black
        self.liveStreamViewController?.showBackgroundPoster()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300), execute: {
            ShopLiveController.isHiddenOverlay = false
            ShopLiveController.shared.pipAnimationg = false
//                    ShopLiveController.loading = true
        })
        _style = .fullScreen
    }

    private func alignPipView() {
        guard let currentCenter = shopLiveWindow?.center else { return }
        guard let mainWindow = self.mainWindow else { return }
        let center = mainWindow.center
        let rate = (mainWindow.frame.height - ShopLiveController.shared.keyboardHeight) / mainWindow.frame.height
        let isPositiveDiffX = center.x - currentCenter.x > 0
        let isPositiveDiffY = (center.y * rate) - currentCenter.y > 0
        let position: ShopLive.PipPosition = {
            switch (isPositiveDiffX, isPositiveDiffY) {
            case (true, true):
                return .topLeft
            case (true, false):
                return .bottomLeft
            case (false, true):
                return .topRight
            case (false, false):
                return .bottomRight
            }
        }()

        lastPipPosition = position
        self.handleKeyboard()

    }
    
    var panGestureInitialCenter: CGPoint = .zero
    
    @objc private func liveWindowPanGestureHandler(_ recognizer: UIPanGestureRecognizer) {
        guard _style == .pip else { return }
        guard let liveWindow = recognizer.view else { return }
        
        let translation = recognizer.translation(in: liveWindow)
        
        switch recognizer.state {
        case .began:
            panGestureInitialCenter = liveWindow.center
        case .changed:
            let centerX = panGestureInitialCenter.x + translation.x
            let centerY = panGestureInitialCenter.y + translation.y
            liveWindow.center = CGPoint(x: centerX, y: centerY)
        case .ended:
            guard let mainWindow = self.mainWindow else { return }
            let velocity = recognizer.velocity(in: liveWindow)
            
            let padding: CGFloat = 20
            let safeAreaInset = mainWindow.safeAreaInsets
            let mainWindowHeight: CGFloat = mainWindow.bounds.height - (isKeyboardShow ? ShopLiveController.shared.keyboardHeight : 0)
            let minX = (liveWindow.bounds.width / 2.0) + padding + safeAreaInset.left
            let maxX = mainWindow.bounds.width - ((liveWindow.bounds.width / 2.0) + padding + safeAreaInset.right)
            let minY = liveWindow.bounds.height / 2.0 + padding + safeAreaInset.top
            let maxY = mainWindowHeight - ((liveWindow.bounds.height / 2.0) + padding + safeAreaInset.bottom)
            
            var centerX = panGestureInitialCenter.x + translation.x
            var centerY = panGestureInitialCenter.y + translation.y
            
            let xRange = padding...(mainWindow.bounds.width - padding)
            let yRange = (padding + safeAreaInset.top)...(mainWindowHeight - (padding + safeAreaInset.bottom)) + (isKeyboardShow ? liveWindow.frame.height * 0.2 : 0)
            
            //범위밖으로 나가면 stop shoplive
            guard xRange.contains(centerX), yRange.contains(centerY) else {
                hideShopLiveView()
                return
            }
            
            guard velocity.x.magnitude > 600 || velocity.y.magnitude > 600 else {
                self.alignPipView()
                return
            }
            
            let animationDuration: CGFloat = 0.5
            
            if velocity.x.magnitude > 600 {
                centerX += velocity.x
            }
            
            if velocity.y.magnitude > 600 {
                centerY += velocity.y
            }
            
            let destination = CGPoint(x: min(max(minX, centerX), maxX), y: min(max(minY, centerY), maxY))
            let initialVelocity = initialAnimationVelocity(for: velocity, from: liveWindow.center, to: destination)
            let parameters = UISpringTimingParameters(dampingRatio: 1, initialVelocity: initialVelocity)
            let animator = UIViewPropertyAnimator(duration: TimeInterval(animationDuration), timingParameters: parameters)

            animator.addAnimations {
                liveWindow.center = destination
            }

            animator.addCompletion { (position) in
                self.alignPipView()
            }

            animator.startAnimation()
        default:
            break
        }
    }
    
    @objc private func swipeDownGestureHandler(_ recognizer: UISwipeGestureRecognizer) {
        guard ShopLiveController.shared.swipeEnabled else { return }
        guard !ShopLiveController.shared.isPreview else { return }
        guard _style == .fullScreen else { return }
        startShopLivePictureInPicture()
    }
    
    private func initialAnimationVelocity(for gestureVelocity: CGPoint, from currentPosition: CGPoint, to finalPosition: CGPoint) -> CGVector {
        var animationVelocity = CGVector.zero
        let xDistance = finalPosition.x - currentPosition.x
        let yDistance = finalPosition.y - currentPosition.y
        if xDistance != 0 {
            animationVelocity.dx = gestureVelocity.x / xDistance
        }
        if yDistance != 0 {
            animationVelocity.dy = gestureVelocity.y / yDistance
        }
        return animationVelocity
    }

    @objc private func pipTapGestureHandler(_ recognizer: UITapGestureRecognizer) {
        guard !ShopLiveController.shared.isPreview else {
            ShopLiveController.shared.isPreview = false
            previewCallback?()
            return
        }
        guard _style == .pip else { return }
        stopShopLivePictureInPicture()
    }

    func fetchPreviewUrl(with campaignKey: String?, completionHandler: @escaping ((URL?) -> Void)) {
        var urlComponents = URLComponents(string: ShopLiveDefines.url)
        var queryItems = urlComponents?.queryItems ?? [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "ak", value: accessKey))
        if let ck = campaignKey {
            queryItems.append(URLQueryItem(name: "ck", value: ck))
        }
        queryItems.append(URLQueryItem(name: "version", value: ShopLiveDefines.sdkVersion))
        queryItems.append(URLQueryItem(name: "preview", value: "1"))
        urlComponents?.queryItems = queryItems
        completionHandler(urlComponents?.url)
    }

    func fetchOverlayUrl(with campaignKey: String?, completionHandler: ((URL?) -> Void)) {
        guard let accessKey = self.accessKey else {
            completionHandler(nil)
            return
        }

        var urlComponents = URLComponents(string: ShopLiveDefines.url)
        var queryItems = urlComponents?.queryItems ?? [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "ak", value: accessKey))
        if let ck = campaignKey {
            queryItems.append(URLQueryItem(name: "ck", value: ck))
        }
        queryItems.append(URLQueryItem(name: "version", value: ShopLiveDefines.sdkVersion))
        if let scm: String = shareScheme {
            let escapedString = scm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            queryItems.append(URLQueryItem(name: "shareUrl", value: escapedString))
        }
        urlComponents?.queryItems = queryItems
        completionHandler(urlComponents?.url)
    }

    func addObserver() {
        self.addObserver(self, forKeyPath: "_style", options: [.initial, .old, .new], context: nil)
        self.addObserver(self, forKeyPath: "_authToken", options: [.initial, .old, .new], context: nil)
        self.addObserver(self, forKeyPath: "_user", options: [.initial, .old, .new], context: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func removeObserver() {
        self.removeObserver(self, forKeyPath: "_style")
        self.removeObserver(self, forKeyPath: "_authToken")
        self.removeObserver(self, forKeyPath: "_user")
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func handleKeyboard() {
        guard _style == .pip else { return }
        guard let shopLiveWindow = self.shopLiveWindow else { return }

        let pipPosition: CGRect = self.pipPosition(with: lastPipScale, position: lastPipPosition)

        UIView.animate(withDuration: 0.3, delay: 0, options: []) {
            shopLiveWindow.frame = pipPosition
            shopLiveWindow.setNeedsLayout()
            shopLiveWindow.layoutIfNeeded()
        }
    }

    @objc func handleNotification(_ notification: Notification) {
        switch notification.name {
        case UIApplication.didBecomeActiveNotification:
            self.pictureInPictureController?.stopPictureInPicture()
            break
        case UIApplication.didEnterBackgroundNotification:
            self.liveStreamViewController?.onBackground()
            break
        case UIApplication.willEnterForegroundNotification:
            self.liveStreamViewController?.onForeground()
            break
        case UIResponder.keyboardWillShowNotification:
            isKeyboardShow = true
            self.handleKeyboard()
            break
        case UIResponder.keyboardWillHideNotification:
            isKeyboardShow = false
            self.handleKeyboard()
            break
        default:
            break
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "_style":
            guard let oldValue: Int = change?[.oldKey] as? Int, let newValue: Int = change?[.newKey] as? Int, oldValue != newValue,
                  let newStyle: ShopLive.PresentationStyle = .init(rawValue: newValue) else {
                if let newValue: Int = change?[.newKey] as? Int, let newStyle: ShopLive.PresentationStyle = .init(rawValue: newValue) {
                    self.liveStreamViewController?.updatePipStyle(with: newStyle)
                }
                return
            }

            self.liveStreamViewController?.updatePipStyle(with: newStyle)
            break
        case "_authToken":
            guard let oldValue: String = change?[.oldKey] as? String,
                  let newValue: String = change?[.newKey] as? String, oldValue != newValue else { return }
            self.liveStreamViewController?.viewModel.authToken = newValue
            break
        case "_user":
            guard let oldValue: ShopLiveUser = change?[.oldKey] as? ShopLiveUser,
                  let newValue: ShopLiveUser = change?[.newKey] as? ShopLiveUser, oldValue != newValue else { return }
            self.liveStreamViewController?.viewModel.user = newValue
            break
        default:
            break
        }
    }
}

extension ShopLiveBase: ShopLiveComponent {
    var viewController: ShopLiveViewController? {
        return self.liveStreamViewController
    }

    func close() {
        self.hideShopLiveView()
    }

    func setChatViewFont(inputBoxFont: UIFont, sendButtonFont: UIFont) {
        ShopLiveController.shared.inputBoxFont = inputBoxFont
        ShopLiveController.shared.sendButtonFont = sendButtonFont
    }

    func hookNavigation(navigation: @escaping ((URL) -> Void)) {
        ShopLiveController.shared.hookNavigation = nil
        ShopLiveController.shared.hookNavigation = navigation
    }

    func setShareScheme(_ scheme: String? = nil, custom: (() -> Void)?) {

        ShopLiveController.shared.customShareAction = nil
        if scheme == nil {
            guard custom != nil else {
                print("When `scheme` not used, `custom` must be used, `custom` can not be null")
                return
            }
        }

        self.shareScheme = scheme
        ShopLiveController.shared.customShareAction = custom
    }

    func onTerminated() {
        liveStreamViewController?.onTerminated()
    }
    
    func setKeepPlayVideoOnHeadphoneUnplugged(_ keepPlay: Bool) {
        ShopLiveConfiguration.soundPolicy.keepPlayVideoOnHeadphoneUnplugged = keepPlay
    }

    func isKeepPlayVideoOnHeadPhoneUnplugged() -> Bool {
        return ShopLiveConfiguration.soundPolicy.keepPlayVideoOnHeadphoneUnplugged
    }

    func setAutoResumeVideoOnCallEnded(_ autoResume: Bool) {
        ShopLiveConfiguration.soundPolicy.autoResumeVideoOnCallEnded = autoResume
    }

    func isAutoResumeVideoOnCallEnded() -> Bool {
        return ShopLiveConfiguration.soundPolicy.autoResumeVideoOnCallEnded
    }

    @objc func startPictureInPicture() {
        startPictureInPicture(with: .default, scale: 2/5)
    }
    
    @objc var authToken: String? {
        get {
            return _authToken
        }
        set {
            _authToken = newValue
        }
    }
    
    @objc var user: ShopLiveUser? {
        get {
            return self._user
        }
        set {
            self._user = newValue
        }
    }

    @objc func configure(with accessKey: String) {
        self.accessKey = accessKey
        self.phase = .REAL
    }

    @objc func configure(with accessKey: String, phase: ShopLive.Phase) {
        self.accessKey = accessKey
        self.phase = phase
    }

    func preview(with campaignKey: String?, completion: @escaping () -> Void) {
        previewCallback = completion
        fetchPreviewUrl(with: campaignKey) { url in
            guard let url = url else { return }
            self.showPreview(previewUrl: url, completion: completion)
        }
    }
    
    @objc func play(with campaignKey: String?, _ parent: UIViewController?) {
        guard self.accessKey != nil else { return }
        fetchOverlayUrl(with: campaignKey) { (overlayUrl) in
            guard let url = overlayUrl else { return }
            liveStreamViewController?.viewModel.authToken = _authToken
            liveStreamViewController?.viewModel.user = _user
            showShopLiveView(with: url, nil)
        }
    }
    
    @objc func reloadLive() {
        guard self.accessKey != nil else { return }
        liveStreamViewController?.reload()
    }
    
    @objc func startPictureInPicture(with position: ShopLive.PipPosition, scale: CGFloat) {
        lastPipScale = scale
        lastPipPosition = position
        startShopLivePictureInPicture()
    }
    @objc func stopPictureInPicture() {
        stopShopLivePictureInPicture()
    }
    
    @objc var style: ShopLive.PresentationStyle {
        get {
            return _style
        }
    }
    
    @objc var pipPosition: ShopLive.PipPosition {
        get {
            return lastPipPosition
        }
        set {
            lastPipPosition = newValue
        }
    }
    
    @objc var pipScale: CGFloat {
        get {
            return lastPipScale
        }
        set {
            lastPipScale = newValue
        }
    }

    @objc var indicatorColor: UIColor {
        get {
            return ShopLiveController.shared.indicatorColor
        }
        set {
            ShopLiveController.shared.indicatorColor = newValue
        }
    }

    
    @objc public var delegate: ShopLiveSDKDelegate? {
        set {
            self._delegate = newValue
        }
        get {
            return self._delegate
        }
    }
    
    @objc var webViewConfiguration: WKWebViewConfiguration? {
        set {
            self._webViewConfiguration = newValue
        }
        get {
            return self._webViewConfiguration
        }
    }
}

extension ShopLiveBase: AVPictureInPictureControllerDelegate {
    
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        //PIP 에서 stop pip 버튼으로 돌아올 때
        isRestoredPip = true
        completionHandler(true)
    }
    
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {

        ShopLiveController.windowStyle = .osPip
    }
    
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        didChangeOSPIP()
    }
    
    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        ShopLiveController.windowStyle = .normal
    }
    
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        if !isRestoredPip { //touch stop pip button in OS PIP view
            self.hideShopLiveView()
        }
        
        isRestoredPip = false
    }
}

extension ShopLiveBase: LiveStreamViewControllerDelegate {
    func campaignInfo(campaignInfo: [String : Any]) {
        delegate?.handleCampaignInfo(campaignInfo: campaignInfo)
    }

    func didChangeCampaignStatus(status: String) {
        delegate?.handleChangeCampaignStatus(status: status)
    }

    func onError(code: String, message: String) {
        delegate?.handleError(code: code, message: message)
    }

    func didTouchCustomAction(id: String, type: String, payload: Any?) {
        let completion: () -> Void = { 
            self.liveStreamViewController?.didCompleteCustomAction(with: id) }
        delegate?.handleCustomAction(with: id, type: type, payload: payload, completion: completion)
    }

    func replay(with size: CGSize) {
        replaySize = size
    }
    
    func didTouchPipButton() {
        startShopLivePictureInPicture()
    }
    
    func didTouchCloseButton() {
        hideShopLiveView()
    }
    
    func didTouchNavigation(with url: URL) {
        guard let hookNavigation = ShopLiveController.shared.hookNavigation else {
            startPictureInPicture()
            _delegate?.handleNavigation(with: url)
            return
        }

        hookNavigation(url)
    }
    
    func didTouchCoupon(with couponId: String) {
        let completion: () -> Void = { [weak self] in self?.liveStreamViewController?.didCompleteDownLoadCoupon(with: couponId) }
        _delegate?.handleDownloadCoupon(with: couponId, completion: completion)
    }
    
    func handleCommand(_ command: String, with payload: Any?) {
        _delegate?.handleCommand(command, with: payload)
    }
}
