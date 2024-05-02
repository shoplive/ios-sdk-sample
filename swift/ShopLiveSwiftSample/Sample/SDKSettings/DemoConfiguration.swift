//
//  DemoConfiguration.swift
//  ShopLiveSwiftSample
//
//  Created by ShopLive on 2021/12/14.
//

import Foundation
import UIKit
import ShopLiveSDK
import ShopliveSDKCommon

@objc protocol DemoConfigurationObserver {
    var identifier: String { get }
    @objc optional func updatedValues(keys: [String])
}

final class DemoConfiguration: NSObject {

    static let shared: DemoConfiguration = .init()
    private var observers: [DemoConfigurationObserver?] = []

    private func notifyObservers(key: String) {
        self.observers.forEach { observer in
            observer?.updatedValues?(keys: [key])
        }
    }

    func addConfigurationObserver(observer: DemoConfigurationObserver) {
        if observers.contains(where: { $0?.identifier == observer.identifier }), let index = observers.firstIndex(where: { $0?.identifier == observer.identifier}) {
            observers.remove(at: index)
        }

        observers.append(observer)
    }

    var authType: String {
        set {
            UserDefaults.standard.set(newValue, forKey: "authType")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "authType") ?? "GUEST"
        }
    }

    var campaign: CampaignKeySet? {
        set {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey:"campaign")
            UserDefaults.standard.synchronize()
            notifyObservers(key: "campaign")
        }
        get {
            guard let data = UserDefaults.standard.value(forKey:"campaign") as? Data else { return nil }
            return try? PropertyListDecoder().decode(CampaignKeySet.self, from: data)
        }
    }

    func setUserInfo(user: ShopLiveCommonUser, jwtToken: String?) {
        self.user = user
        self.jwtToken = jwtToken
        notifyObservers(key: "userInfo")
    }

    var user: ShopLiveCommonUser {
        set {
            userId = newValue.userId
            userName = newValue.userName
            userAge = newValue.age
            userGender = newValue.gender
            userScore = newValue.userScore
        }
        get {
            let user = ShopLiveCommonUser(userId: userId ?? "null" ,userName: userName,age: userAge,gender: userGender, userScore: userScore )
            return user
        }
    }

    private(set) var userId: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "userId")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "userId")
        }
    }

    var userName: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "userName")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "userName")
        }
    }

    var userAge: Int? {
        set {
            UserDefaults.standard.set(newValue, forKey: "userAge")
            UserDefaults.standard.synchronize()
        }
        get {
            guard let age = UserDefaults.standard.string(forKey: "userAge") else {
                return nil
            }
            return Int(age)
        }
    }

    var userGender: ShopliveCommonUserGender? {
        set {
            UserDefaults.standard.set(newValue?.rawValue, forKey: "userGender")
            UserDefaults.standard.synchronize()
        }
        get {
            guard let genderDescription = UserDefaults.standard.string(forKey: "userGender"), let gender = ShopliveCommonUserGender.allCases.first(where: {$0.rawValue == genderDescription}) else {
                return nil
            }
            return gender
        }
    }

    var userScore: Int? {
        set {
            UserDefaults.standard.set(newValue?.description, forKey: "userScore")
            UserDefaults.standard.synchronize()
        }
        get {
            guard let score = UserDefaults.standard.string(forKey: "userScore") else {
                return nil
            }
            return Int(score)
        }
    }

    var jwtToken: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "jwtToken")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "jwtToken")
        }
    }

    var useHeadPhoneOption1: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.headphoneOption1.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey: SDKOptionType.headphoneOption1.optionKey)
        }
    }
    
    var useHeadPhoneOption2: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.headphoneOption2.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey: SDKOptionType.headphoneOption2.optionKey)
        }
    }

    var useCallOption: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.callOption.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey: SDKOptionType.callOption.optionKey)
        }
    }

    var useCustomShare: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.customShare.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey: SDKOptionType.customShare.optionKey)
        }
    }

    var shareScheme: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.shareScheme.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey:  SDKOptionType.shareScheme.optionKey)
        }
    }

    var progressColor: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.progressColor.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey:  SDKOptionType.progressColor.optionKey)
        }
    }

    var useCustomProgress: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.customProgress.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey: SDKOptionType.customProgress.optionKey)
        }
    }

    var useChatInputCustomFont: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.chatInputCustomFont.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.chatInputCustomFont.optionKey)
        }
    }

    var useChatSendButtonCustomFont: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.chatSendButtonCustomFont.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.chatSendButtonCustomFont.optionKey)
        }
    }

    func updateOptions() {
        notifyObservers(key: "options")
    }

    var downloadCouponSuccessMessage: String {
        set {
            UserDefaults.standard.set(newValue, forKey: CouponResponseKey.downloadCouponSuccessMessage.key)
            UserDefaults.standard.synchronize()
        }
        get {
            let message = UserDefaults.standard.string(forKey: CouponResponseKey.downloadCouponSuccessMessage.key) ?? "sample.couponresponse.success.default".localized()

            return message.isEmpty ? "sample.couponresponse.success.default".localized() : message
        }
    }

    var downloadCouponSuccessStatus: ShopLiveResultStatus {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: CouponResponseKey.downloadCouponSuccessStatus.key)
            UserDefaults.standard.synchronize()
        }
        get {
            let rawValue = UserDefaults.standard.integer(forKey: CouponResponseKey.downloadCouponSuccessStatus.key)
            return ShopLiveResultStatus(rawValue: rawValue) ?? .SHOW
        }
    }

    var downloadCouponSuccessAlertType: ShopLiveResultAlertType {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: CouponResponseKey.downloadCouponSuccessAlertType.key)
            UserDefaults.standard.synchronize()
        }
        get {
            let rawValue = UserDefaults.standard.integer(forKey: CouponResponseKey.downloadCouponSuccessAlertType.key)
            return ShopLiveResultAlertType(rawValue: rawValue) ?? .ALERT
        }
    }

    var downloadCouponFailedMessage: String {
        set {
            UserDefaults.standard.set(newValue, forKey: CouponResponseKey.downloadCouponFailedMessage.key)
            UserDefaults.standard.synchronize()
        }
        get {
            let message = UserDefaults.standard.string(forKey: CouponResponseKey.downloadCouponFailedMessage.key) ?? "sample.couponresponse.failed.default".localized()

            return message.isEmpty ? "sample.couponresponse.failed.default".localized() : message
        }
    }

    var downloadCouponFailedStatus: ShopLiveResultStatus {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: CouponResponseKey.downloadCouponFailedStatus.key)
            UserDefaults.standard.synchronize()
        }
        get {
            let rawValue = UserDefaults.standard.integer(forKey: CouponResponseKey.downloadCouponFailedStatus.key)
            return ShopLiveResultStatus(rawValue: rawValue) ?? .SHOW
        }
    }

    var downloadCouponFailedAlertType: ShopLiveResultAlertType {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: CouponResponseKey.downloadCouponFailedAlertType.key)
            UserDefaults.standard.synchronize()
        }
        get {
            let rawValue = UserDefaults.standard.integer(forKey: CouponResponseKey.downloadCouponFailedAlertType.key)
            return ShopLiveResultAlertType(rawValue: rawValue) ?? .ALERT
        }
    }

    var customFont: UIFont? {
        let customFont: String = "NotoSansKR-Regular"
        return UIFont(name: customFont, size: 16)
    }

    var pipPosition: ShopLive.PipPosition {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: SDKOptionType.pipPosition.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            let rawValue = UserDefaults.standard.integer(forKey: SDKOptionType.pipPosition.optionKey)
            return ShopLive.PipPosition(rawValue: rawValue) ?? ShopLive.PipPosition.default
        }
    }
    
    var maxPipSize: CGFloat? {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.maxPipSize.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            guard let pipSize = UserDefaults.standard.string(forKey:  SDKOptionType.maxPipSize.optionKey), !pipSize.isEmpty else {
                return nil
            }

            if let pipSize = pipSize.cgfloatValue, pipSize <= 0.0 {
                return nil
            }

            return pipSize.cgfloatValue
        }
    }
    
    var fixedHeightPipSize : CGFloat? {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.fixedHeightPipSize.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            guard let pipSize = UserDefaults.standard.string(forKey:  SDKOptionType.fixedHeightPipSize.optionKey), !pipSize.isEmpty else {
                return nil
            }

            if let pipSize = pipSize.cgfloatValue, pipSize <= 0.0 {
                return nil
            }

            return pipSize.cgfloatValue
        }
    }
    
    var fixedWidthPipSize : CGFloat? {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.fixedWidthPipSize.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            guard let pipSize = UserDefaults.standard.string(forKey:  SDKOptionType.fixedWidthPipSize.optionKey), !pipSize.isEmpty else {
                return nil
            }

            if let pipSize = pipSize.cgfloatValue, pipSize <= 0.0 {
                return nil
            }

            return pipSize.cgfloatValue
        }
    }
    

    var nextActionTypeOnHandleNavigation: ActionType {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: SDKOptionType.nextActionOnHandleNavigation.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.nextActionOnHandleNavigation.optionKey)
        }
        get {
            let value = UserDefaults.standard.integer(forKey:  SDKOptionType.nextActionOnHandleNavigation.optionKey)
            return ActionType(rawValue: value) ?? .PIP
        }
    }
    
    var pipPadding: UIEdgeInsets {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.pipPadding.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.pipPadding.optionKey)
        }
        get {
            let defPadding: UIEdgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20)
            guard let padding = UserDefaults.standard.cgRect(forKey: SDKOptionType.pipPadding.optionKey) else {
                return defPadding
            }
            
            return padding
        }
    }
    
    var pipFloatingOffset: UIEdgeInsets {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.pipFloatingOffset.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.pipFloatingOffset.optionKey)
        }
        get {
            let defPadding: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
            guard let padding = UserDefaults.standard.cgRect(forKey: SDKOptionType.pipFloatingOffset.optionKey) else {
                return defPadding
            }
            
            return padding
        }
    }
    
    var useAspectOnTablet: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.aspectOnTablet.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.aspectOnTablet.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.aspectOnTablet.optionKey)
        }
    }
    
    var useKeepWindowStateOnPlayExecuted: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.keepWindowStateOnPlayExecuted.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.keepWindowStateOnPlayExecuted.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.keepWindowStateOnPlayExecuted.optionKey)
        }
    }
    
    var usePipKeepWindowStyle: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.pipKeepWindowStyle.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.pipKeepWindowStyle.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.pipKeepWindowStyle.optionKey)
        }
    }
    
    var pipEnableSwipeOut: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.pipEnableSwipeOut.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.pipEnableSwipeOut.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.pipEnableSwipeOut.optionKey)
        }
    }
    
    var pipCornerRadius: Double {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.pipCornerRadius.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.pipCornerRadius.optionKey)
        }
        get {
            return UserDefaults.standard.double(forKey: SDKOptionType.pipCornerRadius.optionKey)
        }
    }
    
    
    var useCloseButton: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.useCloseButton.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.useCloseButton.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.useCloseButton.optionKey)
        }
    }
    
    
    
    var isMuted: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.mute.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.mute.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.mute.optionKey)
        }
    }
    
    var mixAudio: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.mixAudio.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.mixAudio.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.mixAudio.optionKey)
        }
    }
    

    var usePlayWhenPreviewTapped: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.playWhenPreviewTapped.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.playWhenPreviewTapped.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.playWhenPreviewTapped.optionKey)
        }
    }
    
    var statusBarVisibility : Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.statusBarVisibility.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.statusBarVisibility.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.statusBarVisibility.optionKey)
        }
    }
    
    var enablePip : Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.enablePip.optionKey)
            notifyObservers(key: SDKOptionType.enablePip.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.enablePip.optionKey)
        }
    }
    
    var enableOsPip : Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.enableOSPip.optionKey)
            notifyObservers(key: SDKOptionType.enableOSPip.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.enableOSPip.optionKey)
        }
    }
    
    var enablePreviewSound: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.enablePreviewSound.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.enablePreviewSound.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.enablePreviewSound.optionKey)
        }
    }

    
}
