//
//  DemoConfiguration.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/14.
//

import Foundation
import UIKit

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

    var user: ShopLiveUser {
        set {
            userId = newValue.id
            userName = newValue.name
            userAge = newValue.age
            userGender = newValue.gender
            userScore = newValue.userScore
            notifyObservers(key: "user")
        }
        get {
            let user = ShopLiveUser()
            user.id = userId
            user.name = userName
            user.age = userAge
            user.gender = userGender
            user.add(["userScore" : userScore])
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

    var userGender: ShopLiveUser.Gender? {
        set {
            UserDefaults.standard.set(newValue?.description, forKey: "userGender")
            UserDefaults.standard.synchronize()
        }
        get {
            guard let genderDescription = UserDefaults.standard.string(forKey: "userGender"), let gender = ShopLiveUser.Gender.allCases.first(where: {$0.description == genderDescription}) else {
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
            notifyObservers(key: SDKOptionType.headphoneOption1.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey: SDKOptionType.headphoneOption1.optionKey)
        }
    }

    var useCallOption: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.callOption.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.headphoneOption1.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey: SDKOptionType.callOption.optionKey)
        }
    }

    var useCustomShare: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.customShare.optionKey)
            notifyObservers(key: SDKOptionType.headphoneOption1.optionKey)
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
            notifyObservers(key: SDKOptionType.headphoneOption1.optionKey)
        }
        get {
            return UserDefaults.standard.string(forKey:  SDKOptionType.shareScheme.optionKey)
        }
    }

    var progressColor: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.progressColor.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.headphoneOption1.optionKey)
        }
        get {
            return UserDefaults.standard.string(forKey:  SDKOptionType.progressColor.optionKey)
        }
    }

    var useCustomProgress: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.customProgress.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.headphoneOption1.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey: SDKOptionType.customProgress.optionKey)
        }
    }

    var useChatInputCustomFont: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.chatInputCustomFont.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.headphoneOption1.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.chatInputCustomFont.optionKey)
        }
    }

    var useChatSendButtonCustomFont: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.chatSendButtonCustomFont.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.headphoneOption1.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.chatSendButtonCustomFont.optionKey)
        }
    }

    var downloadCouponSuccessMessage: String {
        set {
            UserDefaults.standard.set(newValue, forKey: CouponResponseKey.downloadCouponSuccessMessage.key)
            UserDefaults.standard.synchronize()
        }
        get {
            let message = UserDefaults.standard.string(forKey: CouponResponseKey.downloadCouponSuccessMessage.key) ?? "couponresponse.success.default".localized()

            return message.isEmpty ? "couponresponse.success.default".localized() : message
        }
    }

    var downloadCouponSuccessStatus: ResultStatus {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: CouponResponseKey.downloadCouponSuccessStatus.key)
            UserDefaults.standard.synchronize()
        }
        get {
            let rawValue = UserDefaults.standard.integer(forKey: CouponResponseKey.downloadCouponSuccessStatus.key)
            return ResultStatus(rawValue: rawValue) ?? .SHOW
        }
    }

    var downloadCouponSuccessAlertType: ResultAlertType {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: CouponResponseKey.downloadCouponSuccessAlertType.key)
            UserDefaults.standard.synchronize()
        }
        get {
            let rawValue = UserDefaults.standard.integer(forKey: CouponResponseKey.downloadCouponSuccessAlertType.key)
            return ResultAlertType(rawValue: rawValue) ?? .ALERT
        }
    }

    var downloadCouponFailedMessage: String {
        set {
            UserDefaults.standard.set(newValue, forKey: CouponResponseKey.downloadCouponFailedMessage.key)
            UserDefaults.standard.synchronize()
        }
        get {
            let message = UserDefaults.standard.string(forKey: CouponResponseKey.downloadCouponFailedMessage.key) ?? "couponresponse.failed.default".localized()

            return message.isEmpty ? "couponresponse.failed.default".localized() : message
        }
    }

    var downloadCouponFailedStatus: ResultStatus {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: CouponResponseKey.downloadCouponFailedStatus.key)
            UserDefaults.standard.synchronize()
        }
        get {
            let rawValue = UserDefaults.standard.integer(forKey: CouponResponseKey.downloadCouponFailedStatus.key)
            return ResultStatus(rawValue: rawValue) ?? .SHOW
        }
    }

    var downloadCouponFailedAlertType: ResultAlertType {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: CouponResponseKey.downloadCouponFailedAlertType.key)
            UserDefaults.standard.synchronize()
        }
        get {
            let rawValue = UserDefaults.standard.integer(forKey: CouponResponseKey.downloadCouponFailedAlertType.key)
            return ResultAlertType(rawValue: rawValue) ?? .ALERT
        }
    }

    var customFont: UIFont? {
        let customFont: String = "NanumBrush"
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

    var pipScale: CGFloat? {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.pipScale.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            guard let scale = UserDefaults.standard.string(forKey:  SDKOptionType.pipScale.optionKey), !scale.isEmpty else {
                return nil
            }

            if let scaleValue = scale.cgfloatValue, scaleValue <= 0.0 || scaleValue > 1.0 {
                return nil
            }

            return scale.cgfloatValue
        }
    }
}
