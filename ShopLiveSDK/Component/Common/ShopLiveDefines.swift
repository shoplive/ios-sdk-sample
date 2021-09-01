//
//  Commons.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/05/19.
//

import Foundation
import UIKit
import CoreMedia

@objc internal final class ShopLiveDefines: NSObject {
    static let sdkVersion: String = "1.0.8"
    static var phase: ShopLive.Phase = .REAL
    static let url: String = {
                switch phase {
                case .DEV:
                    return "https://dev.shoplive.show/v1/sdk.html"
                case .STAGE:
                    return "https://stg.shoplive.show/v1/sdk.html"
                default:
                    return "https://www.shoplive.show/v1/sdk.html"
                }
            }()

    static let webInterface: String = "ShopLiveAppInterface"
}

protocol LiveStreamViewControllerDelegate: AnyObject {
    func didTouchPipButton()
    func didTouchCustomAction(id: String, type: String, payload: Any?)
    func didTouchCloseButton()
    func didTouchNavigation(with url: URL)
    func didTouchCoupon(with couponId: String)
    func handleCommand(_ command: String, with payload: Any?)
    func replay(with size: CGSize)
    func campaignInfo(campaignInfo: [String : Any])
    func didChangeCampaignStatus(status: String)
    func onError(code: String, message: String)
}

protocol OverlayWebViewDelegate: AnyObject {
    func didUpdateVideo(with url: URL)
    func reloadVideo()
    func didUpdatePoster(with url: URL)
    func didUpdateForegroundPoster(with url: URL)
    func replay(with size: CGSize)
    func setVideoCurrentTime(to: CMTime)
    func didTouchBlockView()

    func didTouchShareButton(with url: URL?)
    func didTouchCustomAction(id: String, type: String, payload: Any?)
    func didTouchPlayButton()
    func didTouchPauseButton()
    func didTouchMuteButton(with isMuted: Bool)
    func didTouchPipButton()
    func didTouchCloseButton()
    func didTouchNavigation(with url: URL)
    func didTouchCoupon(with couponId: String)
    func didChangeCampaignStatus(status: String)
    func onError(code: String, message: String)
    func handleCommand(_ command: String, with payload: Any?)
}

extension Notification.Name {
    /// Notification for when a timebase changed rate
    static let TimebaseEffectiveRateChangedNotification = Notification.Name(rawValue: kCMTimebaseNotification_EffectiveRateChanged as String)
}


@objc protocol KeyboardNotificationProtocol {
    @objc func keyboardWillShow(notification: Notification)
    @objc func keyboardWillHide(notification: Notification)
    @objc func keyboardWillChangeFrame(notification: Notification)
}

extension KeyboardNotificationProtocol {

    func registerKeyboardNoti() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    func removeKeyboardNoti() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}
