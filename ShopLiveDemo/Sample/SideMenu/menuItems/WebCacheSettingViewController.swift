//
//  WebCacheSettingViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit

class WebCacheSettingViewController: SideMenuItemViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = SideMenuTypes.removeCache.stringKey.localized()
    }

}
