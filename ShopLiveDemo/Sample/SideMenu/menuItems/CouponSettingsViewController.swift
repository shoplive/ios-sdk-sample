//
//  CouponSettingsViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit

class CouponSettingsViewController: SideMenuItemViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = SideMenuTypes.coupon.stringKey.localized()
    }

}
