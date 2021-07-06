//
//  ShopLiveDemoKeyTools.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/06/09.
//

import Foundation

final class ShopLiveDemoKeyTools {

    private static let saveIdentifier: String = "ShopLiveDemoKeys"
    private static let currentKeyIdentifier: String = "currentKey"
    private static let phaseIdentifier: String = "phaseInfo"

    static let shared: ShopLiveDemoKeyTools = ShopLiveDemoKeyTools()

    private var keys: [ShopLiveKeySet] = []

    private var curKey: String = ""

    var phase: String {
        set(phase) {
            guard self.phase != phase else {
                return
            }
            UserDefaults.standard.setValue(phase, forKey: ShopLiveDemoKeyTools.phaseIdentifier)
        }

        get {
            let phaseData: String = (UserDefaults.standard.string(forKey: ShopLiveDemoKeyTools.phaseIdentifier) ?? "")
            return phaseData.isEmpty ? "REAL" : phaseData
        }
    }

    private init() {
        loadData()
    }

    private func saveData() {
        UserDefaults.standard.set(archiveData(keysets: keys), forKey: ShopLiveDemoKeyTools.saveIdentifier)
        UserDefaults.standard.synchronize()
    }

    private func loadData() {
        guard let loadedKeys = unArchiveData() else { return }
        keys.removeAll()
        keys = loadedKeys
        loadCurrentKey()
    }

    private func loadCurrentKey() {
        curKey = UserDefaults.standard.string(forKey: ShopLiveDemoKeyTools.currentKeyIdentifier) ?? ""

    }

    func clearKey() {
        keys.removeAll()
    }

    func saveCurrentKey(alias: String) {
        curKey = alias
        UserDefaults.standard.setValue(curKey, forKey: ShopLiveDemoKeyTools.currentKeyIdentifier)
    }

    func currentKey() -> ShopLiveKeySet? {
        return load(alias: curKey)
    }

    private func remove(alias: String) {
        self.keys.removeAll(where: {$0.alias == alias})
    }

    private func archiveData(keysets : [ShopLiveKeySet]) -> Data {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: keysets, requiringSecureCoding: false)

            return data
        } catch {
            fatalError("Can't encode data: \(error)")
        }

    }

    private func unArchiveData() -> [ShopLiveKeySet]? {
        guard
            let unarchivedObject = UserDefaults.standard.data(forKey: ShopLiveDemoKeyTools.saveIdentifier)
        else {
            return nil
        }
        do {
            guard let keysetArray = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(unarchivedObject) as? [ShopLiveKeySet] else {
                fatalError("unArchiveData - Can't get Keysets")
            }
            return keysetArray
        } catch {
            fatalError("unArchiveData - Can't encode data: \(error)")
        }
    }

    func save(key: ShopLiveKeySet) {
        loadData()
        remove(alias: key.alias)
        keys.append(key)
        saveData()
    }

    func delete(alias: String) {
        remove(alias: alias)
        saveData()
        if self.keys.isEmpty {
            saveCurrentKey(alias: "")
        }
    }

    func load(alias: String) -> ShopLiveKeySet? {
        return self.keys.filter({$0.alias == alias}).first
    }


    func alias() -> [String] {
        return self.keys.map { keyset in
            keyset.alias
        }
    }

}
