//
//  ShopLiveSDK.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/02/04.
//

import UIKit
import AVKit
import WebKit

@objc internal protocol ShopLiveComponent: AnyObject {
    @objc var style: ShopLive.PresentationStyle { get }
    @objc var pipPosition: ShopLive.PipPosition { get set }
    @objc var pipScale: CGFloat { get set }
    @objc var webViewConfiguration: WKWebViewConfiguration? { get set }
    @objc var delegate: ShopLiveSDKDelegate? { get set }

    @objc var authToken: String? { get set }
    @objc var user: ShopLiveUser? { get set }

    @objc func configure(with accessKey: String)
    @objc func configure(with accessKey: String, phase: ShopLive.Phase)
    @objc func play(with campaignKey: String?, _ parent: UIViewController?)
    @objc func startPictureInPicture(with position: ShopLive.PipPosition, scale: CGFloat)
    @objc func startPictureInPicture()
    @objc func stopPictureInPicture()

    @objc func reloadLive()
}

@objc public final class ShopLive: NSObject {
    static var shared: ShopLive = {
        return ShopLive()
    }()

    private var instance: ShopLiveComponent
    override init() {
        if #available(iOS 13.0, *) {
            instance = ShopLiveCombine()
        } else {
            instance = ShopLiveRxSwift()
        }
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

    @objc public enum Phase: Int {
        case DEV
        case STAGE
        case REAL

        var name: String {
            switch self {
            case .DEV:
                return "DEV"
            case .STAGE:
                return "STAGE"
            case .REAL:
                return "REAL"
            }
        }
    }
}

extension ShopLive: ShopLiveSDKInterface {

    public static var user: ShopLiveUser? {
        get {
            shared.instance.user
        }
        set {
            shared.instance.user = newValue
        }
    }

    public static var style: PresentationStyle {
        return shared.instance.style
    }

    public static var pipPosition: PipPosition {
        get {
            shared.instance.pipPosition
        }
        set {
            shared.instance.pipPosition = newValue
        }
    }

    public static var pipScale: CGFloat {
        get {
            shared.instance.pipScale
        }
        set {
            shared.instance.pipScale = newValue
        }
    }

    public static var webViewConfiguration: WKWebViewConfiguration? {
        get {
            shared.instance.webViewConfiguration
        }
        set {
            shared.instance.webViewConfiguration = newValue
        }
    }

    public static var delegate: ShopLiveSDKDelegate? {
        get {
            shared.instance.delegate
        }
        set {
            shared.instance.delegate = newValue
        }
    }

    public static var authToken: String? {
        get {
            shared.instance.authToken
        }
        set {
            shared.instance.authToken = newValue
        }
    }

    public static func configure(with accessKey: String) {
        shared.instance.configure(with: accessKey)
    }

    public static func configure(with accessKey: String, phase: ShopLive.Phase) {
        shared.instance.configure(with: accessKey, phase: phase)
    }

    public static func play(with campaignKey: String?, _ parent: UIViewController? = nil) {
        shared.instance.play(with: campaignKey, parent)
    }

    public static func startPictureInPicture(with position: PipPosition, scale: CGFloat) {
        shared.instance.startPictureInPicture(with: position, scale: scale)
    }

    public static func startPictureInPicture() {
        shared.instance.startPictureInPicture()
    }

    public static func stopPictureInPicture() {
        shared.instance.stopPictureInPicture()
    }

    public static func reloadLive() {
        shared.instance.reloadLive()
    }
}
