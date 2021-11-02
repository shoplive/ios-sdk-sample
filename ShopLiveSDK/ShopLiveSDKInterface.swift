//
//  ShopLiveSDKInterface.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/03/05.
//

import Foundation
import WebKit
import UIKit

@objc public class CouponFailure: NSObject {

    var couponId: String = ""
    var closeCoupon: Bool
    var message: String?

    init(closeCoupon: Bool = false, message: String? = nil) {
        self.closeCoupon = closeCoupon
        self.message = message
    }
}

@objc public protocol ShopLiveSDKDelegate: AnyObject {
    @objc func handleNavigation(with url: URL)
    @objc func handleDownloadCoupon(with couponId: String, completion: @escaping (Bool, CouponFailure?) -> Void)
    @objc func handleCustomAction(with id: String, type: String, payload: Any?, completion: @escaping () -> Void)
    @objc func handleChangeCampaignStatus(status: String)
    @objc func handleError(code: String, message: String)
    @objc func handleCampaignInfo(campaignInfo: [String : Any])
    @objc func handleCommand(_ command: String, with payload: Any?)
}

@objc public class ShopLiveViewController: UIViewController {

}

@objc protocol ShopLiveSDKInterface: AnyObject {
    @objc static var viewController: ShopLiveViewController? { get }
    @objc static var style: ShopLive.PresentationStyle { get }
    @objc static var pipPosition: ShopLive.PipPosition { get set }
    @objc static var pipScale: CGFloat { get set }
    @objc static var indicatorColor: UIColor { get set }
    @objc static var webViewConfiguration: WKWebViewConfiguration? { get set }
    @objc static var delegate: ShopLiveSDKDelegate? { get set }

    
    @objc static var authToken: String? { get set }
    @objc static var user: ShopLiveUser? { get set }
    
    @objc static func configure(with accessKey: String)
    @objc static func configure(with accessKey: String, phase: ShopLive.Phase)
    @objc static func preview(with campaignKey: String?, completion: @escaping () -> Void)
    @objc static func play(with campaignKey: String?, _ parent: UIViewController?)
    @objc static func startPictureInPicture(with position: ShopLive.PipPosition, scale: CGFloat)
    @objc static func startPictureInPicture()
    @objc static func stopPictureInPicture()

//    @objc static func setLoadingAnimation(images: [UIImage])

    @objc static func setKeepAspectOnTabletPortrait(_ keep: Bool)

    @objc static func setKeepPlayVideoOnHeadphoneUnplugged(_ keepPlay: Bool)
    @objc static func isKeepPlayVideoOnHeadPhoneUnplugged() -> Bool
    @objc static func setAutoResumeVideoOnCallEnded(_ autoResume: Bool)
    @objc static func isAutoResumeVideoOnCallEnded() -> Bool
    
    @objc static func reloadLive()
    @objc static func onTerminated()

    @objc static func hookNavigation(navigation: @escaping  ((URL) -> Void))
    @objc static func setShareScheme(_ scheme: String?, custom: (() -> Void)?)
    @objc static func setChatViewFont(inputBoxFont: UIFont, sendButtonFont: UIFont)
    @objc static func close()
}
