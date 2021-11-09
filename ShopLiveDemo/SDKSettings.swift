//
//  SDKSettings.swift
//  ShopLiveSwiftSample
//
//  Created by ShopLive on 2021/11/08.
//

import Foundation

final class SDKSettings {

    private static var ud: UserDefaults = UserDefaults.standard

    enum SettingKey: String {
        case downloadCouponSuccessMessage
        case downloadCouponSuccessStatus
        case downloadCouponSuccessAlertType
        case downloadCouponFailedMessage
        case downloadCouponFailedStatus
        case downloadCouponFailedAlertType

        var key: String {
            self.rawValue
        }
    }

    static var downloadCouponSuccessMessage: String {
        set {
            ud.set(newValue, forKey: SettingKey.downloadCouponSuccessMessage.key)
            ud.synchronize()
        }
        get {
            ud.string(forKey: SettingKey.downloadCouponSuccessMessage.key) ?? ""
        }
    }

    static var downloadCouponSuccessStatus: ResultStatus {
        set {
            ud.set(newValue.rawValue, forKey: SettingKey.downloadCouponSuccessStatus.key)
            ud.synchronize()
        }
        get {
            let rawValue = ud.integer(forKey: SettingKey.downloadCouponSuccessStatus.key)
            return ResultStatus(rawValue: rawValue) ?? .SHOW
        }
    }

    static var downloadCouponSuccessAlertType: ResultAlertType {
        set {
            ud.set(newValue.rawValue, forKey: SettingKey.downloadCouponSuccessAlertType.key)
            ud.synchronize()
        }
        get {
            let rawValue = ud.integer(forKey: SettingKey.downloadCouponSuccessAlertType.key)
            return ResultAlertType(rawValue: rawValue) ?? .ALERT
        }
    }

    static var downloadCouponFailedMessage: String {
        set {
            ud.set(newValue, forKey: SettingKey.downloadCouponFailedMessage.key)
            ud.synchronize()
        }
        get {
            ud.string(forKey: SettingKey.downloadCouponFailedMessage.key) ?? ""
        }
    }

    static var downloadCouponFailedStatus: ResultStatus {
        set {
            ud.set(newValue.rawValue, forKey: SettingKey.downloadCouponFailedStatus.key)
            ud.synchronize()
        }
        get {
            let rawValue = ud.integer(forKey: SettingKey.downloadCouponFailedStatus.key)
            return ResultStatus(rawValue: rawValue) ?? .SHOW
        }
    }

    static var downloadCouponFailedAlertType: ResultAlertType {
        set {
            ud.set(newValue.rawValue, forKey: SettingKey.downloadCouponFailedAlertType.key)
            ud.synchronize()
        }
        get {
            let rawValue = ud.integer(forKey: SettingKey.downloadCouponFailedAlertType.key)
            return ResultAlertType(rawValue: rawValue) ?? .ALERT
        }
    }

}
