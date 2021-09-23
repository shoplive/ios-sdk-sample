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

extension Array {
    subscript (safe index: Int) -> Element? {
        // iOS 9 or later
        return indices ~= index ? self[index] : nil
        // iOS 8 or earlier
        // return startIndex <= index && index < endIndex ? self[index] : nil
        // return 0 <= index && index < self.count ? self[index] : nil
    }
}

extension UIDevice {
    static var isIpad: Bool {
        self.current.userInterfaceIdiom == .pad
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))

        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.setBackgroundImage(backgroundImage, for: state)
    }
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { view in
            self.addSubview(view)
        }
    }
}
