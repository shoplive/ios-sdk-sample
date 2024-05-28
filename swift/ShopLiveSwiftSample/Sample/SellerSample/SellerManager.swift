//
//  SellerManager.swift
//  ShopLivePlayerDemo
//
//  Created by sangmin han on 4/19/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopLiveSDK


class SellerManager {
    static let shared = SellerManager()
    
    
    
    func parseCommand(command : String, payload : [String : Any]?) {
        guard let payload = payload else { return }
        switch command {
        case "ON_RECEIVED_SELLER_CONFIG":
            self.onReceivedSellerConfig(payload: payload)
        case "ON_CLICK_VIEW_SELLER_STORE":
            self.onClickViewSellerStore(payload: payload)
        case "ON_CLICK_SELLER_SUBSCRIPTION":
            self.onClickSellerSubscription(payload: payload)
        default:
            break
        }
    }
    
    
    private func onReceivedSellerConfig(payload : [String : Any]) {
        var temp = payload
        temp["saved"] = true
        ShopLive.sendCommandMessage(command: "SET_SELLER_SAVED_STATE", payload: temp)
    }
    
    private func onClickViewSellerStore(payload : [String : Any]) {
        let sellerStoreData = SellerStoreData(dict: payload)
        if let urlString = sellerStoreData.seller?.storeUrl, let url = URL(string: urlString)  {
            UIApplication.shared.canOpenURL(url)
        }
    }
    
    private func onClickSellerSubscription(payload : [String : Any]) {
        let sellerSubsciptionData = SellerSubscriptionData(dict: payload)
        let sellerSavedData : [String : Any] = ["saved" : !(sellerSubsciptionData.saved ?? true)]
        
        ShopLive.sendCommandMessage(command: "SET_SELLER_SAVED_STATE", payload: sellerSavedData)
    }
}
