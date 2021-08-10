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

    @IBOutlet weak var keyPhase: UITextField!
    @IBOutlet weak var keyAlias: UITextField!
    @IBOutlet weak var keyCampaign: UITextField!
    @IBOutlet weak var keyAccess: UITextField!
    var phase: ShopLive.Phase = .REAL

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
    @IBOutlet weak var swKeepPlayUnplugged: UISwitch!
    @IBOutlet weak var swAutoResume: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ShopLive.delegate = self

        #if DEBUG
        ShopLiveDemoKeyTools.shared.clearKey()
        ShopLiveDemoKeyTools.shared.save(key: .init(alias: "Dev Connect Test", campaignKey: "5545ee5f3d59", accessKey: "rYoegblp6Wbm65PBbZ5q"))
        ShopLiveDemoKeyTools.shared.save(key: .init(alias: "Dev Only", campaignKey: "c5496db11cd2", accessKey: "7xxPlb8yOhZnchquMQHO"))
        ShopLiveDemoKeyTools.shared.save(key: .init(alias: "Dev Replay Only", campaignKey: "e7e712b8728d", accessKey: "7xxPlb8yOhZnchquMQHO"))
        ShopLiveDemoKeyTools.shared.saveCurrentKey(alias: "Dev Only")
        #endif

        hideKeyboard()
        loadKeyData()
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

    func loadKeyData() {
        if let currentKey = ShopLiveDemoKeyTools.shared.currentKey() {
            keyAlias.text = currentKey.alias
            keyCampaign.text = currentKey.campaignKey
            keyAccess.text = currentKey.accessKey
        } else {
            keyAlias.text = ""
            keyCampaign.text = ""
            keyAccess.text = ""
        }

        self.phase = ShopLive.Phase.init(name: ShopLiveDemoKeyTools.shared.phase) ?? .REAL
        keyPhase.text = phase.name
    }

    @IBAction func didTouchPlayButton(_ sender: Any) {
        dismissKeyboard()
        if let key = ShopLiveDemoKeyTools.shared.currentKey() {

            // sign in
            if self.swSignIn.isOn,
               let userId = self.userId.text,
               let userName = self.userName.text,
               let tfAge = self.age.text,
               let userAge = Int(tfAge),
               userId.isEmpty == false && userName.isEmpty == false && tfAge.isEmpty == false {
                let user = ShopLiveUser(id: userId, name: userName, gender: self.userGender, age: userAge)
                ShopLive.user = user
            } else {
                self.userGender = .unknown
                ShopLive.user = nil
            }

            // pip
            if self.swPipSetting.isOn {
                if let slPipCS = self.pipCUstomSize.text,
                   slPipCS.isEmpty == false {
                    ShopLive.pipScale = CGFloat(NSString(string: slPipCS).floatValue)
                } else {
                    ShopLive.pipScale = 2/5
                }

                ShopLive.pipPosition = self.pipPosition
            }

            ShopLive.setKeepPlayVideoOnHeadphoneUnplugged(swKeepPlayUnplugged.isOn)
            ShopLive.setAutoResumeVideoOnCallEnded(swAutoResume.isOn)

            /*
            ShopLive.setShareScheme("https://www.shoplive.cloud", custom: {
                ShopLiveLogger.debugLog("share custom action")
            })
             */
            ShopLive.setShareScheme("https://www.shoplive.cloud", custom: nil)

            ShopLive.configure(with: key.accessKey, phase: phase)
            ShopLive.play(with: key.campaignKey)
        }
    }

    func didTouchKeySetEditorButton() {
        dismissKeyboard()
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "KeySetRegisterController") as? KeySetRegisterController else { return }
        vc.delegate = self
        self.present(vc, animated: true)
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
        if UIDevice.current.userInterfaceIdiom == .pad {
            //디바이스 타입이 iPad일때
            if let popoverController = alert.popoverPresentationController {
                // ActionSheet가 표현되는 위치를 저장해줍니다.
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            self.present(alert, animated: true, completion: nil)
        }
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
        if UIDevice.current.userInterfaceIdiom == .pad {
            //디바이스 타입이 iPad일때
            if let popoverController = alert.popoverPresentationController {
                // ActionSheet가 표현되는 위치를 저장해줍니다.
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func selectPhase() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: "DEV", style: .default, handler: { _IOFBF in
            self.phase = .DEV
            ShopLiveDemoKeyTools.shared.phase = self.phase.name
            self.keyPhase.text = "DEV"
        }))
        alert.addAction(.init(title: "STAGE", style: .default, handler: { _IOFBF in
            self.phase = .STAGE
            ShopLiveDemoKeyTools.shared.phase = self.phase.name
            self.keyPhase.text = "STAGE"
        }))
        alert.addAction(.init(title: "REAL", style: .default, handler: { _IOFBF in
            self.phase = .REAL
            ShopLiveDemoKeyTools.shared.phase = self.phase.name
            self.keyPhase.text = "REAL"
        }))
        alert.addAction(.init(title: "cancel", style: .cancel, handler: nil))
        if UIDevice.current.userInterfaceIdiom == .pad {
            //디바이스 타입이 iPad일때
            if let popoverController = alert.popoverPresentationController {
                // ActionSheet가 표현되는 위치를 저장해줍니다.
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController: KeySetRegisterDelegate {
    func upateKeyInfo(key: ShopLiveKeySet) {
        keyAlias.text = key.alias
        keyCampaign.text = key.campaignKey
        keyAccess.text = key.accessKey

        ShopLive.configure(with: key.accessKey)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        var editing = false
        switch textField {
        case gender:
            dismissKeyboard()
            selectGender()
            break
        case pipCustomPosition:
            dismissKeyboard()
            selectPipCustomPosition()
            break
        case keyPhase:
            dismissKeyboard()
            selectPhase()
            break
        case keyAlias, keyAccess, keyCampaign:
            didTouchKeySetEditorButton()
        default:
            editing = true
            break
        }

        return editing
    }
}

extension ViewController: SFSafariViewControllerDelegate {

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
}

extension ViewController: ShopLiveSDKDelegate {
    func handleCustomAction(with id: String, type: String, payload: Any?, completion: @escaping () -> Void) {
        print("handleCustomAction \(id) \(type) \(payload.debugDescription)")
    }

    func handleCommand(_ command: String, with payload: Any?) {

    }

    func handleNavigation(with url: URL) {
        if #available(iOS 13, *) {
            ShopLive.startPictureInPicture()
            let safari = SFSafariViewController(url: url)
            self.present(safari, animated: true)
        } else {
            // TODO: Single UIWindow 에서 PIP 처리 적용 필요
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
