//
//  SDKOption.swift
//  ShopLiveSwiftSample
//
//  Created by ShopLive on 2021/12/17.
//

import Foundation

enum CouponResponseKey: String {
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

enum SDKOptionType: String, CaseIterable {
    case pipPosition
    case maxPipSize
    case fixedHeightPipSize
    case fixedWidthPipSize
    case pipPadding
    case pipFloatingOffset
    case pipEnableSwipeOut
    case pipCornerRadius
    case nextActionOnHandleNavigation
    case headphoneOption1
    case headphoneOption2
    case callOption
    case customShare
    case shareScheme
    case progressColor
    case customProgress
    case chatInputCustomFont
    case chatSendButtonCustomFont
    case mute
    case playWhenPreviewTapped
    case aspectOnTablet
    case keepWindowStateOnPlayExecuted
    case pipKeepWindowStyle
    case useCloseButton
    case mixAudio
    case statusBarVisibility
    case previewResolution
    case enablePreviewSound
    case enablePip
    case enableOSPip
    case resizeMode
    case isEnabledVolumeKey
    
    enum SettingType: Int {
        case showAlert
        case switchControl
        case dropdown
        case routeTo
    }

    var settingType: SettingType {
        switch self {
        case .shareScheme, .progressColor,.maxPipSize, .fixedHeightPipSize, .fixedWidthPipSize, .pipCornerRadius:
            return .showAlert
        case .pipPosition, .nextActionOnHandleNavigation,.resizeMode:
            return .dropdown
        case .pipFloatingOffset:
            return .routeTo
        default:
            return .switchControl
        }
    }

    var optionKey: String {
        self.rawValue
    }
}

struct SDKOptionItem {
    var name: String
    var optionDescription: String
    var optionType: SDKOptionType
}

struct SDKOption {
    var optionTitle: String
    var optionItems: [SDKOptionItem] = []
}
