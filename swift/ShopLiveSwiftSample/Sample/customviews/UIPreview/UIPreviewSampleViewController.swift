//
//  UIPreviewSampleViewController.swift
//  ShopLiveSwiftSample
//
//  Created by sangmin han on 9/23/24.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import ShopLiveSDK



class UIPreviewSampleViewController : UIViewController {
    
    private var accessKey : String = ""
    private var campaignKey : String = ""
    
    let preview = ShopLivePlayerPreview()
    
    init(accessKey : String, campaignkey : String) {
        super.init(nibName: nil, bundle: nil)
        self.accessKey = accessKey
        self.campaignKey = campaignkey
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setLayout()
        bindPreview()
        
        // initialize preview and feed accessKey and campaignKey to load preview
        preview.action( .initialize )
        preview.action( .start(accessKey: accessKey, campaignKey: campaignKey, referrer: "") )
        preview.action( .setEnabledVolumeKey(isEnabledVolumeKey: true) )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //Subscribe Events emitted from preview instance
    private func bindPreview() {
        preview.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .log(name: let name, feature: let feature, campaignKey: let campaignKey, payload: let payload):
                break
            case .handleReceivedCommand(command: let command, payload: let payload):
                break
            case .avPlayerTimeControlStatus(_):
                break
            case .avPlayerItemStatus(_):
                break
            case .requestShowAlertController(_):
                break
            case .didChangeCampaignStatus(_):
                break
            case .onError(code: let code, message: let message):
                break
            case .handleCommand(command: let command, payload: let payload):
                break
            case .onSetUserName(payload: let payload):
                 break
            case .handleShare(data: let data):
                break
            case .didChangeCampaignInfo(_):
                break
            case .didChangeVideoDimension(_):
                break
            case .handleShopLivePlayerCampaign(_):
                break
            case .handleShopLivePlayeBrand(_):
                break
            @unknown default:
                break
            }
        }
    }
    
    
    
}
extension UIPreviewSampleViewController {
    private func setLayout() {
        self.view.addSubview(preview)
        preview.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            preview.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            preview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            preview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            preview.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
