//
//  AppDelegate.swift
//  SwiftDemo
//
//  Created by ShopLive on 2021/05/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

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


}

//extension AppDelegate: ShopLiveSDKDelegate {
//    func handleCommand(_ command: String, with payload: Any?) {
//
//    }
//
//    func handleNavigation(with url: URL) {
//        if #available(iOS 13, *) {
//
//        } else {
////            ShopLive.startPictureInPicture()
//            let safari = SFSafariViewController(url: url)
//            UIApplication.shared.keyWindow?.rootViewController?.present(safari, animated: true)
//        }
//
//    }
//
//    func handleDownloadCoupon(with couponId: String, completion: @escaping () -> Void) {
//        if #available(iOS 13, *) {
//
//        } else {
//            NSLog("handle download coupon: %@", couponId)
//            DispatchQueue.main.async {
//                NSLog("complete download coupon: %@", couponId)
//                completion()
//            }
//        }
//
//    }
//
//
//}
