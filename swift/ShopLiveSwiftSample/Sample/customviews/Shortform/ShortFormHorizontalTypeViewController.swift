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
        
        builder = ShopLiveShortform.ListViewBuilder()
        collectionView = builder!.build(cardViewType: .type2,
                                       listViewType: .horizontal,
                                       playableType: .FIRST,
                                        listViewDelegate: self,
                                       enableSnap: currentSnap,
                                       enablePlayVideo: true,
                                       playOnlyOnWifi: false,
                                       cellSpacing: 20).getView()
        builder?.submit()
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        setCollectionViewLayout()
        
        //see below extension to see how it works
        ShopLiveShortform.ShortsReceiveInterface.setNativeHandler(self)
        ShopLiveShortform.ShortsReceiveInterface.setHandler(self)
        
        //MARK: - hashtag, brand settings
        /**
         setting hashtag or brand after calling submit(), call reloadItem() to get new datas set
         builder?.setHashTags(tags: ["test,test2"], tagSearchOperator: .OR)
         builder?.setBrands(brands: ["test"])
         builder?.reloadItems()
         */
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
    
    //MARK: - notify UIScreen to builder for invalidating layout
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        builder?.notifyViewRotated() // notifying view rotating to builder will result to reCalculating cellsize correctly for orientation
    }
    
}
//MARK: - native handler delegate
extension ShortFormHorizontalTypeViewController : ShopLiveShortformNativeHandlerDelegate {
    func handleProductItem(shortsId: String, shortsSrn: String, product: ShopLiveShortformSDK.Product) {
        // when webview is connected, preview will be shown automatically as configured in admin web
        // when webview is not connected with ShopLiveShortform.BridgeInterface.connect(<#T##webview: WKWebView##WKWebView#>)
        // use this method to navigate to desired product page or show preview
        // ex) displaying preview natively
        //ShopLiveShortform.showPreview(requestData: ShopLiveShortformRelatedData)
        // ShopLiveShortformRelateData contains productId, customerProductId, tags, brands and etc
        // allocating these values will get related shorts collections
    }
    
    func handleProductBanner(shortsId: String, shortsSrn: String, scheme: String, shortsDetail: ShopLiveShortformSDK.ShortsDetail) {
        // when webview is not connected with ShopLive ShopLiveShortform.BridgeInterface.connect(<#T##webview: WKWebView##WKWebView#>)
        // use this method to navigate to desired product view or show preview
    }
}
//MARK: - receive Handler delegate
extension ShortFormHorizontalTypeViewController : ShopLiveShortformReceiveHandlerDelegate {
    func handleShare(shareUrl: String) {
        
    }
    
    func onEvent(command: String, payload: String?) {
        //from here you can observe shortform event ex) click event on collectionView Item, collectionView initialized event, preview show event and etc, see https://docs.shoplive.kr/docs/api-shortform-events for more informations
        //payload are configured as JSONstring
    }
    
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
//MARK: - list view delegate
extension ShortFormHorizontalTypeViewController : ShopLiveShortformListViewDelegate {
    func onListViewError(error: Error) {
        // by this delegate function you can get api errors and avplayer occured from listviews
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
