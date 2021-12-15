//
//  SDKConfiguration.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/14.
//

import Foundation



final class SDKConfiguration {

    static var currentKey: ShopLiveKeySet? {
        return ShopLiveDemoKeyTools.shared.currentKey()
    }



}
