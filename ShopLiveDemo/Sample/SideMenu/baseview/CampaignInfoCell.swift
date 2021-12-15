//
//  CampaignInfoCell.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/14.
//

import UIKit

class CampaignInfoCell: SampleBaseCell {

    lazy var chooseButton: GuideTitleButton = {
        let view = GuideTitleButton(guide: "base.section.campaignInfo.campaign.none.title".localized(), buttonTitle: "base.section.campaignInof.button.chooseCampaign.title".localized())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    lazy var accessKeyInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.placeholder = "accessKey"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        return view
    }()

    lazy var campaignKeyInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.placeholder = "campaignKey"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        return view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        ShopLiveDemoKeyTools.shared.addKeysetObserver(observer: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupViews() {
        super.setupViews()
        self.itemView.addSubview(chooseButton)
        self.itemView.addSubview(accessKeyInputField)
        self.itemView.addSubview(campaignKeyInputField)
        chooseButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.greaterThanOrEqualTo(35)
        }

        accessKeyInputField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.top.equalTo(chooseButton.snp.bottom).offset(10)
            $0.height.equalTo(45)
        }

        campaignKeyInputField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.top.equalTo(accessKeyInputField.snp.bottom).offset(10)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(45)
        }

        self.setSectionTitle(title: "base.section.campaignInfo.title".localized())
    }

}

extension CampaignInfoCell: GuideTitleButtonDelegate {
    func didTouchGuideTitleButton(_ sender: GuideTitleButton) {
        print("didTouchGuideTitleButton")
        let page = CampaignsViewController()
        page.selectKeySet = true
        self.parent?.navigationController?.pushViewController(page, animated: true)
    }
}

extension CampaignInfoCell: KeySetObserver {
    var identifier: String {
        return "MainViewController"
    }

    func keysetUpdated() {

    }

    func currentKeyUpdated() {
        print("CampaignInfoCell currentKeyUpdated")
        if let currentKey = ShopLiveDemoKeyTools.shared.currentKey() {
            chooseButton.updateGuide(guide: currentKey.alias)
            campaignKeyInputField.text = currentKey.campaignKey
            accessKeyInputField.text = currentKey.accessKey
        } else {
            chooseButton.clearGuide()
            campaignKeyInputField.text = "campaignKey"
            accessKeyInputField.text = "accessKey"
        }
    }
}
