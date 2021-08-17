//
//  Extensions.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/07/06.
//

import Foundation
import UIKit

extension UIViewController
{
    @objc public func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

extension NSObject {
  func safeRemoveObserver(_ observer: NSObject, forKeyPath keyPath: String) {
    switch self.observationInfo {
    case .some:
      self.removeObserver(observer, forKeyPath: keyPath)
    default:
        ShopLiveLogger.debugLog("observer does not exist")
    }
  }
}
