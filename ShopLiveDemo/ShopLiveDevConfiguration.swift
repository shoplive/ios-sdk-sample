//
//  ShopLiveDevConfiguration.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/16.
//

import Foundation
import UIKit

final class ShopLiveDevConfiguration {

    static let shared: ShopLiveDevConfiguration = .init()

    var useWebLog: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "useWebLog")
            UserDefaults.standard.synchronize()
        }
        get {
            UserDefaults.standard.bool(forKey: "useWebLog")
        }
    }

    var phase: String {
        set {
            UserDefaults.standard.set(newValue, forKey: "playerPhase")
            UserDefaults.standard.synchronize()
        }
        get {
            UserDefaults.standard.string(forKey: "playerPhase") ?? ShopLive.Phase.REAL.name
        }
    }

    var phaseType: ShopLive.Phase {
        let phases: [String: ShopLive.Phase] = [
            ShopLive.Phase.DEV.name: ShopLive.Phase.DEV,
            ShopLive.Phase.STAGE.name: ShopLive.Phase.STAGE,
            ShopLive.Phase.REAL.name: ShopLive.Phase.REAL]


        return phases[phase] ?? .DEV


    }

}
