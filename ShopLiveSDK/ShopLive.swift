//
//  ShopLiveSDK.swift
//  ShopLiveSDK
//
//  Created by purpleworks on 2021/02/04.
//

import UIKit
import Combine
import AVKit
import WebKit

@objc public final class ShopLive: NSObject {
    static var shared: ShopLive = {
        return ShopLive()
    }()
    
    private lazy var cancellableSet = Set<AnyCancellable>()
    private lazy var pipControllerPublisherCancellableSet = Set<AnyCancellable>()
    
    private var shopLiveWindow: UIWindow? = nil
    private var videoWindowPanGestureRecognizer: UIPanGestureRecognizer?
    private var videoWindowTapGestureRecognizer: UITapGestureRecognizer?
    private var videoWindowSwipeDownGestureRecognizer: UISwipeGestureRecognizer?
    private var webViewConfiguration: WKWebViewConfiguration?
    private var isRestoredPip: Bool = false
    private var accessKey: String? = nil
    
    private var lastPipPosition: PipPosition = .default
    private var lastPipScale: CGFloat = 2/5
    
    weak private var mainWindow: UIWindow? = nil
    
    @Published var style: PresentationStyle = .unknown
    @Published var authToken: String?
    @Published var user: ShopLiveUser?
    
    var liveStreamViewController: LiveStreamViewController?
    var pictureInPictureController: AVPictureInPictureController?
    
    var pipPossibleObservation: NSKeyValueObservation?
    var originAudioSessionCategory: AVAudioSession.Category?
    
    weak var delegate: ShopLiveSDKDelegate?
    
    override init() {
        super.init()
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).receive(on: RunLoop.main).sink { [weak self] (notification) in
            guard self?.style != .unknown else { return }
            DispatchQueue.main.async {
                self?.pictureInPictureController?.stopPictureInPicture()
            }
        }.store(in: &cancellableSet)
        
        $authToken.removeDuplicates().sink { [weak self] (authToken) in
            self?.liveStreamViewController?.viewModel.authToken = authToken
        }.store(in: &cancellableSet)
        
        $user.removeDuplicates().sink { [weak self] (user) in
            self?.liveStreamViewController?.viewModel.user = user
        }.store(in: &cancellableSet)
        
        $style.dropFirst().removeDuplicates().sink { (style) in
            self.liveStreamViewController?.updatePipStyle(with: style)
        }.store(in: &cancellableSet)
    }
    
    func showShopLiveView(with overlayUrl: URL) {
        guard style == .unknown else {
            liveStreamViewController?.viewModel.overayUrl = overlayUrl
            liveStreamViewController?.reload()
            stopShopLivePictureInPicture()
            return
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        originAudioSessionCategory = audioSession.category
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
        } catch  {
            print("Audio session failed")
        }
        
        liveStreamViewController = LiveStreamViewController()
        liveStreamViewController?.delegate = self
        liveStreamViewController?.webViewConfiguration = webViewConfiguration
        liveStreamViewController?.viewModel.overayUrl = overlayUrl
        liveStreamViewController?.viewModel.authToken = authToken
        liveStreamViewController?.viewModel.user = user
        
        mainWindow = (UIApplication.shared.windows.first(where: { $0.isKeyWindow }))
        
        shopLiveWindow = UIWindow()
        shopLiveWindow?.windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
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
        style = .fullScreen
    }
    
    func hideShopLiveView(_ animated: Bool = true) {
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
            self.style = .unknown
        }
//        overlayUrl = nil
    }
    
    //OS 제공 PIP 세팅
    func setupPictureInPicture() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error {
            debugPrint(error)
        }
        guard let playerLayer = liveStreamViewController?.playerLayer else { return }
        playerLayer.frame = CGRect(x: 100, y: 100, width: 320, height: 180)
        // Ensure PiP is supported by current device.
        if AVPictureInPictureController.isPictureInPictureSupported() {
            // Create a new controller, passing the reference to the AVPlayerLayer.
            pictureInPictureController = AVPictureInPictureController(playerLayer: playerLayer)
            pictureInPictureController?.delegate = self
//            pictureInPictureController?.publisher(for: \.isPictureInPicturePossible)
//                .receive(on: RunLoop.main)
//                .sink(receiveValue: { [weak self] (isPictureInPicturePossible) in
////                    self?.liveStreamViewController?.pipButton?.isEnabled = isPictureInPicturePossible
//                })
//                .store(in: &pipControllerPublisherCancellableSet)

//            pictureInPictureController?.publisher(for: \.isPictureInPictureActive)
//                .receive(on: RunLoop.main)
//                .sink(receiveValue: { [weak self] (isPictureInPictureActive) in
////                    self?.style = isPictureInPictureActive ? .pip : .fullScreen
//                })
//                .store(in: &pipControllerPublisherCancellableSet)

//            pictureInPictureController?.publisher(for: \.isPictureInPictureSuspended)
//                .receive(on: RunLoop.main)
//                .sink(receiveValue: { (isPictureInPictureSuspended) in
//
//                })
//                .store(in: &pipControllerPublisherCancellableSet)
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
        var videoSize = liveStreamViewController?.viewModel.videoPlayer.currentItem?.presentationSize ?? .zero
        videoSize = videoSize == .zero ? CGSize(width: 9, height: 16) : videoSize
        
        let width = mainWindow.bounds.width * scale
        let height = (videoSize.height / videoSize.width) * width
        
        return CGSize(width: width, height: height)
    }
    
    private func pipCenter(with position: PipPosition) -> CGPoint {
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
    
    private func startCustomPictureInPicture(with position: PipPosition = .default, scale: CGFloat = 2/5) {
        guard let mainWindow = self.mainWindow else { return }
        guard let shopLiveWindow = self.shopLiveWindow else { return }
        let pipSize = self.pipSize(with: scale)
        let pipCenter = self.pipCenter(with: position)
        let safeAreaInset = mainWindow.safeAreaInsets
        
        shopLiveWindow.clipsToBounds = false
        shopLiveWindow.rootViewController?.view.layer.cornerRadius = 10
        shopLiveWindow.rootViewController?.view.backgroundColor = .clear
        liveStreamViewController?.hideBackgroundPoster()
        
        videoWindowPanGestureRecognizer?.isEnabled = true
        videoWindowTapGestureRecognizer?.isEnabled = true
        videoWindowSwipeDownGestureRecognizer?.isEnabled = false
        
        if liveStreamViewController?.isReplayMode ?? false {
            //Webview dom이 에니메이션 이후에 바뀌는 이슈가 있음
            //transform 에니메이션 이후에 에니메이션 이전 크기가 잠시 보였다가 최종 크기로 변하는 이슈가 있음.
            //에니메이션 종료 후 스냅샷으로 최종 크기가 될 때까지 대체함.
            let transformScaleX = pipSize.width / shopLiveWindow.frame.width
            let transformScaleY = pipSize.height / (shopLiveWindow.frame.height - safeAreaInset.top)
            let transform = shopLiveWindow.transform.concatenating(CGAffineTransform(scaleX: transformScaleX, y: transformScaleY))
            let midCenter = CGPoint(x: pipCenter.x, y: pipCenter.y - (safeAreaInset.top * transformScaleY) / 2.0)
            
            UIView.animate(withDuration: 0.3, delay: 0, options: []) {
                self.liveStreamViewController?.isHiddenOverlay = true
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
                self.liveStreamViewController?.isHiddenOverlay = true
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
            }
        }
        

        style = .pip
    }
    
    private func stopCustomPictureInPicture() {
        guard let mainWindow = self.mainWindow else { return }
        guard let shopLiveWindow = self.shopLiveWindow else { return }
        
        videoWindowPanGestureRecognizer?.isEnabled = false
        videoWindowTapGestureRecognizer?.isEnabled = false
        videoWindowSwipeDownGestureRecognizer?.isEnabled = true
        
        shopLiveWindow.layer.shadowColor = nil
        shopLiveWindow.layer.shadowOpacity = 0.0
        shopLiveWindow.layer.shadowOffset = .zero
        shopLiveWindow.layer.shadowRadius = 0
        
        
        shopLiveWindow.rootViewController?.view.backgroundColor = .clear
        
        if liveStreamViewController?.isReplayMode ?? false {
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
                    self.liveStreamViewController?.isHiddenOverlay = false
                    self.liveStreamViewController?.view.isHidden = false
                    snapshop.removeFromSuperview()
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
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100), execute: {
                    self.liveStreamViewController?.isHiddenOverlay = false
                })
            }
        }
        
        style = .fullScreen
    }
    
    private func alignPipView() {
        guard let currentCenter = shopLiveWindow?.center else { return }
        guard let mainWindow = self.mainWindow else { return }
        let center = mainWindow.center
        
        let isPositiveDiffX = center.x - currentCenter.x > 0
        let isPositiveDiffY = center.y - currentCenter.y > 0
        let position: PipPosition = {
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
        guard style == .pip else { return }
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
        guard style == .fullScreen else { return }
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
        guard style == .pip else { return }
        stopShopLivePictureInPicture()
    }
    
    func fetchOverlayUrl(with campaignKey: String?, completionHandler: ((URL?) -> Void)) {
        guard let accessKey = self.accessKey else {
            completionHandler(nil)
            return
        }
        let url = "https://static.shoplive.cloud/sdk/player.html"
        
        var urlComponents = URLComponents(string: url)
        var queryItems = urlComponents?.queryItems ?? [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "ak", value: accessKey))
        if let ck = campaignKey {
            queryItems.append(URLQueryItem(name: "ck", value: ck))
        }
        
        urlComponents?.queryItems = queryItems
        completionHandler(urlComponents?.url)
    }
}

extension ShopLive {
    @objc public enum PipPosition: Int {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        case `default`
    }
    
    @objc public enum PresentationStyle: Int {
        case unknown
        case fullScreen
        case pip
    }
}

extension ShopLive: ShopLiveSDKInterface {
    @objc public class func startPictureInPicture() {
        startPictureInPicture(with: .default, scale: 2/5)
    }
    
    @objc public class var authToken: String? {
        get {
            return shared.authToken
        }
        set {
            shared.authToken = newValue
        }
    }
    
    @objc public class var user: ShopLiveUser? {
        get {
            return shared.user
        }
        set {
            shared.user = newValue
        }
    }
    
    @objc public class func configure(with accessKey: String) {
        shared.accessKey = accessKey
    }
    
    @objc public class func play(with campaignKey: String?) {
        guard shared.accessKey != nil else { return }
        shared.fetchOverlayUrl(with: campaignKey) { (overlayUrl) in
            guard let url = overlayUrl else { return }
            shared.showShopLiveView(with: url)
        }
    }
    
    @objc public class func reloadLive() {
        guard shared.accessKey != nil else { return }
        shared.liveStreamViewController?.reload()
    }
    
//    @objc public class func dismissShopLive() {
//        guard shared.apiKey != nil else { return }
//        shared.hideShopLiveView()
//    }
    
    @objc public class func startPictureInPicture(with position: PipPosition, scale: CGFloat) {
        shared.lastPipScale = scale
        shared.lastPipPosition = position
        shared.startShopLivePictureInPicture()
    }
    @objc public class func stopPictureInPicture() {
        shared.stopShopLivePictureInPicture()
    }
    
    @objc public class var style: ShopLive.PresentationStyle {
        get {
            return shared.style
        }
    }
    
    @objc public class var pipPosition: ShopLive.PipPosition {
        get {
            return shared.lastPipPosition
        }
        set {
            shared.lastPipPosition = newValue
        }
    }
    
    @objc public class var pipScale: CGFloat {
        get {
            return shared.lastPipScale
        }
        set {
            shared.lastPipScale = newValue
        }
    }
    
    @objc public class var delegate: ShopLiveSDKDelegate? {
        set {
            shared.delegate = newValue
        }
        get {
            return shared.delegate
        }
    }
    
    @objc public class var webViewConfiguration: WKWebViewConfiguration? {
        set {
            shared.webViewConfiguration = newValue
        }
        get {
            return shared.webViewConfiguration
        }
    }
}

extension ShopLive: AVPictureInPictureControllerDelegate {
    
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        //PIP 에서 stop pip 버튼으로 돌아올 때
        isRestoredPip = true
        completionHandler(true)
    }
    
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        UIView.animate(withDuration: 0.2) {
            self.shopLiveWindow?.alpha = 0
        } completion: { (isCompleted) in
            self.shopLiveWindow?.isHidden = true
            self.shopLiveWindow?.alpha = 1.0
        }
    }
    
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        
    }
    
    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        
    }
    
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        if isRestoredPip { //touch stop pip button in OS PIP view
            self.shopLiveWindow?.isHidden = false
            stopShopLivePictureInPicture()
        }
        else { //touch close pip button in OS PIP view
            self.hideShopLiveView()
        }
        
        isRestoredPip = false
    }
}

extension ShopLive: LiveStreamViewControllerDelegate {
    func didTouchPipButton() {
        startShopLivePictureInPicture()
    }
    
    func didTouchCloseButton() {
        hideShopLiveView()
    }
    
    func didTouchNavigation(with url: URL) {
        delegate?.handleNavigation(with: url)
    }
    
    func didTouchCoupon(with couponId: String) {
        let completion: () -> Void = { [weak self] in self?.liveStreamViewController?.didCompleteDownLoadCoupon(with: couponId) }
        delegate?.handleDownloadCoupon(with: couponId, completion: completion)
    }
    
    func handleCommand(_ command: String, with payload: Any?) {
        delegate?.handleCommand(command, with: payload)
    }
}
