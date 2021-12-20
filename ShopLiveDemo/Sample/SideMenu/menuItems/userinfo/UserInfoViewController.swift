//
//  UserInfoViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit

final class UserInfoViewController: SideMenuItemViewController {

    private var secretKeyButtonTitle: String {
        guard let key = DemoSecretKeyTool.shared.currentKey()?.key, !key.isEmpty else {
            return "userinfo.button.chooseSecret.input.title".localized()
        }

        return "userinfo.button.chooseSecret.change.title".localized()
    }

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

    private lazy var saveUserInfoButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6
        view.backgroundColor = .red
        view.setTitle("userinfo.jwt.button.usersave".localized(), for: .normal)
        view.titleLabel?.textColor = .white
        view.addTarget(self, action: #selector(saveAct), for: .touchUpInside)
        return view
    }()

    private lazy var authTokenTitle: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.textColor = .black
        view.font = .systemFont(ofSize: 18, weight: .bold)
        view.text = "userinfo.authToken.title".localized()
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
        view.isUserInteractionEnabled = false
        view.isEnabled = false
        return view
    }()

    lazy var jwtInputButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle(secretKeyButtonTitle, for: .normal)
        view.backgroundColor = .red
        view.layer.cornerRadius = 6
        view.addTarget(self, action: #selector(showSecretList), for: .touchUpInside)
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
        view.addTarget(self, action: #selector(tokenGenerateSaveAct), for: .touchUpInside)
        return view
    }()

    private var user: ShopLiveUser = DemoConfiguration.shared.user
    private var newUser: ShopLiveUser?
    override func viewDidLoad() {
        super.viewDidLoad()

        DemoSecretKeyTool.shared.addKeysetObserver(observer: self)
        setupNaviItems()
        setupViews()
        updateUserInfo()
    }

    func setupNaviItems() {
        self.title = SideMenuTypes.userinfo.stringKey.localized()

        let delete = UIBarButtonItem(title: "sdk.user.delete".localized(from: "shoplive"), style: .plain, target: self, action: #selector(deleteAct))

//        let save = UIBarButtonItem(title: "sdk.user.save".localized(from: "shoplive"), style: .plain, target: self, action: #selector(saveAct))

        delete.tintColor = .white
//        save.tintColor = .white

        self.navigationItem.rightBarButtonItems = [delete] //save,
    }

    func setupViews() {
        self.view.addSubview(userIdInputField)
        self.view.addSubview(userNameInputField)
        self.view.addSubview(ageInputField)
        self.view.addSubview(userScoreInputField)
        self.view.addSubview(genderView)
        self.view.addSubview(saveUserInfoButton)
        self.view.addSubview(authTokenTitle)
        self.view.addSubview(jwtInputField)
        self.view.addSubview(jwtInputButton)
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

        saveUserInfoButton.snp.makeConstraints {
            $0.top.equalTo(genderView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.height.equalTo(35)
        }

        authTokenTitle.snp.makeConstraints {
            $0.top.equalTo(saveUserInfoButton.snp.bottom).offset(35)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.height.equalTo(30)
        }

        jwtInputField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.top.equalTo(authTokenTitle.snp.bottom).offset(10)
            $0.trailing.equalTo(jwtInputButton.snp.leading).offset(-15)
            $0.height.equalTo(35)
        }

        jwtInputButton.snp.makeConstraints {
            $0.top.equalTo(jwtInputField)
            $0.trailing.equalToSuperview().offset(-15)
            $0.width.equalTo(100)
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
            DemoConfiguration.shared.jwtToken = nil
            self.updateUserInfo()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func save() {
        user.id = userIdInputField.text
        user.name = userNameInputField.text
        user.gender = selectedGender()
        if let ageText = ageInputField.text, !ageText.isEmpty, let age = Int(ageText), age >= 0 {
            user.age = age
        } else {
            user.age = nil
        }

        user.add(["userScore" : userScoreInputField.text])

        DemoConfiguration.shared.user = user

        UIWindow.showToast(message: "userinfo.msg.save.success".localized())
        handleNaviBack()
    }

    @objc func saveAct() {
        dismissKeyboard()
        if userIdInputField.text == nil || (userIdInputField.text ?? "").isEmpty {
            /*
            let alert = UIAlertController(title: "userinfo.msg.save.failed.noneId".localized(), message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "alert.msg.no".localized(), style: .cancel, handler: { action in

            }))
            alert.addAction(.init(title: "alert.msg.ok".localized(), style: .default, handler: { action in
                self.save()
            }))
            self.present(alert, animated: true, completion: nil)
            */
            UIWindow.showToast(message: "userinfo.msg.save.failed.noneId".localized())
        } else {
            save()
        }
    }

    @objc func tokenGenerateSaveAct() {
        makeJWT { isGenerated in
            guard isGenerated else { return }

            guard let jwt = self.jwtResultLabel.text, !jwt.isEmpty, jwt != "userinfo.jwt.result.message" else {
                UIWindow.showToast(message: "userinfo.msg.save.failed.noneToken".localized())
                return
            }

            self.saveToken()
        }

    }

    private func saveToken() {
        if let jwt = jwtResultLabel.text, !jwt.isEmpty {
            DemoConfiguration.shared.jwtToken = jwt
        } else {
            DemoConfiguration.shared.jwtToken = nil
        }
        UIWindow.showToast(message: "userinfo.msg.save.success".localized())
    }

    @objc func showSecretList() {
        let vc = SecretKeysViewController()
        vc.selectKeySet = true
        self.navigationController?.pushViewController(vc, animated: true)
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
        updateJwtToken()
        currentSecretKeyUpdated()
    }

    func updateJwtToken() {
        if let jwtToken = DemoConfiguration.shared.jwtToken, !jwtToken.isEmpty {
            jwtResultLabel.text = jwtToken
        } else {
            jwtResultLabel.text = "userinfo.jwt.result.message".localized()
        }
    }

    @objc func makeJWT(completion: @escaping (Bool) -> Void) {
        dismissKeyboard()
        let makeUser = ShopLiveUser()
        makeUser.id = userIdInputField.text
        makeUser.name = userNameInputField.text
        makeUser.gender = selectedGender()
        if let ageText = ageInputField.text, !ageText.isEmpty, let age = Int(ageText), age >= 0 {
            makeUser.age = age
        } else {
            makeUser.age = nil
        }

        makeUser.add(["userScore" : userScoreInputField.text])

        guard !isEqualUser(user: makeUser) else {
            UIWindow.showToast(message: "userinfo.msg.save.failed.sameInfo".localized())
            completion(false)
            return
        }
        newUser = makeUser
        guard let newToken = JWTTool.makeJWT(user: makeUser), !newToken.isEmpty else {
            jwtResultLabel.text = "userinfo.jwt.result.message".localized()
            completion(false)
            return
        }

        jwtResultLabel.text = newToken
        completion(true)

    }

    private func isEqualUser(user: ShopLiveUser) -> Bool {
        if newUser == nil {
            return false
        }

        if let curUser = newUser,
            curUser.id == user.id &&
            curUser.name == user.name &&
            curUser.age == user.age &&
            curUser.userScore == user.userScore &&
            curUser.gender == user.gender {
            return true
        }

        return false
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

extension UserInfoViewController: SecretKeySetObserver {
    var identifier: String {
        "UserInfoViewController"
    }

    func setretKeysetUpdated() {
        guard let key = DemoSecretKeyTool.shared.currentKey()?.key else {
            jwtInputField.text = ""
            return
        }

        jwtInputField.text = key
    }

    func currentSecretKeyUpdated() {
        if let currentKey = DemoSecretKeyTool.shared.currentKey() {
            jwtInputField.text = currentKey.name
        } else {
            jwtInputField.text = nil
        }

        jwtInputButton.setTitle(secretKeyButtonTitle, for: .normal)
    }

}
