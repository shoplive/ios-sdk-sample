//
//  MenuCell.swift
//  ShopLiveSwiftSample
//
//  Created by ShopLive on 2021/12/23.
//

import UIKit

protocol MenuCellDelegate: AnyObject {
    func didTapMenu(item: MenuItem?)
}

class MenuCell: UITableViewCell {

    weak var delegate: MenuCellDelegate?

    private(set) var identifier: String = ""
    private(set) var item: MenuItem?

    private lazy var menuButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        view.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        view.layer.cornerRadius = 6
        return view
    }()

    private lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.textColor = .lightGray
        view.font = .systemFont(ofSize: 14)
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func setupViews() {
        self.contentView.backgroundColor = .white
        self.contentView.addSubviews(menuButton, descriptionLabel)
        menuButton.snp.makeConstraints {
//            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.leading.equalToSuperview().offset(8)
            $0.top.equalToSuperview().offset(15)
//            $0.centerX.equalToSuperview()
            $0.height.equalTo(35)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(menuButton.snp.bottom).offset(10)
            $0.bottom.equalToSuperview().offset(-15)
            $0.leading.equalTo(menuButton).offset(8)
            $0.trailing.equalToSuperview().offset(-8)
        }
    }

    @objc func didTapButton() {
        delegate?.didTapMenu(item: self.item)
    }

    func configure(item: MenuItem) {
        self.item = item
        self.menuButton.setTitle("  " + item.menuTitle + "  ", for: .normal)
        var itemDescription: String = ""
        switch item {
        case .step1:    // Campaign settings
            if let campaign = DemoConfiguration.shared.campaign {
                itemDescription = "• " + "campaign_setting.accesskey.guide".localized() + "\(campaign.accessKey.isEmpty ? "campaign_setting.key.none".localized() : "campaign_setting.key.entered".localized())"
                itemDescription += "\n"
                itemDescription += "• " + "campaign_setting.campaignkey.guide".localized() + "\(campaign.campaignKey.isEmpty ? "campaign_setting.key.none".localized() : "campaign_setting.key.entered".localized())"
            } else {
                itemDescription = "campaign_setting.campaignkey.guide.none".localized()
            }
            break
        case .step2:    // User setting
            var userDescription: String = ""
            switch DemoConfiguration.shared.authType {
            case "USER":
                userDescription += "sample.authType.user".localized() + "\n\n"
                let user = DemoConfiguration.shared.user
                let id = user.userId ?? ""
                let name = user.userName ?? ""
                let gender = user.gender?.rawValue ?? ""
                let age = user.age
                let score = user.userScore

                if (id.isEmpty && name.isEmpty && !(gender == "m" || gender == "f") && age == nil && score == nil) {
                    userDescription += item.emptyItemMessage
                    break
                }
                var description: String = "• " + "User ID: \(user.userId ?? "User ID: ")\n"
                description += "• " + "User Name: \(user.userName ?? "User Name: ")\n"
                description += "• " + "Age: \(user.ageText)\n"
                description += "• " + "User Score: \(user.scoreText)\n"

                var userGender: String = "userinfo.gender.none".localized()

                if let gender = user.gender {
                    switch gender {
                    case .male:
                        userGender = "userinfo.gender.male".localized()
                        break
                    case .female:
                        userGender = "userinfo.gender.female".localized()
                        break
                    default:
                        break
                    }
                }

                description += "• " + "Gender: \(userGender)"

                userDescription += description
                break
            case "TOKEN":
                userDescription += "sample.authType.token".localized() + "\n\n"
                if let jwtToken = DemoConfiguration.shared.jwtToken, !jwtToken.isEmpty {
                    userDescription += "• " + "JWT token: " + jwtToken
                } else {
                    userDescription += "sample.menu.step2.jwt.lebel.placeholder".localized()
                }

                break
            case "GUEST":
                userDescription += "sample.authType.guest".localized()
                break
            default:
                userDescription += "sample.authType.user".localized()
                break
            }

            itemDescription = userDescription
            break
        case .step3:    // Other options
            var userDescription: String = ""

            userDescription += "sdkoption.section.pip.title".localized()  + "\n"
            let position = DemoConfiguration.shared.pipPosition.optionName
            userDescription += "• " + "sdkoption.pipPosition.title".localized() + ": \(position)"
            
            userDescription += "\n"
            let nextActionTypeOnHandleNavigation = DemoConfiguration.shared.nextActionTypeOnHandleNavigation
            userDescription += "• " + "sdkoption.nextActionTypeOnNavigation.guide".localized() + ": \(nextActionTypeOnHandleNavigation.localizedName)"
            
            userDescription += "\n\n"

            userDescription += "sdkoption.section.autoPlay.title".localized() + "\n"

            let useHeadphoneOption1 = DemoConfiguration.shared.useHeadPhoneOption1
            userDescription += "• " + "sdkoption.headphoneOption1.setting.guide".localized() + ": \(useHeadphoneOption1.guideString())" + "\n"

            let useCallOption = DemoConfiguration.shared.useCallOption
            userDescription += "• " + "sdkoption.callOption.setting.guide".localized() + ": \(useCallOption.guideString())"

            userDescription += "\n\n"

            userDescription += "sdkoption.section.share.title".localized() + "\n"

            let useCustomShare = DemoConfiguration.shared.useCustomShare
            userDescription += "• " + "sdkoption.customShare.setting.guide".localized() + ": \(useCustomShare.guideString())" + "\n"

            if let shareScheme = DemoConfiguration.shared.shareScheme, !shareScheme.isEmpty {
                userDescription += "• " + "sdkoption.shareScheme.title".localized() + ": \(shareScheme)"
            }
            

            userDescription += "\n\n"

            userDescription += "sdkoption.section.progress.title".localized()

            if let progressColor = DemoConfiguration.shared.progressColor {
                userDescription += "\n"
                userDescription += "• " + "sdkoption.progressColor.setting.guide".localized() + ": \(progressColor)"
            }

            let useCustomProgress = DemoConfiguration.shared.useCustomProgress
            userDescription += "\n"
            userDescription += "• " + "sdkoption.customProgress.setting.guide".localized() + ": \(useCustomProgress.guideString())"

            userDescription += "\n\n"

            userDescription += "sdkoption.section.chatFont.title".localized() + "\n"

            let useChatInputCustomFont = DemoConfiguration.shared.useChatInputCustomFont
            userDescription += "• " + "sdkoption.chatInputCustomFont.setting.guide".localized() + ": \(useChatInputCustomFont.guideString())" + "\n"

            let useChatSendButtonCustomFont = DemoConfiguration.shared.useChatSendButtonCustomFont
            userDescription += "• " + "sdkoption.chatSendButtonCustomFont.setting.guide".localized() + ": \(useChatSendButtonCustomFont.guideString())" + "\n"

            itemDescription = userDescription
            break
        }

        self.descriptionLabel.text = itemDescription ?? item.emptyItemMessage
    }
}
