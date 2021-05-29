//
//  ViewController.swift
//  SwiftDemo
//
//  Created by ShopLive on 2021/05/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }

    @IBAction func didTouchPlayButton(_ sender: Any) {
        ShopLive.play(with: "55fb5331d9f5", self)
    }

    @IBAction func didTouchSignInButton(_ sender: Any) {
        NSLog("start signin")
        DispatchQueue.main.async {
            let userId = "customerId"
            let userName = "customer"
            let userAge = 30;
            let userGender = ShopLiveUser.Gender.male

            NSLog("complete signin")
            NSLog("user id: %@", userId)
            NSLog("user name: %@", userName)
            NSLog("user age: %ld", userAge)
            NSLog("user gender: %ld", userGender.rawValue)

            let user = ShopLiveUser(id: userId, name: userName, gender: userGender, age: userAge)
            ShopLive.user = user
            ShopLive.play(with: "55fb5331d9f5")
        }
    }

    @IBAction func didTouchCustomSizePipPlayButton(_ sender: Any) {
        ShopLive.pipScale = 0.2
        ShopLive.play(with: "55fb5331d9f5")
    }

    @IBAction func didTouchCustomPositionPipPlayButton(_ sender: Any) {
        ShopLive.pipPosition = .topLeft
        ShopLive.play(with: "55fb5331d9f5")
    }
    
}

