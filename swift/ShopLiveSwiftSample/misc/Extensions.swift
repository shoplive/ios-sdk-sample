//
//  Extensions.swift
//  ShopLiveSwiftSample
//
//  Created by ShopLive on 2021/11/08.
//

import Foundation
import UIKit

 extension UIImage {
     func toNSTextAttachment(_ width: CGFloat? = nil, _ height: CGFloat? = nil, _ yPos: CGFloat = -8) -> NSTextAttachment {
         let imageAttachment = NSTextAttachment()
         imageAttachment.bounds = CGRect(x: 0, y: yPos, width: width ?? self.size.width, height: height ?? self.size.height)
         imageAttachment.image = self
         return imageAttachment
     }

     func toNSTextAttachment(yPos: CGFloat = -8) -> NSTextAttachment {
         let imageAttachment = NSTextAttachment()
         imageAttachment.bounds = CGRect(x: 0, y: yPos, width:  self.size.width, height: self.size.height)
         imageAttachment.image = self
         return imageAttachment
     }
 }

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { view in
            self.addSubview(view)
        }
    }
}
