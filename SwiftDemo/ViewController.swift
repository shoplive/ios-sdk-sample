//
//  ViewController.swift
//  SwiftDemo
//
//  Created by ShopLive on 2021/05/23.
//

import UIKit
import SafariServices

class ViewController: UIViewController {

    @IBOutlet weak var menuItemViews: UIStackView!

    @IBOutlet weak var keyAlias: UITextField!
    @IBOutlet weak var keyCampaign: UITextField!
    @IBOutlet weak var keyAccess: UITextField!

    @IBOutlet weak var userId: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var gender: UITextField!
    var userGender: ShopLiveUser.Gender = .unknown

    @IBOutlet weak var signInViews: UIStackView!
    @IBOutlet weak var pipViews: UIStackView!

    @IBOutlet weak var pipCUstomSize: UITextField!
    @IBOutlet weak var pipCustomPosition: UITextField!
    var pipPosition: ShopLive.PipPosition = .default

    @IBOutlet weak var swSignIn: UISwitch!
    @IBOutlet weak var swPipSetting: UISwitch!

    @IBOutlet weak var swPipCustomSize: UISwitch!
    @IBOutlet weak var swPipCustomPosition: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let key = ShopLiveDemoKeyTools.shared.currentKey() {
            ShopLive.configure(with: key.campaignKey)
        }

        ShopLive.delegate = self
        setupViews()
        hideKeyboard()
        loadKeyData()
    }

    private func setupViews() {

    }

    @IBAction private func switchAction(swItem: UISwitch) {
        switch swItem {
        case swSignIn:
            signInViews.isHidden = !swItem.isOn
            break
        case swPipSetting:
            pipViews.isHidden = !swItem.isOn
            break
        default:
            break
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.menuItemViews.layoutIfNeeded()
        })
    }

    @objc
    private func didTouchGenderSetting() {
//        print("didTouchGenderSetting")
    }

    func loadKeyData() {
        if let currentKey = ShopLiveDemoKeyTools.shared.currentKey() {
            keyAlias.text = currentKey.alias
            keyCampaign.text = currentKey.campaignKey
            keyAccess.text = currentKey.accessKey

            ShopLive.configure(with: currentKey.campaignKey)
        } else {
            keyAlias.text = ""
            keyCampaign.text = ""
            keyAccess.text = ""
        }
    }

    @IBAction func didTouchPlayButton(_ sender: Any) {
        if let key = ShopLiveDemoKeyTools.shared.currentKey() {

            // sign in
            if swSignIn.isOn,
               let userId = userId.text,
               let userName = userName.text,
               let tfAge = age.text,
               let userAge = Int(tfAge),
               userId.isEmpty == false && userName.isEmpty == false && tfAge.isEmpty == false {
                let user = ShopLiveUser(id: userId, name: userName, gender: userGender, age: userAge)
                ShopLive.user = user
            }

            // pip
            if swPipSetting.isOn {
                if swPipCustomSize.isOn {
                    if let slPipCS = pipCUstomSize.text,
                       slPipCS.isEmpty == false {
                        ShopLive.pipScale = CGFloat(NSString(string: slPipCS).floatValue)
                    }
                }

                if swPipCustomPosition.isOn {
                    ShopLive.pipPosition = pipPosition
                }
            }

            ShopLive.play(with: key.accessKey)
        }
    }
/*
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
            ShopLive.play(with: "c5496db11cd2")
        }
    }
 */
    @IBAction func didTouchKeySetEditorButton(_ sender: Any) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "KeySetRegisterController") as? KeySetRegisterController else { return }
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
/*
    @IBAction func didTouchCustomSizePipPlayButton(_ sender: Any) {
        guard let url = URL(string: "https://m.naver.com") else {return}
        let safari = SFSafariViewController(url: url)
        safari.delegate = self
        self.present(safari, animated: true)
//        ShopLive.pipScale = 0.2
//        ShopLive.play(with: "c5496db11cd2")
    }

    @IBAction func didTouchCustomPositionPipPlayButton(_ sender: Any) {
        ShopLive.pipPosition = .topLeft
        ShopLive.play(with: "c5496db11cd2")
    }
*/
    private var selectKeyHandler: ((UIAlertAction) -> Void)? = { action in
        guard let alias = action.title, let keyset = ShopLiveDemoKeyTools.shared.load(alias: alias) else { return }
//        print("[key info]\nalias: \(keyset.alias)\ncampaignKey: \(keyset.campaignKey) \naccessKey: \(keyset.accessKey)")
    }

    private func selectGender() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: "male", style: .default, handler: { _IOFBF in
            self.userGender = .male
            self.gender.text = "male"
        }))
        alert.addAction(.init(title: "female", style: .default, handler: { _IOFBF in
            self.userGender = .female
            self.gender.text = "female"
        }))
        alert.addAction(.init(title: "neutral", style: .default, handler: { _IOFBF in
            self.userGender = .neutral
            self.gender.text = "neutral"
        }))
        alert.addAction(.init(title: "cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func selectPipCustomPosition() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: "topLeft", style: .default, handler: { _IOFBF in
            self.pipPosition = .topLeft
            self.pipCustomPosition.text = "topLeft"
        }))
        alert.addAction(.init(title: "topRight", style: .default, handler: { _IOFBF in
            self.pipPosition = .topRight
            self.pipCustomPosition.text = "topRight"
        }))
        alert.addAction(.init(title: "bottomLeft", style: .default, handler: { _IOFBF in
            self.pipPosition = .bottomLeft
            self.pipCustomPosition.text = "bottomLeft"
        }))
        alert.addAction(.init(title: "bottomRight", style: .default, handler: { _IOFBF in
            self.pipPosition = .bottomRight
            self.pipCustomPosition.text = "bottomRight"
        }))
        alert.addAction(.init(title: "default", style: .default, handler: { _IOFBF in
            self.pipPosition = .default
            self.pipCustomPosition.text = "default"
        }))
        alert.addAction(.init(title: "cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: KeySetRegisterDelegate {
    func upateKeyInfo(key: ShopLiveKeySet) {
        keyAlias.text = key.alias
        keyCampaign.text = key.campaignKey
        keyAccess.text = key.accessKey

        ShopLive.configure(with: key.campaignKey)
    }
}

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)
        if let vc = self as? KeySetRegisterController {
            tap.delegate = vc
        }
    }
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        var editing = false
        switch textField {
        case gender:
            selectGender()
            break
        case pipCustomPosition:
            selectPipCustomPosition()
            break
        default:
            editing = true
            break
        }

        return editing
    }
}

extension ViewController: SFSafariViewControllerDelegate {

}

extension ViewController: ShopLiveSDKDelegate {
    func handleCommand(_ command: String, with payload: Any?) {

    }

    func handleNavigation(with url: URL) {
        if #available(iOS 13, *) {
            ShopLive.startPictureInPicture()
            let safari = SFSafariViewController(url: url)
            self.present(safari, animated: true)
        } else {
//            ShopLive.startPictureInPicture()
            let safari = SFSafariViewController(url: url)
            safari.delegate = self
            self.present(safari, animated: true)
        }

    }

    func handleDownloadCoupon(with couponId: String, completion: @escaping () -> Void) {
        if #available(iOS 13, *) {
            NSLog("handle download coupon: %@", couponId)
            DispatchQueue.main.async {
                NSLog("complete download coupon: %@", couponId)
                completion()
            }
        } else {
            NSLog("handle download coupon: %@", couponId)
            DispatchQueue.main.async {
                NSLog("complete download coupon: %@", couponId)
                completion()
            }
        }

    }


}
