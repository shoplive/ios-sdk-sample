//
//  UserInfoCell.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/14.
//

import UIKit

class UserInfoCell: SampleBaseCell {

    lazy var chooseButton: GuideTitleButton = {
        let view = GuideTitleButton(guide: "base.section.userinfo.none.title".localized(), buttonTitle: "base.section.userinfo.button.chooseCampaign.title".localized())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
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

}

extension UserInfoCell: GuideTitleButtonDelegate {
    func didTouchGuideTitleButton(_ sender: GuideTitleButton) {
        print("didTouchGuideTitleButton")

        let page = UserInfoViewController()
        self.parent?.navigationController?.pushViewController(page, animated: true)
    }
}
