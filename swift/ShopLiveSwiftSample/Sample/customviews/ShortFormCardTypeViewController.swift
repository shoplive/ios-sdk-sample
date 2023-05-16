//
//  ShortFormCardTypeViewExampleViewController.swift
//  ShopLiveSwiftSample
//
//  Created by sangmin han on 2023/05/12.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import ShopLiveShortformSDK

final class ShortFormCardTypeViewController : UIViewController {
    
    
    private var snapLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "개별 컨텐츠 강조"
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private var snapBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("SNAP", for: .normal)
        btn.setTitleColor(.black, for: .selected)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 6
        return btn
    }()
    
    private var type1Btn : UIButton = {
        let btn = UIButton()
        btn.setTitle("type1", for: .normal)
        btn.setTitleColor(.black, for: .selected)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 6
        btn.isSelected = true
        btn.tag = 1
        return btn
    }()
    
    private var type2Btn : UIButton = {
        let btn = UIButton()
        btn.setTitle("type2", for: .normal)
        btn.setTitleColor(.black, for: .selected)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 6
        btn.tag = 2
        return btn
    }()
    private var stack = UIStackView()
    private var builder : ShopLiveShortform.CardTypeViewBuilder?
    private var collectionView : UIView?
    private var currentSnap = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setLayout()
        
        
        snapBtn.addTarget(self, action: #selector(snapbtnTapped(sender: )), for: .touchUpInside)
        type1Btn.addTarget(self, action: #selector(typeBtnTapped(sender: )), for: .touchUpInside)
        type2Btn.addTarget(self, action: #selector(typeBtnTapped(sender: )), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ShopLiveShortform.ShortsReceiveInterface.setHandler(self)
        builder = ShopLiveShortform.CardTypeViewBuilder()
        collectionView = builder!.build(cardViewType: .type1,
                                       enableSnap: currentSnap,
                                       enablePlayVideo: true,
                                       playOnlyOnWifi: false,
                                       cellSpacing: 20).getView()
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.backgroundColor = .white
        
        setCollectionViewLayout()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.collectionView?.removeFromSuperview()
        self.collectionView = nil
        self.builder = nil
    }
    
    @objc func snapbtnTapped(sender : UIButton){
        guard let builder = builder else { return }
        sender.isSelected = !sender.isSelected
        self.currentSnap = sender.isSelected
        if sender.isSelected {
            builder.enableSnap()
        }
        else {
            builder.disableSnap()
        }
    }
    
    @objc func typeBtnTapped(sender : UIButton){
        guard let builder = builder else { return }
        if sender.tag == 1 && type1Btn.isSelected == false {
            type1Btn.isSelected = true
            type2Btn.isSelected = false
            builder.setCardViewType(type: .type1)
        }
        else if sender.tag == 2 && type2Btn.isSelected == false {
            type1Btn.isSelected = false
            type2Btn.isSelected = true
            builder.setCardViewType(type: .type2)
        }
        
    }
}
extension ShortFormCardTypeViewController : ShopLiveShortformReceiveHandlerDelegate {
    func onError(error: Error) {
        if let error = error as? ShortformError {
            if case .other(let error) = error {
                let alert = UIAlertController(title: "알림", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let cancelAction = UIAlertAction(title: "cancel", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(cancelAction)
                guard let window = UIApplication.shared.windows.first else { return }
                window.rootViewController?.present(alert, animated: true)
            }
        }
    }
}
extension ShortFormCardTypeViewController {
    private func setCollectionViewLayout(){
        guard let collectionView = collectionView else { return }
        self.view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: stack.bottomAnchor,constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    
    private func setLayout(){
        self.view.addSubview(snapLabel)
        self.view.addSubview(snapBtn)
        stack = UIStackView(arrangedSubviews: [type1Btn,type2Btn])
        stack = UIStackView(arrangedSubviews: [type1Btn,type2Btn])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        self.view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            snapLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            snapLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            snapLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            snapLabel.heightAnchor.constraint(equalToConstant: 30),
            
            snapBtn.leadingAnchor.constraint(equalTo: snapLabel.trailingAnchor, constant: 10),
            snapBtn.centerYAnchor.constraint(equalTo: snapLabel.centerYAnchor, constant: 0),
            snapBtn.widthAnchor.constraint(equalToConstant: 60),
            snapBtn.heightAnchor.constraint(equalToConstant: 30),
            
            stack.topAnchor.constraint(equalTo: snapBtn.bottomAnchor, constant: 5),
            stack.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            stack.widthAnchor.constraint(equalToConstant: 110),
            stack.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
}

