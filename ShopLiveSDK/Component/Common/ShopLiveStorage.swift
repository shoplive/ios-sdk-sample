//
//  ShopLiveStorage.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/09/07.
//

import Foundation

enum StorageKey: String {
    case guestUid
    case resolution
}

internal final class ShopLiveStorage {

    private static let def = UserDefaults.standard
    static func set<T>(key: StorageKey, value: T?) {
        guard let value = value else { return }
        def.setValue(value, forKey: key.rawValue)
    }

    static func get<T>(key: StorageKey) -> T? {
        return def.value(forKey: key.rawValue) as? T
    }

    static func remove(keys: [StorageKey]) {
        for key in keys {
            remove(key: key)
        }
    }

    static func remove(key: StorageKey) {
        def.removeObject(forKey: key.rawValue)
    }

}
