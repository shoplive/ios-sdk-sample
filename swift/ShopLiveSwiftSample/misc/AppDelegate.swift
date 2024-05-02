//
//  AppDelegate.swift
//  SwiftDemo
//
//  Created by ShopLive on 2021/05/23.
//

import UIKit

@_exported import ShopLiveSDK
@_exported import SnapKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        UserDefaults.standard.register(defaults: [SDKOptionType.pipEnableSwipeOut.optionKey: false,
                                                  SDKOptionType.mixAudio.optionKey : true,
                                                  SDKOptionType.useCloseButton.optionKey : true,
                                                  SDKOptionType.statusBarVisibility.optionKey : true,
                                                  SDKOptionType.enablePreviewSound.optionKey : false,
                                                  SDKOptionType.enablePip.optionKey : true,
                                                  SDKOptionType.enableOSPip.optionKey : true])
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        ShopLive.onTerminated()
    }
}
