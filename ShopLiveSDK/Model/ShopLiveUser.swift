//
//  ShopLiveUser.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/03/16.
//

import Foundation

@objc public class ShopLiveUser: NSObject {
    var name: String?
    var gender: Gender?
    var id: String?
    var age: Int?

    private var parameters: [String: String] = [:]

    @objc public override init() {
        name = nil
        gender = nil
        id = nil
        age = nil
    }

    @objc public init(id: String = "", name: String = "", gender: Gender = .unknown, age: Int = -1) {
        self.id = id.isEmpty ? nil : id
        self.name = name.isEmpty ? nil : name
        self.gender = gender == .unknown ? nil : gender
        self.age = age > 0 ? age : nil
    }

    public func add(_ params: [String: Any?]) {
        params.forEach { (key: String, value: Any?) in
            parameters[key] = "\(value ?? "null")"
        }
    }

    public func remove(key: String) {
        guard let index = parameters.firstIndex(where: { $0.key == key}) else {
            return
        }
        parameters.remove(at: index)
    }

    public func getParams() -> [String: String] {
        return parameters
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


