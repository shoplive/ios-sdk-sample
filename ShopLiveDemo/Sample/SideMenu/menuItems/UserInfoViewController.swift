//
//  UserInfoViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit

class UserInfoViewController: SideMenuItemViewController {

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
        view.keyboardType = .alphabet
        return view
    }()

    lazy var userNameInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "userinfo.userName.placeholder".localized()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        view.keyboardType = .alphabet
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
            view.configure(identifier: "male", description: "userinfo.gender.male".localized())
            view.delegate = self
            return view
        }()

        let femaleRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "female", description: "userinfo.gender.female".localized())
            view.delegate = self
            return view
        }()

        let noneRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "none", description: "userinfo.gender.none".localized())
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
        view.keyboardType = .numberPad
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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNaviItems()
        setupViews()
        loadDatas()
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
        
    }

    @objc func saveAct() {

    }

    private func loadDatas() {
        // jwt 생성 키값이 없으면
        jwtResultLabel.text = "userinfo.jwt.result.message".localized()

        // gender
        updateGender(identifier: "none") // 선택된 데이터가 없으면 none
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
}
