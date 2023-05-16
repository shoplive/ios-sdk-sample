//
//  ShortFormWebTypeViewController.swift
//  ShopLiveSwiftSample
//
//  Created by sangmin han on 2023/05/12.
//

import Foundation
import UIKit
import WebKit
import ShopLiveShortformSDK


final class ShortFormWebTypeViewController : UIViewController {
    
    private lazy var webview: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = false
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.preferences.javaScriptEnabled = true
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.navigationDelegate = self
        webView.scrollView.backgroundColor = .clear
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private var isforAuthentication : Bool = false
    private var productURl : URL?
    
    var viewDidDisAppearCompletionBlock : (() -> ())?
    
    init(isforAuthentication : Bool,productUrl : URL? = nil){
        super.init(nibName: nil, bundle: nil)
        self.isforAuthentication = isforAuthentication
        self.productURl = productUrl
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setLayout()
        
        if let productURl = productURl {
            webview.load(.init(url: productURl))
        }
        else {
            webview.load(.init(url: URL(string : "https://shopliveshorts.cafe24.com/index.html")!))
        }

        ShopLiveShortform.BridgeInterface.connect(webview)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewDidDisAppearCompletionBlock?()
    }
    
    
    
}
extension ShortFormWebTypeViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if isforAuthentication {
            if let nav = self.navigationController  {
                nav.popViewController(animated: false)
            }
            else {
                self.dismiss(animated: false)
            }
        }
    }
    
}

extension ShortFormWebTypeViewController {
    private func setLayout(){
        self.view.addSubview(webview)
        webview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webview.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            webview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            webview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            webview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}
