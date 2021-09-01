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
        addObserver()
    }

    deinit {
        removeObserver()
    }

    func showPreview(previewUrl: URL, completion: @escaping () -> Void) {
        previewCallback = completion
        liveStreamViewController?.viewModel.authToken = _authToken
        liveStreamViewController?.viewModel.user = _user
        showShopLiveView(with: previewUrl) {
            self.startPictureInPicture()
        }
    }

    func showShopLiveView(with overlayUrl: URL, _ completion: (() -> Void)? = nil) {
        if _style == .fullScreen {
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
            if ShopLiveController.shared.isPreview, _style == .fullScreen {
                completion?()
            }
            return
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
        } else {
            // Fallback on earlier versions
        }
        shopLiveWindow?.backgroundColor = .clear
        shopLiveWindow?.windowLevel = .init(rawValue: 1)
        shopLiveWindow?.frame = mainWindow?.frame ?? UIScreen.main.bounds
        shopLiveWindow?.setNeedsLayout()
        shopLiveWindow?.layoutIfNeeded()
        shopLiveWindow?.rootViewController = liveStreamViewController
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(liveWindowPanGestureHandler))
        shopLiveWindow?.addGestureRecognizer(panGesture)
        videoWindowPanGestureRecognizer = panGesture
        videoWindowPanGestureRecognizer?.isEnabled = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pipTapGestureHandler))
        shopLiveWindow?.addGestureRecognizer(tapGesture)
        videoWindowTapGestureRecognizer = tapGesture
        videoWindowTapGestureRecognizer?.isEnabled = false
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownGestureHandler))
        swipeDownGesture.direction = .down
        shopLiveWindow?.addGestureRecognizer(swipeDownGesture)
        videoWindowSwipeDownGestureRecognizer = swipeDownGesture
        videoWindowSwipeDownGestureRecognizer?.isEnabled = true
        
        setupPictureInPicture()
        shopLiveWindow?.makeKeyAndVisible()

        if ShopLiveController.shared.isPreview {
            completion?()
        } else {
            _style = .fullScreen
        }
    }
    
    func hideShopLiveView(_ animated: Bool = true) {
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
        }
//        overlayUrl = nil
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
    
    private func pipCenter(with position: ShopLive.PipPosition) -> CGPoint {
        guard let mainWindow = self.mainWindow else { return .zero }
        let pipSize = self.pipSize(with: lastPipScale)
        let padding: CGFloat = 20
        let safeAreaInset = mainWindow.safeAreaInsets
        
        let leftCenterX = (pipSize.width / 2) + padding + safeAreaInset.left
        let rightCenterX = mainWindow.bounds.width - ((pipSize.width / 2) + padding + safeAreaInset.right)
        let topCenterY = (pipSize.height / 2) + padding + safeAreaInset.top
        let bottomCenterY = mainWindow.bounds.height - ((pipSize.height / 2) + padding + safeAreaInset.bottom)
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
        guard let mainWindow = self.mainWindow else { return }
        guard let shopLiveWindow = self.shopLiveWindow else { return }
        let pipSize = self.pipSize(with: scale)
        let pipCenter = self.pipCenter(with: position)
        let safeAreaInset = mainWindow.safeAreaInsets

        ShopLiveController.windowStyle = .inAppPip
        shopLiveWindow.clipsToBounds = false
        shopLiveWindow.rootViewController?.view.layer.cornerRadius = 10
        shopLiveWindow.rootViewController?.view.backgroundColor = .clear
        liveStreamViewController?.hideBackgroundPoster()
        
        videoWindowPanGestureRecognizer?.isEnabled = true
        videoWindowTapGestureRecognizer?.isEnabled = true
        videoWindowSwipeDownGestureRecognizer?.isEnabled = false

        if ShopLiveController.isReplayMode {
            //Webview dom이 에니메이션 이후에 바뀌는 이슈가 있음
            //transform 에니메이션 이후에 에니메이션 이전 크기가 잠시 보였다가 최종 크기로 변하는 이슈가 있음.
            //에니메이션 종료 후 스냅샷으로 최종 크기가 될 때까지 대체함.
            let transformScaleX = pipSize.width / shopLiveWindow.frame.width
            let transformScaleY = pipSize.height / (shopLiveWindow.frame.height - safeAreaInset.top)
            let transform = shopLiveWindow.transform.concatenating(CGAffineTransform(scaleX: transformScaleX, y: transformScaleY))
            let midCenter = CGPoint(x: pipCenter.x, y: pipCenter.y - (safeAreaInset.top * transformScaleY) / 2.0)

            UIView.animate(withDuration: 0.3, delay: 0, options: []) {
                ShopLiveController.isHiddenOverlay = true
                shopLiveWindow.transform = transform
                shopLiveWindow.center = midCenter
            } completion: { (isCompleted) in
                guard let snapshop = shopLiveWindow.snapshotView(afterScreenUpdates: false) else { return }
                let bounds = CGRect(x: 0, y: 0, width: pipSize.width, height: pipSize.height)
                self.liveStreamViewController?.view.isHidden = true
                shopLiveWindow.addSubview(snapshop)
                snapshop.frame = CGRect(x: 0, y: -(safeAreaInset.top * transformScaleY), width: pipSize.width, height: pipSize.height + (safeAreaInset.top * transformScaleY))
//                snapshop.center = shopLiveWindow.center
                shopLiveWindow.transform = .identity
                shopLiveWindow.bounds = bounds
                shopLiveWindow.center = pipCenter
                shopLiveWindow.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
                shopLiveWindow.rootViewController?.view.clipsToBounds = true
                shopLiveWindow.rootViewController?.view.backgroundColor = .black
                shopLiveWindow.layer.shadowColor = UIColor.black.cgColor
                shopLiveWindow.layer.shadowOpacity = 0.5
                shopLiveWindow.layer.shadowOffset = .zero
                shopLiveWindow.layer.shadowRadius = 10
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100)) {
                    self.liveStreamViewController?.view.isHidden = false
                    snapshop.removeFromSuperview()
                    ShopLiveController.shared.pipAnimationg = false
                }
            }
        }
        else {
            //pip 애니메이션시 완료되었을 때와 중간 transform 되었을 때 영상 사이즈가 달라지기 때문에 맞추기 위해 중간 사이즈와 중간 센터를 설정함
            let midScale = pipSize.height / (shopLiveWindow.frame.height - safeAreaInset.top)
            let midWidth = pipSize.width / midScale
            let currentCenter = shopLiveWindow.center
            shopLiveWindow.bounds = CGRect(x: 0, y: 0, width: midWidth, height: shopLiveWindow.bounds.height)
            shopLiveWindow.center = currentCenter
            
            let transformScaleX = pipSize.width / shopLiveWindow.frame.width
            let transformScaleY = pipSize.height / (shopLiveWindow.frame.height - safeAreaInset.top)
            let midCenter = CGPoint(x: pipCenter.x, y: pipCenter.y - (safeAreaInset.top * transformScaleY) / 2.0)
            
            let transform = shopLiveWindow.transform.concatenating(CGAffineTransform(scaleX: transformScaleX, y: transformScaleY))
            
            UIView.animate(withDuration: 0.3, delay: 0, options: []) {
                ShopLiveController.isHiddenOverlay = true
                shopLiveWindow.transform = transform
                shopLiveWindow.center = midCenter
            } completion: { (isCompleted) in
                let bounds = CGRect(x: 0, y: 0, width: pipSize.width, height: pipSize.height)
                shopLiveWindow.transform = .identity
                shopLiveWindow.bounds = bounds
                shopLiveWindow.center = pipCenter
                shopLiveWindow.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
                shopLiveWindow.rootViewController?.view.clipsToBounds = true
                shopLiveWindow.rootViewController?.view.backgroundColor = .black
                shopLiveWindow.layer.shadowColor = UIColor.black.cgColor
                shopLiveWindow.layer.shadowOpacity = 0.5
                shopLiveWindow.layer.shadowOffset = .zero
                shopLiveWindow.layer.shadowRadius = 10
                ShopLiveController.shared.pipAnimationg = false
            }
        }

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
        
        if ShopLiveController.isReplayMode {
            //Webview dom이 에니메이션 이후에 바뀌는 이슈가 있음
            //transform 에니메이션 이후에 에니메이션 이전 크기가 잠시 보였다가 최종 크기로 변하는 이슈가 있음.
            //에니메이션 종료 후 스냅샷으로 최종 크기가 될 때까지 대체함.
            let safeAreaInset = mainWindow.safeAreaInsets
            let transformScale = (mainWindow.bounds.height - safeAreaInset.top) / shopLiveWindow.bounds.height
            let transform = shopLiveWindow.transform.concatenating(CGAffineTransform(scaleX: transformScale, y: transformScale))
            let midCenter = CGPoint(x: mainWindow.center.x, y: mainWindow.center.y + safeAreaInset.top / 2)
            
            UIView.animate(withDuration: 0.3, delay: 0, options: []) {
                shopLiveWindow.transform = transform
                shopLiveWindow.center = midCenter
                shopLiveWindow.layer.cornerRadius = 0
                shopLiveWindow.rootViewController?.view.layer.cornerRadius = 0
            } completion: { (isCompleted) in
                
                guard let snapshop = shopLiveWindow.snapshotView(afterScreenUpdates: false) else { return }
                self.liveStreamViewController?.view.isHidden = true
                shopLiveWindow.addSubview(snapshop)
                snapshop.frame = CGRect(x: 0, y: safeAreaInset.top, width: shopLiveWindow.bounds.width * transformScale , height: mainWindow.bounds.height - safeAreaInset.top)
                snapshop.center.x = mainWindow.center.x
                
                shopLiveWindow.transform = .identity
                shopLiveWindow.frame = mainWindow.bounds
                shopLiveWindow.rootViewController?.view.clipsToBounds = false
                shopLiveWindow.rootViewController?.view.backgroundColor = .black
                self.liveStreamViewController?.showBackgroundPoster()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100), execute: {
                    ShopLiveController.isHiddenOverlay = false
                    self.liveStreamViewController?.view.isHidden = false
                    snapshop.removeFromSuperview()
                    ShopLiveController.shared.pipAnimationg = false
                })
            }
        }
        else {
            let safeAreaInset = mainWindow.safeAreaInsets
            let transformScale = (mainWindow.bounds.height - safeAreaInset.top) / shopLiveWindow.bounds.height
            let transform = shopLiveWindow.transform.concatenating(CGAffineTransform(scaleX: transformScale, y: transformScale))
            let midCenter = CGPoint(x: mainWindow.center.x, y: mainWindow.center.y + safeAreaInset.top / 2)
            
            UIView.animate(withDuration: 0.3, delay: 0, options: []) {
                shopLiveWindow.transform = transform
                shopLiveWindow.center = midCenter
                shopLiveWindow.layer.cornerRadius = 0
                shopLiveWindow.rootViewController?.view.layer.cornerRadius = 0
            } completion: { (isCompleted) in
                shopLiveWindow.transform = .identity
                shopLiveWindow.frame = mainWindow.bounds
                shopLiveWindow.rootViewController?.view.clipsToBounds = false
                shopLiveWindow.rootViewController?.view.backgroundColor = .black
                self.liveStreamViewController?.showBackgroundPoster()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300), execute: {
                    ShopLiveController.isHiddenOverlay = false
                    ShopLiveController.shared.pipAnimationg = false
                })
            }
        }
        
        _style = .fullScreen
    }

    private func alignPipView() {
        guard let currentCenter = shopLiveWindow?.center else { return }
        guard let mainWindow = self.mainWindow else { return }
        let center = mainWindow.center
        
        let isPositiveDiffX = center.x - currentCenter.x > 0
        let isPositiveDiffY = center.y - currentCenter.y > 0
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
        
        let pipCenter = self.pipCenter(with: position)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
            self.shopLiveWindow?.center = pipCenter
        }
        lastPipPosition = position
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
            let minX = (liveWindow.bounds.width / 2.0) + padding + safeAreaInset.left
            let maxX = mainWindow.bounds.width - ((liveWindow.bounds.width / 2.0) + padding + safeAreaInset.right)
            let minY = liveWindow.bounds.height / 2.0 + padding + safeAreaInset.top
            let maxY = mainWindow.bounds.height - ((liveWindow.bounds.height / 2.0) + padding + safeAreaInset.bottom)
            
            var centerX = panGestureInitialCenter.x + translation.x
            var centerY = panGestureInitialCenter.y + translation.y
            
            let xRange = padding...(mainWindow.bounds.width - padding)
            let yRange = (padding + safeAreaInset.top)...(mainWindow.bounds.height - (padding + safeAreaInset.bottom))
            
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

    @objc private func pipTapGestureHandler(_ recognizer: UIPanGestureRecognizer) {
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
    }

    func removeObserver() {
        self.removeObserver(self, forKeyPath: "_style")
        self.removeObserver(self, forKeyPath: "_authToken")
        self.removeObserver(self, forKeyPath: "_user")
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
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
        fetchPreviewUrl(with: campaignKey) { url in
            guard let url = url else { return }
            self.showPreview(previewUrl: url, completion: completion)
        }
    }
    
    @objc func play(with campaignKey: String?, _ parent: UIViewController?) {
        guard self.accessKey != nil else { return }
        fetchOverlayUrl(with: campaignKey) { (overlayUrl) in
            guard let url = overlayUrl else { return }
            delegate?.handleCommand("willShopLiveOn", with: nil)
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

    }
    
    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        ShopLiveController.windowStyle = .normal
    }
    
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        if isRestoredPip { //touch stop pip button in OS PIP view
            self.shopLiveWindow?.isHidden = false
//            stopShopLivePictureInPicture()
        }
        else { //touch close pip button in OS PIP view
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
