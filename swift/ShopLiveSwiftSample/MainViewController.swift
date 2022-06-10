//
//  MainViewController.swift
//  ShopLiveSwiftSample
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit
import SideMenu
import SafariServices
import Toast

enum MenuItem: String, CaseIterable {
    case step1
    case step2
    case step3

    var menuTitle: String {
        switch self {
        case .step1:
            return "sample.menu.step1".localized()
        case .step2:
            return "sample.menu.step2".localized()
        case .step3:
            return "sample.menu.step3".localized()
        }
    }

    var emptyItemMessage: String {
        switch self {
        case .step1:
            return "sample.menu.msg.empty.campaign".localized()
        case .step2:
            return "sample.menu.msg.empty.user".localized()
        case .step3:
            return ""
        }
    }

    var identifier: String {
        return self.rawValue
    }
}

final class MainViewController: SampleBaseViewController {

    private var items: [MenuItem] = MenuItem.allCases

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self
        view.register(MenuCell.self, forCellReuseIdentifier: "MenuCell")
        view.backgroundColor = .white
        view.separatorStyle = .none
        return view
    }()

    private lazy var playButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.setBackgroundColor(.red, for: .normal)
        view.layer.cornerRadius = 6
        view.addTarget(self, action: #selector(play), for: .touchUpInside)
        view.setTitle("sample.button.play".localized(), for: .normal)
        return view
    }()

    private lazy var previewButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.setBackgroundColor(.red, for: .normal)
        view.layer.cornerRadius = 6
        view.addTarget(self, action: #selector(preview), for: .touchUpInside)
        view.setTitle("sample.button.preview".localized(), for: .normal)
        return view
    }()

    var safari: SFSafariViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white

        self.title = "sample.app.title".localized()

        ShopLive.delegate = self

        DemoConfiguration.shared.addConfigurationObserver(observer: self)

        setupViews()
    }

    func setupViews() {

        self.view.addSubviews(tableView, playButton, previewButton)
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalTo(playButton.snp.top).offset(15)
            $0.leading.trailing.equalToSuperview()
        }

        playButton.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.4)
            $0.height.equalTo(35)
            $0.trailing.equalTo(self.view.snp.centerX).offset(-10)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }

        previewButton.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.4)
            $0.height.equalTo(35)
            $0.leading.equalTo(self.view.snp.centerX).offset(10)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }

    func setupShopliveSettings() {
        let config = DemoConfiguration.shared

        switch config.authType {
        case "USER":
            if let userId = config.user.id, !userId.isEmpty {
                ShopLive.user = config.user
            }
            break
        case "TOKEN":
            ShopLive.authToken = config.jwtToken
            break
        case "GUEST":
            break
        default:
            break
        }

        // Keep play video on headphone unplugged setting
        ShopLive.setKeepPlayVideoOnHeadphoneUnplugged(config.useHeadPhoneOption1)

        // Auto resume video on call end setting
        ShopLive.setAutoResumeVideoOnCallEnded(config.useCallOption)

        // Custom Image Animation Indicator setting
        if config.useCustomProgress {
            var images: [UIImage] = []

            for i in 1...11 {
                images.append(.init(named: "loading\(i)")!)
            }

            ShopLive.setLoadingAnimation(images: images)
        }

        // Share URL/Scheme Setting
        if let scheme = config.shareScheme, !scheme.isEmpty {
            if config.useCustomShare {
                // Custom Share Setting
                ShopLive.setShareScheme(scheme, custom: {
                    let customShareVC = CustomShareViewController()
                    customShareVC.modalPresentationStyle = .overFullScreen
                    ShopLive.viewController?.present(customShareVC, animated: false, completion: nil)
                })
            } else {
                // Default iOS Share
                ShopLive.setShareScheme(scheme, custom: nil)
            }
        }
        
        // indicator color
        if let indicatorColor = DemoConfiguration.shared.progressColor {
            ShopLive.indicatorColor = UIColor(indicatorColor)
        }

        let inputDefaultFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        let sendButtonDefaultFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        if let customFont = config.customFont {
            ShopLive.setChatViewFont(inputBoxFont: config.useChatInputCustomFont ? customFont : inputDefaultFont, sendButtonFont: config.useChatSendButtonCustomFont ? customFont : sendButtonDefaultFont)
        }

        // Picture in Picture Setting
        ShopLive.pipScale = config.pipScale ?? 2/5
        ShopLive.pipPosition = config.pipPosition
        
        // handle Navigation Action Type
        ShopLive.setNextActionOnHandleNavigation(actionType: DemoConfiguration.shared.nextActionTypeOnHandleNavigation)
        
        // Pip padding setting
        let padding = config.pipPadding
        ShopLive.setPictureInPicturePadding(padding: .init(top: padding.top, left: padding.left, bottom: padding.bottom, right: padding.right))
        
        // Pip floating offset setting
        let floatingOffset = config.pipFloatingOffset
        ShopLive.setPictureInPictureFloatingOffset(offset: .init(top: floatingOffset.top, left: floatingOffset.left, bottom: floatingOffset.bottom, right: floatingOffset.right))
        
        // Mute Sound Setting
        ShopLive.setMuteWhenPlayStart(config.isMuted)
    }

    @objc func preview() {

        let config = DemoConfiguration.shared
        guard let campaign = config.campaign else {
            UIWindow.showToast(message: "sample.msg.none_key".localized())
            return
        }

        setupShopliveSettings()

        if config.authType == "USER", (config.user.id == nil || (config.user.id != nil && config.user.id!.isEmpty)) {
            UIWindow.showToast(message: "sample.msg.failed.noneUserId".localized())
            return
        }

        ShopLive.configure(with: campaign.accessKey)
        ShopLive.preview(with: campaign.campaignKey) {
            if DemoConfiguration.shared.usePlayWhenPreviewTapped {
                ShopLive.play(with: campaign.campaignKey, keepWindowStateOnPlayExecuted: true)
            } else {
                UIWindow.showToast(message: "tap preview".localized(), curView: self.view)
            }
        }
    }

    @objc func play() {
        let config = DemoConfiguration.shared
        guard let campaign = config.campaign else {
            UIWindow.showToast(message: "sample.msg.none_key".localized())
            return
        }

        setupShopliveSettings()
        ShopLive.setEndpoint("https://www.shoplive.show/v1/sdk.html")
        
        
        if config.authType == "USER", (config.user.id == nil || (config.user.id != nil && config.user.id!.isEmpty)) {
            UIWindow.showToast(message: "sample.msg.failed.noneUserId".localized())
            return
        }
        ShopLive.configure(with: campaign.accessKey)
        ShopLive.play(with: campaign.campaignKey, keepWindowStateOnPlayExecuted: true)
    }
}

extension MainViewController: ShopLiveSDKDelegate {
    func handleNavigation(with url: URL) {
        print("handleNavigation \(url)")

        var presenter: UIViewController?
                
        switch DemoConfiguration.shared.nextActionTypeOnHandleNavigation {
        case .PIP, .CLOSE:
            presenter = self
            break
        case .KEEP:
            presenter = ShopLive.viewController
            break
        @unknown default:
            break
        }
        
        guard url.absoluteString.hasPrefix("http") else {
            let alert = UIAlertController(title: nil, message: "sample.msg.wrongurl".localized() + "[\(url.absoluteString)]", preferredStyle: .alert)
            alert.addAction(.init(title: "alert.msg.confirm".localized(), style: .default, handler: nil))
            presenter?.present(alert, animated: true, completion: nil)
            return
        }

        if #available(iOS 13, *) {
            if let browser = self.safari {
                browser.dismiss(animated: false, completion: nil)
            }

            safari = .init(url: url)

            guard let browser = self.safari else { return }
            presenter?.present(browser, animated: true)
        } else {
            // TODO: Single UIWindow 에서 PIP 처리 적용 필요
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func handleChangeCampaignStatus(status: String) {
        print("handleChangeCampaignStatus \(status)")
    }

    func handleError(code: String, message: String) {
        print("handleError")
    }

    func handleCampaignInfo(campaignInfo: [String : Any]) {
        print("handleCampaignInfo")
    }

    /*
     // deprecated
     func handleDownloadCoupon(with couponId: String, completion: @escaping () -> Void)
    
     func handleDownloadCouponResult(with couponId: String, completion: @escaping (CouponResult) -> Void)
    */
    func handleDownloadCoupon(with couponId: String, result: @escaping (ShopLiveCouponResult) -> Void) {
        print("handleDownloadCoupon")
        let alert = UIAlertController(title: "sample.coupon.download".localized(), message: "sample.coupon.coupon_id".localized() + ": \(couponId)", preferredStyle: .alert)
        alert.addAction(.init(title: "alert.msg.failed".localized(), style: .cancel, handler: { _ in
            DispatchQueue.main.async {
                let message = DemoConfiguration.shared.downloadCouponFailedMessage
                let status = DemoConfiguration.shared.downloadCouponFailedStatus
                let alertType = DemoConfiguration.shared.downloadCouponFailedAlertType
                DispatchQueue.main.async {
                    let couponResult = ShopLiveCouponResult(couponId: couponId, success: false, message: message, status: status, alertType: alertType)
                    result(couponResult)
                }
            }
        }))
        alert.addAction(.init(title: "alert.msg.success".localized(), style: .default, handler: { _ in
            let message = DemoConfiguration.shared.downloadCouponSuccessMessage
            let status = DemoConfiguration.shared.downloadCouponSuccessStatus
            let alertType = DemoConfiguration.shared.downloadCouponSuccessAlertType
            DispatchQueue.main.async {
                let couponResult = ShopLiveCouponResult(couponId: couponId, success: true, message: message, status: status, alertType: alertType)
                result(couponResult)
            }
        }))
        ShopLive.viewController?.present(alert, animated: true, completion: nil)
    }

    /*
     // deprecated
    func handleCustomAction(with id: String, type: String, payload: Any?, completion: @escaping () -> Void) {
        print("handleCustomAction \(id) \(type) \(payload.debugDescription)")
    }
    func handleCustomActionResult(with id: String, type: String, payload: Any?, completion: @escaping (CustomActionResult) -> Void) {
    }
     */

    func handleCustomAction(with id: String, type: String, payload: Any?, result: @escaping (ShopLiveCustomActionResult) -> Void) {
        print("handleCustomAction")

        let alert = UIAlertController(title: "CUSTOM ACTION", message: "id: \(id)\ntype: \(type)\npayload: \(String(describing: payload))", preferredStyle: .alert)
        alert.addAction(.init(title: "alert.msg.failed".localized(), style: .cancel, handler: { _ in
            DispatchQueue.main.async {
                let message = DemoConfiguration.shared.downloadCouponFailedMessage
                let status = DemoConfiguration.shared.downloadCouponFailedStatus
                let alertType = DemoConfiguration.shared.downloadCouponFailedAlertType
                let customActionResult = ShopLiveCustomActionResult(id: id, success: false, message: message, status: status, alertType: alertType)
                result(customActionResult)
            }
        }))
        alert.addAction(.init(title: "alert.msg.success".localized(), style: .default, handler: { _ in
            let message = DemoConfiguration.shared.downloadCouponSuccessMessage
            let status = DemoConfiguration.shared.downloadCouponSuccessStatus
            let alertType = DemoConfiguration.shared.downloadCouponSuccessAlertType
            DispatchQueue.main.async {
                let customActionResult = ShopLiveCustomActionResult(id: id, success: true, message: message, status: status, alertType: alertType)
                result(customActionResult)
            }
        }))
        ShopLive.viewController?.present(alert, animated: true, completion: nil)
    }

    func handleCommand(_ command: String, with payload: Any?) {
        print("handleCommand: \(command)  payload: \(String(describing: payload))")
    }

    func onSetUserName(_ payload: [String : Any]) {
        print("onSetUserName")
        payload.forEach { (key, value) in
            print("onSetUserName key: \(key) value: \(value)")
        }
    }

    func handleReceivedCommand(_ command: String, with payload: Any?) {
        print("handleReceivedCommand command: \(command) payload: \(String(describing: payload))")
        
        switch command {
        case "LOGIN_REQUIRED":
            let loginAlert = UIAlertController(title: "sample.login.alert.title".localized(), message: "sample.login.alert.message".localized(), preferredStyle: .alert)
            loginAlert.addAction(.init(title: "alert.msg.cancel".localized(), style: .cancel))
            loginAlert.addAction(.init(title: "alert.msg.confirm".localized(), style: .default, handler: { [weak self] action in
                ShopLive.startPictureInPicture()
                let login = LoginViewController()
                login.delegate = self
                self?.navigationController?.pushViewController(login, animated: true)
            }))
            ShopLive.viewController?.present(loginAlert, animated: true)
            
            break
        default:
            break
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = items[safe: indexPath.row], let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as? MenuCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.configure(item: item)
        return cell
    }

}

extension MainViewController: MenuCellDelegate {
    func didTapMenu(item: MenuItem?) {
        guard let item = item else { return }

        switch item {
        case .step1:
            let page = CampaignSettingController()
            self.navigationController?.pushViewController(page, animated: true)
            break
        case .step2:
            let page = UserInfoViewController()
            self.navigationController?.pushViewController(page, animated: true)
            break
        case .step3:
            let page = OptionsViewController()
            self.navigationController?.pushViewController(page, animated: true)
            break
        }
    }
}

extension MainViewController: DemoConfigurationObserver {
    var identifier: String {
        "MainViewController"
    }

    func updatedValues(keys: [String]) {
            tableView.reloadData()
    }


}

extension MainViewController: LoginDelegate {
    func loginSuccess() {
        let config = DemoConfiguration.shared
        guard let campaign = config.campaign else {
            UIWindow.showToast(message: "sample.msg.none_key".localized())
            return
        }
        
        let loginUser = ShopLiveUser(id: "shoplive", name: "loginUser", gender: .male, age: 20)
        ShopLive.user = loginUser
        
        ShopLive.play(with: campaign.campaignKey, keepWindowStateOnPlayExecuted: true)
    }
}
