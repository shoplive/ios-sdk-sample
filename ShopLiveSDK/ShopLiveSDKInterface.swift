//
//  ShopLiveSDKInterface.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/03/05.
//

import Foundation
import WebKit

@objc public protocol ShopLiveSDKDelegate: AnyObject {
    @objc func handleNavigation(with url: URL)
    @objc func handleDownloadCoupon(with couponId: String, completion: @escaping () -> Void)
    @objc func handleCommand(_ command: String, with payload: Any?)
}

@objc protocol ShopLiveSDKInterface: AnyObject {
    @objc static var style: ShopLive.PresentationStyle { get }
    @objc static var pipPosition: ShopLive.PipPosition { get set }
    @objc static var pipScale: CGFloat { get set }
    @objc static var webViewConfiguration: WKWebViewConfiguration? { get set }
    @objc static var delegate: ShopLiveSDKDelegate? { get set }
    
    @objc static var authToken: String? { get set }
    @objc static var user: ShopLiveUser? { get set }
    
    @objc static func configure(with accessKey: String)
    @objc static func configure(with accessKey: String, phase: ShopLive.Phase)
    @objc static func play(with campaignKey: String?, _ parent: UIViewController?)
    @objc static func startPictureInPicture(with position: ShopLive.PipPosition, scale: CGFloat)
    @objc static func startPictureInPicture()
    @objc static func stopPictureInPicture()
    
    @objc static func reloadLive()
    //    @objc static func dismissShopLive()
}
