//
//  UserInfoViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit

class UserInfoViewController: SideMenuItemViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = SideMenuTypes.userinfo.stringKey.localized()
    }

}
