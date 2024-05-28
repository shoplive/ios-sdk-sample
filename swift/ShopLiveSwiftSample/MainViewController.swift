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
import ShopliveSDKCommon
import ShopLiveSDK
import ShopLiveShortformSDK


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
    
    private lazy var nativeshortformButton : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.masksToBounds = true
        btn.setBackgroundColor(.red, for: .normal)
        btn.layer.cornerRadius = 6
        btn.addTarget(self, action: #selector(nativeshortform), for: .touchUpInside)
        btn.setTitle("sample.button.shortform.native".localized(), for: .normal)
        
        return btn
    }()
    
    private lazy var hybridshortformButton : UIButton = {
        let btn = UIButton()
        btn.layer.masksToBounds = true
        btn.setBackgroundColor(.red, for: .normal)
        btn.layer.cornerRadius = 6
        btn.addTarget(self, action: #selector(hybridshortform), for: .touchUpInside)
        btn.setTitle("sample.button.shortform.hybrid".localized(), for: .normal)
        return btn
    }()
    

    var safari: SFSafariViewController? = nil
    
    private let previewCoverMaker = PreviewCoverViewMaker()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ShopLiveSDK version \(ShopLive.sdkVersion)")
        print("ShopLiveCommonSDK version \(ShopLiveCommon.sdkVersion)")
        print("ShopLiveShortformSDK version \(ShopLiveShortform.sdkVersion)")
        
        self.view.backgroundColor = .white

        self.title = "sample.app.title".localized()

        ShopLive.delegate = self

        DemoConfiguration.shared.addConfigurationObserver(observer: self)

        setupViews()
    }

    func setupViews() {
        
        let topBtnStack = UIStackView(arrangedSubviews: [playButton,previewButton])
        topBtnStack.axis = .horizontal
        topBtnStack.distribution = .fillEqually
        topBtnStack.spacing = 10
        
        let bottomBtnStack = UIStackView(arrangedSubviews: [nativeshortformButton,hybridshortformButton])
        bottomBtnStack.axis = .horizontal
        bottomBtnStack.distribution = .fillEqually
        bottomBtnStack.spacing = 10
        
        let btnStack = UIStackView(arrangedSubviews: [topBtnStack,bottomBtnStack])
        btnStack.translatesAutoresizingMaskIntoConstraints = false
        btnStack.axis = .vertical
        btnStack.distribution = .fillEqually
        btnStack.spacing = 10
        
        
        
        self.view.addSubviews(tableView, btnStack)
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalTo(playButton.snp.top).offset(15)
            $0.leading.trailing.equalToSuperview()
        }
        
        btnStack.snp.makeConstraints {
            $0.leading.equalTo(self.view.snp.leading).offset(10)
            $0.trailing.equalTo(self.view.snp.trailing).offset(-10)
            $0.bottom.equalTo(self.view.snp.bottom).offset(-15)
            $0.height.equalTo(35 + 10 + 35)
        }
    }

    func setupShopliveSettings() {
        let config = DemoConfiguration.shared
        
        switch config.authType {
        case "USER":
            if !config.user.userId.isEmpty {
                ShopLiveCommon.setUser(user: config.user)
            }
            break
        case "TOKEN":
            ShopLiveCommon.setAuthToken(authToken: config.jwtToken)
            break
        case "GUEST":
            break
        default:
            break
        }

        // Keep play video on headphone unplugged setting
        ShopLive.setKeepPlayVideoOnHeadphoneUnplugged(config.useHeadPhoneOption1, isMute: config.useHeadPhoneOption2)

        // Auto resume video on call end setting
        ShopLive.setAutoResumeVideoOnCallEnded(config.useCallOption)
        
        //Keep aspect ratio of video(CENTER_CROP,FIT, default is CENTER_CROP)
        ShopLive.setResizeMode(mode: config.resizeMode)

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
                ShopLive.setShareScheme(scheme, shareDelegate: self)
            } else {
                // Default iOS Share
                ShopLive.setShareScheme(scheme, shareDelegate: nil)
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
        
        // handle Navigation Action Type
        ShopLive.setNextActionOnHandleNavigation(actionType: DemoConfiguration.shared.nextActionTypeOnHandleNavigation)
        
        // Pip padding setting
        let padding = config.pipPadding
        let isPaddingSuccess  = ShopLive.setPictureInPicturePadding(padding: .init(top: padding.top, left: padding.left, bottom: padding.bottom, right: padding.right))
        
        // Pip floating offset setting
        let floatingOffset = config.pipFloatingOffset
        let isFloatingSuccess = ShopLive.setPictureInPictureFloatingOffset(offset: .init(top: floatingOffset.top, left: floatingOffset.left, bottom: floatingOffset.bottom, right: floatingOffset.right))
        
        // Picture in Picture Setting
        let pipSize : ShopLiveInAppPipSize
        if let max = DemoConfiguration.shared.maxPipSize {
            pipSize = .init(pipMaxSize: max)
        }
        else if let fixedHeight = DemoConfiguration.shared.fixedHeightPipSize {
            pipSize = .init(pipFixedHeight: fixedHeight)
        }
        else {
            pipSize = .init(pipFixedWidth: DemoConfiguration.shared.fixedWidthPipSize ?? 100)
        }
        
        
        let inAppPipConfig = ShopLiveInAppPipConfiguration(useCloseButton: config.useCloseButton,
                                                           pipPosition: config.pipPosition,
                                                           enableSwipeOut: config.pipEnableSwipeOut,
                                                           pipSize: pipSize,
                                                           pipRadius: CGFloat(config.pipCornerRadius))
        
        ShopLive.setInAppPipConfiguration(config: inAppPipConfig)
        
        // Mute Sound Setting
        ShopLive.setMuteWhenPlayStart(config.isMuted)
        
        // AVAudiosession option .mixWithOthers option
        ShopLive.setMixWithOthers(isMixAudio: config.mixAudio)
        
        // Keep aspect on tablet setting
        ShopLive.setKeepAspectOnTabletPortrait(config.useAspectOnTablet)
        
        ShopLive.setKeepWindowStyleOnReturnFromOsPip(config.usePipKeepWindowStyle)
        
        ShopLive.setVisibleStatusBar(isVisible: config.statusBarVisibility)
        
        
        ShopLive.setEnabledPictureInPictureMode(isEnabled: config.enablePip)
        
        ShopLive.setEnabledOSPictureInPictureMode(isEnabled: config.enableOsPip)
        
        
        //Customize preview CoverView(make sure to set useCloseButton = false)
//        previewCoverMaker.setCustomerPreviewCoverView()
        
    }

    @objc func preview() {

        let config = DemoConfiguration.shared
        guard let campaign = config.campaign else {
            UIWindow.showToast(message: "sample.msg.none_key".localized())
            return
        }

        ShopLiveCommon.setAccessKey(accessKey: campaign.accessKey)
        
        setupShopliveSettings()
        
        let playerData = ShopLivePreviewData(campaignKey: campaign.campaignKey,
                                            keepWindowStateOnPlayExecuted: DemoConfiguration.shared.useKeepWindowStateOnPlayExecuted,
                                            referrer: "customReferrer",
                                             isMuted: !DemoConfiguration.shared.enablePreviewSound,
                                             isEnabledVolumeKey: DemoConfiguration.shared.isEnabledVolumeKey) { campaign in
            ShopLiveLogger.debugLog(" campaign callBack campaign Title : \(campaign.title ?? "")")
        } brandHandler: { brand in
            ShopLiveLogger.debugLog(" brand callback brand Name : \(brand.name ?? "") \n brand Image : \(brand.imageUrl ?? "") \n brand Identifier : \(brand.identifier ?? "")")
        }
        
        ShopLive.preview(data: playerData)
        
    }

    @objc func play() {
        let config = DemoConfiguration.shared
        guard let campaign = config.campaign else {
            UIWindow.showToast(message: "sample.msg.none_key".localized())
            return
        }

        ShopLiveCommon.setAccessKey(accessKey: campaign.accessKey)
        setupShopliveSettings()
        ShopLive.setEndpoint("https://www.shoplive.show/v1/sdk.html")
        
        
        ShopLive.play(data: .init(campaignKey: campaign.campaignKey,
                                  keepWindowStateOnPlayExecuted: DemoConfiguration.shared.useKeepWindowStateOnPlayExecuted,
                                  isEnabledVolumeKey: DemoConfiguration.shared.isEnabledVolumeKey))
    }
    
    @objc func nativeshortform() {
        let config = DemoConfiguration.shared
        guard let campaign = config.campaign else {
            UIWindow.showToast(message: "sample.msg.none_key".localized())
            return
        }
        if campaign.accessKey == "" {
            UIWindow.showToast(message: "sample.msg.none_key".localized())
        }
        else {
            ShopLiveCommon.setAccessKey(accessKey: campaign.accessKey)
        }
        
        let view = ShortFormTabViewController()
        if let nav = self.navigationController {
            nav.pushViewController(view, animated: true)
        }
        else {
            self.present(view, animated: true)
        }
    }
    
    @objc func hybridshortform(){
        let view = ShortFormWebTypeViewController()
        if let nav = self.navigationController {
            nav.pushViewController(view, animated: true)
        }
        else {
            self.present(view, animated: true)
        }
    }
}

extension MainViewController: ShopLiveSDKDelegate {
    func playerPanGesture(state: UIGestureRecognizer.State, position: CGPoint) {
        
    }
    
    func onEvent(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String : Any]) {
        switch name {
        case "video_muted":
            break
        case "video_unmuted":
            break
        case "product_list":
            guard feature == .CLICK else { return }
            handleProductList(payload: payload)
        default:
            break
        }
    }
    
    private func handleProductList(payload: [String : Any]) {
        ShopLiveEvent.sendConversionEvent(data: .init(type: "purchase",
                                                      products: [.init(productId: payload["goodsId"] as? String,
                                                                       sku: payload["sku"] as? String,
                                                                       url: payload["url"] as? String,
                                                                       purchaseQuantity: 1,
                                                                       purchaseUnitPrice: payload["discountedPrice"] as? Double )],
                                                      orderId: "customOrderId",
                                                     referrer: "customReferrer",
                                                      custom: ["key" : "value" ]))
    }
    
   
    
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
    
    //  this delegate function is available after 1.5.8 version,
    // to get info abound sellers under 1.5.7 use handleReceivedCommand(_ command: String, with payload: Any?) instead
    func handleReceivedCommand(_ command: String, data: [String : Any]?) {
        switch command {
        case "ON_RECEIVED_SELLER_CONFIG","ON_CLICK_VIEW_SELLER_STORE","ON_CLICK_SELLER_SUBSCRIPTION":
            SellerManager.shared.parseCommand(command: command, payload: data)
        default:
            break
        }
    }
}
extension MainViewController : ShopLivePlayerShareDelegate {
    func handleShare(data: ShopLivePlayerShareData) {
        //show share sheet
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
        
        let loginUser = ShopLiveCommonUser(userId: "shoplive", age: 20, gender: .male)
        ShopLive.user = loginUser
        
        ShopLive.play(data: .init(campaignKey: campaign.campaignKey,keepWindowStateOnPlayExecuted: true))
    }
}
