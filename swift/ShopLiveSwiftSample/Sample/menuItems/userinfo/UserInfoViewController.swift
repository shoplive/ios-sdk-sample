//
//  UserInfoViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit

final class UserInfoViewController: SampleBaseViewController {

    var userTypeRadioGroup: [ShopLiveRadioButton] = []

    lazy var userTypeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let userRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "USER", description: "userinfo.type.simple".localized())
            view.delegate = self
            return view
        }()

        let tokenRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "TOKEN", description: "userinfo.type.token".localized())
            view.delegate = self
            return view
        }()

        let guestRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "GUEST", description: "userinfo.type.guest".localized())
            view.delegate = self
            view.updateRadio(selected: true)
            return view
        }()

        self.userTypeRadioGroup = [userRadio, tokenRadio, guestRadio]
        view.addSubviews(userRadio, tokenRadio, guestRadio)

        guestRadio.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.height.equalTo(20)
        }

        userRadio.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(guestRadio.snp.trailing).offset(15)
            $0.height.equalTo(20)
        }

        tokenRadio.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(userRadio.snp.trailing).offset(15)
            $0.trailing.lessThanOrEqualToSuperview()
            $0.height.equalTo(20)
        }

        return view
    }()

    private lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.textColor = .lightGray
        view.font = .systemFont(ofSize: 14)
        view.text = "userinfo.setting.guide".localized()
        return view
    }()

    lazy var userIdInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "userinfo.userid.placeholder".localized()
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

    lazy var userNameInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "userinfo.userName.placeholder".localized()
        view.setPlaceholderColor(.darkGray)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        return view
    }()

    lazy var ageInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "userinfo.age.placeholder".localized()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        view.keyboardType = .numberPad
        return view
    }()

    lazy var userScoreInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "userinfo.userScore.placeholder".localized()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        view.keyboardType = .numberPad
        return view
    }()


    var genderRadioGroup: [ShopLiveRadioButton] = []

    lazy var genderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let maleRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "m", description: "userinfo.gender.male".localized())
            view.delegate = self
            return view
        }()

        let femaleRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "f", description: "userinfo.gender.female".localized())
            view.delegate = self
            return view
        }()

        let noneRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "unknown", description: "userinfo.gender.none".localized())
            view.delegate = self
            view.updateRadio(selected: true)
            return view
        }()

        self.genderRadioGroup = [maleRadio, femaleRadio, noneRadio]
        view.addSubview(maleRadio)
        view.addSubview(femaleRadio)
        view.addSubview(noneRadio)

        maleRadio.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.height.equalTo(20)
        }

        femaleRadio.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(maleRadio.snp.trailing).offset(15)
            $0.height.equalTo(20)
        }

        noneRadio.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(femaleRadio.snp.trailing).offset(15)
            $0.trailing.lessThanOrEqualToSuperview()
            $0.height.equalTo(20)
        }

        return view
    }()

    private lazy var tokenGuideLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        let guideLink: String = "sample.link.tokenGuide".localized()
        let textRange = NSRange(location: 0, length: guideLink.count)
                let attributedText = NSMutableAttributedString(string: guideLink)

        attributedText.addAttributes([.foregroundColor : UIColor.lightGray,
                                      .font: UIFont.systemFont(ofSize: 14)], range: textRange)
        attributedText.addAttribute(.underlineStyle,
                                    value: NSUnderlineStyle.single.rawValue,
                                    range: textRange)

        view.attributedText = attributedText
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTokenGuide)))
        view.isUserInteractionEnabled = true
        return view
    }()

    lazy var jwtInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "sample.menu.step2.jwt.lebel.placeholder".localized()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        view.isUserInteractionEnabled = true
        view.isEnabled = true
        return view
    }()

    lazy var jwtFromStudioButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("sample.button.gettoken.studio".localized(), for: .normal)
        view.layer.cornerRadius = 6
        view.isEnabled = false
        view.backgroundColor = .lightGray
        view.setTitleColor(.init("#d0d0d0"), for: .disabled)
        return view
    }()

    private lazy var typeArea: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.addSubviews(userTypeView, descriptionLabel)

        userTypeView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.lessThanOrEqualToSuperview().offset(-15)
            $0.height.equalTo(20)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(userTypeView.snp.bottom).offset(10)
            $0.leading.equalTo(userTypeView).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().offset(-15)
            $0.height.equalTo(22)
            $0.bottom.equalToSuperview()
        }

        return view
    }()

    private lazy var userArea: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.addSubviews(userIdInputField, userNameInputField,
                         ageInputField, userScoreInputField, genderView)

        userIdInputField.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.height.greaterThanOrEqualTo(35)
        }

        userNameInputField.snp.makeConstraints {
            $0.top.equalTo(userIdInputField.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.height.greaterThanOrEqualTo(35)
        }

        ageInputField.snp.makeConstraints {
            $0.top.equalTo(userNameInputField.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.height.greaterThanOrEqualTo(35)
        }

        userScoreInputField.snp.makeConstraints {
            $0.top.equalTo(ageInputField.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.height.greaterThanOrEqualTo(35)
        }

        genderView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.top.equalTo(userScoreInputField.snp.bottom).offset(15)
            $0.height.equalTo(20)
            $0.bottom.equalToSuperview()
        }
        return view
    }()

    private lazy var tokenArea: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.addSubviews(tokenGuideLabel, jwtInputField)
        view.isUserInteractionEnabled = true
        tokenGuideLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.height.equalTo(22)
        }
        jwtInputField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.top.equalTo(tokenGuideLabel.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().offset(-15)
            $0.height.equalTo(35)
            $0.bottom.lessThanOrEqualToSuperview()
        }

        return view
    }()

    private var user: ShopLiveUser = DemoConfiguration.shared.user
    private var newUser: ShopLiveUser?
    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboard()
        setupNaviItems()
        setupViews()
        updateUserInfo()
    }

    private func setupNaviItems() {
        self.title = "sample.menu.step2.title".localized()

        let save = UIBarButtonItem(title: "sample.menu.navi.save".localized(), style: .plain, target: self, action: #selector(saveAct))

        save.tintColor = .white

        self.navigationItem.rightBarButtonItems = [save]
    }

    private func setupViews() {
        self.view.addSubviews(typeArea, userArea, tokenArea)
        typeArea.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.leading.trailing.equalToSuperview()
        }

        userArea.snp.makeConstraints {
            $0.top.equalTo(typeArea.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
        }

        tokenArea.snp.makeConstraints {
            $0.top.equalTo(userArea.snp.bottom).offset(35)
            $0.leading.trailing.equalToSuperview()
        }

    }

    @objc private func saveAct() {

        user.id = userIdInputField.text
        user.name = userNameInputField.text
        user.gender = selectedGender()
        if let ageText = ageInputField.text, !ageText.isEmpty, let age = Int(ageText), age >= 0 {
            user.age = age
        } else {
            user.age = nil
        }

        user.add(["userScore" : userScoreInputField.text])

        DemoConfiguration.shared.authType = selectedType()

        DemoConfiguration.shared.setUserInfo(user: user, jwtToken: jwtInputField.text)

        handleNaviBack()
    }

    @objc private func openTokenGuide() {
        if let url = URL(string: "userinfo.setting.jwt.guide.url".localized()) {
            UIApplication.shared.open(url)
        }
    }

    private func updateUserInfo() {
        updateUserType(identifier: DemoConfiguration.shared.authType)
        user = DemoConfiguration.shared.user
        userIdInputField.text = user.id ?? ""
        userNameInputField.text = user.name ?? ""
        let age = user.age ?? -1
        ageInputField.text = age >= 0 ? "\(age)" : ""
        updateGender(identifier: user.gender?.description ?? "unknown")
        let userScore = DemoConfiguration.shared.userScore
        userScoreInputField.text = userScore != nil ? "\(userScore!)" : ""

        // setup jwt token
        jwtInputField.text = DemoConfiguration.shared.jwtToken
    }
}

extension UserInfoViewController: ShopLiveRadioButtonDelegate {
    func didSelectRadioButton(_ sender: ShopLiveRadioButton) {
        if genderRadioGroup.contains(where: {$0 == sender}) {
            updateGender(identifier: sender.identifier)
        } else {
            updateUserType(identifier: sender.identifier)
        }
    }

    func updateUserType(identifier: String) {
        userTypeRadioGroup.forEach { radio in
            radio.updateRadio(selected: radio.identifier == identifier)
        }

        switch identifier {
        case "USER":
            descriptionLabel.text = "userinfo.setting.simple.guide".localized()
            userArea.isHidden = false
            tokenArea.isHidden = true
            break
        case "TOKEN":
            descriptionLabel.text = "userinfo.setting.token.guide".localized()
            userArea.isHidden = false
            tokenArea.isHidden = false
            break
        case "GUEST":
            descriptionLabel.text = "userinfo.setting.guest.guide".localized()
            userArea.isHidden = true
            tokenArea.isHidden = true
            break
        default:
            descriptionLabel.text = "userinfo.setting.simple.guide".localized()
        }
    }

    func updateGender(identifier: String) {
        genderRadioGroup.forEach { radio in
            radio.updateRadio(selected: radio.identifier == identifier)
        }
    }

    func selectedType() -> String {
        guard let selected = userTypeRadioGroup.first(where: {$0.isSelected == true}) else {
            return "GUEST"
        }
        return selected.identifier
    }

    func selectedGender() -> ShopLiveUser.Gender {
        guard let selected = genderRadioGroup.first(where: {$0.isSelected == true}) else {
            return .unknown
        }

        switch selected.identifier {
        case ShopLiveUser.Gender.male.description:
            return .male
        case ShopLiveUser.Gender.female.description:
            return .female
        case ShopLiveUser.Gender.unknown.description:
            return .unknown
        default:
            return .unknown
        }

    }
}
