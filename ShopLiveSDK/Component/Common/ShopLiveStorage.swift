//
//  ShopLiveStorage.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/09/07.
//

import Foundation

internal final class ShopLiveStorage {

    private static let def = SLKeychainWrapper.standard
    static func set(key: String, value: String?) {
        guard let value = value else { return }
        def.set(value, forKey: key)
    }

    static func get(key: String) -> String? {
        return def.string(forKey: key)
    }

    static func remove(key: String) {
        _ = def.removeObject(forKey: key)
    }

    static func removeAll() {
        for key in def.allKeys() {
            def.removeObject(forKey: key)
        }
        def.removeAllKeys()
    }

    static var allItems: [String: String] {
        var data: [String: String] = [:]
        for key in def.allKeys() {
            data[key] = def.string(forKey: key)
        }
        return data
    }

}
