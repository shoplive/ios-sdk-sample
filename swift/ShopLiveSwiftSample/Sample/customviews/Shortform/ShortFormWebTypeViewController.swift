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
    
    
    private var productURl : URL?
    
    init(productUrl : URL? = nil){
        super.init(nibName: nil, bundle: nil)
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

//        setObserver()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        removeObserver()
    }
    
//
//    private func setObserver(){
//        NotificationCenter.default.addObserver(self, selector: #selector(handleNotifcation(_:)), name: NSNotification.Name("moveToProductPage"), object: nil)
//    }
//
//    private func removeObserver(){
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("moveToProductPage"), object: nil)
//    }
//
//
//    private func handleNotifcation(_ notification : Notification) {
//        switch notification.name {
//        case Notification.Name(rawValue: "moveToProductPage"):
//            guard let product = notification.userInfo?["product"] as? Product, let urlString = product.url, let url = URL(string: urlString) else { return }
////            self.webview.load(URLRequest(url: <#T##URLConvertible#>, method: <#T##HTTPMethod#>))
//            break
//        default:
//            break
//        }
//    }
    
}
extension ShortFormWebTypeViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
}
extension ShortFormWebTypeViewController : ShopLiveShortformReceiveHandlerDelegate {
    func onError(error: Error) {
        
    }
    
    func onEvent(command: String, payload: String?) {
        print("web command \(command) with payload \(payload)")
        
    }
    
    func handleShare(shareUrl: String) {
        
    }
    
    func handleProductBanner(shortsId: String, shortsSrn: String, scheme: String, shortsDetail: ShopLiveShortformSDK.ShortsDetail) {
        
    }
    
    func handleProductItem(shortsId: String, shortsSrn: String, product: Product) {
        print(shortsId)
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
