//
//  CampaignSettingController.swift
//  ShopLiveSwiftSample
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit
import DropDown

final class CampaignSettingController: SampleBaseViewController {

    lazy var accessInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "campaign_setting.accesskey".localized()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        view.keyboardType = .default
        view.delegate = self
        return view
    }()

    lazy var campaignInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "campaign_setting.campaignkey".localized()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        view.keyboardType = .default
        view.delegate = self
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNaviItems()
        setupViews()

        guard let campaign = DemoConfiguration.shared.campaign else { return }
        updateCampaign(accessKey: campaign.accessKey, campaignKey: campaign.campaignKey)
    }

    private func setupNaviItems() {
        self.title = "sample.menu.step1.title".localized()
        let save = UIBarButtonItem(title: "sample.menu.navi.save".localized(), style: .plain, target: self, action: #selector(saveAct))
        save.tintColor = .white
        self.navigationItem.rightBarButtonItems = [save]
    }

    private func setupViews() {
        self.view.addSubviews(accessInputField, campaignInputField)

        self.accessInputField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.width.equalToSuperview().multipliedBy(0.95)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(35)
        }

        self.campaignInputField.snp.makeConstraints {
            $0.top.equalTo(accessInputField.snp.bottom).offset(8)
            $0.width.equalToSuperview().multipliedBy(0.95)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(35)
        }
    }

    private func updateCampaign(accessKey: String, campaignKey: String) {
        DispatchQueue.main.async {
            self.accessInputField.text = accessKey
            self.campaignInputField.text = campaignKey
        }
    }

    @objc func saveAct() {
        
        guard let accessKey = accessInputField.text, !accessKey.isEmpty,
              let campaignKey = campaignInputField.text, !campaignKey.isEmpty else {
                  DemoConfiguration.shared.campaign = nil
                  handleNaviBack()
                  return
              }
        DemoConfiguration.shared.campaign = CampaignKeySet(accessKey: accessKey, campaignKey: campaignKey)
        handleNaviBack()
    }
}

extension CampaignSettingController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case accessInputField:
            self.campaignInputField.becomeFirstResponder()
            break
        case campaignInputField:
            hideKeyboard()
            break
        default:
            break
        }

        return true
    }
}
