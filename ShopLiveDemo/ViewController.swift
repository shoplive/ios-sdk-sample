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
    @IBOutlet weak var swShare: UISwitch!
    @IBOutlet weak var swLog: UISwitch!

    var safari: SFSafariViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ShopLive.delegate = self

        #if DEBUG
        ShopLiveDemoKeyTools.shared.clearKey()
        ShopLiveDemoKeyTools.shared.save(key: .init(alias: "Dev Connect Test", campaignKey: "5545ee5f3d59", accessKey: "rYoegblp6Wbm65PBbZ5q"))
        ShopLiveDemoKeyTools.shared.save(key: .init(alias: "Dev Only", campaignKey: "c5496db11cd2", accessKey: "7xxPlb8yOhZnchquMQHO"))
        ShopLiveDemoKeyTools.shared.save(key: .init(alias: "Dev Replay Only", campaignKey: "e7e712b8728d", accessKey: "7xxPlb8yOhZnchquMQHO"))
        ShopLiveDemoKeyTools.shared.save(key: .init(alias: "DHT", campaignKey: "0dc055e4997e", accessKey: "DSUjM1uk7uw4bRiuRcQ1"))
        ShopLiveDemoKeyTools.shared.save(key: .init(alias: "NickName", campaignKey: "614d5e3d4fd4", accessKey: "9M2FwM5BmJf9RVeesKeg"))
        ShopLiveDemoKeyTools.shared.save(key: .init(alias: "TestBR", campaignKey: "120b6234673e", accessKey: "a1AW6QRCXeoZ9MEWRdDQ"))
        ShopLiveDemoKeyTools.shared.save(key: .init(alias: "TestBR AA", campaignKey: "be23b8478d0d", accessKey: "a1AW6QRCXeoZ9MEWRdDQ"))
        ShopLiveDemoKeyTools.shared.save(key: .init(alias: "HS", campaignKey: "d5c6ccfe6b39", accessKey: "uv9CGthPzlvsInZerCw0"))
//        ShopLiveDemoKeyTools.shared.saveCurrentKey(alias: "NickName")
        ShopLiveDemoKeyTools.shared.save(key: .init(alias: "REPLAY TEST", campaignKey: "cd3b7fdc6843", accessKey: "a1AW6QRCXeoZ9MEWRdDQ"))

        ShopLiveDemoKeyTools.shared.save(key: .init(alias: "ZZ", campaignKey: "40723305fc5a", accessKey: "a1AW6QRCXeoZ9MEWRdDQ"))
        ShopLiveDemoKeyTools.shared.save(key: .init(alias: "ZZ for Preview Test", campaignKey: "f944566a4f20", accessKey: "a1AW6QRCXeoZ9MEWRdDQ"))
        ShopLiveDemoKeyTools.shared.save(key: .init(alias: "ConfirmTest", campaignKey: "c5496db11cd2", accessKey: "7xxPlb8yOhZnchquMQHO"))
        ShopLiveDemoKeyTools.shared.save(key: .init(alias: "314", campaignKey: "a581c87960c2", accessKey: "a1AW6QRCXeoZ9MEWRdDQ"))
        ShopLiveDemoKeyTools.shared.save(key: .init(alias: "310", campaignKey: "f944566a4f20", accessKey: "a1AW6QRCXeoZ9MEWRdDQ"))
        ShopLiveDemoKeyTools.shared.save(key: .init(alias: "6044", campaignKey: "d5c6ccfe6b39", accessKey: "uv9CGthPzlvsInZerCw0"))


        ShopLiveDemoKeyTools.shared.saveCurrentKey(alias: "ZZ")
        #endif
        
        hideKeyboard()
        loadKeyData()
    }

    struct BlogPost: Decodable {
        enum Category: String, Decodable {
            case swift, combine, debugging, xcode
        }

        let title: String
        let url: URL
        let category: Category
        let views: Int
    }

    @IBAction private func switchAction(swItem: UISwitch) {
        switch swItem {
        case swSignIn:
            signInViews.isHidden = !swItem.isOn
            break
        case swPipSetting:
            pipViews.isHidden = !swItem.isOn
            break
        case swShare:
            setupShare()
        case swLog:
            ShopLiveViewLogger.shared.setVisible(show: swItem.isOn)
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

    private func setupShare() {
        if self.swShare.isOn {
            ShopLive.setShareScheme("https://www.shoplive.cloud", custom: nil)
        } else {
            ShopLive.setShareScheme("https://www.shoplive.cloud", custom: {
                let alert = UIAlertController.init(title: "커스텀 공유하기 사용", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                }))
                ShopLive.viewController?.present(alert, animated: true, completion: nil)
            })
        }
    }

    @IBAction func didTouchPreviewButton(_ sender: Any) {
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
            ShopLive.configure(with: key.accessKey, phase: phase)
            ShopLive.preview(with: key.campaignKey) {
                ShopLive.play(with: key.campaignKey)
                ShopLiveViewLogger.shared.addLog(log: "preview finish")
            }
        }
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
            setupShare()
            ShopLive.setKeepPlayVideoOnHeadphoneUnplugged(swKeepPlayUnplugged.isOn)

            ShopLive.configure(with: key.accessKey, phase: phase)
            /*
            ShopLive.hookNavigation { url in
                ShopLiveDemoLogger.shared.addLog(log: "hookNavigation \(url)")
                if #available(iOS 13, *) {
                    if let browser = self.safari {
                        browser.dismiss(animated: false, completion: nil)
                    }
                    self.safari = .init(url: url)

                    guard let browser = self.safari else { return }
                    self.present(browser, animated: true)
                } else {
                    // TODO: Single UIWindow 에서 PIP 처리 적용 필요
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
             */
            ShopLive.setKeepAspectOnTabletPortrait(true)
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
    func handleChangeCampaignStatus(status: String) {
        print("handleChangeCampaignStatus \(status)")
        ShopLiveViewLogger.shared.addLog(log: "handleChangeCampaignStatus \(status)")
    }

    func handleError(code: String, message: String) {
        ShopLiveViewLogger.shared.addLog(log: "handleError \(code)  \(message)")
        print("handleError")
    }

    func handleCampaignInfo(campaignInfo: [String : Any]) {
        ShopLiveViewLogger.shared.addLog(log: "handleCampaignInfo \(campaignInfo)")
        print("handleCampaignInfo")
    }

    func handleCustomAction(with id: String, type: String, payload: Any?, completion: @escaping () -> Void) {
        print("handleCustomAction \(id) \(type) \(payload.debugDescription)")
    }

    func handleCommand(_ command: String, with payload: Any?) {
        ShopLiveViewLogger.shared.addLog(log: "handleCommand \(command)")
        print("handleCommand: \(command)  payload: \(payload)")
    }

    func handleNavigation(with url: URL) {
        ShopLiveViewLogger.shared.addLog(log: "handleNavigation \(url)")

        if #available(iOS 13, *) {
            if let browser = self.safari {
                browser.dismiss(animated: false, completion: nil)
            }
            safari = .init(url: url)

            guard let browser = self.safari else { return }
            self.present(browser, animated: true)
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
