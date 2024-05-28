//
//  PreviewCover.swift
//  ShopLiveSwiftSample
//
//  Created by sangmin han on 5/28/24.
//

import Foundation
import UIKit
import ShopLiveSDK


class PreviewCoverViewMaker : NSObject {
    
    var previewViewCoverView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init(white: 0.2, alpha: 0.5)
        return view
    }()
    
    var previewCoverViewTagView : UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        view.textAlignment = .center
        view.text = "TagView"
        view.adjustsFontSizeToFitWidth = true
        return view
    }()
    
    var previewCoverViewTitleView : UIButton = {
        let label = UIButton()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setTitle("Campaign Title", for: .normal)
        label.titleLabel?.adjustsFontSizeToFitWidth = true
        label.setTitleColor(.white, for: .normal)
        return label
    }()
    
    
    override init() {
        super.init()
        previewCoverViewTitleView.addTarget(self, action: #selector(tapped(sender: )), for: .touchUpInside)
    }
    
    @objc func tapped(sender : UIButton) {
        ShopLive.close(actionType: .onBtnTapped)
    }
    
    func setCustomerPreviewCoverView() {
        previewCoverViewTitleView.addTarget(self, action: #selector(tapped(sender: )), for: .touchUpInside)
        previewViewCoverView.addSubview(previewCoverViewTagView)
        previewViewCoverView.addSubview(previewCoverViewTitleView)
        
        NSLayoutConstraint.activate([
            previewCoverViewTagView.topAnchor.constraint(equalTo: previewViewCoverView.topAnchor),
            previewCoverViewTagView.trailingAnchor.constraint(equalTo: previewViewCoverView.trailingAnchor),
            previewCoverViewTagView.widthAnchor.constraint(equalToConstant: 50),
            previewCoverViewTagView.heightAnchor.constraint(equalToConstant: 30),
            
            
            previewCoverViewTitleView.bottomAnchor.constraint(equalTo: previewViewCoverView.bottomAnchor),
            previewCoverViewTitleView.leadingAnchor.constraint(equalTo: previewViewCoverView.leadingAnchor),
            previewCoverViewTitleView.trailingAnchor.constraint(equalTo: previewViewCoverView.trailingAnchor),
            previewCoverViewTitleView.heightAnchor.constraint(equalToConstant: 40),
            
        ])
        
        ShopLive.addSubViewToPreview(subView: previewViewCoverView)
    }
    
    
    func hideTitle(isPreview : Bool) {
        previewCoverViewTitleView.isHidden = !isPreview
    }
    
    
    
    

}



