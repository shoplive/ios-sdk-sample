//
//  UserInfoViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit

final class UserInfoViewController: SideMenuItemViewController {

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


    var radioGroup: [ShopLiveRadioButton] = []

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

        self.radioGroup = [maleRadio, femaleRadio, noneRadio]
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

    lazy var jwtInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "JWT Secret Key"
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

    lazy var jwtResultLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.textColor = .lightGray
        return view
    }()

    lazy var jwtGenerateButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("userinfo.jwt.button.generate".localized(), for: .normal)
        view.layer.cornerRadius = 6
        view.backgroundColor = .red
        return view
    }()

    private var user: ShopLiveUser = DemoConfiguration.shared.user
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNaviItems()
        setupViews()
        updateUserInfo()
    }

    func setupNaviItems() {
        self.title = SideMenuTypes.userinfo.stringKey.localized()

        let delete = UIBarButtonItem(title: "sdk.user.delete".localized(from: "shoplive"), style: .plain, target: self, action: #selector(deleteAct))

        let save = UIBarButtonItem(title: "sdk.user.save".localized(from: "shoplive"), style: .plain, target: self, action: #selector(saveAct))

        delete.tintColor = .white
        save.tintColor = .white

        self.navigationItem.rightBarButtonItems = [save, delete]
    }

    func setupViews() {
        self.view.addSubview(userIdInputField)
        self.view.addSubview(userNameInputField)
        self.view.addSubview(ageInputField)
        self.view.addSubview(userScoreInputField)
        self.view.addSubview(genderView)
        self.view.addSubview(jwtInputField)
        self.view.addSubview(jwtResultLabel)
        self.view.addSubview(jwtGenerateButton)
        jwtInputField.isHidden = true
        jwtResultLabel.isHidden = true
        jwtGenerateButton.isHidden = true

        userIdInputField.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(15)
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
        }

        jwtInputField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.top.equalTo(genderView.snp.bottom).offset(25)
            $0.trailing.equalToSuperview().offset(-15)
            $0.height.equalTo(35)
        }

        jwtResultLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.top.equalTo(jwtInputField.snp.bottom).offset(5)
            $0.height.greaterThanOrEqualTo(20)
        }

        jwtGenerateButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.top.equalTo(jwtResultLabel.snp.bottom).offset(5)
            $0.height.equalTo(35)
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }

    @objc func deleteAct() {
        let alert = UIAlertController(title: "userinfo.msg.deleteAll.title".localized(), message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "alert.msg.no".localized(), style: .cancel, handler: { action in

        }))
        alert.addAction(.init(title: "alert.msg.ok".localized(), style: .default, handler: { action in
            DemoConfiguration.shared.user = ShopLiveUser()
            self.updateUserInfo()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    @objc func saveAct() {
        guard let userIdText = userIdInputField.text, !userIdText.isEmpty else {
            UIWindow.showToast(message: "userinfo.msg.save.failed.noneId".localized())
            return
        }
        user.id = userIdText
        user.name = userNameInputField.text
        user.gender = selectedGender()
        if let ageText = ageInputField.text, !ageText.isEmpty, let age = Int(ageText), age >= 0 {
            user.age = age
        } else {
            user.age = nil
        }

        user.add(["userScore" : userScoreInputField.text])

        DemoConfiguration.shared.user = user

        UIWindow.showToast(message: "userinfo.msg.save".localized())
        handleNaviBack()
    }

    private func updateUserInfo() {
        user = DemoConfiguration.shared.user
        userIdInputField.text = user.id ?? ""
        userNameInputField.text = user.name ?? ""
        let age = user.age ?? -1
        ageInputField.text = age >= 0 ? "\(age)" : ""
        updateGender(identifier: user.gender?.description ?? "unknown")
        let userScore = DemoConfiguration.shared.userScore
        userScoreInputField.text = userScore != nil ? "\(userScore!)" : ""

        // jwt 생성 키값이 없으면
        jwtResultLabel.text = "userinfo.jwt.result.message".localized()
    }
}

extension UserInfoViewController: ShopLiveRadioButtonDelegate {

    func updateGender(identifier: String) {
        radioGroup.forEach { radio in
            radio.updateRadio(selected: radio.identifier == identifier)
        }
    }

    func didSelectRadioButton(_ sender: ShopLiveRadioButton) {
        updateGender(identifier: sender.identifier)
    }

    func selectedGender() -> ShopLiveUser.Gender {
        guard let selected = radioGroup.first(where: {$0.isSelected == true}) else {
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
