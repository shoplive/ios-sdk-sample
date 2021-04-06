//
//  ShopLiveUser.swift
//  ShopLiveSDK
//
//  Created by purpleworks on 2021/03/16.
//

import Foundation

@objc public class ShopLiveUser: NSObject, Codable {
    let name: String?
    let gender: Gender?
    let id: String?
    let age: Int?
    
    @objc public init(id: String = "", name: String = "", gender: Gender = .unknown, age: Int = -1) {
        self.id = id.isEmpty ? nil : id
        self.name = name.isEmpty ? nil : name
        self.gender = gender == .unknown ? nil : gender
        self.age = age > 0 ? age : nil
    }
}

extension ShopLiveUser {
    @objc public enum Gender: Int, Codable, CaseIterable {
        case female = 1
        case male = 2
        case neutral = 3
        case unknown = 0
        
        public var description: String {
            switch self {
            case .female:
                return "f"
            case .male:
                return "m"
            case .neutral:
                return "n"
            case .unknown:
                return "unknown"
            }
        }
    }
}


