//
//  OptionsViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit

class OptionsViewController: SideMenuItemViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = SideMenuTypes.options.stringKey.localized()
    }

}
