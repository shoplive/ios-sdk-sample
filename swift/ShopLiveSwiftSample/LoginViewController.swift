//
//  LoginViewController.swift
//  ShopLiveSwiftSample
//
//  Created by ShopLive on 2022/03/23.
//

import UIKit

protocol LoginDelegate: AnyObject {
    func loginSuccess()
}

class LoginViewController: UIViewController {

    weak var delegate: LoginDelegate?
    
    private let idInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leftViewMode = .always
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.isUserInteractionEnabled = false
        view.text = "shoplive"
        view.textColor = .black
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        return view
    }()
    
    private let pwdInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leftViewMode = .always
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textContentType = .password
        view.isUserInteractionEnabled = false
        view.text = "password"
        view.textColor = .black
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        return view
    }()
    
    private lazy var loginButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .darkGray
        view.layer.cornerRadius = 6
        view.setTitle("sample.login.button.title".localized(), for: .normal)
        view.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    private func setupViews() {
        self.view.backgroundColor = .white
        self.view.addSubviews(idInputField, pwdInputField, loginButton)
        
        idInputField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(150)
            $0.height.equalTo(30)
        }
        
        pwdInputField.snp.makeConstraints {
            $0.top.equalTo(idInputField.snp.bottom).offset(15)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(150)
            $0.height.equalTo(30)
        }
        
        loginButton.snp.makeConstraints {
            $0.top.equalTo(pwdInputField.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(150)
            $0.height.equalTo(30)
        }
    }
    
    @objc func loginAction() {
        delegate?.loginSuccess()
        self.navigationController?.popViewController(animated: true)
    }

}
