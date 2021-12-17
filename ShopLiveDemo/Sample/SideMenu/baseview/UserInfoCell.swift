//
//  UserInfoCell.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/14.
//

import UIKit
import XCTest

class UserInfoCell: SampleBaseCell {

    private var user = DemoConfiguration.shared.user

    private var userButtonTitle: String {
        guard user.id != nil else {
            return "base.section.userinfo.button.chooseCampaign.input.title".localized()
        }
        return "base.section.userinfo.button.chooseCampaign.change.title".localized()
    }

    private var userDescription: String {

        guard let userId = user.id else {
            return "base.section.userinfo.none.title".localized()
        }

        var description: String = "userId: \(userId)\n"
        description += "userName: \(user.name ?? "userName: ")\n"
        description += "age: \(user.ageText)\n"
        description += "userScore: \(user.scoreText)\n"

        var userGender: String = "선택안함"

        if let gender = user.gender {
            switch gender {
            case .male:
                userGender = "남"
                break
            case .female:
                userGender = "여"
                break
            default:
                break
            }
        }

        description += "gender: \(userGender)"

        return description
    }

    lazy var chooseButton: GuideTitleButton = {
        let view = GuideTitleButton(guide: "base.section.userinfo.none.title".localized(), buttonTitle: "base.section.userinfo.button.chooseCampaign.input.title".localized())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        updateUserInfo()
        DemoConfiguration.shared.addConfigurationObserver(observer: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupViews() {
        super.setupViews()

        self.itemView.addSubview(chooseButton)
        chooseButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.greaterThanOrEqualTo(35)
        }

        self.setSectionTitle(title: "base.section.userinfo.title".localized())
    }

    private func updateUserInfo() {
        user = DemoConfiguration.shared.user
        chooseButton.updateGuide(guide: userDescription)
        chooseButton.updateButtonTitle(userButtonTitle)
    }
}

extension UserInfoCell: GuideTitleButtonDelegate {
    func didTouchGuideTitleButton(_ sender: GuideTitleButton) {
        let page = UserInfoViewController()
        self.parent?.navigationController?.pushViewController(page, animated: true)
    }
}

extension UserInfoCell: DemoConfigurationObserver {
    var identifier: String {
        "UserInfoCell"
    }

    func updatedValues(keys: [String]) {
        keys.forEach { key in
            switch key {
            case "user":
                self.updateUserInfo()
                break
            default:
                break
            }
        }
    }
}

extension ShopLiveUser {
    var userScore: Int? {
        if let userScoreObj = self.getParams().first(where: { $0.key == "userScore" }) {
            return Int(userScoreObj.value)
        } else {
            return nil
        }
    }

    var scoreText: String {
        guard let scoreValue = self.userScore else {
            return ""
        }
        return "\(scoreValue)"
    }

    var ageText: String {
        guard let ageValue = self.age, ageValue >= 0 else {
            return ""
        }
        return "\(ageValue)"
    }
}
