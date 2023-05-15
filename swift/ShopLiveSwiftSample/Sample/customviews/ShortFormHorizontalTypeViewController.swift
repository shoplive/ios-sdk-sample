//
//  ShortFormHorizontalTypeViewController.swift
//  ShopLiveSwiftSample
//
//  Created by sangmin han on 2023/05/12.
//

import Foundation
import UIKit
import ShopLiveShortformSDK


final class ShortFormHorizontalTypeViewController : UIViewController {
    
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
    
    private var stack = UIStackView()
    private var builder : ShopLiveShortform.ListViewBuilder?
    private var collectionView : UIView?
    private var currentSnap : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setLayout()
        
        snapBtn.addTarget(self, action: #selector(snapbtnTapped(sender: )), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ShopLiveShortform.ShortsReceiveInterface.setHandler(self)
        builder = ShopLiveShortform.ListViewBuilder()
        collectionView = builder!.build(cardViewType: .type2,
                                       listViewType: .horizontal,
                                       enableSnap: currentSnap,
                                       enablePlayVideo: true,
                                       playOnlyOnWifi: false,
                                       cellSpacing: 20).getView()
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
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
}
extension ShortFormHorizontalTypeViewController : ShopLiveShortformReceiveHandlerDelegate {
    func onError(error: Error) {
        if let error = error as? ShortsError {
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
extension ShortFormHorizontalTypeViewController {
    
    private func setCollectionViewLayout(){
        guard let collectionView = collectionView else { return }
        self.view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: snapBtn.bottomAnchor,constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 500)
            
        ])
    }
    
    private func setLayout(){
        self.view.addSubview(snapLabel)
        self.view.addSubview(snapBtn)
        
        NSLayoutConstraint.activate([
            snapLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            snapLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            snapLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            snapLabel.heightAnchor.constraint(equalToConstant: 30),
            
            snapBtn.leadingAnchor.constraint(equalTo: snapLabel.trailingAnchor, constant: 10),
            snapBtn.centerYAnchor.constraint(equalTo: snapLabel.centerYAnchor, constant: 0),
            snapBtn.widthAnchor.constraint(equalToConstant: 60),
        ])
    }
    
}
