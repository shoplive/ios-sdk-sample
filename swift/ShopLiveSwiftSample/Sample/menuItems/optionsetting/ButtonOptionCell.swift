//
//  ButtonOptionCell.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/16.
//

import UIKit
import ShopLiveSDK

final class ButtonOptionCell: UITableViewCell {

    var item: SDKOptionItem?
    lazy var optionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .gray
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
        
        self.contentView.addSubview(optionLabel)
        
        optionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.lessThanOrEqualToSuperview().offset(-10)
            $0.top.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
    }

    func configure(item: SDKOptionItem) {
        updateDatas(item: item)
    }

    func updateDatas(item: SDKOptionItem) {
        var descriptionTitle: String = ""
        var itemLabelText: NSMutableAttributedString = .init()
        itemLabelText = itemLabelText.titleLabel(string: item.name + "\n")
        switch item.optionType.settingType {
        case .dropdown:
            itemLabelText = itemLabelText.descriptionLabel(string: item.optionDescription + "\n")
            switch item.optionType {
            case .pipPosition:
                let pipPosition = DemoConfiguration.shared.pipPosition
                if pipPosition != ShopLive.PipPosition.default {
                    descriptionTitle = pipPosition.optionName
                } else {
                    descriptionTitle = item.optionDescription
                }
                break
            case .nextActionOnHandleNavigation:
                let nextActionOnHandleNavigation: ActionType = DemoConfiguration.shared.nextActionTypeOnHandleNavigation
                
                descriptionTitle = nextActionOnHandleNavigation.localizedName
                break
            default:
                break
            }
            itemLabelText = itemLabelText.dropdownValueLabel(string: descriptionTitle)
            break
        case .routeTo:
            switch item.optionType {
            case .pipFloatingOffset:
                descriptionTitle = item.optionDescription
                break
            default:
                descriptionTitle = item.optionDescription
                break
            }
            itemLabelText = itemLabelText.descriptionLabel(string: descriptionTitle)
            break
        default:
            switch item.optionType {
            case .shareScheme:
                if let shareScheme = DemoConfiguration.shared.shareScheme, !shareScheme.isEmpty {
                    descriptionTitle = shareScheme
                } else {
                    descriptionTitle = item.optionDescription
                }
                break
            case .progressColor:
                if let progressColor = DemoConfiguration.shared.progressColor, !progressColor.isEmpty {
                    descriptionTitle = progressColor
                } else {
                    descriptionTitle = item.optionDescription
                }
                break
            case .pipScale:
                if let pipScale = DemoConfiguration.shared.pipScale, pipScale > 0.0, pipScale <= 1.0 {
                    descriptionTitle = String(format: "%.1fx",  pipScale)
                } else {
                    descriptionTitle = item.optionDescription
                }
                break
            default:
                descriptionTitle = item.optionDescription
                break
            }
            itemLabelText = itemLabelText.descriptionLabel(string: descriptionTitle)
            break
        }
        optionLabel.attributedText = itemLabelText
    }

}

extension ShopLive.PipPosition {
    
    var optionName: String {
        switch self {
        case .default, .bottomRight:
            return "sdkoption.pipPosition.item4".localized()
        case .bottomLeft:
            return "sdkoption.pipPosition.item3".localized()
        case .topLeft:
            return "sdkoption.pipPosition.item1".localized()
        case .topRight:
            return "sdkoption.pipPosition.item2".localized()
        default:
            return "sdkoption.pipPosition.item4".localized()
        }
    }
    
}
