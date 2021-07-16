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
