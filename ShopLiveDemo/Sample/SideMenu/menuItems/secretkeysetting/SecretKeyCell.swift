//
//  SecretKeyCell.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/19.
//

import UIKit

final class SecretKeyCell: UITableViewCell {

    private let keyNameLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.textColor = .black
        view.font = .systemFont(ofSize: 13, weight: .medium)
        view.textAlignment = .left
        return view
    }()

    private let keyLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.textColor = .black
        view.font = .systemFont(ofSize: 13, weight: .medium)
        view.textAlignment = .left
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
        self.contentView.addSubview(keyNameLabel)
        self.contentView.addSubview(keyLabel)

        let bottomLine: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .lightGray
            return view
        }()

        self.contentView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        keyNameLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(15)
            $0.trailing.lessThanOrEqualToSuperview().offset(-15)
        }

        keyLabel.snp.makeConstraints {
            $0.top.equalTo(keyNameLabel.snp.bottom)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.lessThanOrEqualToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-15)
        }
    }

    func configure(keySet: DemoSecretKeySet) {
        self.keyNameLabel.text = keySet.name
        var prefix = "\(keySet.key.prefix(10))"

        for _ in 0..<(keySet.key.count) {
            prefix += "*"
        }

        self.keyLabel.text = prefix
    }

}
