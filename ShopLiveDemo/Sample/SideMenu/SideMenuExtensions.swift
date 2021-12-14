//
//  SideMenuExtensions.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import Foundation
import UIKit

extension UIButton {

    /// Default debounce delay for UIButton taps. Allows delay to be updated globally.
    static var debounceDelay: Double = 0.5

    /// Debounces button taps with the specified delay.
    func debounce(delay: Double = UIButton.debounceDelay) {
        isEnabled = false
        let deadline = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
            self?.isEnabled = true
        }
    }

}

extension String {
    func localized(from: String = "shoplive", comment: String = "") -> String {
        return Bundle.main.localizedString(forKey: self, value: nil, table: from)
    }

    func localized(with argument: CVarArg = [], from: String = "shoplive", comment: String = "") -> String {
        return String(format: self.localized(from: from, comment: comment), argument)
    }
}
