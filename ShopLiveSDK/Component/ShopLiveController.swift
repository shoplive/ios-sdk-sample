//
//  ShopLiveController.swift
//  ShopLivePlayer
//
//  Created by ShopLive on 2021/08/01.
//

import Foundation

enum ShopLivePlayerObserveValue: String {
    case videoUrl
    case timeControlStatus = "player.timeControlStatus"
    case isPlayable = "urlAsset.isPlayable"
    case playerItemStatus = "playerItem.status"
}

protocol ShopLivePlayerDelegate {
    var identifier: String { get }
    func isEqualTo(_ other: ShopLivePlayerDelegate) -> Bool

    func updatedValue(key: ShopLivePlayerObserveValue)
}

extension ShopLivePlayerDelegate where Self: Equatable {
    func isEqualTo(_ other: ShopLivePlayerDelegate) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }
}

final class ShopLiveController: NSObject {
    static let shared = ShopLiveController()

    private override init() {
        super.init()
        self.addPlayerObserver()
    }

    deinit {
        self.removePlayerObserver()
    }

    private var playerDelegates: [ShopLivePlayerDelegate] = []
    @objc dynamic var playItem: ShopLivePlayItem = .init()
    @objc dynamic var playerItem: ShopLivePlayerItem = .init()

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, let key = ShopLivePlayerObserveValue(rawValue: keyPath), let _ = change?[.newKey] else { return }
        switch key {
        case .videoUrl, .timeControlStatus, .isPlayable, .playerItemStatus:
            postPlayerObservers(key: key)
            break
//        default:
//            break
        }
    }

    func addPlayerDelegate(delegate: ShopLivePlayerDelegate) {
            guard self.playerDelegates.filter({ $0.isEqualTo(delegate) }).isEmpty else { return }
            playerDelegates.append(delegate)
        }

    func removePlayerDelegate(delegate: ShopLivePlayerDelegate) {
        guard let index = self.playerDelegates.firstIndex(where: {$0.isEqualTo(delegate)}) else { return }
        self.playerDelegates.remove(at: index)
    }

}

// MARK: ShopLive Player Section
extension ShopLiveController {
    func addPlayerObserver() { 
        playItem.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.videoUrl.rawValue, options: .new, context: nil)
        playItem.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.isPlayable.rawValue, options: .new, context: nil)
        playItem.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.playerItemStatus.rawValue, options: .new, context: nil)
        playerItem.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.timeControlStatus.rawValue, options: .new, context: nil)
    }

    func removePlayerObserver() {
        playItem.removeObserver(self, forKeyPath: ShopLivePlayerObserveValue.videoUrl.rawValue)
        playItem.removeObserver(self, forKeyPath: ShopLivePlayerObserveValue.isPlayable.rawValue)
        playItem.removeObserver(self, forKeyPath: ShopLivePlayerObserveValue.playerItemStatus.rawValue)
        playItem.removeObserver(self, forKeyPath: ShopLivePlayerObserveValue.timeControlStatus.rawValue)
    }

    func postPlayerObservers(key: ShopLivePlayerObserveValue) {
        print("key: \(key.rawValue)")
        for playerDelegate in playerDelegates {
            print("playerDelegate.identifier: \(playerDelegate.identifier) - key: \(key)")
            playerDelegate.updatedValue(key: key)
        }
    }
}
