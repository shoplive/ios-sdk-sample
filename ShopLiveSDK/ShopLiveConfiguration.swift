//
//  ShopLiveConfiguration.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/07/11.
//

import Foundation

protocol SLNotificationName {
    var name: Notification.Name { get }
}

extension RawRepresentable where RawValue == String, Self: SLNotificationName {
    var name: Notification.Name {
        get {
            return Notification.Name(self.rawValue)
        }
    }
}

internal final class ShopLiveConfiguration {

    enum SLNotifications: String, SLNotificationName {
        case soundPolicyUpdate
    }

    enum SLPlayControl {
        case none
        case stop
        case pause
        case play
        case resume
    }

    class SoundPolicy {
        var keepPlayVideoOnHeadphoneUnplugged: Bool = false {
            willSet {
                guard keepPlayVideoOnHeadphoneUnplugged != newValue else { return }
                updateNotification()
            }
        }

        var autoResumeVideoOnCallEnded: Bool = false {
            willSet {
                guard autoResumeVideoOnCallEnded != newValue else { return }
                updateNotification()
            }
        }

        private func updateNotification() {
            NotificationCenter.default.post(name: SLNotifications.soundPolicyUpdate.name, object: nil)
        }
    }

    static var soundPolicy: SoundPolicy = .init()

    fileprivate init() {}
}
