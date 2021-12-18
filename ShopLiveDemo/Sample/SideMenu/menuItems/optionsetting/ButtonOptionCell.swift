//
//  ButtonOptionCell.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/16.
//

import UIKit

final class ButtonOptionCell: UITableViewCell {

    var item: SDKOptionItem?
    lazy var optionTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.textColor = .black
        view.font = .systemFont(ofSize: 15, weight: .regular)
        return view
    }()

    private lazy var optionDescriptionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.textColor = .lightGray
        view.font = .systemFont(ofSize: 14, weight: .regular)
        return view
    }()

    private lazy var labelBoxView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(optionTitleLabel)
        view.addSubview(optionDescriptionLabel)
        optionTitleLabel.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.greaterThanOrEqualTo(20)
        }
        optionDescriptionLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(optionTitleLabel.snp.bottom).offset(4)
            $0.bottom.equalToSuperview()
        }
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
        self.contentView.addSubview(labelBoxView)

        labelBoxView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.lessThanOrEqualToSuperview().offset(-10)
            $0.top.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }

    func configure(item: SDKOptionItem) {
        optionTitleLabel.text = item.name
        updateDatas(item: item)
    }

    func updateDatas(item: SDKOptionItem) {
        var descriptionTitle: String = ""
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
                descriptionTitle = String(format: "%.1f",  pipScale)
            } else {
                descriptionTitle = item.optionDescription
            }
            break
        case .pipPosition:
            let pipPosition = DemoConfiguration.shared.pipPosition
            if pipPosition != ShopLive.PipPosition.default {
                descriptionTitle = pipPosition.name
            } else {
                descriptionTitle = item.optionDescription
            }
            break
        default:
            descriptionTitle = item.optionDescription
            break
        }

        optionDescriptionLabel.text = descriptionTitle
    }

}
