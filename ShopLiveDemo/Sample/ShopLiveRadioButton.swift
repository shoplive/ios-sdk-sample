//
//  ShopLiveRadioButton.swift
//  ShopLiveOn
//
//  Created by ShopLive on 2021/09/16.
//

import UIKit

protocol ShopLiveRadioButtonDelegate: AnyObject {
    func didSelectRadioButton(_ sender: ShopLiveRadioButton)
}

final class ShopLiveRadioButton: UIView {

    weak var delegate: ShopLiveRadioButtonDelegate?

    var identifier: String = ""

    lazy var radioButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false

        view.setImage(UIImage(named: "radio_not_selected"), for: .normal)
        view.setImage(UIImage(named: "radio_selected"), for: .selected)
        return view
    }()

    lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.textColor = .black
        return view
    }()

    lazy var touchArea: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.addTarget(self, action: #selector(didTouchRadioButton), for: .touchUpInside)
        return view
    }()

    init() {
        super.init(frame: .zero)
        setupViews()
    }
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(descriptionLabel)
        self.addSubview(radioButton)
        self.addSubview(touchArea)

        radioButton.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.height.equalTo(20)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.leading.equalTo(radioButton.snp.trailing).offset(5)
        }

        touchArea.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func configure(identifier: String, description: String) {
        self.identifier = identifier
        self.descriptionLabel.text = description
    }

    func updateRadio(selected: Bool) {
        self.radioButton.isSelected = selected
    }

    @objc func didTouchRadioButton() {
        delegate?.didSelectRadioButton(self)
    }
}

